# 10 Database Architecture v1.1

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DB-001 |
| Product | SubSense |
| Version | v1.1 |
| Status | Frozen implementation baseline |
| Source of Truth | Supabase PostgreSQL schema and RLS architecture |
| Depends On | 09_Implementation_Readiness_v1.0 |

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
- audit_action.
- premium_source (DEC-038): `razorpay_test_mode`, `manual_grant`.
- split_method (DEC-036): `equal`, `custom`.
- member_status (DEC-036): `active`, `removed`.
- payment_request_status (DEC-036, DEC-037): `pending`, `paid_pending_confirmation`, `paid`, `cancelled`.
- reminder_type (DEC-036, DEC-039): `seven_day`, `two_day`, `renewal_day`, `post_renewal_checkin`, `shared_payment`, `dev_test`.
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
- last_login_at.
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
- Per DEC-038, this is the single source of truth for premium entitlement (matches the "Premium status | Billing/Profile" ownership assignment in `03_Information_Architecture_v1.2`). No other table stores current entitlement state — `premium_plans` is a plan catalog and `payment_transactions` is a transaction log, neither reflects "is this user premium right now."

Key columns:

- id UUID primary key.
- user_id unique FK to users, `ON DELETE CASCADE`.
- display_name.
- profile_photo_url.
- country.
- timezone: IANA timezone string (e.g. `Asia/Kolkata`), not null, default `Asia/Kolkata`. Used by the Reminder Engine for due-today evaluation per DEC-039.
- default_currency.
- is_premium: boolean, not null, default `false`. The single premium entitlement flag.
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

Access:

- Authenticated users read.
- Admin/service role writes.

### subscription_catalog

Purpose:

- Known subscription providers such as Netflix, Spotify, ChatGPT.

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
- user_id UUID FK to `users` (the recipient).
- subscription_id UUID FK to `subscriptions`, nullable (null only for `shared_payment` reminders, which attach to a payment request instead).
- payment_request_id UUID FK to `payment_requests`, nullable (set only for `shared_payment` reminders).
- reminder_type: enum `reminder_type` (`seven_day`, `two_day`, `renewal_day`, `post_renewal_checkin`, `shared_payment`, `dev_test`), not null.
- scheduled_for: timestamptz, not null — stored as an absolute UTC instant, computed at generation time from the renewal date and the user's `user_profiles.timezone` (DEC-039), not recomputed at send time.
- timezone_snapshot: the IANA timezone used to compute `scheduled_for`, captured at generation time so a later change to the user's profile timezone does not retroactively shift an already-scheduled reminder.
- status: enum `reminder_status` (`pending`, `sent`, `skipped_archived`, `failed`), not null default `pending`.
- created_at, updated_at.

Constraints:

- `CHECK`: `subscription_id IS NOT NULL OR payment_request_id IS NOT NULL`.
- Partial unique index: `UNIQUE (subscription_id, reminder_type) WHERE reminder_type IN ('seven_day','two_day','renewal_day','post_renewal_checkin') AND status = 'pending'` — prevents `generate_default_reminders()` or the Post-Renewal Check-In job from creating duplicate pending rows on repeated trigger firing.

Generation mechanism (closes the previous gap where 3 of 6 reminder types had no defined generation path):

| Reminder type | Generated by |
| --- | --- |
| `seven_day`, `two_day`, `renewal_day` | `generate_default_reminders()` trigger on `subscriptions` insert/update, per `11_API_Integration_Architecture_v1.0`. |
| `post_renewal_checkin` | A scheduled function (Path B, cron) that evaluates subscriptions whose `next_renewal_date` has just passed and creates one `post_renewal_checkin` row per renewed subscription, per DEC-039. |
| `shared_payment` | Created on demand when a `payment_requests` row is created, and also user-triggerable via `send-shared-payment-reminder` (5.3 in doc 11). |
| `dev_test` | Created only via the `dev-trigger` Edge Function (5.4 in doc 11), never by a schedule. |

FK/cascade and archive behavior:

- `subscription_id` FK is `ON DELETE RESTRICT`.
- When a subscription's `archived_at` is set, a trigger sets `status = 'skipped_archived'` on any still-`pending` reminders for that subscription rather than deleting them, so `reminder_history` traceability is preserved and the cron job simply skips non-`pending` rows.

Due-today evaluation (DEC-039):

- The cron job selects reminders where `scheduled_for` falls within the current UTC day boundary as computed *in each reminder's own `timezone_snapshot`*, not the server's UTC day. This avoids the midnight edge case where a user in `Asia/Kolkata` (UTC+5:30) would otherwise have their "due today" reminder evaluated against the wrong calendar day.

RLS:

- Owner: select only. Insert/update are system-only (service role), matching the existing Table Security Matrix row for Reminder Engine tables.

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
- user_id UUID FK to `users`.
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

RLS:

- Owner: select only, no client write (matches existing Table Security Matrix; service role writes via `send-reminder-email` / `send-shared-payment-reminder`).

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

- `UNIQUE (razorpay_payment_id)` where not null — this is the concrete backing for the idempotency rule in `11_API_Integration_Architecture_v1.0` ("keyed on `razorpay_payment_id`"): a duplicate verification call hits the unique constraint and the Edge Function returns the existing row instead of writing a second one.

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

\* "Owner" is the default for the Shared category. `payment_requests` is a named exception per DEC-037: a linked member may also update, but only through the single `pending -> paid_pending_confirmation` transition — see the Permission model table under `payment_requests` above for the full rule. `user_profiles.is_premium`/`premium_expires_at`/`premium_source` are a column-level exception in the otherwise-Owner User-owned category: those three columns are backend/service-role write-only per DEC-038.

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

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Database architecture frozen after IR-002 and IR-009. |
| v1.1 | Current | Added `payment_method` ENUM and `payment_reference_note` field to `subscriptions` per DEC-032. Non-breaking additive change. Corrected title/Document Control version to match filename (was misstated as v1.0). Added field-level columns, constraints, indexes, and FK cascade/archive behavior for `shared_subscriptions`, `shared_members`, `payment_requests`, `reminders`, `ai_recommendations`, `notifications`, and `payment_transactions` (DEC-036). Added premium entitlement fields to `user_profiles` (DEC-038). Reconciled the `payment_requests` permission model with `11_API_Integration_Architecture_v1.0` (DEC-037). Defined the generation mechanism, timezone handling, and archive-exclusion rule for all six reminder types (DEC-039). |
