# 03 Information Architecture v1.2

## Document Control

| Field | Value |
| --- | --- |
| Document ID | IA-001 |
| Product | SubSense |
| Version | v1.2 |
| Status | Frozen implementation baseline |
| Source of Truth | Product structure, navigation, and information ownership |
| Depends On | 00_Project_Governance_v1.2, 01_Product_Strategy_v1.2, 02_Experience_Strategy_v1.2 |

## Purpose

This document defines how SubSense information is organized. It owns module hierarchy, navigation hierarchy, screen hierarchy, data ownership, and structural relationships.

It does not define detailed UI styling or backend schema.

## Architecture Philosophy

SubSense uses:

- Decision-first structure.
- Workflow-first navigation.
- Progressive disclosure.
- Modular growth.
- Single ownership of information.

Users move through complete workflows rather than disconnected pages.

## Product Hierarchy

Root product:

- SubSense.

Primary authenticated modules:

- Decision Workspace.
- My Subscriptions.
- Shared Subscriptions.
- Insights.
- Profile.
- Developer/Test Utilities.

Authentication exists outside primary product navigation.

## Global Navigation

Primary navigation:

1. Decision Workspace.
2. My Subscriptions.
3. Shared Subscriptions.
4. Insights.
5. Profile.
6. Developer/Test Utilities, restricted.

Navigation rules:

- Decision Workspace is the default authenticated destination.
- My Subscriptions owns subscription browsing and management.
- Shared Subscriptions owns split-related workflows.
- Insights owns analytical and financial views.
- Profile owns account, preferences, and plan settings.
- Developer/Test Utilities are authentication-protected and not normal end-user navigation.

## Screen Hierarchy

### Authentication

- Landing or authentication entry.
- Google Sign-In.
- Email/password fallback where supported.
- Forgot password.
- Reset password.

### Decision Workspace

- Today's Financial Context.
- AI Insights.
- Upcoming Renewals.
- Recommended Reviews.
- Shared Payment Activity.
- Potential Savings.

### My Subscriptions

- Subscription list.
- Search.
- Filters.
- Sort.
- Add Subscription entry.
- Subscription cards.

### Add Subscription

- Catalog search.
- Custom subscription entry.
- Billing details.
- Renewal date.
- Annual cost preview.
- Save and validation states.

### Subscription Details

- Overview.
- Billing.
- Lifecycle status.
- Reminder context.
- AI Insight.
- Shared members.
- History.
- View -> Edit state.

### Shared Subscriptions

- Shared list.
- Shared subscription details.
- Members.
- Payment requests.
- Pending payments.
- Reminder actions.

### Insights

- Spending summary.
- Annual cost.
- Monthly trend.
- Category breakdown.
- AI insight summary.
- Savings opportunities.

### Profile

- Personal information.
- Google account.
- Currency.
- Time zone.
- Reminder preferences.
- Notification preferences.
- Security.
- Subscription plan.
- Sign out.

### Developer/Test Utilities

- Send Reminder Now.
- Test AI generation.
- Test email delivery.
- Razorpay Test Mode validation.
- View test payloads where appropriate.

## Screen Dependency Chain

Core dependency order:

Authentication -> Decision Workspace -> My Subscriptions -> Add Subscription -> Subscription Details -> Shared Subscriptions -> Insights

Profile and Developer/Test Utilities are supporting modules.

## User Journey Hierarchy

### Primary Journey

Login -> Decision Workspace -> Review Subscription -> Subscription Details -> Edit or Confirm -> Decision Workspace

### Subscription Creation Journey

Decision Workspace or My Subscriptions -> Add Subscription -> Save -> My Subscriptions -> Decision Workspace updates

### Shared Journey

Shared Subscriptions -> Add or edit member -> Send reminder -> Update payment status -> Shared history

### Reminder Journey

Subscription -> Renewal date -> Reminder schedule -> Email notification -> User action -> Reminder history

### AI Journey

Renewal context -> AI request -> AI insight -> User review -> User decision

### Premium Demonstration Journey

Profile or upgrade entry -> Razorpay Test Mode -> Payment transaction -> Premium status demonstration -> Developer/Test Utilities validation

## Information Ownership Matrix

| Information | Owner Module |
| --- | --- |
| Authentication state | Authentication |
| User profile | Profile |
| User preferences | Profile |
| Subscription cost | Subscription Details |
| Billing frequency | Subscription Details |
| Renewal date | Subscription Details |
| Renewal urgency | Decision Workspace and Subscription Details |
| Annual cost | Insights and Subscription Details where contextual |
| AI insight | Decision Workspace |
| AI recommendation history | AI Decision Support backend |
| Shared member status | Shared Subscriptions |
| Payment request | Shared Subscriptions |
| Notification delivery | Notification Service |
| Premium status | Billing/Profile |

Each information element has one source of truth.

## Data Relationship Model

Core relationships:

- User owns Profile and Preferences.
- User owns Subscriptions.
- Subscription may reference Subscription Catalog and Subscription Category.
- Subscription owns Reminder records.
- Reminder creates Reminder History.
- Subscription may have AI Recommendations.
- Subscription may have Shared Subscriptions.
- Shared Subscription owns Shared Members and Payment Requests.
- Notification records are created by service workflows.
- Payment Transactions relate to user and premium plan.
- Audit Logs observe significant events.

## AI Information Flow

AI reads:

- Subscription metadata.
- Renewal schedule.
- Billing frequency.
- Lifecycle status.
- Shared subscription status.
- User preferences where relevant.

AI writes:

- AI Recommendation or AI Insight records.

AI never owns:

- Subscription state.
- Payment status.
- Renewal confirmation.
- Shared payment status.

## Security Structure

Security layers:

Authentication -> Authorization -> Row Level Security -> Application Logic -> Database

Requirements:

- Users can access only their own data.
- Shared data access is explicitly linked through sharing relationships.
- Master data is read-only for authenticated users.
- Service role credentials never reach the frontend.

## Developer/Test Utilities Isolation

Developer/Test Utilities:

- Are authenticated.
- Are separated from normal user navigation.
- Are used for validation and capstone demonstration.
- Must not weaken production data or security boundaries.

## Future Module Expansion

Reserved future modules:

- Reports.
- Advanced analytics.
- Team or family workspace.
- Multi-language support.
- Mobile-specific flows.

These should follow the same ownership and dependency standards.

## Validation Checklist

| Check | Status |
| --- | --- |
| Navigation hierarchy defined | Complete |
| Screen hierarchy defined | Complete |
| Module ownership defined | Complete |
| Data ownership defined | Complete |
| AI information boundary defined | Complete |
| Security structure defined | Complete |
| Developer utilities isolated | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.1 | Frozen | Architecture Freeze information architecture. |
| v1.2 | Current | Implementation Freeze alignment and full documentation package mapping. |
