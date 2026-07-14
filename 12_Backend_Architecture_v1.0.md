# 12 Backend Architecture v1.0

## Document Control

| Field | Value |
| --- | --- |
| Document ID | BE-001 |
| Product | SubSense |
| Version | v1.0 |
| Status | Frozen implementation baseline |
| Source of Truth | Backend services, business logic, jobs, and provider orchestration |
| Depends On | 10_Database_Architecture_v1.1, 11_API_Integration_Architecture_v1.0 |

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
- Reminder delivery (the cron-triggered send, not the initial row generation — see Reminder Service below).
- Audit logging.
- Writes to `ai_recommendations`, `notifications`, `reminder_history`, `audit_logs`, `payment_transactions`.

The frontend never directly accesses external providers or service-role credentials, on either path.

## Backend Layer Model

Standard dependency direction (Path B only):

API -> Services -> Repositories -> Supabase

Path A bypasses this stack entirely by design — see Backend Philosophy above and `11_API_Integration_Architecture_v1.0` Section 1 for the full Path A/Path B assignment rule.

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
| Reminder Service | Scheduled delivery of due reminders (Path B, `send-reminder-email`) and the Post-Renewal Check-In and archived-subscription exclusion rules per DEC-039. Row generation for the 7-day/2-day/renewal-day set is a Path A database trigger (`generate_default_reminders()`), not backend service code. |
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
| v1.0 | Current | Backend architecture frozen after IR-004 and IR-009. Amended per DEC-035 to reconcile with Lean Access Architecture (DEC-031): clarified that Path A user-owned CRUD bypasses the Services/Repositories stack entirely (RLS and database triggers are the enforcement layer), and that this document's layered model governs Path B only. Updated Reminder Service ownership to reflect the Path A generation trigger versus Path B delivery split (DEC-039). |
