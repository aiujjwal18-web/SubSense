# 11 API Integration Architecture v1.0

## Document Control

| Field | Value |
| --- | --- |
| Document ID | API-001 |
| Product | SubSense |
| Version | v1.0 |
| Status | Frozen implementation baseline |
| Source of Truth | API, integration, and data-access contract |
| Depends On | 09_Implementation_Readiness_v1.0, 10_Database_Architecture_v1.1, 12_Backend_Architecture_v1.0 |
| Supersedes | 11_API_Integration_Architecture_v1.0 (skeleton draft) |

## Purpose

This document defines exactly how the SubSense frontend accesses data and business logic. It replaces the earlier placeholder skeleton with a real, buildable contract, expressed in the **Lean Access Architecture** (Decision Log entry DEC-031 below): direct Supabase client access under Row Level Security for standard data operations, and dedicated Edge Functions only where a provider secret or cross-cutting business computation is involved.

This document does not change product scope, screens, entities, or business rules defined in documents 00-10. It defines *how* those already-frozen rules are technically enforced.

## New Decision Record

| ID | Category | Decision | Rationale | Affected Documents | Status |
| --- | --- | --- | --- | --- | --- |
| DEC-031 | Architecture | SubSense MVP uses Lean Access Architecture: direct Supabase client + RLS for CRUD, Edge Functions only for secret-bearing or cross-cutting logic. | Matches solo/part-time build capacity without changing enforced business rules; RLS becomes the Repository/Service enforcement layer for simple entities. | 07, 11, 12, 13 | Active |

This decision does not alter DEC-016 (frontend never talks directly to external providers) or DEC-017 (hub-and-spoke integration architecture). Both remain true: the frontend still never calls OpenAI, Resend, or Razorpay directly, and all provider traffic still passes through a single mediation point per provider.

## 1. Access Architecture Overview

Two access paths exist. Every table and every capability in SubSense is assigned to exactly one.

| Path | Mechanism | Used For |
| --- | --- | --- |
| A — Direct Data Access | Supabase client (`supabase-js`) from Lovable frontend, governed entirely by RLS policies from `10_Database_Architecture_v1.1` | All user-owned CRUD: profile, preferences, subscriptions, shared subscriptions, members, payment requests, reading reminders/notifications/AI output/catalog |
| B — Edge Function APIs | Supabase Edge Functions, using the service role key, never exposed to the frontend | Anything touching OpenAI, Resend, or Razorpay secrets; anything that must run on a schedule; anything writing to system-owned tables (`ai_recommendations`, `notifications`, `reminder_history`, `audit_logs`, `payment_transactions`) |

Rule of assignment: **if a table is only ever read or written by its owning user, it is Path A. If a write requires a provider secret, a cron trigger, or must never be user-editable, it is Path B.**

## 2. API Standards (applies to Path B only; Path A follows Supabase's native contract)

- JSON request and response bodies.
- All Edge Functions require a valid Supabase JWT in the `Authorization` header, verified before any logic runs.
- Dates in ISO 8601. Currency values as decimal, currency code separate (`INR` / `USD`).
- Every Edge Function response follows the standard envelope defined in `12_Backend_Architecture_v1.0`:

```json
{ "success": true, "data": {}, "meta": {} }
```
```json
{ "success": false, "error": { "code": "ERROR_CODE", "message": "User-safe message" } }
```

- Idempotency keys are required on `razorpay-verify-payment` and `send-reminder-email` to prevent duplicate financial or email side effects on retry.

## 3. Authentication and Authorization

Authentication: Supabase Auth, Google Sign-In primary, email/password fallback, per `01_Product_Strategy_v1.3`.

Provisioning (implements BR-006, BR-007): a Postgres trigger `handle_new_user()` fires on `auth.users` insert and creates the corresponding `users`, `user_profiles`, and `user_preferences` rows in one transaction. This guarantees profile provisioning happens exactly once, at the database layer, with no custom API code and no possibility of a duplicate-profile race condition.

Authorization for Path A is enforced entirely by RLS policies already specified per-table in `10_Database_Architecture_v1.1`. Authorization for Path B is enforced by each Edge Function validating the caller's JWT `sub` (user id) against the resource being acted on before using its service-role privileges.

Developer/Test Utilities (`03_Information_Architecture_v1.2`) call the same Path B functions as normal usage — there is no separate "test" code path, only a restricted route that is allowed to trigger them on demand instead of waiting for a schedule or user action.

## 4. Path A — Direct Data Access Catalogue

For each resource: allowed client operations, and which RLS policy (already defined in doc 10) governs it.

| Resource (table) | Client Operations | Governing RLS | Business Rule Enforced |
| --- | --- | --- | --- |
| `user_profiles` | select, update (own row) | Owner only | Profile module ownership |
| `user_preferences` | select, update (own row) | Owner only | Reminder default configuration |
| `subscription_categories` | select | Authenticated read, admin write | Master data read-only |
| `subscription_catalog` | select | Authenticated read, admin write | Catalog search in Add Subscription |
| `subscriptions` | select, insert, update, soft-delete (`archived_at`) | Owner only | BR-002; Archive-first (EXP-007); DEC-032 payment rail awareness |
| `shared_subscriptions` | select, insert, update | Owner only | Sharing Strategy |
| `shared_members` | select, insert, update, soft-remove | Owner of parent `shared_subscriptions` | Preserve payment history on member removal |
| `payment_requests` | select, insert, update status | Owner: any valid transition. Linked member: `pending -> paid_pending_confirmation` only (DEC-037) | Payment status tracking |
| `reminders` | select | Owner only, insert/update system-only | Reminder visibility without user tampering |
| `reminder_history` | select | Owner only, append-only, no client write | Immutable execution record |
| `ai_recommendations` | select | Owner only, no client write | BR-001: AI output is read-only to the user who receives it |
| `notifications` | select | Owner only, no client write | Delivery record integrity |
| `premium_plans` | select | Authenticated read, admin write | Plan comparison in Profile |
| `payment_transactions` | select | Owner only, no client write | Financial record integrity |
| `audit_logs`, `system_settings` | none | No client access at any level | System/security isolation |

**Calculated fields** (`monthly_equivalent`, `annual_equivalent` on `subscriptions`): computed by a Postgres function `calculate_subscription_equivalents()` invoked as a `BEFORE INSERT OR UPDATE` trigger, so the database is always the authoritative value. The frontend's Annual Cost Preview (component C-011) mirrors the same formula client-side purely for live-typing feedback before save; the saved value always comes from the trigger, not the client calculation. This keeps DEC-024 (single source of truth for business data) intact.

**Reminder generation** (DEC-039, full column/constraint detail in `10_Database_Architecture_v1.1`): the six reminder types in `01_Product_Strategy_v1.3` Reminder Strategy are generated by three different mechanisms, not one:

- `seven_day`, `two_day`, `renewal_day`: a trigger on `subscriptions` insert/update calls `generate_default_reminders()`, which reads the user's `reminder_default_days` from `user_preferences` and the user's `user_profiles.timezone`, and creates the corresponding rows in `reminders` with `scheduled_for` computed in that timezone. This is the "Reminder Service" from doc 12, implemented as a database function rather than an application-layer class.
- `post_renewal_checkin`: generated by a scheduled Path B function that evaluates subscriptions whose `next_renewal_date` has just passed, closing the gap where this promised reminder type previously had no generation mechanism at all.
- `shared_payment`: created when a `payment_requests` row is created, and re-sendable on demand via 5.3 below.

**Due-today evaluation**: `send-reminder-email` (5.2) selects reminders due in the current day *as computed in each reminder's own `timezone_snapshot`*, not server UTC, so a user in `Asia/Kolkata` is not evaluated against the wrong calendar day near midnight UTC.

**Archived subscriptions**: a trigger sets any still-`pending` reminder to `status = 'skipped_archived'` when its parent subscription is archived, so the cron job never sends a reminder for a subscription the user has already archived.

## 5. Path B — Edge Function Catalogue

### 5.1 `POST /functions/v1/ai-generate-insight`

- **Purpose:** Implements the AI Insight Service. Generates an AI Decision Card / AI Insight for one subscription or the full Decision Workspace batch.
- **Auth:** Required. Caller must own the subscription(s) requested.
- **Request:** `{ "subscription_id": "uuid" }` or `{ "scope": "workspace" }`
- **Behavior:** Loads subscription metadata, renewal schedule, billing frequency, lifecycle status, shared status (per AI Information Flow, doc 03). Calls OpenAI. Writes result to `ai_recommendations` using the service role key. Creates an `audit_logs` entry.
- **Response:** `{ "recommendation": "...", "reason": "...", "financial_impact": {...} }`
- **Never:** writes to `subscriptions`, `shared_subscriptions`, or any table other than `ai_recommendations` and `audit_logs` — this is the literal enforcement point for BR-001 and GP-002.
- **Errors:** `AI_001` provider timeout, `AI_002` invalid subscription ownership, `AI_003` generation failed (fallback: Decision Workspace shows a neutral "insight unavailable" state, never a blocking error).

### 5.2 `POST /functions/v1/send-reminder-email` (scheduled)

- **Purpose:** Implements the Notification Service for renewal reminders. Invoked by Supabase Scheduled Functions (cron) evaluating `reminders` due today.
- **Auth:** Service-role only; not callable by the frontend directly. Developer/Test Utilities call it through 5.4 instead.
- **Behavior:** Selects due reminders, renders the matching `notification_templates` row, calls Resend, writes `notifications` (delivery status) and `reminder_history` (append-only, immutable per doc 10).
- **Idempotency:** keyed on `reminder_id` + scheduled date, so a retried cron run cannot double-send.
- **Errors:** `NOTIF_001` template missing, `NOTIF_002` provider delivery failure (retried up to 3 times, then logged to `audit_logs`).

### 5.3 `POST /functions/v1/send-shared-payment-reminder`

- **Purpose:** User-triggered variant of 5.2 for a specific `payment_requests` row (Shared Subscriptions "Send Reminder" action).
- **Auth:** Required. Caller must own the parent `shared_subscriptions` row.
- **Request:** `{ "payment_request_id": "uuid" }`
- **Behavior/Errors:** same as 5.2, scoped to one request.

### 5.4 `POST /functions/v1/dev-trigger`

- **Purpose:** Single restricted entry point behind Developer/Test Utilities that invokes 5.1, 5.2, or a Razorpay test transaction on demand, for capstone validation.
- **Auth:** Required, and gated by the Developer/Test Utilities route protection defined in `03_Information_Architecture_v1.2`.
- **Request:** `{ "action": "send_reminder_now" | "test_ai" | "test_email" | "test_payment", "target_id": "uuid" }`
- **Rule:** exposes no secrets in its response; returns only status and the same payload shape the real flow would produce.

### 5.5 `POST /functions/v1/razorpay-create-order`

- **Purpose:** Implements the Billing Service order-creation step for the premium demonstration flow.
- **Auth:** Required.
- **Behavior:** Creates a Razorpay Test Mode order for the selected `premium_plans` row. Returns the order id and test-mode client key needed for Razorpay's checkout widget. Never returns the Razorpay secret key.
- **Response:** `{ "order_id": "...", "amount": ..., "currency": "INR", "key_id": "test_..." }`

### 5.6 `POST /functions/v1/razorpay-verify-payment`

- **Purpose:** Implements payment verification. Called after the Razorpay Test Mode checkout completes client-side.
- **Auth:** Required.
- **Request:** `{ "razorpay_order_id": "...", "razorpay_payment_id": "...", "razorpay_signature": "..." }`
- **Behavior:** Verifies the signature server-side against the Razorpay secret (never sent to the client). On success, writes `payment_transactions` and sets `user_profiles.is_premium = true`, `premium_expires_at`, and `premium_source = 'razorpay_test_mode'` (DEC-038 — the single premium entitlement source of truth; no other table stores current entitlement state). On failure, writes a failed transaction record and returns a user-safe error.
- **Idempotency:** keyed on `razorpay_payment_id` — a duplicate verification call for an already-verified payment returns the existing result rather than double-crediting premium status.
- **Errors:** `PAY_001` signature mismatch, `PAY_002` order not found, `PAY_003` already verified (idempotent success, not an error to the user).

## 6. Provider Integration Contracts

| Provider | Reached By | Reads | Writes | Never |
| --- | --- | --- | --- | --- |
| OpenAI | 5.1 only | Subscription/renewal context | `ai_recommendations` | Never touches `subscriptions` or any business-state table |
| Resend | 5.2, 5.3 only | Notification request + template | `notifications`, `reminder_history` | Never creates reminders itself |
| Razorpay | 5.5, 5.6 only | Plan, order, signature | `payment_transactions` | Never processes live payment in MVP; Test Mode only |
| Google OAuth | Supabase Auth (native) | — | `auth.users`, cascades via trigger to `users`/`user_profiles`/`user_preferences` | — |

This table is the literal implementation of DEC-016 and DEC-017: three providers, three narrow entry points, zero frontend exposure.

## 7. Error Catalogue

Standard error object (matches `12_Backend_Architecture_v1.0`):

```json
{ "success": false, "error": { "code": "SUB_001", "message": "Validation failed" } }
```

| Code Family | Meaning |
| --- | --- |
| `AUTH_xxx` | Session/authorization failures (Path A surfaces these as native Supabase auth errors) |
| `SUB_xxx` | Subscription validation (name required, cost positive, currency INR/USD, valid billing frequency, valid payment_method) |
| `SHR_xxx` | Sharing/member/payment-request validation |
| `AI_xxx` | AI generation failures (5.1) |
| `NOTIF_xxx` | Email delivery failures (5.2, 5.3) |
| `PAY_xxx` | Payment verification failures (5.5, 5.6) |

## 8. Traceability

Requirement → Table/Function → Enforcement Mechanism → Test Case (per `14_Testing_Strategy_v1.1`):

| Requirement | Table/Function | Enforcement | Test |
| --- | --- | --- | --- |
| BR-001 AI never acts for user | `ai-generate-insight` | Service-role write scope limited to `ai_recommendations` only | AI boundary test |
| BR-002 Auth required for data | All Path A tables | RLS | Auth/RLS tests |
| BR-006/BR-007 Profile provisioning | `handle_new_user()` trigger | Database transaction, single execution | Onboarding tests |
| DEC-016 No direct provider access | All Edge Functions | Frontend has no provider keys; only Edge Functions do | Frontend integration tests |
| Shared payment history preserved | `shared_members` soft-remove | RLS + `archived_at`, never hard delete | Sharing regression tests |

## 9. Validation Checklist

| Check | Status |
| --- | --- |
| Access architecture decision recorded | Complete |
| Path A resource catalogue defined | Complete |
| Path B function catalogue defined | Complete |
| Provider contracts defined | Complete |
| Error catalogue defined | Complete |
| Traceability to business rules defined | Complete |
| Consistency with docs 00-10, 12-16 verified | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 (draft) | Superseded | Placeholder skeleton, no real contract. |
| v1.0 | Current | Real, buildable API contract under Lean Access Architecture (DEC-031), fully traced to existing frozen documents 00-10 and 12-16. Reconciled `payment_requests` permissions with `10_Database_Architecture_v1.1`'s Table Security Matrix (DEC-037), pointed premium-status writes at the `user_profiles` entitlement fields (DEC-038), and defined the generation mechanism and timezone/archive handling for all six reminder types (DEC-039). Updated cross-references to `10_Database_Architecture_v1.1` and `01_Product_Strategy_v1.3`. |
