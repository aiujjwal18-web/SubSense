# 14 Testing Strategy v1.0

## Document Control

| Field | Value |
| --- | --- |
| Document ID | TEST-001 |
| Product | SubSense |
| Version | v1.0 |
| Status | Frozen implementation baseline |
| Source of Truth | Testing architecture and release quality gates |
| Depends On | 09_Implementation_Readiness_v1.0, 10_Database_Architecture_v1.0, 11_API_Integration_Architecture_v1.0, 12_Backend_Architecture_v1.0, 13_Frontend_Architecture_v1.0 |

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

| Gate | Requirement |
| --- | --- |
| Unit tests | Critical utility and business logic pass |
| Component tests | Reusable components behave as specified |
| API contract tests | Critical API contracts pass |
| Integration tests | Critical flows pass |
| E2E tests | Primary user journeys pass |
| Security tests | No unresolved Critical or High findings |
| Accessibility checks | Core flows meet accessibility expectations |
| Performance checks | Key screens meet agreed thresholds |
| Regression tests | No critical regression |

Final numerical thresholds may be refined during implementation, but the gates themselves are frozen.

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
| Load path check | Exercise the AI Decision Card and reminder-email path repeatedly to confirm no flakiness under repeated use, since these are the primary demo-critical flows |

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

## Critical E2E Test Scenarios

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
| v1.1 | Current | Added Mid-Build Stress Test Checkpoint (Week 3) per DEC-033. |
