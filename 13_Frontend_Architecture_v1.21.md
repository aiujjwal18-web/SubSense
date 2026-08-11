# 13 Frontend Architecture v1.21

## Document Control

| Field | Value |
| --- | --- |
| Document ID | FE-001 |
| Product | SubSense |
| Version | v1.21 |
| Status | Frozen implementation baseline |
| Source of Truth | Frontend engineering architecture |
| Depends On | 04_Experience_Blueprint_v1.25, 05_Design_System_v1.33, 06_Component_Library_v1.28, 11_API_Integration_Architecture_v1.14 |

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
| Supabase Client | Path A direct data access (RLS-governed CRUD), per DEC-031 and `11_API_Integration_Architecture_v1.14` |
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

- Components never access the database with elevated (service-role) credentials or outside the sanctioned Path A Supabase client calls defined in `11_API_Integration_Architecture_v1.14`; there is no ad hoc query building in components.
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

- **Path A — direct Supabase client access**, for the RLS-governed tables listed in `11_API_Integration_Architecture_v1.14` Section 4 (`user_profiles`, `user_preferences`, `subscriptions`, `shared_subscriptions`, `shared_members`, `payment_requests`, and reads of catalog/reminders/notifications/AI output/`premium_plans`/`payment_transactions`). RLS is the enforcement boundary; the frontend never bypasses it with elevated credentials.
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
- Payment method required: one of `upi_autopay`, `card_emandate`, `app_store`, `manual` (DEC-032, `10_Database_Architecture_v1.22`). Blocking client-side validation, mirrored server-side by the `SUB_xxx` error family in `11_API_Integration_Architecture_v1.14`.

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

Keyboard navigation and visible focus are implemented as the shared focus-visible ring defined in `05_Design_System_v1.33` Micro-interactions, applied uniformly to buttons, interactive cards, toggles, and inputs — not a per-component treatment invented in the frontend layer.

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
| v1.0 | Frozen | Frontend architecture frozen after IR-005 and IR-009. Amended per DEC-035 to reconcile with Lean Access Architecture (DEC-031): added the Supabase Client layer, split API Communication into Path A/Path B routes, and clarified the component database-access rule. Added missing `payment_method` field validation per DEC-032. |
| v1.1 | Frozen | Updated dependency reference to 04_Experience_Blueprint_v1.4, 05_Design_System_v1.3, and 06_Component_Library_v1.3, and the payment method validation cross-reference to 10_Database_Architecture_v1.3, following the brand kit finalization under DEC-042. |
| v1.2 | Frozen | Updated dependency reference to 05_Design_System_v1.4 and 06_Component_Library_v1.4, following the spacing/card/icon system closure under DEC-043. |
| v1.3 | Frozen | Updated dependency reference to 05_Design_System_v1.5 and 06_Component_Library_v1.5, and tied the Accessibility Requirements' keyboard/focus rule to the shared focus-visible ring, following the micro-interaction system closure under DEC-044. |
| v1.4 | Frozen | Updated dependency reference to 05_Design_System_v1.6 and 06_Component_Library_v1.6, following the AI copy tone closure under DEC-045. |
| v1.5 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 04_Experience_Blueprint_v1.6, 05_Design_System_v1.8, and 06_Component_Library_v1.8, closing a citation-integrity gap found during the DEC-045 pass. |
| v1.6 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 04_Experience_Blueprint_v1.6, 05_Design_System_v1.8, 06_Component_Library_v1.8, and 11_API_Integration_Architecture_v1.1 (its four body cross-references to document 11 also updated), as part of the cascade patching 11's own internal reference-integrity gaps. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and four body cross-references to 11_API_Integration_Architecture_v1.2, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 04_Experience_Blueprint_v1.8, 05_Design_System_v1.10, 06_Component_Library_v1.9, and 11_API_Integration_Architecture_v1.3; updated the focus-visible-ring cross-reference to 05_Design_System_v1.10, three further body cross-references to 11_API_Integration_Architecture_v1.3, and the payment method validation cross-reference to 10_Database_Architecture_v1.5, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 04_Experience_Blueprint_v1.9, 05_Design_System_v1.11, 06_Component_Library_v1.10, and 11_API_Integration_Architecture_v1.4, the body cross-references to 11_API_Integration_Architecture_v1.4, and the payment method validation cross-reference to 10_Database_Architecture_v1.7, as part of the cascade recording DEC-047, batched with the notification-template SQL patch (file 23). |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 04_Experience_Blueprint_v1.10, 05_Design_System_v1.12, and 06_Component_Library_v1.11, and the focus-visible-ring body cross-reference to 05_Design_System_v1.12, as part of the cascade recording DEC-049 ("Ledger Dark" visual direction). No frontend-engineering content changed. |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 05_Design_System_v1.13 and 06_Component_Library_v1.12, and the focus-visible-ring body cross-reference to 05_Design_System_v1.13, as part of the cascade recording DEC-050 (Ledger Dark extended to light-mode/email surfaces). No frontend-engineering content changed. A follow-up pre-PRD audit caught the Depends On field's 04_Experience_Blueprint citation still at v1.10 -- now v1.11. Not bumping the version again for this. |
| v1.12 | Frozen | Recorded DEC-053: updated the dependency reference to 04_Experience_Blueprint_v1.12, 05_Design_System_v1.14, 06_Component_Library_v1.13, and 11_API_Integration_Architecture_v1.5, plus four body cross-references to document 11 and the focus-visible-ring cross-reference to 05_Design_System_v1.14. No frontend-engineering content changed — this document never named Lovable directly. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 04_Experience_Blueprint_v1.13, 05_Design_System_v1.15, 06_Component_Library_v1.14, and 11_API_Integration_Architecture_v1.6, plus the same body cross-references, since all four continued to move within the same DEC-053 cascade. No frontend-engineering content changed. |
| v1.14 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 04_Experience_Blueprint_v1.14, 05_Design_System_v1.16, 06_Component_Library_v1.15, and 11_API_Integration_Architecture_v1.7, plus the same body cross-references, settling this cascade's final versions. No frontend-engineering content changed. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 04_Experience_Blueprint_v1.15, 05_Design_System_v1.17, and 06_Component_Library_v1.16, and the payment-method-validation and focus-visible-ring body cross-references to 10_Database_Architecture_v1.8 and 05_Design_System_v1.17, as 04/05/06/10 continued moving within the same DEC-053 cascade. No frontend-engineering content changed. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 04_Experience_Blueprint_v1.16, 05_Design_System_v1.18, and 06_Component_Library_v1.17, and the focus-visible-ring body cross-reference to 05_Design_System_v1.18, following DEC-054. No frontend-engineering content changed. |
| v1.17 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and four body cross-references (Path A summary, database-access rule, RLS-governed table list, payment-method validation) to 11_API_Integration_Architecture_v1.8, and the payment-method validation cross-reference to 10_Database_Architecture_v1.9 — closing drift deliberately deferred since the DEC-054 pass. No frontend-engineering content changed. |
| v1.18 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 05_Design_System_v1.19 and 06_Component_Library_v1.18, and the focus-visible-ring body cross-reference to 05_Design_System_v1.19, following DEC-055 (logo wordmark font resolved, logo formally implemented). No frontend-engineering content changed. **Correction (same day):** the dependency reference to 04_Experience_Blueprint corrected to v1.17, since 04 moved again later in this same cleanup pass. **Further correction (same day):** a fuller sweep found the Depends On field and four body cross-references to 11_API_Integration_Architecture still at v1.8, and one to 10_Database_Architecture still at v1.9 — both corrected to v1.9 and v1.10 respectively, since both moved again within this same cleanup pass. Not bumping the version again for this. **Further correction (same day, DEC-056 login-page visual exception cascade):** the dependency reference and the focus-visible-ring body cross-reference updated to 05_Design_System_v1.20. Not bumping the version again for this either. **Further correction (DEC-057 brand kit cascade):** both updated again to 05_Design_System_v1.21. Not bumping the version again for this. **Further correction (DEC-058 motion-system cascade):** both updated again to 05_Design_System_v1.22. Not bumping the version again for this either. **Further correction (DEC-059 generic-icon cascade):** the dependency reference and focus-visible-ring cross-reference updated to 05_Design_System_v1.23, the dependency reference's 06_Component_Library citation updated to v1.19, and the Payment Method cross-reference to 10_Database_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-060/061 logo-asset and Header-restructure cascade):** the dependency reference and focus-visible-ring cross-reference updated to 05_Design_System_v1.25. Not bumping the version again for this either. **Further correction (DEC-062/063/064 cascade):** the dependency reference's 05_Design_System and 06_Component_Library citations updated to v1.28 and v1.20, and the focus-visible-ring cross-reference updated to 05_Design_System_v1.28. Not bumping the version again for this either. **Further correction (DEC-065/066 cascade):** the dependency reference's 05_Design_System and 06_Component_Library citations updated to v1.30 and v1.21, and the focus-visible-ring cross-reference updated to 05_Design_System_v1.30. Not bumping the version again for this either. **Further correction (DEC-067 cascade):** the dependency reference's 06_Component_Library citation updated to v1.22. Not bumping the version again for this either. **Further correction (doc 04/08 follow-up — closing DEC-067's own flagged doc 04 gap):** the dependency reference's 04_Experience_Blueprint citation updated to v1.18. Not bumping the version again for this either. **Further correction (DEC-068 cascade — Phase 6 reminder-scheduling architecture):** the dependency reference and three body cross-references (Path A summary, database-access rule, RLS-governed table list) updated to 11_API_Integration_Architecture_v1.10, and the payment-method validation cross-reference updated to 10_Database_Architecture_v1.12. Not bumping the version again for this either. **Further correction (DEC-069 cascade — reminders CHECK constraint loosening, new audit_action enum value):** the payment-method validation cross-reference updated to 10_Database_Architecture_v1.13. Not bumping the version again for this either. **Further correction (DEC-070 cascade — reminder lifecycle fix):** the payment-method validation cross-reference updated to 10_Database_Architecture_v1.14. Not bumping the version again for this either. **Further correction (DEC-071 cascade — post_renewal_checkin paused-exclusion fix):** the payment-method validation cross-reference updated to 10_Database_Architecture_v1.15. Not bumping the version again for this either. **Further correction (DEC-073 cascade — light-mode/email accent tokens resolved to Cyber Lime):** the dependency reference's 05_Design_System and 06_Component_Library citations updated to v1.31 and v1.23, and the focus-visible-ring cross-reference updated to 05_Design_System_v1.31. Not bumping the version again for this either. **Further correction (DEC-079 cascade — Phase 7 AI runtime architecture):** the dependency reference's 04_Experience_Blueprint citation updated to v1.19. Not bumping the version again for this either. **Further correction (DEC-079 same-day extension — Phase 7 batch response shape and AI Insights merge resolved during implementation planning):** the dependency reference's 04_Experience_Blueprint and 11_API_Integration_Architecture citations, and the four body cross-references to 11_API_Integration_Architecture (Path A summary, database-access rule, RLS-governed table list, payment-method validation), updated to 04_Experience_Blueprint_v1.20 and 11_API_Integration_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-080 cascade — Phase 8 architecture forks resolved):** the dependency reference's 04_Experience_Blueprint citation updated to v1.21, and the payment-method validation cross-reference updated to 10_Database_Architecture_v1.16. Not bumping the version again for this either. **Further correction (DEC-080 same-day extension — Phase 8 technical-planning gaps):** the payment-method validation cross-reference updated to 10_Database_Architecture_v1.17. Not bumping the version again for this either. **Further correction (DEC-080 live-testing extension):** the payment-method validation cross-reference updated to 10_Database_Architecture_v1.18. Not bumping the version again for this either. **Further correction (DEC-081/082 cascade — Phase 8 closed out):** the payment-method validation cross-reference updated to 10_Database_Architecture_v1.19. Not bumping the version again for this either. **Further correction (DEC-082 — doc 04 v1.22, premium AI Insight split):** the Depends On field's 04_Experience_Blueprint citation updated to v1.22. Not bumping the version again for this either. |
| v1.20 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field and the four body cross-references (Supabase Client summary, database-access rule, Path A summary, payment-method validation) to 06_Component_Library_v1.27 and 11_API_Integration_Architecture_v1.13, as part of the cascade recording DEC-085 (currency-drop fix, Cost Comparison Card rename). No frontend-engineering content changed. **Further correction (same day, second-order cascade closure):** the payment-method validation cross-reference, missed in the pass above, updated from 10_Database_Architecture_v1.20 to v1.21. Not bumping the version again for this. |
| v1.21 | Current | Housekeeping pass, not tied to a new DEC: updated the Depends On field's 04_Experience_Blueprint citation to v1.25, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No frontend-engineering content changed. **Further correction (same day, second-order cascade closure):** the Accessibility Checklist section's focus-visible-ring body cross-reference, missed in the pass above, updated from 05_Design_System_v1.32 to v1.33 (05 bumped again during this same closure pass). Not bumping the version again for this. **Further correction (documentation audit pass):** the Depends On field's 06_Component_Library and 11_API_Integration_Architecture citations, left one hop stale, corrected to v1.28 and v1.14; three further body cross-references to 11_API_Integration_Architecture (Supabase Client summary, database-access rule, Path A summary) corrected to v1.14, and the payment-method validation cross-reference to 10_Database_Architecture corrected to v1.22. Not bumping the version again for this either. |
| v1.19 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field to 04_Experience_Blueprint_v1.24, 05_Design_System_v1.32, 06_Component_Library_v1.25, and 11_API_Integration_Architecture_v1.12, and the four body cross-references (database-access rule, Path A summary, payment-method validation x2) to 11_API_Integration_Architecture_v1.12 and 10_Database_Architecture_v1.20, as part of the cascade recording DEC-083 (Phase 9+10 built and deployed). No frontend-engineering content changed. **Correction (same day):** the Depends On field's 06_Component_Library citation corrected to v1.26, since 06 moved again later in this same cleanup pass. **Further correction (same day, full grep audit):** the focus-visible-ring body cross-reference (Accessibility Checklist section), missed in the pass above, updated from 05_Design_System_v1.31 to v1.32. Not bumping the version again for this. |
