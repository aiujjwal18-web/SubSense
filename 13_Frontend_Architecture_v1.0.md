# 13 Frontend Architecture v1.0

## Document Control

| Field | Value |
| --- | --- |
| Document ID | FE-001 |
| Product | SubSense |
| Version | v1.0 |
| Status | Frozen implementation baseline |
| Source of Truth | Frontend engineering architecture |
| Depends On | 04_Experience_Blueprint_v1.3, 05_Design_System_v1.2, 06_Component_Library_v1.2, 11_API_Integration_Architecture_v1.0 |

## Purpose

This document defines how the SubSense frontend is engineered. It does not redesign the UI. It implements the already frozen UX, information architecture, design system, and component library.

## Frontend Philosophy

SubSense follows a component-driven frontend architecture:

Presentation Layer -> Feature Components -> Shared Components -> API Client -> Backend

Each layer has one responsibility.

## Frontend Layers

| Layer | Responsibility |
| --- | --- |
| Presentation | Pages, routes, layouts |
| Feature Components | Module-specific UI and behavior |
| Shared Components | Reusable UI from Component Library |
| State Management | Client state and server state coordination |
| Supabase Client | Path A direct data access (RLS-governed CRUD), per DEC-031 and `11_API_Integration_Architecture_v1.0` |
| API Client | Path B Edge Function communication |
| Auth Boundary | Session and protected route handling |

## Feature Modules

| Module | Frontend Owner |
| --- | --- |
| Authentication | Auth feature |
| Decision Workspace | Decision feature |
| My Subscriptions | Subscription feature |
| Add Subscription | Subscription feature |
| Subscription Details | Subscription feature |
| Shared Subscriptions | Sharing feature |
| Insights | Insights feature |
| Billing/Premium Demo | Billing feature |
| Profile | Profile feature |
| Notifications | Notification feature |
| Developer/Test Utilities | Developer feature |

## Component Hierarchy

Application structure:

- App shell.
- Layout.
- Navigation.
- Page.
- Feature components.
- Shared components.
- Dialogs.
- Feedback states.

Rules:

- Components never access the database with elevated (service-role) credentials or outside the sanctioned Path A Supabase client calls defined in `11_API_Integration_Architecture_v1.0`; there is no ad hoc query building in components, and Path B tables are only ever reached through the API Client.
- Shared components do not contain business workflow decisions.
- Feature modules compose shared components.
- Business logic belongs in feature modules or backend services, not presentational components. Path A calculated fields (e.g. `monthly_equivalent`) still treat the database trigger's value as authoritative; any client-side mirror is for live-typing feedback only, never the saved value.

## Routing Architecture

Routes follow the Information Architecture.

Representative structure:

- `/auth`
- `/`
- `/decision-workspace`
- `/subscriptions`
- `/subscriptions/add`
- `/subscriptions/:id`
- `/shared`
- `/insights`
- `/profile`
- `/billing`
- `/dev-tools`, restricted

Rules:

- Authenticated routes are protected.
- Unauthenticated users redirect to authentication.
- Existing valid sessions load the Decision Workspace.
- Developer/Test Utilities are protected and not normal user navigation.

## State Management

### Client State

Examples:

- Modal open/close.
- Active filters.
- Search query.
- Sidebar collapsed state.
- Edit mode state.
- Theme preference where locally reflected.

### Server State

Examples:

- User profile.
- Subscriptions.
- Shared members.
- Payment requests.
- Reminders.
- AI recommendations.
- Notifications.
- Premium status.

Server state is refreshed from backend APIs and must not be duplicated as independent business truth in components.

## Single Data Ownership Standard

Each business entity has exactly one frontend source of truth.

Components may derive UI state, but must not create conflicting copies of business data.

## Optimistic UI Standard

Optimistic updates are allowed only for safe, reversible operations.

Allowed examples:

- Local filter changes.
- UI preference changes.
- Non-critical reversible updates after clear rollback support.

Not allowed:

- Authentication.
- Payments.
- AI generation.
- Email delivery.
- Reminder execution.

## API Communication

Per DEC-031 (Lean Access Architecture), the frontend has two sanctioned communication routes, not one:

- **Path A — direct Supabase client access**, for the RLS-governed tables listed in `11_API_Integration_Architecture_v1.0` Section 4 (`user_profiles`, `user_preferences`, `subscriptions`, `shared_subscriptions`, `shared_members`, `payment_requests`, and reads of catalog/reminders/notifications/AI output/`premium_plans`/`payment_transactions`). RLS is the enforcement boundary; the frontend never bypasses it with elevated credentials.
- **Path B — the backend/API (Edge Function) layer**, for anything secret-bearing, scheduled, or writing to a system-owned table.

Never directly with, on either path:

- OpenAI.
- Resend.
- Razorpay.
- Supabase service role operations (the service-role key never reaches the frontend under any circumstance).

Supabase Auth may be used for authentication/session behavior as defined in the API and backend architecture.

## Standard Screen States

Every asynchronous screen implements:

1. Loading.
2. Empty.
3. Success.
4. Error.

Applies to:

- Decision Workspace.
- My Subscriptions.
- Subscription Details.
- Shared Subscriptions.
- Insights.
- Profile.
- Developer/Test Utilities.

## Form Architecture

Forms use:

- Controlled validation.
- Inline error messages.
- Clear save/cancel actions.
- View -> Edit where applicable.
- Review before committing meaningful changes.

Subscription form validation:

- Name required.
- Cost positive.
- Currency INR or USD.
- Billing frequency valid.
- Renewal date valid.
- Payment method required: one of `upi_autopay`, `card_emandate`, `app_store`, `manual` (DEC-032, `10_Database_Architecture_v1.1`). Blocking client-side validation, mirrored server-side by the `SUB_xxx` error family in `11_API_Integration_Architecture_v1.0`.

## Security Boundaries

Frontend never stores:

- OpenAI API keys.
- Resend API keys.
- Razorpay secret keys.
- Supabase service role key.
- Payment secrets.

JWT/session artifacts are the only authentication mechanism exposed to the client.

## Performance Principles

- Lazy-load feature pages where possible.
- Reuse shared components.
- Minimize duplicate API calls.
- Keep server state normalized.
- Avoid unnecessary client-side caching.
- Prevent layout shifts in fixed-format components.

## Accessibility Requirements

Frontend implementation must preserve:

- Keyboard navigation.
- Visible focus.
- Screen-reader labels.
- Accessible form errors.
- Accessible dialogs.
- Non-color-only status meaning.

## Frontend Validation Checklist

| Check | Status |
| --- | --- |
| Component-driven architecture defined | Complete |
| Feature modules mapped | Complete |
| Routing defined | Complete |
| Client/server state separated | Complete |
| API boundary defined | Complete |
| Loading states standardized | Complete |
| Security boundaries defined | Complete |
| Design/component dependencies referenced | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Current | Frontend architecture frozen after IR-005 and IR-009. Amended per DEC-035 to reconcile with Lean Access Architecture (DEC-031): added the Supabase Client layer, split API Communication into Path A/Path B routes, and clarified the component database-access rule. Added missing `payment_method` field validation per DEC-032. |
