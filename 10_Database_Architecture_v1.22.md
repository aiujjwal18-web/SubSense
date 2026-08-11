# 10 Database Architecture v1.22

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DB-001 |
| Product | SubSense |
| Version | v1.22 |
| Status | Frozen implementation baseline |
| Source of Truth | Supabase PostgreSQL schema and RLS architecture |
| Depends On | 09_Implementation_Readiness_v1.11 |

## Purpose

This document defines the database architecture for SubSense, including bounded domains, entity ownership, table strategy, identifiers, RLS model, migration order, and implementation standards.

## Database Philosophy

The database supports the product. It does not define the product.

Modeling order:

Business Domain -> Business Entity -> Relationships -> Business Rules -> Database Entity -> Table Specification -> SQL

## Platform

| Area | Technology |
| --- | --- |
| Database | Supabase PostgreSQL |
| Authentication source | Supabase Auth |
| Security | Row Level Security |
| Primary keys | UUID |
| Business IDs | Human-readable prefixed identifiers |
| Stable states | PostgreSQL ENUMs |

## Bounded Domains

| Domain | Purpose |
| --- | --- |
| Identity | Users, profiles, preferences |
| Subscription Management | Subscriptions, catalog, categories |
| Shared Subscription | Shared ownership and payment requests |
| Reminder Engine | Reminder configuration and execution history |
| AI Decision Support | AI-generated recommendations |
| Notifications | Email and notification records |
| Billing | Premium plans and Razorpay Test Mode transactions |
| System and Audit | Logs, configuration, operational audit |

## Entity Inventory

| Entity | Owner Module | Table |
| --- | --- | --- |
| User | Authentication | users |
| User Profile | Profile | user_profiles |
| User Preferences | Profile | user_preferences |
| Subscription Category | My Subscriptions | subscription_categories |
| Subscription Catalog | Add Subscription | subscription_catalog |
| Subscription | My Subscriptions | subscriptions |
| Shared Subscription | Shared Subscriptions | shared_subscriptions |
| Shared Member | Shared Subscriptions | shared_members |
| Payment Request | Shared Subscriptions | payment_requests |
| Reminder | Reminder Engine | reminders |
| Reminder History | Reminder Engine | reminder_history |
| AI Recommendation | Decision Workspace | ai_recommendations |
| Notification | Notification Service | notifications |
| Notification Template | Notification Service | notification_templates |
| Premium Plan | Billing | premium_plans |
| Payment Transaction | Billing | payment_transactions |
| Audit Log | System | audit_logs |
| System Setting | System | system_settings |

## Identifier Standard

| Entity | Internal ID | Business ID |
| --- | --- | --- |
| User | UUID | USR- |
| Subscription | UUID | SUB- |
| Reminder | UUID | REM- |
| Shared Subscription | UUID | SHR- |
| Payment Request | UUID | PAY- |
| AI Recommendation | UUID | AIR- |
| Notification | UUID | NOT- |
| Audit Log | UUID | AUD- |

UUIDs are primary keys. Business IDs are secondary identifiers for traceability.

## ENUM Standard

Use PostgreSQL ENUMs for stable shared values:

- account_status.
- theme.
- currency.
- billing_frequency.
- lifecycle_status.
- payment_method.
- review_status.
- delivery_status.
- transaction_status.
- notification_channel.
- trigger_source.
- actor_type.
- audit_action (DEC-036, DEC-069): `auth_profile_provisioned`, `subscription_created`, `subscription_updated`, `subscription_archived`, `shared_member_changed`, `payment_request_changed`, `reminder_executed`, `ai_generated`, `email_delivery_failed`, `payment_verified`, `security_failure`, `reminder_generation_failed`. The last value was added under DEC-069 specifically so `generate_scheduled_reminders()`'s per-row failure logging (`GEN_001`, `11_API_Integration_Architecture_v1.14` §5.7) has a value distinct from `reminder_executed` (an actual send, not a generation failure).
- premium_source (DEC-038): `razorpay_test_mode`, `manual_grant`.
- split_method (DEC-036): `equal`, `custom`.
- member_status (DEC-036): `active`, `removed`.
- payment_request_status (DEC-036, DEC-037): `pending`, `paid_pending_confirmation`, `paid`, `cancelled`.
- reminder_type (DEC-036, DEC-039, DEC-041): `seven_day`, `two_day`, `renewal_day`, `post_renewal_checkin`, `shared_payment`, `dev_test`, `monthly_digest`, `lapsed_reengagement`.
- reminder_status (DEC-036, DEC-039): `pending`, `sent`, `skipped_archived`, `failed`.

## Core Identity Tables

### users

Purpose:

- Stores SubSense application identity metadata.
- Supabase Auth remains the source of authentication.

Key columns:

- id UUID primary key.
- user_code unique.
- auth_user_id unique FK to auth.users.
- email unique.
- auth_provider.
- account_status.
- email_verified.
- last_login_at — also the sole basis for the "active user" definition in the Retention Policy (DEC-041, `01_Product_Strategy`): a user is active if `last_login_at` falls within the trailing 30 days.
- created_at.
- updated_at.
- archived_at.

RLS:

- Users can read their own record.
- Inserts are backend controlled.
- Updates are limited.
- Delete disabled; archive only.

### user_profiles

Purpose:

- Stores profile information independent of authentication.
- Per DEC-038, this is the single source of truth for premium entitlement (matches the "Premium status | Billing/Profile" ownership assignment in `03_Information_Architecture_v1.17`). No other table stores current entitlement state — `premium_plans` is a plan catalog and `payment_transactions` is a transaction log, neither reflects "is this user premium right now."

Key columns:

- id UUID primary key.
- user_id unique FK to users, `ON DELETE CASCADE`.
- display_name.
- profile_photo_url.
- country.
- timezone: IANA timezone string (e.g. `Asia/Kolkata`), not null, default `Asia/Kolkata`. Used by the Reminder Engine for due-today evaluation per DEC-039.
- default_currency.
- is_premium: boolean, not null, default `false`. The single premium entitlement flag. **Implemented (DEC-083):** Decision Workspace's AI Insight batch checks this via `user_has_active_premium(uuid)` (a `security definer` SQL function implementing the gating rule server-side, called by every Edge Function that needs a premium check rather than each one reimplementing the boolean) and caps free-tier users to 1 insight, vs. premium's full 3-subscription batch; the Phase 9 Insights page is premium-exclusive entirely, gated both client-side (no network call for free users) and server-side (the real boundary, since RLS has no premium concept). Frontend-only UI checks (what to render, not a security boundary) use a plain TypeScript `isPremiumActive(profile)` helper instead of the RPC, to avoid an extra round trip.
- premium_expires_at: nullable timestamptz. Null means no expiry tracked (or never purchased); a past timestamp means entitlement has lapsed and `is_premium` must be treated as false by all readers even if the flag itself has not yet been flipped by a batch job.
- premium_source: enum `premium_source` (`razorpay_test_mode`, `manual_grant`), not null default `manual_grant`. Records how entitlement was granted, for support/debugging.
- created_at.
- updated_at.

Write ownership:

- `is_premium`, `premium_expires_at`, and `premium_source` are written only by the `razorpay-verify-payment` Edge Function (Path B, service-role), never by the client directly, even though the row itself is Path A for all other fields. This is the one column-level exception to "owner can update their own `user_profiles` row" in the Table Security Matrix below.

RLS:

- Owner may select and update all columns except `is_premium`, `premium_expires_at`, `premium_source`, which are excluded from the client's update grant (enforced via a restricted `UPDATE` policy column list, not a separate table).

### user_preferences

Purpose:

- Stores configurable user behavior.

Key columns:

- id.
- user_id unique FK to users.
- email_notifications.
- reminder_default_days.
- theme.
- dashboard_layout.
- created_at.
- updated_at.

RLS:

- Owner only.

## Master Data Tables

### subscription_categories

Purpose:

- Standardized subscription classification.
- Seven categories as of DEC-046: the original five (Entertainment, Productivity, Education, Utilities, Other) plus Music and AI Tools, added to accommodate the catalog expansion below. Education and Utilities are each used by zero and one catalog row respectively — left in place rather than dropped, since removing a seeded category is a schema-adjacent decision distinct from adding catalog content.

Access:

- Authenticated users read.
- Admin/service role writes.

### subscription_catalog

Purpose:

- Known subscription providers such as Netflix, Spotify Premium, ChatGPT Plus.
- Seeded with 31 rows as of DEC-046 (up from the original 10 in `17_SubSense_Migration_v2`), curated for the Indian market.

Key columns (beyond `id`, `category_id`, `name`, `slug`, `created_by_user_id`, `approved_at`, `created_at`):

- website_url: nullable text, the service's official site.
- logo_url: nullable text, added per DEC-046. Originally pointed at a third-party-hosted brand icon (Simple Icons CDN for globally recognized brands, a Wikimedia Commons file URL for India-specific brands with no Simple Icons coverage). **Deprecated under DEC-059**: the frontend no longer reads this column anywhere — every subscription card now renders a fixed, generic category icon (Lucide, per `05_Design_System`'s Icon System) instead of a real per-service brand logo, to close a trademark/IP exposure the real-logo approach carried even for a non-commercial capstone build. All 30 populated real-logo values are nulled via `27_SubSense_Catalog_Logo_Removal_v1.0.sql`, scrubbing the stored brand-logo references rather than leaving them unrendered but present. The column itself is retained in the schema, unused, rather than dropped — a column drop is a separate, higher-effort schema change not required to close the actual concern, and retaining it keeps the door open at low cost if a future decision ever wants a per-service image again.

Access:

- Authenticated users read.
- Admin/service role writes.
- Future user-created entries may be owner-only until approved.

### premium_plans

Purpose:

- Defines Free and Premium demonstration plans.

Access:

- Authenticated users read.
- Admin/service role writes.

### notification_templates

Purpose:

- Reusable email and notification templates.
- One fixed, well-written template per `reminder_type` (8 rows total) — finalized per DEC-047. Variety is between template types, not within repeated sends of the same type; per-send rotation was considered and deliberately not built for MVP (would need multiple variant rows plus selection logic, for a repetition-fatigue problem that mainly applies to co-viewed AI insight cards per DEC-045, not to emails a user receives days apart).

Access:

- Backend services read.
- Admin/service role writes.

## Business Data Tables

### subscriptions

Purpose:

- User-owned subscription records.

Typical fields:

- user_id.
- catalog_id.
- custom_name.
- cost.
- currency.
- billing_frequency.
- next_renewal_date.
- payment_method: enum, one of `upi_autopay`, `card_emandate`, `app_store`, `manual`.
- payment_reference_note: optional text, e.g. UPI app name or mandate reference, for the user's own recall.
- lifecycle_status.
- monthly_equivalent.
- annual_equivalent.
- created_at.
- updated_at.
- archived_at.

`payment_method` and `payment_reference_note` exist because cancellation paths in India differ fundamentally by rail — a UPI AutoPay mandate can only be cancelled from the originating UPI app, never by SubSense (DEC-032). Subscription Details surfaces rail-specific guidance from this field rather than implying SubSense can act on it, preserving GP-001 and BR-001.

RLS:

- Owner: select, insert, update (all columns), archive.
- Linked shared member, active status only (live-testing pass): select only, via `subscriptions_select_shared_member` — a new, additive policy checking the `shared_subscriptions`/`shared_members` bridge for an active membership, bridging a gap where a member's own `shared_subscriptions`/`shared_members` RLS access existed but the base `subscriptions` row they're paying toward did not, causing PostgREST to silently drop the entire visible parent row on any query embedding `subscriptions` inside it (see DEC-080's live-testing extension in doc 08 for the full root cause). **Accepted scope tradeoff:** this is a full-row grant, matching this schema's existing table+row-only security convention (no column-level security exists anywhere in it) — a linked member also gains read access to `cost`, `payment_method`, and `payment_reference_note`, not just the subscription's name. Confirmed and accepted rather than building this schema's first column-level-security mechanism for one field.

### shared_subscriptions

Purpose:

- Represents shared ownership or shared cost context for a subscription.

Key columns:

- id UUID primary key.
- subscription_id UUID FK to `subscriptions`, unique (one shared context per subscription in MVP).
- owner_user_id UUID FK to `users` (denormalized from `subscriptions.user_id` so RLS can check ownership without a join).
- split_method: enum `split_method` (`equal`, `custom`), not null default `equal`.
- currency: must match the parent subscription's currency.
- created_at, updated_at, archived_at.

Constraints:

- `UNIQUE (subscription_id)`.
- `CHECK`: `archived_at IS NULL OR archived_at >= created_at`.

FK/cascade behavior:

- `subscription_id` FK is `ON DELETE RESTRICT` — subscriptions are never hard-deleted (soft delete only per Delete Strategy), so this never fires in normal operation; it exists as a safety rail.
- A trigger on `subscriptions.archived_at` transitioning from null to non-null sets `archived_at` on the matching `shared_subscriptions` row and cascades to open `payment_requests` (see below), so an archived subscription cannot keep generating shared-payment activity.

RLS:

- Owner: select, insert, update (all columns), archive.
- Linked member (via `shared_members.user_id`): select only.

### shared_members

Purpose:

- Stores participant details, amount owed, and active/inactive membership.

Key columns:

- id UUID primary key.
- shared_subscription_id UUID FK to `shared_subscriptions`.
- user_id UUID FK to `users`, nullable (a member may be tracked by name/email only if they do not have a SubSense account).
- display_name.
- email.
- amount_owed: numeric, not null.
- currency: must match the parent `shared_subscriptions.currency`.
- status: enum `member_status` (`active`, `removed`), not null default `active`.
- joined_at, removed_at nullable, created_at, updated_at.

Constraints:

- Partial unique index: `UNIQUE (shared_subscription_id, email) WHERE status = 'active'` — prevents duplicate active members with the same email in one split.
- `CHECK`: `amount_owed >= 0`.
- `CHECK`: `(status = 'active' AND removed_at IS NULL) OR (status = 'removed' AND removed_at IS NOT NULL)`.

FK/cascade behavior:

- `shared_subscription_id` FK is `ON DELETE RESTRICT`.
- Removal is soft (`status = 'removed'`, `removed_at` populated), never a hard delete, so that `payment_requests` history tied to this member is preserved — this is the literal implementation of the product requirement "preserve payment history on member removal."
- **Removing a member does not cascade-cancel their open `payment_requests`** (DEC-080) — any `pending`/`paid_pending_confirmation` request tied to a removed member is left open and unchanged, matching the payment-history-preservation rationale above. This is deliberately different from the archive-cascade rule below (archiving the parent `shared_subscriptions` row does cancel open requests): archiving means there is no subscription left for anyone to owe money toward, a categorically different signal than one member leaving an otherwise-active split.
- **Equal-split rebalance trigger (DEC-080):** for a parent `shared_subscriptions` row with `split_method = 'equal'`, a trigger on `shared_members` insert/soft-remove recomputes `amount_owed` for every currently-active member of that split (subscription cost / (active member count + 1) — the owner is an implicit sharer, never represented by a `shared_members` row of their own), keeping "equal" true on an ongoing basis rather than freezing it at whatever it was when each member joined. This only ever updates `shared_members.amount_owed` going forward — it never touches already-generated `payment_requests` rows, which are immutable per-cycle snapshots (see `billing_cycle_date` below), except for the pending-sync behavior noted just below. `custom` split rows are never touched by this trigger; their `amount_owed` stays fully owner-managed. **Corrected (live-testing pass):** the original formula divided by active member count alone, with no `+ 1` for the owner — a single member was billed the full subscription cost instead of half. Corrected via `32_SubSense_Equal_Split_Fixes_v1.0.sql`. **Accepted rounding remainder (DEC-080 same-day extension, example updated for the corrected divisor):** `round(cost / (active_member_count + 1), 2)` will not always sum exactly back to `cost` (e.g. ₹1000 with 2 members -> ₹1000/3 -> ₹333.33 per person, ₹999.99 total across all three shares) — a standard MVP simplification, not solved by an owner-adjustable remainder line in this pass.
- **Pending-request live-sync (live-testing pass):** the same rebalance trigger also updates `amount` on any `payment_requests` row that is still `status = 'pending'` for a currently-active member of the split, syncing it to the freshly computed per-member amount. Closes a real, confusing gap: previously, an already-generated but not-yet-acted-on request stayed frozen at whatever the split was the instant it was created, even as `shared_members.amount_owed` itself correctly updated as more members joined. Once a request moves past `pending` (`paid_pending_confirmation`, `paid`, `cancelled`), it is untouched, exactly as before — this narrows what counts as "not yet locked" from "the instant it's created" to "still pending," it does not change the immutability rule itself. Ships via the same `32_SubSense_Equal_Split_Fixes_v1.0.sql`.
- **Initial generation on join (DEC-080 same-day extension):** a second trigger, `shared_members_generate_initial_request` (`after insert on shared_members`), calls the rebalance trigger above first, then generates the current cycle's `payment_requests` row for the new member immediately — closing the gap where the renewal-date-change trigger alone would leave a brand-new share, or a member added mid-cycle to an already-shared subscription, with zero `payment_requests` until the next renewal.
- **Member-account linking on add (live-testing pass):** a new `before insert` trigger, `handle_shared_member_link_existing_user` (`33_SubSense_Link_Existing_User_On_Member_Add_v1.0.sql`), looks up `public.users` by a case-insensitive email match and sets the new row's `user_id` if a match exists and none was already supplied. Closes a real gap found live-testing: `shared_members.user_id` was never populated by the add-member flow at all, so the "linked member: select only" RLS grant below could never actually fire for anyone, regardless of whether that member already had a SubSense account. Scoped to add-time only — a member added before they have an account, who signs up later, is not retroactively linked by this trigger; an accepted, deferred gap for this MVP pass.

RLS:

- Owner of parent `shared_subscriptions`: select, insert, update, soft-remove.
- The member themself (if `user_id` is set and matches the caller): select only.

### payment_requests

Purpose:

- Tracks split payment requests and status.

Key columns:

- id UUID primary key.
- shared_subscription_id UUID FK to `shared_subscriptions`.
- shared_member_id UUID FK to `shared_members`.
- billing_cycle_date: the `subscriptions.next_renewal_date` value this request corresponds to, used to prevent duplicate requests per cycle.
- amount: numeric, not null.
- currency.
- status: enum `payment_request_status` (`pending`, `paid_pending_confirmation`, `paid`, `cancelled`), not null default `pending`.
- member_marked_paid_at: nullable timestamptz.
- owner_confirmed_at: nullable timestamptz.
- created_at, updated_at.

Constraints:

- `UNIQUE (shared_member_id, billing_cycle_date)` — one request per member per billing cycle.
- `CHECK`: `amount > 0`.
- `CHECK`: status transitions are one-directional (`pending` -> `paid_pending_confirmation` -> `paid`, or `pending`/`paid_pending_confirmation` -> `cancelled`); enforced by a `BEFORE UPDATE` trigger, not a plain CHECK, since it is a transition rule rather than a static condition.

FK/cascade behavior:

- `shared_member_id` FK is `ON DELETE RESTRICT` (see `shared_members` above — history must survive member removal).
- The archive-cascade trigger on `shared_subscriptions` sets any `pending` or `paid_pending_confirmation` request to `cancelled` (never deletes) when the parent subscription is archived.

**Generation mechanism (DEC-080):** a new trigger, extending the same event-driven pattern DEC-070 established for `reminders` (fires on `subscriptions.next_renewal_date` change), creates one `payment_requests` row per currently-active `shared_members` row for the new `billing_cycle_date` whenever a shared subscription's `next_renewal_date` advances — snapshotting `amount` from each member's `shared_members.amount_owed` at that moment. Deliberately not a lazy-generate-on-page-load approach (DEC-079's Phase 7 precedent) or a daily scheduled Edge Function (DEC-068's Phase 6 precedent): a request must exist the instant a cycle rolls over, independent of page visits or cron ticks, since `send-shared-payment-reminder` (doc 11 §5.3) needs a real row to attach to. The existing `UNIQUE (shared_member_id, billing_cycle_date)` constraint is the idempotency guard, same role the partial unique index plays for `reminders`. **Second trigger (DEC-080 same-day extension):** `shared_members_generate_initial_request` (`after insert on shared_members`) calls the same underlying per-member generation helper against the parent subscription's *current* `next_renewal_date`, so a brand-new share or a mid-cycle new member gets an immediate request rather than waiting for the next renewal-date change — both triggers share one helper function rather than duplicating the insert logic, and the same `UNIQUE` constraint (`ON CONFLICT DO NOTHING`) protects against either firing twice for the same member/cycle.

**Permission model (DEC-037 — resolves the conflict between the original Table Security Matrix "Shared -> Update -> Owner" row and the API document's "owner or linked member" grant):**

| Actor | Allowed transition |
| --- | --- |
| Parent-owner (owner of `shared_subscriptions`) | Any valid status transition, including directly to `paid` or `cancelled`. |
| Linked member (the `shared_members.user_id` on this request) | May move `pending` -> `paid_pending_confirmation` only (self-reporting "I paid"). Cannot set `paid` or `cancelled` directly. |

A request only becomes `paid` when the owner confirms it (owner transitions `paid_pending_confirmation` -> `paid`) or sets it directly from `pending` -> `paid` (e.g. cash handed over in person, confirmed by the owner without the member using the app). This keeps "member marks paid" and "owner confirms paid" as two distinct, non-conflicting steps rather than the same permission fighting over one boolean.

RLS:

- Owner of parent `shared_subscriptions`: select, insert, update (any transition above).
- Linked member: select, update restricted to the single `pending -> paid_pending_confirmation` transition (enforced by the trigger in Constraints above, not by RLS alone, since RLS cannot express "only this specific transition").

### reminders

Purpose:

- Defines scheduled reminders for subscriptions and shared payments.

Key columns:

- id UUID primary key.
- user_id UUID FK to `users` (the recipient), nullable (DEC-080 same-day extension) — null specifically for a `shared_payment` reminder attached to an unlinked `shared_members` row (`shared_members.user_id IS NULL`, a member tracked by name/email only, no SubSense account). Every other reminder type still requires `user_id`.
- subscription_id UUID FK to `subscriptions`, nullable — null for `shared_payment` reminders (which attach to a payment request instead) and for `monthly_digest`/`lapsed_reengagement` (DEC-069: both are user-level, with no subscription to anchor to).
- payment_request_id UUID FK to `payment_requests`, nullable — set only for `shared_payment` reminders; also null for `monthly_digest`/`lapsed_reengagement` (DEC-069).
- reminder_type: enum `reminder_type` (`seven_day`, `two_day`, `renewal_day`, `post_renewal_checkin`, `shared_payment`, `dev_test`, `monthly_digest`, `lapsed_reengagement`), not null.
- scheduled_for: timestamptz, not null — stored as an absolute UTC instant, computed at generation time from the renewal date and the user's `user_profiles.timezone` (DEC-039), not recomputed at send time.
- timezone_snapshot: the IANA timezone used to compute `scheduled_for`, captured at generation time so a later change to the user's profile timezone does not retroactively shift an already-scheduled reminder.
- status: enum `reminder_status` (`pending`, `sent`, `skipped_archived`, `skipped_superseded`, `failed`), not null default `pending`. `skipped_superseded` (DEC-070) marks a pending reminder whose generating condition no longer holds — the subscription's `next_renewal_date` changed, or it was paused — distinct from `skipped_archived` (the subscription itself was archived).
- created_at, updated_at.

Constraints:

- `CHECK` (`reminders_target_present`, loosened under DEC-069): `subscription_id IS NOT NULL OR payment_request_id IS NOT NULL OR reminder_type IN ('monthly_digest','lapsed_reengagement')`. Originally required a subscription or payment-request anchor unconditionally; loosened to also permit both null for the two user-level reminder types that have no natural row to anchor to.
- `CHECK` (`reminders_shared_payment_target`, loosened under DEC-069 — **not previously documented in this section at all**, a real pre-existing gap this pass closes): `(reminder_type = 'shared_payment' AND payment_request_id IS NOT NULL) OR (reminder_type IN ('monthly_digest','lapsed_reengagement')) OR (reminder_type NOT IN ('shared_payment','monthly_digest','lapsed_reengagement') AND subscription_id IS NOT NULL)`. Independently of the constraint above, this one requires `payment_request_id` specifically for `shared_payment` and `subscription_id` specifically for every other type except the two user-level ones — both constraints had to be loosened together, since loosening only `reminders_target_present` would still leave `monthly_digest`/`lapsed_reengagement` inserts blocked by this one.
- `CHECK` (`reminders_user_id_present`, added DEC-080 same-day extension, mirrors the DEC-069 pattern above of loosening a target-presence constraint for one specific reminder-type case): `user_id IS NOT NULL OR payment_request_id IS NOT NULL`. Backs the `user_id` nullability above — a `shared_payment` reminder with no `user_id` must still carry a `payment_request_id` to resolve a recipient through (`payment_request_id -> shared_members.email`). Every non-`shared_payment` reminder type already requires `user_id` via application logic (nothing generates them without it), so this CHECK's practical effect is scoped to the `shared_payment` case.
- Partial unique index: `UNIQUE (subscription_id, reminder_type) WHERE reminder_type IN ('seven_day','two_day','renewal_day','post_renewal_checkin') AND status = 'pending'` — prevents `generate_default_reminders()` or the Post-Renewal Check-In job from creating duplicate pending rows on repeated trigger firing.
- `monthly_digest` and `lapsed_reengagement` are per-user, not per-subscription, so this index does not cover them. Duplicate prevention instead relies on the generating cron job checking for an existing `pending` or `sent` row of the same `reminder_type` for that `user_id` within the current period (calendar month for `monthly_digest`; rolling 45 days for `lapsed_reengagement`) before inserting (DEC-041).

Generation mechanism (closes the previous gap where 3 of 6 reminder types had no defined generation path):

| Reminder type | Generated by |
| --- | --- |
| `seven_day`, `two_day`, `renewal_day` | `generate_default_reminders()` trigger on `subscriptions` insert/update (per `11_API_Integration_Architecture_v1.14`), refactored under DEC-070 into a thin wrapper over a callable helper, `generate_default_reminders_for_subscription()`, so the same insertion logic can also run from the resume path below without duplicating it. |
| `post_renewal_checkin`, `monthly_digest`, `lapsed_reengagement` | `generate-scheduled-reminders` (Edge Function, Supabase Cron, daily — 5.7 in `11_API_Integration_Architecture_v1.14`, DEC-068), calling the `generate_scheduled_reminders()` Postgres function via RPC (implemented in `28_SubSense_Scheduled_Reminders_Patch_v1.0.sql`, DEC-069; `post_renewal_checkin`'s query corrected under DEC-071, `30_SubSense_Post_Renewal_Checkin_Paused_Fix_v1.0.sql`). One daily run evaluates all three conditions (3 days post-`next_renewal_date`, and `lifecycle_status <> 'paused'` as of DEC-071 — closing a gap where a paused subscription's frozen renewal date could still generate a fresh check-in on a later cron run, since DEC-070's cancel trigger only reacts to the *transition into* paused, not the daily generator's own query; fixed monthly cadence; `last_login_at` > 45 days) and inserts the corresponding rows, since day-granularity events do not need hourly evaluation. `post_renewal_checkin`'s `scheduled_for` is still set to 9am in the user's `user_profiles.timezone` via `local_date_at_9am_tz()` (DEC-039, offset fixed per DEC-047, not user-configurable — unlike `seven_day`/`two_day`/`renewal_day`, it is not read from `user_preferences.reminder_default_days`). `monthly_digest` creates one row per calendar month for every user with at least one non-archived subscription (DEC-041). `lapsed_reengagement` creates one row per rolling 45-day window per user whose `last_login_at` exceeds that threshold (DEC-041). Per-row insert failures are caught and logged to `audit_logs` (`reminder_generation_failed`, DEC-069) without aborting the rest of the run. |
| `shared_payment` | Created on demand when a `payment_requests` row is created (both the renewal-date generation trigger and the member-join generation trigger below insert one), and also user-triggerable via `send-shared-payment-reminder` (5.3 in doc 11). `user_id` is set from the member's `shared_members.user_id` and may be null for an unlinked member (DEC-080 same-day extension) — recipient-email resolution for that case falls back to `payment_request_id -> shared_members.email`. **`owed_to` context fallback chain (DEC-082):** the email itself states the subscription owner's name, resolved `shared_subscriptions.owner_user_id -> user_profiles.display_name`, falling back to `users.email` if `display_name` is null, falling back to a generic "the subscription owner" string as a final defensive floor — addresses a real trust/spam-risk gap (a payment request with no named sender), independent of the still-unbuilt Profile page since `display_name` is already populated at signup. |
| `dev_test` | Created only via the `dev-trigger` Edge Function (5.4 in doc 11), never by a schedule. |

FK/cascade and archive behavior:

- `subscription_id` FK is `ON DELETE RESTRICT`.
- When a subscription's `archived_at` is set, a trigger (`skip_reminders_for_archived_subscription()`) sets `status = 'skipped_archived'` on any still-`pending` reminders for that subscription rather than deleting them, so `reminder_history` traceability is preserved and the cron job simply skips non-`pending` rows.
- **DEC-070**: a second trigger, `subscriptions_cancel_stale_reminders` (function `handle_reminder_lifecycle_changes()`, `29_SubSense_Reminder_Lifecycle_Patch_v1.0.sql`), fires `after update of next_renewal_date, lifecycle_status` and sets `status = 'skipped_superseded'` on any still-`pending` `seven_day`/`two_day`/`renewal_day`/`post_renewal_checkin` reminders whenever `next_renewal_date` changes or `lifecycle_status` enters `'paused'` — closing the gap where `generate_default_reminders()` inserted fresh reminders for a new renewal date but never cancelled the stale ones from the previous cycle, and where nothing reacted to a subscription being paused at all. Named to fire alphabetically before `subscriptions_generate_default_reminders`, so the cancellation always commits before the new insert is attempted in the same statement — otherwise the partial unique index above (`WHERE status = 'pending'`) would silently block the new row via `ON CONFLICT DO NOTHING` against the still-pending old one. The same trigger also calls `generate_default_reminders_for_subscription()` when a subscription resumes from `'paused'` (its `next_renewal_date` is unchanged across a pause, so the existing generate trigger never fires on resume alone).

Due-today evaluation (DEC-039, query logic completed under DEC-068):

- `send-reminder-email` (5.2 in doc 11) runs hourly via Supabase Cron and selects `WHERE status = 'pending' AND scheduled_for <= now()`. Because `scheduled_for` is already stored as an absolute UTC instant computed from each reminder's own `timezone_snapshot` at generation time (not recomputed at send time), a direct instant comparison is simpler than, and equivalent to, evaluating a UTC day boundary per timezone — it still avoids the midnight edge case where a user in `Asia/Kolkata` (UTC+5:30) would otherwise be evaluated against the wrong calendar day, since that timezone was already baked into `scheduled_for` when the row was created.
- This comparison is also self-healing: it naturally catches up on any reminder whose `scheduled_for` has passed, whether from normal hourly operation or a skipped/delayed cron tick, with no separate retry mechanism required. A reminder is only ever set to `status = 'sent'` after Resend confirms delivery (never optimistically before the call), so a mid-run failure leaves it `pending` for the next tick to pick up rather than silently losing it.

RLS:

- Owner: select only. Insert/update are system-only (service role), matching the existing Table Security Matrix row for Reminder Engine tables.
- **Known gap, accepted for MVP (DEC-080 same-day extension):** `reminders_select_own` is keyed on `user_id = current_app_user_id()`. A `shared_payment` reminder with `user_id IS NULL` (unlinked member) is therefore permanently unselectable via Path A by anyone, including the subscription owner — `null = anything` is never true. No functional impact today: generation and sending both go through the service-role client (bypasses RLS by design), and no locked component spec (C-019/C-020/C-021) surfaces reminder history in the UI. A future "last reminded" or audit-trail feature would need a new owner-scoped SELECT policy (e.g. via `payment_request_id -> shared_subscriptions.owner_user_id`) to read these rows at all.

### ai_recommendations

Purpose:

- Stores generated AI insights and recommendation context.

AI does not own business state.

Key columns:

- id UUID primary key.
- user_id UUID FK to `users`.
- subscription_id UUID FK to `subscriptions`, nullable (null for a workspace-level batch insight covering multiple subscriptions).
- recommendation_text, reason_text.
- financial_impact: jsonb.
- model_version: text, records which OpenAI model produced the row, for reproducibility/debugging.
- generated_at, created_at.

Constraints:

- Index on `(user_id, subscription_id, generated_at DESC)` for "latest insight per subscription" lookups.
- No update, no delete columns/policy — rows are append-only, consistent with "AI does not own business state" and BR-001.

RLS:

- Owner: select only, no client write (matches existing Table Security Matrix; service role inserts via `ai-generate-insight`).

### notifications

Purpose:

- Stores notification delivery records.

Key columns:

- id UUID primary key.
- user_id UUID FK to `users`, nullable (DEC-080 same-day extension) — null under the same condition as `reminders.user_id` above: a shared-payment notification for an unlinked member. `send-reminder-email` writes this row on every send attempt (success or failure), so it needed the identical fix once `reminders.user_id` went nullable.
- reminder_id UUID FK to `reminders`, nullable.
- payment_request_id UUID FK to `payment_requests`, nullable (for shared-payment notifications not tied to a reminder row).
- channel: enum `notification_channel` (`email`), not null.
- template_id UUID FK to `notification_templates`.
- delivery_status: enum `delivery_status` (`queued`, `sent`, `failed`, `bounced`), not null default `queued`.
- provider_message_id: nullable text (Resend message id, for delivery-status reconciliation).
- sent_at: nullable timestamptz.
- created_at.

Constraints:

- Index on `(user_id, created_at DESC)`.
- `CHECK` (`notifications_user_id_present`, added DEC-080 same-day extension, identical pattern to `reminders_user_id_present`): `user_id IS NOT NULL OR payment_request_id IS NOT NULL`.

RLS:

- Owner: select only, no client write (matches existing Table Security Matrix; service role writes via `send-reminder-email` / `send-shared-payment-reminder`).
- **Known gap, accepted for MVP (DEC-080 same-day extension):** same issue as `reminders_select_own` above — `notifications_select_own` is keyed on `user_id = current_app_user_id()`, so a null-`user_id` row is permanently unselectable by anyone, including the owner. Same acceptance rationale: no functional impact (service-role writes, no UI surfacing this data today).

### payment_transactions

Purpose:

- Stores Razorpay Test Mode premium transaction history.

No production payment processing is part of MVP.

Key columns:

- id UUID primary key.
- user_id UUID FK to `users`.
- premium_plan_id UUID FK to `premium_plans`.
- razorpay_order_id: text, unique.
- razorpay_payment_id: text, unique, nullable until the checkout completes.
- razorpay_signature: text, nullable, never returned to the client after verification.
- amount, currency.
- status: enum `transaction_status` (`created`, `verified`, `failed`), not null default `created`.
- failure_reason: nullable text.
- verified_at: nullable timestamptz.
- created_at.

Constraints:

- `UNIQUE (razorpay_payment_id)` where not null — this is the concrete backing for the idempotency rule in `11_API_Integration_Architecture_v1.14` ("keyed on `razorpay_payment_id`"): a duplicate verification call hits the unique constraint and the Edge Function returns the existing row instead of writing a second one.

RLS:

- Owner: select only, no client write (matches existing Table Security Matrix; only `razorpay-verify-payment` writes, using the service role).

## System Data Tables

### reminder_history

Purpose:

- Immutable record of every reminder execution attempt.

Rules:

- Append-only.
- No update.
- No delete.

### audit_logs

Purpose:

- Immutable record of security-sensitive and business-significant events.

Access:

- Admin/service roles only.
- No direct end-user access.

### system_settings

Purpose:

- Application-wide configuration not specific to one user.

Access:

- Backend read.
- Admin write.
- No end-user access.

## RLS Security Model

Principle:

- Least privilege.

Security layers:

Authentication -> RLS -> Application Business Rules -> Frontend

Actor roles:

| Role | Purpose |
| --- | --- |
| Authenticated User | Normal app user |
| Service Role | Backend automation |
| Administrator | Platform administration |
| Anonymous | No data access |

## Table Security Matrix

| Table Category | Read | Create | Update | Delete |
| --- | --- | --- | --- | --- |
| User-owned | Owner | Owner or backend | Owner | Archive only |
| Shared | Owner/member | Owner | Owner\* | Archive |
| Master data | Authenticated users | Admin | Admin | Admin |
| Infrastructure | Restricted | Service/Admin | Service/Admin | Never or admin-only |

\* "Owner" is the default for the Shared category. `payment_requests` is a named exception per DEC-037: a linked member may also update, but only through the single `pending -> paid_pending_confirmation` transition — see the Permission model table under `payment_requests` above for the full rule. `user_profiles.is_premium`/`premium_expires_at`/`premium_source` are a column-level exception in the otherwise-Owner User-owned category: those three columns are backend/service-role write-only per DEC-038. `subscriptions` is also a named exception in the otherwise-Owner User-owned category (live-testing pass): a linked, active shared member may also read (never write) the specific subscription row(s) they share, via `subscriptions_select_shared_member` — see the `subscriptions` table's own RLS note above for the full rationale and the accepted full-row-grant tradeoff.

## Delete Strategy

Business data uses soft delete:

Delete intent -> archived_at populated -> excluded from active views

Physical deletes are not part of normal MVP behavior.

## Migration Order

1. ENUM types.
2. Core identity tables.
3. Master data tables.
4. Business data tables.
5. System data tables.
6. Indexes.
7. RLS enablement.
8. RLS policies.
9. Seed data.
10. Validation queries.

## Database Validation Checklist

| Check | Status |
| --- | --- |
| Entity domains defined | Complete |
| Table ownership defined | Complete |
| Identifier standard defined | Complete |
| ENUM standard defined | Complete |
| RLS model defined | Complete |
| Soft delete policy defined | Complete |
| Migration order defined | Complete |
| API dependency noted | Complete |
| Field-level schema for shared/reminder/AI/notification/payment tables defined | Complete |
| Constraints, indexes, and FK cascade/archive behavior defined | Complete |
| Shared-payment permission model reconciled with API document | Complete |
| Premium entitlement source of truth defined | Complete |
| Reminder generation mechanism defined for all six reminder types | Complete |
| Retention reminder types (`monthly_digest`, `lapsed_reengagement`) defined | Complete |
| Catalog `logo_url` column, category expansion, and 31-row seed data (DEC-046) defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Database architecture frozen after IR-002 and IR-009. |
| v1.1 | Frozen | Added `payment_method` ENUM and `payment_reference_note` field to `subscriptions` per DEC-032. Non-breaking additive change. Corrected title/Document Control version to match filename (was misstated as v1.0). Added field-level columns, constraints, indexes, and FK cascade/archive behavior for `shared_subscriptions`, `shared_members`, `payment_requests`, `reminders`, `ai_recommendations`, `notifications`, and `payment_transactions` (DEC-036). Added premium entitlement fields to `user_profiles` (DEC-038). Reconciled the `payment_requests` permission model with `11_API_Integration_Architecture_v1.1` (DEC-037). Defined the generation mechanism, timezone handling, and archive-exclusion rule for all six reminder types (DEC-039). |
| v1.2 | Frozen | Added `monthly_digest` and `lapsed_reengagement` to the `reminder_type` enum, their generation mechanisms, and their duplicate-prevention logic; documented `users.last_login_at` as the basis for the Retention Policy's active-user definition (DEC-041). Additive change against the already-applied `17_SubSense_Migration_v2` — see `20_SubSense_Retention_Patch_v1.0.sql` for the incremental migration. |
| v1.3 | Frozen | Housekeeping pass, not tied to a new DEC: corrected two stale references to `11_API_Integration_Architecture_v1.0` (the `generate_default_reminders()` trigger note and the `payment_transactions` idempotency note) to v1.1, corrected a long-stale reference to `03_Information_Architecture_v1.2` (DEC-038 premium status cross-reference, unnoticed since before this session's earlier housekeeping rounds) to v1.5, and updated the dependency reference to 09_Implementation_Readiness_v1.1, as part of the cascade patching 11's own internal reference-integrity gaps. |
| v1.4 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 09_Implementation_Readiness_v1.2 and the two body cross-references to 11_API_Integration_Architecture_v1.2, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. |
| v1.5 | Frozen | Recorded DEC-046: added `logo_url` to `subscription_catalog`, added Music and AI Tools categories, and documented the catalog expansion from 10 to 31 seeded rows. Additive schema change against the already-applied `17_SubSense_Migration_v2` — see `21_SubSense_Catalog_Logo_Patch_v1.2.sql` and `22_SubSense_Catalog_Expansion_v2.0.sql` for the incremental migrations (both still DRAFT pending this documentation, now satisfied). |
| v1.6 | Frozen | Recorded DEC-047: pinned the `post_renewal_checkin` generation offset at exactly 3 days after `next_renewal_date`, evaluated at 9am local time, fixed and non-configurable — closing the ambiguity DEC-039 left as "has just passed." Noted the finalized one-template-per-type `notification_templates` content (8 rows). No schema change. Citation cascade to dependent documents deferred and will be batched with the upcoming notification-template SQL patch rather than run twice in a row. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 09_Implementation_Readiness_v1.4, the Premium status cross-reference to 03_Information_Architecture_v1.8, and the two `11_API_Integration_Architecture` body cross-references to v1.4 — these had gone stale as a direct side effect of this document's own v1.6 bump triggering the wider DEC-047 citation cascade, which in turn moved 09, 03, and 11 to new versions this document itself cites. Executed as part of the same batched pass as the notification-template SQL patch (file 23). No schema change. A follow-up pre-PRD audit caught the Premium status cross-reference to 03_Information_Architecture one further version behind (v1.8) -- now v1.10. Not bumping the version again for this. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 09_Implementation_Readiness_v1.5, the Premium status cross-reference to 03_Information_Architecture_v1.12, and the two `11_API_Integration_Architecture` body cross-references to v1.7, as part of the cascade recording DEC-053 (Lovable to Cursor tooling change). No schema change. **Correction (same day, caught before this pass finished):** the Premium status cross-reference corrected to 03_Information_Architecture_v1.13, since 03 moved again after this row was written. Not bumping the version again for this. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Premium status cross-reference to 03_Information_Architecture_v1.14, closing citation drift left deliberately deferred since the DEC-054 pass. No schema change. **Correction (same day):** the Depends On field's 09_Implementation_Readiness citation corrected to v1.6, since 09 moved again later in this same cleanup pass. Not bumping the version again for this. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Premium status cross-reference to 03_Information_Architecture_v1.15, following DEC-055 (logo wordmark font resolved, logo formally implemented). No schema change. **Correction (same day):** the Depends On field's 09_Implementation_Readiness citation corrected to v1.7, since 09 moved again later in this same cleanup pass. **Further correction (same day, full folder grep audit):** two pre-existing stale body cross-references to 11_API_Integration_Architecture (stuck at v1.7, in the reminder-generation table and the payment idempotency note) corrected to v1.9. Not bumping the version again for this. |
| v1.11 | Frozen | Recorded DEC-059's impact on this document: `subscription_catalog.logo_url` (DEC-046) is deprecated — no longer read by the frontend, which now renders a fixed generic category icon instead of a real per-service brand logo. Its 30 populated real-logo values are nulled via a new SQL patch (`27_SubSense_Catalog_Logo_Removal_v1.0.sql`); the column itself is retained in the schema, unused, rather than dropped. No structural schema change (no migration against live tables beyond the data-nulling UPDATE) — this is a status/usage correction to an existing column's description, not a new column or constraint. |
| v1.12 | Frozen | Recorded DEC-068: completed the reminders table's generation-mechanism table, which previously left `post_renewal_checkin`, `monthly_digest`, and `lapsed_reengagement` each described only as "a scheduled function (Path B, cron)" with no concrete mechanism named — now names a single `generate-scheduled-reminders` Edge Function (Supabase Cron, daily) covering all three. Also completed the Due-today evaluation note: names `send-reminder-email` explicitly as the hourly Supabase Cron job, and clarifies its query as `WHERE status = 'pending' AND scheduled_for <= now()` — a simpler, equivalent refinement of the prior day-boundary-in-timezone_snapshot phrasing, since `scheduled_for` is already a precomputed absolute UTC instant. Added the explicit self-healing/catch-up and confirm-before-marking-sent reliability notes. No schema change. **Correction (same day):** the Depends On field's 09_Implementation_Readiness citation corrected to v1.8, since 09 moved again later in this same cleanup pass (its own API Document Note citing this document's own new version). Not bumping the version again for this. **Further correction (same day, full grep audit):** two pre-existing stale body cross-references to `11_API_Integration_Architecture`, both stuck at v1.9 (the `generate_default_reminders()` trigger note and the `payment_transactions` idempotency note), corrected to v1.10 — missed in this pass's own initial edit. Not bumping the version again for this. |
| v1.13 | Frozen | Recorded DEC-069: documents `28_SubSense_Scheduled_Reminders_Patch_v1.0.sql`. Both `reminders_target_present` and `reminders_shared_payment_target` CHECK constraints are now listed under Constraints and shown loosened to permit `monthly_digest`/`lapsed_reengagement` rows with `subscription_id` and `payment_request_id` both null — `reminders_shared_payment_target` specifically had never been documented in this section at all before this pass, a real pre-existing gap closed here, not introduced by it. Corrected the `subscription_id`/`payment_request_id` nullability body text to match. Expanded the bare `audit_action` bullet to list all 12 values, including the new `reminder_generation_failed` (added via the same two-step enum-addition pattern as `20_SubSense_Retention_Patch_v1.0.sql`). The Generation mechanism table's `post_renewal_checkin`/`monthly_digest`/`lapsed_reengagement` row now cites `generate_scheduled_reminders()` and file 28 by name, plus the per-row failure-logging behavior. Schema change: additive against the already-applied `17_SubSense_Migration_v2` — see file 28 for the incremental migration. No Depends On change. |
| v1.14 | Frozen | Recorded DEC-070: documents `29_SubSense_Reminder_Lifecycle_Patch_v1.0.sql`, fixing a real bug confirmed live (a subscription paid forward, and a separately paused subscription, both still delivered stale reminders tied to a superseded state). Added a new `reminder_status` value, `skipped_superseded`, alongside the existing four. `generate_default_reminders()` documented as refactored into a thin wrapper over a new callable helper, `generate_default_reminders_for_subscription()`. Added a new FK/cascade bullet documenting the new `subscriptions_cancel_stale_reminders` trigger (`handle_reminder_lifecycle_changes()`) — cancels stale pending `seven_day`/`two_day`/`renewal_day`/`post_renewal_checkin` reminders on a `next_renewal_date` change or entering `'paused'`, regenerates the default set on resuming from `'paused'`, and is named to fire alphabetically before the existing generate trigger so cancellation always precedes the new insert (avoiding a silent block against the existing partial unique index on pending reminders). Schema change: additive against the already-applied `17_SubSense_Migration_v2`/`28_SubSense_Scheduled_Reminders_Patch_v1.0` — see file 29 for the incremental migration. Run against the live Supabase project and verified. No Depends On change. |
| v1.15 | Frozen | Recorded DEC-071: documents `30_SubSense_Post_Renewal_Checkin_Paused_Fix_v1.0.sql`, closing a narrow gap found by walking DEC-070's fix through every subscription-state transition — the Generation mechanism table's `post_renewal_checkin`/`monthly_digest`/`lapsed_reengagement` row updated to note the daily cron's `post_renewal_checkin` query never checked `lifecycle_status`, so a paused subscription's frozen renewal date could still generate a fresh check-in on a later run. One-clause fix (`and s.lifecycle_status <> 'paused'`), everything else in `generate_scheduled_reminders()` unchanged from file 28. Schema change: additive, single function replace against the already-applied file 28 — see file 30 for the incremental migration, not yet run against the live Supabase project. No Depends On change. **Further correction (DEC-079 same-day extension — Phase 7 implementation planning):** the three body cross-references to `11_API_Integration_Architecture` (reminder-generation table, twice, and the idempotency note) updated to v1.11. Not bumping the version again for this either. |
| v1.16 | Frozen | Recorded DEC-080: three additions to the `shared_subscriptions`/`shared_members`/`payment_requests` cluster, resolving forks left open since these tables were first designed. (1) A new **Generation mechanism** note under `payment_requests`, extending DEC-070's event-driven trigger pattern: fires on `subscriptions.next_renewal_date` change, creates one `payment_requests` row per active `shared_members` row for the new `billing_cycle_date`, snapshotting `amount` from `shared_members.amount_owed` — the existing `UNIQUE (shared_member_id, billing_cycle_date)` constraint is the idempotency guard. (2) A new **equal-split rebalance trigger** bullet under `shared_members`: for `split_method = 'equal'`, a trigger on member insert/soft-remove recomputes every active member's `amount_owed` (cost / active count), never retroactively altering already-generated `payment_requests` snapshots; `custom` split untouched. (3) An explicit **no-cascade-on-removal** bullet under `shared_members`, closing a real documentation gap: this section already stated payment history is preserved on removal, but never explicitly said what happens to a removed member's still-open request — now stated directly (left open, unchanged), contrasted against the existing archive-cascade rule which does cancel. **Retroactive correction (caught this pass):** the Document Control table's Version field had been stuck at v1.13 since the v1.14/v1.15 bumps (a real drift between the file's own title/filename and its Document Control metadata) — corrected to match. No structural schema change beyond the two new triggers described above (additive, no new columns/constraints). No Depends On change — 09_Implementation_Readiness is still at v1.8. |
| v1.17 | Frozen | **DEC-080 same-day extension**, closing four real gaps a Claude Code technical-planning pass surfaced against the locked v1.16 architecture (plan-only, reviewed and revised twice before build): (1) a second trigger, `shared_members_generate_initial_request` (`after insert on shared_members`), added to the `payment_requests` Generation mechanism note and the `shared_members` rebalance bullet — generates the current cycle's request immediately on member join via the same underlying helper the renewal-date trigger uses, closing the gap where a brand-new share or mid-cycle new member would otherwise generate zero requests until the next renewal. (2) `reminders.user_id` and `notifications.user_id` both documented as nullable, each backed by a new CHECK (`reminders_user_id_present` / `notifications_user_id_present`: `user_id IS NOT NULL OR payment_request_id IS NOT NULL`), mirroring DEC-069's existing target-presence-loosening pattern — scoped to a `shared_payment` reminder/notification tied to an unlinked (`shared_members.user_id IS NULL`) member; recipient-email resolution falls back to `payment_request_id -> shared_members.email`. `reminder_history.user_id` checked and confirmed already nullable in the live schema, needing no change. (3) An accepted-rounding-remainder note added to the equal-split rebalance bullet (`round(cost / active_count, 2)` will not always sum exactly to `cost`) — a documented MVP simplification, not a bug. (4) A known, accepted RLS gap documented on both `reminders` and `notifications`: `..._select_own` policies are keyed on `user_id = current_app_user_id()`, so a null-`user_id` row becomes permanently unselectable via Path A by anyone including the owner — accepted since generation/sending both go through the service-role client and no locked component spec surfaces this data in the UI; a future audit-trail feature would need a new owner-scoped policy. No new columns; all four changes are additive constraint/trigger-comment-level documentation matched to the not-yet-run migration. No Depends On change — 09_Implementation_Readiness is still at v1.8. |
| v1.18 | Frozen | **DEC-080 further extension, from live-testing the built feature** (no new DEC number): three real schema/RLS corrections. (1) `rebalance_equal_split_members()`'s divisor corrected from `active_count` to `active_count + 1` — the owner was never counted as a sharer, so a single member was billed the full cost instead of half; the rounding-remainder acceptance note (v1.17) still stands, now against the corrected divisor and with its example updated. Also added: still-`pending` `payment_requests` rows now sync to the current per-member amount on every rebalance rather than freezing at creation. Both via `32_SubSense_Equal_Split_Fixes_v1.0.sql`. (2) A new `before insert` trigger, `handle_shared_member_link_existing_user`, links a newly-added member's row to their existing SubSense account by a case-insensitive email match — `33_SubSense_Link_Existing_User_On_Member_Add_v1.0.sql`; retroactive linking on later signup is an accepted, deferred gap. (3) A new RLS policy, `subscriptions_select_shared_member` (`34_SubSense_Shared_Member_Subscription_Visibility_v1.0.sql`), grants a linked, active shared member read-only access to the specific `subscriptions` row(s) they share — closing a PostgREST embed-swallow bug that silently hid an otherwise-visible `shared_subscriptions` row on the Shared Subscriptions page. Accepted as a full-row grant (`cost`/`payment_method`/`payment_reference_note` included), matching this schema's existing table+row-only security convention. `subscriptions`'s own RLS documented explicitly for the first time in this pass (previously covered only by the generic Table Security Matrix row); the matrix's footnote updated to cross-reference this new named exception. No Depends On change — 09_Implementation_Readiness is still at v1.8. |
| v1.21 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field to 09_Implementation_Readiness_v1.10 and the three `11_API_Integration_Architecture` body cross-references (audit_action enum note, seven_day/two_day/renewal_day generation mechanism, post_renewal_checkin/monthly_digest/lapsed_reengagement generation mechanism, and the razorpay_payment_id idempotency note) to v1.13, as part of the cascade recording DEC-085 (currency-drop fix, Cost Comparison Card rename). No schema/RLS content changed. |
| v1.22 | Current | Housekeeping pass, not tied to a new DEC: updated the Depends On field to 09_Implementation_Readiness_v1.11, the three `11_API_Integration_Architecture` body cross-references to v1.14, and the Premium-entitlement ownership cross-reference to `03_Information_Architecture_v1.17`, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No schema/RLS content changed. |
| v1.20 | Frozen | Recorded DEC-083: `user_profiles.is_premium`'s bullet updated from "planned reader" to **implemented** — Decision Workspace's AI Insight batch and the Phase 9 Insights page both now check entitlement server-side via `user_has_active_premium(uuid)` (the existing `security definer` SQL function, called via RPC rather than reimplemented in each Edge Function), capping free-tier users to 1 insight vs. premium's 3-subscription batch, and gating the Insights page premium-exclusive both client- and server-side. Frontend-only checks use a separate plain TypeScript helper, not the RPC, since they aren't a security boundary. No schema change — this describes real behavior against existing columns, not new structure. No Depends On change — 09_Implementation_Readiness is still at v1.8. **Further correction (same day, full grep audit):** three body cross-references to `11_API_Integration_Architecture`, found stuck at v1.11 (the `reminder_generation_failed` enum-value note, and both cells of the reminder-generation table's `seven_day`/`two_day`/`renewal_day` and `post_renewal_checkin`/`monthly_digest`/`lapsed_reengagement` rows), corrected to v1.12. The Depends On field's `09_Implementation_Readiness` citation updated to v1.9, since 09 moved again later in this same cleanup pass. Also, the Premium-entitlement ownership cross-reference to `03_Information_Architecture`, found stuck at v1.15, corrected to v1.16. Not bumping the version again for this. |
| v1.19 | Frozen | Recorded DEC-082's two documentation-only additions, no new DEC number of its own. (1) The `reminders` table's `shared_payment` notification-type description gets an **`owed_to` context fallback chain** note: the email now states the subscription owner's name, resolved `shared_subscriptions.owner_user_id -> user_profiles.display_name`, falling back to `users.email` if null, falling back to a generic "the subscription owner" string as a final defensive floor — implemented via `35_SubSense_Shared_Payment_Owed_To_Patch_v1.0.sql` and `36_SubSense_Shared_Payment_Owed_To_Body_Fix_v1.0.sql`, both run and verified live against a real sent email. (2) `user_profiles.is_premium`'s bullet gets a **planned reader** note: confirmed via full-codebase grep that no reader currently exists anywhere in the built product; DEC-082 locks in that the Decision Workspace's AI Insight batch is meant to check this and cap free-tier users to 1 insight (vs. premium's full 3-subscription batch), and the Phase 9 Insights page is meant to be premium-exclusive entirely — neither check is built yet, per DEC-082's explicit decide-now-build-later scoping. No schema change (both notes describe existing columns/behavior more completely, not new structure). No Depends On change — 09_Implementation_Readiness is still at v1.8. |
