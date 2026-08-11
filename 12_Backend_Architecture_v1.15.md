# 12 Backend Architecture v1.15

## Document Control

| Field | Value |
| --- | --- |
| Document ID | BE-001 |
| Product | SubSense |
| Version | v1.15 |
| Status | Frozen implementation baseline |
| Source of Truth | Backend services, business logic, jobs, and provider orchestration |
| Depends On | 10_Database_Architecture_v1.22, 11_API_Integration_Architecture_v1.14 |

## Purpose

This document defines how SubSense backend behavior is organized. It covers service boundaries, transaction ownership, repository access, background jobs, provider abstraction, security responsibilities, and operational behavior.

## Backend Philosophy

Per DEC-031 (Lean Access Architecture), "backend" in SubSense means two things, not one uniform pipeline:

- For Path A (user-owned CRUD on `subscriptions`, `shared_subscriptions`, `shared_members`, `payment_requests`, `user_profiles`, `user_preferences`, and reads of catalog/reminders/notifications/AI output), the "backend" is Supabase itself: RLS policies plus database triggers/functions (`calculate_subscription_equivalents()`, `generate_default_reminders()`, `handle_new_user()`) enforce the business rules that a Service/Repository layer would otherwise own. No custom API, Service, or Repository code is written for these operations.
- For Path B (anything secret-bearing, scheduled, or writing to system-owned tables), the backend is the layered model described in this document: API Handlers, Services, Repositories, and Provider Clients, as detailed below.

This document defines the Path B architecture in full. It mediates:

- External provider calls (OpenAI, Resend, Razorpay).
- AI generation.
- Email delivery.
- Razorpay Test Mode verification.
- Reminder delivery and Path B row generation for the day-granularity reminder types (see Reminder Service below).
- Audit logging.
- Writes to `ai_recommendations`, `notifications`, `reminder_history`, `audit_logs`, `payment_transactions`.

The frontend never directly accesses external providers or service-role credentials, on either path.

## Backend Layer Model

Standard dependency direction (Path B only):

API -> Services -> Repositories -> Supabase

Path A bypasses this stack entirely by design — see Backend Philosophy above and `11_API_Integration_Architecture_v1.14` Section 1 for the full Path A/Path B assignment rule.

**Note on the 11/12 mutual dependency:** this document's Depends On field cites 11, and 11's Depends On field cites this document back. That is intentional, not a circular build-order error — this document's Standard Response Contract (below) defines the envelope and error-object format that 11 requires (11 Sections 2 and 7), while this document depends on 11's Section 1 routing rule to know what counts as Path A versus Path B in the first place. The two documents co-define a shared contract rather than one strictly preceding the other. See the corresponding note in 11 and the corrected Architecture Integrity Review in 09.

Forbidden dependencies:

- Repository -> Service.
- Repository -> API.
- Service -> API.
- Database -> Service callback.

## Backend Layers

| Layer | Responsibility |
| --- | --- |
| API Handlers | Authenticated request handling, validation, response envelope |
| Services | Business logic and transaction boundaries |
| Repositories | Supabase data access |
| Provider Clients | OpenAI, Resend, Razorpay communication |
| Jobs | Scheduled/background execution using services |
| Audit | Event logging and traceability |

## Service Ownership

| Service | Responsibility |
| --- | --- |
| Auth/Profile Service | User profile provisioning and preference loading |
| Subscription Service | Subscription CRUD, lifecycle, cost calculations |
| Catalog Service | Catalog lookup and custom subscription handling |
| Reminder Service | Two Supabase Cron jobs, platform and split formalized under DEC-068: hourly delivery of due reminders (`send-reminder-email`, `WHERE status = 'pending' AND scheduled_for <= now()`), and daily row generation for the three day-granularity types that need a schedule rather than a table trigger (`generate-scheduled-reminders`, covering `post_renewal_checkin`, `monthly_digest`, `lapsed_reengagement`) — see `11_API_Integration_Architecture_v1.14` Sections 4-5 for full behavior. Row generation for the 7-day/2-day/renewal-day set remains a Path A database trigger (`generate_default_reminders()`), not backend service code. Reliability is handled entirely by query design (the `<= now()` catch-up comparison, and never marking `sent` until Resend confirms) rather than a dedicated retry/alerting system — active cron-failure monitoring is deferred past MVP. |
| AI Insight Service | AI recommendation generation and persistence |
| Notification Service | Email request creation and delivery tracking |
| Sharing Service | Shared subscriptions, members, payment requests |
| Billing Service | Razorpay Test Mode flow and premium status demonstration |
| Audit Service | Append-only audit log creation |

## Transaction Boundary Standard

Every backend service owns its database transaction.

Rules:

- One service equals one transaction boundary.
- Cross-service communication occurs after the transaction commits.
- External provider calls never execute inside database transactions.
- Provider failures must not leave partially committed business state.

## Repository Standard

Repositories:

- Encapsulate Supabase queries.
- Enforce table-specific access patterns.
- Do not contain business decisions.
- Do not call external providers.
- Do not call services.

Services:

- Enforce business rules.
- Compose repositories.
- Decide workflow transitions.
- Create audit events.

## Background Job Isolation

Scheduled and background processes use the same service layer as API requests.

Examples:

- Reminder execution.
- AI generation.
- Email retries.
- Payment verification.

Jobs must never bypass business services or write directly to repositories.

## External Provider Boundaries

### OpenAI

Reads:

- Subscription context.
- Renewal context.
- User preferences.

Writes:

- AI recommendation or AI insight record.

Never:

- Updates subscriptions.
- Cancels, renews, or charges.

### Resend

Reads:

- Notification request.
- Notification template.

Writes:

- Delivery result and notification status.

Never:

- Creates reminders.
- Changes business entities.

### Razorpay Test Mode

Reads:

- Premium plan.
- Transaction request.

Writes:

- Payment verification or test transaction status.

Never:

- Updates subscription data.
- Processes live payments in MVP.

## Business Rules Enforcement

Backend services enforce:

- BR-001: AI never performs user actions.
- BR-002: Auth required for subscription data.
- BR-006: First login provisions profile.
- BR-007: Returning users do not create duplicate profiles.
- BR-008: Auth completes before user-specific data loads.

## Standard Response Contract

The API document defines the canonical response envelope. Backend handlers must follow it.

Typical success shape:

```json
{
  "success": true,
  "data": {},
  "meta": {}
}
```

Typical error shape:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "User-safe error message"
  }
}
```

## Idempotency Standard

Idempotency is required for operations where duplicate requests could create duplicate business effects.

Examples:

- Payment verification.
- Reminder send.
- Email delivery retry.
- Subscription creation retries where supported.

## Error Ownership

| Layer | Responsibility |
| --- | --- |
| Frontend | User-friendly presentation |
| API Handler | Request validation and auth checks |
| Service | Business validation |
| Repository | Data access errors |
| Provider Client | Provider-specific error normalization |

## Security Responsibilities

Backend must:

- Validate JWTs.
- Protect service role credentials.
- Keep provider secrets server-side.
- Enforce authorization before business actions.
- Respect RLS.
- Avoid logging sensitive data.
- Create audit events for meaningful changes.

## Logging and Audit

Audit events should be created for:

- Authentication provisioning.
- Subscription creation/update/archive.
- Shared member/payment changes.
- Reminder execution.
- AI generation.
- Email delivery failure.
- Payment verification.
- Security-sensitive failures.

## Backend Validation Checklist

| Check | Status |
| --- | --- |
| Dependency direction defined | Complete |
| Service ownership defined | Complete |
| Transaction boundary standard defined | Complete |
| Background job isolation defined | Complete |
| Provider boundaries defined | Complete |
| Business rule enforcement defined | Complete |
| Security responsibilities defined | Complete |
| API document dependency noted | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Backend architecture frozen after IR-004 and IR-009. Amended per DEC-035 to reconcile with Lean Access Architecture (DEC-031): clarified that Path A user-owned CRUD bypasses the Services/Repositories stack entirely (RLS and database triggers are the enforcement layer), and that this document's layered model governs Path B only. Updated Reminder Service ownership to reflect the Path A generation trigger versus Path B delivery split (DEC-039). |
| v1.1 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 10_Database_Architecture_v1.3 and 11_API_Integration_Architecture_v1.1, and the Backend Layer Model's cross-reference to document 11 Section 1, as part of the cascade patching 11's own internal reference-integrity gaps. First version bump since Implementation Freeze. |
| v1.2 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 10_Database_Architecture_v1.4 and 11_API_Integration_Architecture_v1.2; added a note to the Backend Layer Model clarifying that the mutual Depends On relationship with 11 is intentional (11 needs this document's Standard Response Contract; this document needs 11's Path A/Path B routing rule), not a circular build-order dependency. Corresponding note added to 11 and the Architecture Integrity Review corrected in 09. |
| v1.3 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 10_Database_Architecture_v1.5 and 11_API_Integration_Architecture_v1.3, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). |
| v1.4 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 10_Database_Architecture_v1.7 and 11_API_Integration_Architecture_v1.4, as part of the cascade recording DEC-047, batched with the notification-template SQL patch (file 23). |
| v1.5 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 11_API_Integration_Architecture_v1.5, as part of the cascade recording DEC-053 (Lovable to Cursor tooling change). No backend service, job, or provider-orchestration content changed. |
| v1.6 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 11_API_Integration_Architecture_v1.6, as 11 continued to move within the same DEC-053 cascade. No backend service, job, or provider-orchestration content changed. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and the Path A/B routing-rule body cross-reference to 11_API_Integration_Architecture_v1.7, its now-settled final version in this cascade. No backend service, job, or provider-orchestration content changed. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 10_Database_Architecture_v1.8, as 10 moved again within the same DEC-053 cascade. No backend service, job, or provider-orchestration content changed. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and the Path A/B routing-rule body cross-reference to 10_Database_Architecture_v1.9 and 11_API_Integration_Architecture_v1.8, closing drift deliberately deferred since the DEC-054 pass. No backend service, job, or provider-orchestration content changed. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and the Path A/B routing-rule body cross-reference to 10_Database_Architecture_v1.10 and 11_API_Integration_Architecture_v1.9, following DEC-055 (logo wordmark font resolved, logo formally implemented). No backend service, job, or provider-orchestration content changed. |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 10_Database_Architecture_v1.11, as part of the cascade recording DEC-059 (subscription cards no longer render a real per-service brand logo). No backend service, job, or provider-orchestration content changed — this decision is frontend/data-only. |
| v1.12 | Frozen | Recorded DEC-068: completed the Reminder Service row, which previously only described the delivery half (`send-reminder-email`, Path B, tied to DEC-039) with no platform or cadence named and no mention of who generates `post_renewal_checkin`/`monthly_digest`/`lapsed_reengagement`. Now names both Supabase Cron jobs explicitly (hourly `send-reminder-email`; daily `generate-scheduled-reminders`) and states the reliability approach (query-design catch-up and confirm-before-sent, no dedicated retry/alerting system at MVP). Updated the Path A/B routing-rule cross-reference and the dependency reference to 11_API_Integration_Architecture_v1.10, and the dependency reference to 10_Database_Architecture_v1.12. No other backend service, job, or provider-orchestration content changed. **Correction (DEC-069 cascade — reminders CHECK constraint loosening, new audit_action enum value):** the dependency reference to 10_Database_Architecture updated to v1.13. Not bumping the version again for this. **Further correction (DEC-070 cascade — reminder lifecycle fix):** the dependency reference to 10_Database_Architecture updated to v1.14. Not bumping the version again for this either. **Further correction (DEC-071 cascade — post_renewal_checkin paused-exclusion fix):** the dependency reference to 10_Database_Architecture updated to v1.15. Not bumping the version again for this either. **Further correction (DEC-079 same-day extension — Phase 7 implementation planning):** the dependency reference and the two body cross-references (Path A/B routing rule, Reminder Service row) updated to 11_API_Integration_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-080 cascade and same-day extension — Phase 8 Shared Subscriptions architecture, plus the member-join generation trigger/nullable-user_id/rounding-remainder/RLS-gap technical-planning gaps):** the dependency reference to 10_Database_Architecture updated to v1.17. Not bumping the version again for this either. **Further correction (DEC-080 live-testing extension):** the dependency reference to 10_Database_Architecture updated to v1.18. Not bumping the version again for this either. **Further correction (DEC-081/082 cascade — Phase 8 closed out: Phase 6 Cron/JWT-gateway regression found and fixed, plus premium feature-gating decided for AI Insights):** the dependency reference to 10_Database_Architecture updated to v1.19. Not bumping the version again for this either. |
| v1.14 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field and the Path A/B routing-rule and Reminder Service body cross-references to 10_Database_Architecture_v1.21 and 11_API_Integration_Architecture_v1.13, as part of the cascade recording DEC-085 (currency-drop fix, Cost Comparison Card rename). No other backend service, job, or provider-orchestration content changed. |
| v1.15 | Current | Housekeeping pass, not tied to a new DEC: updated the Depends On field and the Path A/B routing-rule and Reminder Service body cross-references to 10_Database_Architecture_v1.22 and 11_API_Integration_Architecture_v1.14, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No other backend service, job, or provider-orchestration content changed. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field and the Path A/B routing-rule and Reminder Service body cross-references to 10_Database_Architecture_v1.20 and 11_API_Integration_Architecture_v1.12, as part of the cascade recording DEC-083 (Phase 9+10 built and deployed — Razorpay order-creation/verification Edge Functions and the new insights-generate-summary function, all Path B). No other backend service, job, or provider-orchestration content changed. |
