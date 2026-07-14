# 14 Testing Strategy v1.1

## Document Control

| Field | Value |
| --- | --- |
| Document ID | TEST-001 |
| Product | SubSense |
| Version | v1.1 |
| Status | Frozen implementation baseline |
| Source of Truth | Testing architecture and release quality gates |
| Depends On | 09_Implementation_Readiness_v1.0, 10_Database_Architecture_v1.1, 11_API_Integration_Architecture_v1.0, 12_Backend_Architecture_v1.0, 13_Frontend_Architecture_v1.0 |

## Purpose

This document defines how SubSense will be validated before release. It verifies that the frozen product, UX, database, backend, frontend, integration, security, and deployment decisions behave correctly after implementation.

## Testing Philosophy

SubSense follows a business-first testing pyramid:

User Acceptance

-> End-to-End Business Flows

-> Integration and Service Tests

-> Component and API Contract Tests

-> Unit and Utility Tests

Testing is not only about code correctness. It is about confirming that the frozen architecture works as a product.

## Testing Layers

| Layer | Purpose |
| --- | --- |
| Unit | Validate isolated business logic and utilities |
| Component | Validate reusable frontend components |
| API Contract | Verify request/response standards from document 11 |
| Integration | Validate interaction between modules and providers |
| End-to-End | Validate complete user journeys |
| User Acceptance | Validate product behavior against the frozen baseline |

## Requirements Traceability Matrix

Every approved architectural decision, business rule, and user flow must trace to one or more test cases.

Mandatory chain:

Architecture Decision -> Business Rule -> User Flow -> Test Case -> Test Result

Example:

| Requirement | Rule | Flow | Test |
| --- | --- | --- | --- |
| Auth required for user data | BR-002 | Onboarding, protected routes | Auth and RLS tests |
| AI never acts for user | BR-001 | AI Recommendation | AI boundary tests |
| Returning user avoids duplicate profile | BR-007 | User Onboarding | Onboarding regression |
| Frontend never calls providers directly | DEC-016 | AI, Email, Payment | Frontend integration tests |

## Test Coverage Areas

### Product Flows

- User onboarding.
- Add first subscription.
- Review existing subscription.
- Shared subscription management.
- Reminder lifecycle.
- AI recommendation.
- Premium demonstration.
- Account management.

### Database

- Schema constraints.
- Foreign keys.
- ENUM values.
- Soft delete behavior.
- RLS policies.
- Migration execution.
- Seed data.

### API and Integrations

Covered by the completed API document:

- Standard response envelope.
- Authentication requirements.
- Error structure.
- Idempotency.
- Provider boundaries.
- Rate/error handling where applicable.

### Backend

- Service transaction boundaries.
- Repository access patterns.
- Background job behavior.
- Provider client isolation.
- Audit logging.
- Business rule enforcement.

### Frontend

- Routing.
- Protected routes.
- Loading/empty/success/error states.
- Component rendering.
- View -> Edit behavior.
- Form validation.
- Responsive behavior.
- Accessibility.

### External Providers

- OpenAI AI insight generation.
- Resend email delivery.
- Razorpay Test Mode.
- Supabase Auth.
- Supabase database access.

## Quality Gate Standard

Implementation cannot progress between environments unless quality gates pass.

Minimum release gates:

| Gate | Requirement | Numeric Threshold |
| --- | --- | --- |
| Unit tests | Critical utility and business logic pass | 100 percent pass; at least 80 percent line coverage on Services and Postgres functions |
| Component tests | Reusable components behave as specified | 100 percent pass on Component Library items in active use |
| API contract tests | Critical API contracts pass | 100 percent pass on all Path B functions in `11_API_Integration_Architecture_v1.0` Section 5 |
| Integration tests | Critical flows pass | 100 percent pass on the 12 Critical E2E Test Scenarios below |
| E2E tests | Primary user journeys pass | 100 percent pass, 0 Critical defects, at most 1 open High defect with an approved workaround |
| Security tests | No unresolved Critical or High findings | 0 Critical, 0 High; RLS cross-user access denied on 100 percent of tables in the Table Security Matrix |
| Accessibility checks | Core flows meet accessibility expectations | 0 Critical/Serious findings (WCAG 2.1 AA) on Decision Workspace, Add Subscription, Subscription Details, Shared Subscriptions |
| Performance checks | Key screens meet agreed thresholds | Decision Workspace and My Subscriptions: p95 load under 3 seconds on a simulated 4G connection with 50 subscriptions seeded |
| Regression tests | No critical regression | 0 Critical, 0 High regressions versus the prior release build |

These thresholds are the frozen pass/fail bar referenced by the MVP Success Metrics in `01_Product_Strategy_v1.3` (DEC-040); they may only change through change control, not implementation convenience.

## Test Automation Ownership

| Test Type | Execution |
| --- | --- |
| Unit | Automated |
| Component | Automated |
| API Contract | Automated |
| Integration | Automated |
| End-to-End | Automated plus manual exploratory support |
| User Acceptance | Manual |

## Non-Functional Validation

Implementation sign-off requires validation of:

- Performance.
- Security.
- Reliability.
- Accessibility.
- Recoverability.
- Scalability.

## Mid-Build Stress Test Checkpoint (Week 3)

Per DEC-033, a dedicated stress-test pass runs at week 3 of implementation — after core CRUD, sharing, reminders, and AI insight are built (Roadmap Phases 1-9), before Premium Demonstration and Developer/Test Utilities (Phases 10-11). This checkpoint exists specifically so defects are found with time left to fix them, rather than surfacing during final QA (Phase 12) with no runway remaining.

Checkpoint scope:

| Area | What is verified |
| --- | --- |
| RLS boundary | Attempt cross-user reads/writes on every table in the Table Security Matrix; confirm all are denied |
| Edge Function auth | Call each Path B function (`11_API_Integration_Architecture_v1.0`) with a missing, expired, and foreign-user JWT; confirm rejection |
| Accessibility | Run the Accessibility Experience Requirements checklist (`02_Experience_Strategy_v1.2`) against every primary screen: keyboard navigation, focus states, screen-reader labels, non-color-only status |
| Load path check | Exercise the AI Decision Card and reminder-email path 50 consecutive times against seeded test data. Pass bar: at least 95 percent success rate, p95 response time under 5 seconds for `ai-generate-insight`, under 10 seconds end-to-end for a `send-reminder-email` batch of 20 due reminders, and 0 duplicate sends (idempotency holds under retry) |
| Reminder timezone/edge case check | Seed reminders with `timezone_snapshot` values spanning at least 3 offsets (e.g. `Asia/Kolkata`, `America/New_York`, `UTC`) plus one archived subscription; confirm the due-today cron selects the correct rows in each timezone and skips the archived one, per DEC-039 |

A failed checkpoint item is treated as a blocking defect for Phase 10 onward, not a note for later.

## Test Environments

| Environment | Purpose |
| --- | --- |
| Local Development | Developer checks and debugging |
| Development | Feature validation |
| Staging | Integration, UAT, performance validation |
| Production | Live environment, smoke tests and monitoring |

Provider environments:

- Razorpay Test Mode.
- OpenAI development configuration.
- Resend test configuration.
- Supabase development/staging/production projects where available.

## Critical E2E Test Scenarios (12)

1. New user signs in with Google and reaches Decision Workspace.
2. User adds first subscription and sees it in My Subscriptions.
3. Annual cost preview calculates correctly.
4. User opens Subscription Details and edits through View -> Edit.
5. User archives a subscription and it leaves active views.
6. User adds shared member and sends reminder.
7. Reminder lifecycle creates notification and history.
8. AI insight is generated but does not modify subscription state.
9. Razorpay Test Mode transaction demonstrates premium status.
10. Protected routes block unauthenticated access.
11. Linked member self-reports a payment request as paid (`pending -> paid_pending_confirmation`); owner confirms it (`-> paid`); member cannot set `paid` directly and owner action is required to finalize (DEC-037).
12. Razorpay Test Mode transaction sets `user_profiles.is_premium` and `premium_expires_at`; a second verification call with the same `razorpay_payment_id` returns the existing result without double-crediting; premium state correctly reads as false once `premium_expires_at` has passed (DEC-038).

## Defect Severity

| Severity | Meaning |
| --- | --- |
| Critical | Blocks core flow, data security, payment demo, or deployment |
| High | Breaks major feature or creates misleading financial state |
| Medium | Partial feature failure with workaround |
| Low | Cosmetic or minor usability issue |

## Exit Criteria

Implementation is complete only when:

- Functional validation passes.
- Non-functional validation passes.
- Quality gates pass.
- No blocking defects remain.
- Business acceptance is achieved.
- Documentation is updated.

## Validation Checklist

| Check | Status |
| --- | --- |
| Testing pyramid defined | Complete |
| RTM standard defined | Complete |
| Quality gates defined | Complete |
| Automation ownership defined | Complete |
| Critical flows defined | Complete |
| Non-functional validation defined | Complete |
| Exit criteria defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Testing strategy frozen after IR-006 and IR-009. |
| v1.1 | Current | Added Mid-Build Stress Test Checkpoint (Week 3) per DEC-033. Corrected title/Document Control version to match filename (was misstated as v1.0) and updated dependency reference to 10_Database_Architecture_v1.1. Added numeric thresholds to all release gates and the Week 3 load-path check, added a reminder timezone/archive edge-case checkpoint item, and added E2E scenarios 11-12 covering the shared-payment permission model (DEC-037) and premium entitlement (DEC-038), per DEC-040. |
