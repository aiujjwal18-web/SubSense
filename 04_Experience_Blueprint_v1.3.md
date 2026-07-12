# 04 Experience Blueprint v1.2

## Document Control

| Field | Value |
| --- | --- |
| Document ID | SXB-001 |
| Product | SubSense |
| Version | v1.2 |
| Status | Frozen implementation baseline |
| Source of Truth | Screen and journey implementation guidance |
| Depends On | 00_Project_Governance_v1.2, 01_Product_Strategy_v1.2, 02_Experience_Strategy_v1.2, 03_Information_Architecture_v1.2 |

## Purpose

This document translates strategy and information architecture into screen-by-screen implementation guidance.

It answers: if a designer or Lovable starts tomorrow, exactly what experience should be built?

## Blueprint Philosophy

The blueprint is journey-first, not screen-ID-first. SubSense should be implemented around the user's natural flow:

Enter product -> Review today's priorities -> Browse subscriptions -> Add subscription -> Review subscription -> Edit subscription -> Manage shared subscriptions -> Review insights

Each journey step references one or more screen specifications.

## Blueprint Dependency Matrix

| Blueprint Area | Depends On |
| --- | --- |
| Decision Workspace | Governance, Product Strategy, Experience Strategy, Information Architecture |
| My Subscriptions | Decision Workspace, Subscription data |
| Add Subscription | My Subscriptions, Catalog, Design System |
| Subscription Details | My Subscriptions, Reminders, AI, Sharing |
| Shared Subscriptions | Subscription Details, Shared Members, Payment Requests |
| Insights | Subscription Data, AI Recommendations, Spending Calculations |
| Profile | Authentication, User Profile, Preferences |
| Developer/Test Utilities | API, Backend, Provider Integrations |

## Screen Responsibility Matrix

| Screen | Primary Question |
| --- | --- |
| Authentication | How do I securely enter SubSense? |
| Decision Workspace | What needs my attention today? |
| My Subscriptions | What subscriptions do I have? |
| Add Subscription | How do I add one quickly and correctly? |
| Subscription Details | Should I review this subscription before renewal? |
| Shared Subscriptions | Who owes what? |
| Insights | Where is my recurring money going? |
| Profile | How do I manage my account and preferences? |
| Developer/Test Utilities | How do I validate key integrations? |

## Standard Screen Specification Template

Each screen specification should include:

1. Purpose.
2. User question.
3. Entry points.
4. Exit points.
5. Components.
6. Data sources.
7. Actions.
8. Empty states.
9. Error states.
10. Responsive behavior.
11. Accessibility.
12. Dependencies.
13. Implementation notes.
14. Future enhancements, if any.

## Navigation Entry and Exit Matrix

| Screen | Enter From | Exit To |
| --- | --- | --- |
| Authentication | Public entry | Decision Workspace |
| Decision Workspace | Login, logo, sidebar | Subscription Details, My Subscriptions, Shared, Insights |
| My Subscriptions | Sidebar, Decision Workspace | Add Subscription, Subscription Details |
| Add Subscription | My Subscriptions, empty state CTA | My Subscriptions, Subscription Details |
| Subscription Details | My Subscriptions, Decision Workspace | Edit state, Shared, Insights |
| Shared Subscriptions | Sidebar, Subscription Details | Member details, Payment Request |
| Insights | Sidebar, Decision Workspace | Subscription Details |
| Profile | Header/Profile menu | Preferences, Sign out |
| Developer/Test Utilities | Restricted navigation | Test result views |

## Decision Workspace Blueprint

Purpose:

- Surface the most important financial and renewal decisions for the user.

Primary content:

- Today's Financial Context.
- AI Insight.
- Upcoming Renewals.
- Potential Savings.
- Shared Payment Activity.

Key actions:

- Review Subscription.
- Remind Me Later.
- Open My Subscriptions.
- Open Shared Subscriptions.

States:

- Loading.
- Empty, when no subscriptions exist.
- Healthy, when no urgent action exists.
- Attention needed, when renewals or shared payments require review.
- Error, when AI or reminder data cannot load.

Implementation notes:

- AI language must be explanatory.
- No cancel, delete, or provider-control actions appear on this screen.
- It must satisfy the Five Second Rule.

## My Subscriptions Blueprint

Purpose:

- Show the user's subscription library.

Primary content:

- Search.
- Filters.
- Sort.
- Subscription cards.
- Add Subscription action.

Key actions:

- Add subscription.
- Open subscription details.
- Search and filter.

States:

- Empty state with Add Subscription CTA.
- Loading skeleton.
- Filtered no-results state.
- Error state.

Implementation notes:

- Contextual search belongs here.
- Search is not a standalone product module.

## Add Subscription Blueprint

Purpose:

- Let users add a subscription with minimal manual effort.

Primary content:

- Catalog search.
- Custom subscription option.
- Cost.
- Currency.
- Billing frequency.
- Payment method (UPI AutoPay, card e-mandate, app-store, or manual).
- Renewal date.
- Annual Cost Preview.

Key actions:

- Save subscription.
- Cancel.
- Add custom provider.

Validation:

- Subscription name required.
- Cost required and positive.
- Currency must be INR or USD.
- Renewal date required.
- Billing frequency required.
- Payment method required.

Implementation notes:

- Annual Cost Preview updates as cost, frequency, and currency change.
- Custom services are user-owned immediately and may be reviewed before entering the global catalog.

## Subscription Details Blueprint

Purpose:

- Help the user review one subscription and decide what to do next.

Primary content:

- Subscription overview.
- Billing details.
- Renewal information.
- Annual cost.
- Lifecycle status.
- AI Insight.
- Shared members.
- Reminder history.

Key actions:

- Edit details.
- Confirm renewal.
- Pause.
- Archive.
- Manage sharing.

Interaction:

- Default state is view.
- Editing is explicit through View -> Edit.
- Archive is preferred over destructive delete.

When payment method is UPI AutoPay or a card e-mandate, the Billing section surfaces one plain-language line naming where to actually cancel it (e.g. "This runs on UPI AutoPay — cancel it from your UPI app"), per EXP-014 Transparency. This is presented as information, not an in-app action, since SubSense never modifies a mandate on the user's behalf.

## Shared Subscriptions Blueprint

Purpose:

- Track shared subscription members and payment status.

Primary content:

- Shared subscriptions.
- Members.
- Amount owed.
- Currency.
- Paid/pending status.
- Payment request history.

Key actions:

- Add member.
- Edit member.
- Remove from active split.
- Mark paid.
- Send reminder.

Implementation notes:

- Removing a member should preserve payment history.
- Email reminders use Resend through backend services.

## Insights Blueprint

Purpose:

- Help users understand recurring spend patterns.

Primary content:

- Monthly spend.
- Annual spend.
- Spending trends.
- Category analysis.
- AI insights.
- Savings opportunities.

Implementation notes:

- Insights should explain, not overwhelm.
- Financial information should prioritize savings and decision context before raw charts.

## Profile Blueprint

Purpose:

- Manage account, preferences, plan, and sign-out.

Primary content:

- Personal information.
- Google account.
- Currency.
- Time zone.
- Reminder preferences.
- Notification preferences.
- Plan or premium demonstration status.
- Sign out.

## Developer/Test Utilities Blueprint

Purpose:

- Support capstone validation and implementation testing.

Possible tools:

- Send Reminder Now.
- Test AI response.
- Test email payload.
- Test Razorpay payment flow.
- Inspect integration status.

Restrictions:

- Protected by authentication.
- Not primary user navigation.
- Must not expose secrets.

## UX Compliance Checklist

Every screen must satisfy:

- Decision-first design.
- Workflow-first behavior.
- View -> Edit where editing exists.
- Five Second Rule.
- Progressive disclosure.
- Adaptive priority flow.
- Responsive structural consistency.
- Accessibility.
- Controlled vocabulary.

## Screen Lifecycle Status

| Status | Meaning |
| --- | --- |
| Planned | Defined but not designed. |
| Wireframed | Wireframe complete. |
| Validated | UX reviewed. |
| Frozen | Architecture locked. |
| Implemented | Built. |
| Tested | QA complete. |

## Validation Checklist

| Check | Status |
| --- | --- |
| Journey-first structure defined | Complete |
| Screen responsibilities defined | Complete |
| Navigation entry/exit defined | Complete |
| Screen template defined | Complete |
| UX compliance checklist defined | Complete |
| Developer utilities scoped | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.1 | Frozen | Architecture Freeze experience blueprint. |
| v1.2 | Frozen | Implementation Freeze alignment and expanded screen guidance. |
| v1.3 | Current | Added payment method field to Add Subscription and rail-specific cancellation guidance to Subscription Details, per DEC-032. |
