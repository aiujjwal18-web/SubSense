# 16 Implementation Roadmap v1.0

## Document Control

| Field | Value |
| --- | --- |
| Document ID | ROAD-001 |
| Product | SubSense |
| Version | v1.0 |
| Status | Frozen implementation baseline |
| Source of Truth | Development sequence and implementation handoff |
| Depends On | 00 through 15, including external 11_API_Integration_Architecture_v1.0 |

## Purpose

This document defines the recommended implementation sequence for SubSense after architecture and implementation readiness are frozen.

It is designed for Lovable, Supabase, and supporting backend/API implementation.

## Implementation Principles

- Build against frozen documentation.
- Preserve user control and AI boundaries.
- Implement foundation before feature surfaces.
- Validate each layer before building dependent layers.
- Avoid scope expansion during MVP build.
- Use document 11 for API and integration contracts.
- Use Developer/Test Utilities only for validation and capstone demonstration.

## Required Documentation Set

The full implementation package consists of 17 documents:

| Number | Document | Status |
| --- | --- | --- |
| 00 | Project Governance | Generated |
| 01 | Product Strategy | Generated |
| 02 | Experience Strategy | Generated |
| 03 | Information Architecture | Generated |
| 04 | Experience Blueprint | Generated |
| 05 | Design System | Generated |
| 06 | Component Library | Generated |
| 07 | Product Architecture | Generated |
| 08 | Decision Log | Generated |
| 09 | Implementation Readiness | Generated |
| 10 | Database Architecture | Generated |
| 11 | API Integration Architecture | Existing user document |
| 12 | Backend Architecture | Generated |
| 13 | Frontend Architecture | Generated |
| 14 | Testing Strategy | Generated |
| 15 | Deployment Architecture | Generated |
| 16 | Implementation Roadmap | Generated |

## Recommended Build Phases

### Phase 0: Repository and Environment Setup

Goals:

- Initialize repository structure.
- Configure Supabase project.
- Configure environment variables.
- Prepare GitHub source control.
- Prepare deployment target.

Deliverables:

- Repo scaffold.
- Environment variable register.
- Supabase project.
- Vercel/Lovable setup.
- Development and staging configuration.

### Phase 1: Database Foundation

Goals:

- Implement database schema.
- Add ENUMs.
- Create identity, master data, business data, and system data tables.
- Enable RLS.
- Seed initial catalog data.

Deliverables:

- Migrations.
- RLS policies.
- Seed scripts.
- Validation queries.

Dependencies:

- `10_Database_Architecture_v1.0.md`.

### Phase 2: Authentication and Profile

Goals:

- Implement Google Sign-In.
- Create first-login provisioning.
- Load profile and preferences.
- Protect authenticated routes.

Deliverables:

- Auth flow.
- Profile initialization.
- User preferences.
- Protected route behavior.

Critical rules:

- BR-002.
- BR-006.
- BR-007.
- BR-008.

### Phase 3: App Shell and Navigation

Goals:

- Build authenticated app shell.
- Implement header.
- Implement sidebar.
- Implement responsive navigation.
- Route to primary modules.

Deliverables:

- Global Header.
- Sidebar Navigation.
- Profile menu.
- App layout.

Dependencies:

- `03_Information_Architecture_v1.2.md`.
- `05_Design_System_v1.2.md`.
- `06_Component_Library_v1.2.md`.

### Phase 4: Subscription Management

Goals:

- Implement My Subscriptions.
- Implement Add Subscription.
- Implement Subscription Details.
- Implement View -> Edit.
- Implement archive behavior.
- Implement annual cost preview.

Deliverables:

- Subscription CRUD.
- Catalog search.
- Custom subscription entry.
- Annual cost calculations.
- Lifecycle status.

Acceptance:

- User can add a subscription.
- Subscription appears in My Subscriptions.
- Subscription can be reviewed and edited.
- Archive removes it from active views without destroying history.

### Phase 5: Decision Workspace

Goals:

- Build the primary product home.
- Show today's financial context.
- Show upcoming renewals.
- Show the initial AI insight state and then real AI output once backend integration is ready.
- Show shared activity preview.

Deliverables:

- Decision Workspace.
- AI Decision Card.
- Renewal List.
- Financial Context.
- Empty/healthy states.

Acceptance:

- User understands the screen purpose within five seconds.
- No provider-control action appears here.

### Phase 6: Reminder Engine and Notifications

Goals:

- Implement reminder scheduling/evaluation.
- Implement email sending through Resend.
- Record notification status.
- Record reminder history.
- Implement Send Reminder Now in Developer/Test Utilities.

Deliverables:

- Reminder service.
- Notification service.
- Email templates.
- Reminder history.
- Developer test action.

Dependencies:

- Backend architecture.
- API document 11.

### Phase 7: AI Decision Support

Goals:

- Generate AI insights using OpenAI.
- Store AI recommendation records.
- Present AI guidance in Decision Workspace and Subscription Details.
- Preserve AI boundary.

Deliverables:

- AI Insight service.
- AI recommendation persistence.
- AI UI states.
- AI failure handling.

Acceptance:

- AI explains recommendations.
- AI does not modify subscription state.
- AI output remains user-owned decision support.

### Phase 8: Shared Subscriptions

Goals:

- Implement shared subscription workflows.
- Add/edit/remove shared members.
- Track amount owed.
- Track paid/pending status.
- Send split reminders.

Deliverables:

- Shared Subscriptions module.
- Shared member management.
- Payment request status.
- Reminder email integration.

Acceptance:

- Payment history is preserved when a member is removed from active split.

### Phase 9: Insights

Goals:

- Implement spend summaries.
- Show monthly and annual spend.
- Show category breakdown.
- Show savings opportunities where available.
- Summarize AI insights.

Deliverables:

- Insights page.
- Spending summary.
- Financial reports.
- AI insight summary.

### Phase 9.5: Mid-Build Stress Test Checkpoint (Week 3)

Goals:

- Verify RLS boundaries, Edge Function auth boundaries, accessibility, and demo-critical load paths before building the remaining lower-risk phases.

Deliverables:

- Checkpoint results against the criteria in `14_Testing_Strategy_v1.1`.
- Defect log for anything failed, resolved before Phase 10 begins.

Dependencies:

- Phases 1-9 complete (core CRUD, sharing, reminders, AI insight, Insights).

Rationale:

- Per DEC-033, this runs mid-build rather than only inside Phase 12, so defects are caught with runway left to fix them, not at the deadline.

### Phase 10: Premium Demonstration

Goals:

- Implement Razorpay Test Mode premium demonstration.
- Store payment transaction.
- Reflect premium demonstration status.
- Validate through Developer/Test Utilities.

Deliverables:

- Test payment flow.
- Payment transaction record.
- Premium status UI.

Restrictions:

- No live payment processing in MVP.

### Phase 11: Developer/Test Utilities

Goals:

- Centralize validation tools.
- Support capstone demonstration.

Utilities:

- Send Reminder Now.
- Test AI Response.
- Test Email Payload.
- Test Razorpay Payment.
- View integration status.

Restrictions:

- Authenticated and protected.
- No secrets exposed.
- Not normal end-user navigation.

### Phase 12: Testing and QA

Goals:

- Execute business-first testing strategy.
- Validate RTM coverage.
- Run E2E flows.
- Run security and RLS checks.
- Run accessibility checks.

Deliverables:

- Test results.
- Defect log.
- UAT sign-off.
- Release checklist.

Dependencies:

- `14_Testing_Strategy_v1.0.md`.

### Phase 13: Deployment

Goals:

- Deploy to staging.
- Validate environment configuration.
- Run smoke tests.
- Deploy to production after approval.

Deliverables:

- Staging deployment.
- Production deployment.
- Deployment verification checklist.
- Rollback plan.

Dependencies:

- `15_Deployment_Architecture_v1.0.md`.

## MVP Acceptance Checklist

| Capability | Required |
| --- | --- |
| Google authentication | Yes |
| Profile provisioning | Yes |
| Add subscription | Yes |
| Subscription list | Yes |
| Subscription details | Yes |
| Annual cost calculation | Yes |
| Decision Workspace | Yes |
| AI insight | Yes |
| Renewal reminder | Yes |
| Email delivery | Yes |
| Shared subscription | Yes |
| Payment request status | Yes |
| Insights | Yes |
| Razorpay Test Mode demo | Yes |
| Developer/Test Utilities | Yes |
| RLS validation | Yes |
| Deployment verification | Yes |

## Implementation Risks

| Risk | Mitigation |
| --- | --- |
| Scope expansion | Follow MVP scope and change control |
| API ambiguity | Use document 11 as source of truth |
| RLS mistakes | Test owner/member/admin access paths |
| AI overreach | Enforce BR-001 in backend and frontend copy |
| Email deliverability | Use Resend test and delivery logs |
| Payment confusion | Label Razorpay as Test Mode |
| Data duplication | Follow single ownership standards |
| UI inconsistency | Use Design System and Component Library |
| Defects found too late to fix | Phase 9.5 Mid-Build Stress Test Checkpoint (Week 3) surfaces RLS, auth, accessibility, and load issues with runway remaining |

## Recommended Development Order Summary

1. Environment setup.
2. Database schema and RLS.
3. Authentication and profile.
4. App shell and navigation.
5. Subscription management.
6. Decision Workspace.
7. Reminders and notifications.
8. AI decision support.
9. Shared subscriptions.
10. Insights.
10.5. Mid-Build Stress Test Checkpoint (Week 3).
11. Premium Test Mode.
12. Developer/Test Utilities.
13. Testing.
14. Deployment.

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Implementation roadmap generated from frozen architecture and IR-009 baseline. |
| v1.1 | Current | Inserted Phase 9.5 Mid-Build Stress Test Checkpoint (Week 3) per DEC-033. |
