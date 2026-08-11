# 03 Information Architecture v1.17

## Document Control

| Field | Value |
| --- | --- |
| Document ID | IA-001 |
| Product | SubSense |
| Version | v1.17 |
| Status | Frozen implementation baseline |
| Source of Truth | Product structure, navigation, and information ownership |
| Depends On | 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19, 02_Experience_Strategy_v1.20 |

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

Each information element has one source of truth. Per DEC-038, "Premium status" resolves at the database layer to `user_profiles.is_premium` / `premium_expires_at` / `premium_source`, defined in `10_Database_Architecture_v1.22` — not a separate entitlement table; per DEC-083, these fields now have real readers (`razorpay-verify-payment` writes them, `user_has_active_premium(uuid)` reads them server-side).

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
| v1.2 | Frozen | Implementation Freeze alignment and full documentation package mapping. Added a cross-reference from Premium status ownership to the `user_profiles` entitlement fields defined in `10_Database_Architecture_v1.3` per DEC-038. |
| v1.3 | Frozen | Updated dependency references to 00_Project_Governance_v1.3, 01_Product_Strategy_v1.5, and 02_Experience_Strategy_v1.3, following the brand kit finalization under DEC-042. |
| v1.4 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, and 02_Experience_Strategy_v1.8 — the 02 reference had been left at v1.3 since the DEC-042 pass despite two subsequent 02 version bumps (DEC-044, DEC-045), found during a citation-integrity check. |
| v1.5 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, and 02_Experience_Strategy_v1.8, and the Premium status cross-reference to 10_Database_Architecture_v1.3, as part of the cascade patching 11_API_Integration_Architecture's own internal reference-integrity gaps. |
| v1.6 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.9, 01_Product_Strategy_v1.8, and 02_Experience_Strategy_v1.9, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.10, 01_Product_Strategy_v1.9, and 02_Experience_Strategy_v1.10, and the Premium status cross-reference to 10_Database_Architecture_v1.5, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.11, 01_Product_Strategy_v1.10, and 02_Experience_Strategy_v1.11, and the Premium status cross-reference to 10_Database_Architecture_v1.7, as part of the cascade recording DEC-047 (post_renewal_checkin fixed offset, finalized notification_templates copy), batched with the notification-template SQL patch (file 23). |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.12 and 02_Experience_Strategy_v1.12, as part of the cascade recording DEC-049 ("Ledger Dark" visual direction). No structure/navigation content changed. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.13 and 02_Experience_Strategy_v1.13, as part of the cascade recording DEC-050 (Ledger Dark extended to light-mode/email surfaces). No structure/navigation content changed. |
| v1.11 | Frozen | Recorded DEC-053 (Lovable to Cursor tooling change): updated dependency references to 00_Project_Governance_v1.14, 01_Product_Strategy_v1.11, and 02_Experience_Strategy_v1.14. No structure/navigation content changed. |
| v1.12 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.15, 01_Product_Strategy_v1.12, and 02_Experience_Strategy_v1.15, as all three continued to move within the same DEC-053 cascade. No structure/navigation content changed. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 01_Product_Strategy_v1.13 and 02_Experience_Strategy_v1.16, and the Premium status cross-reference to 10_Database_Architecture_v1.8, as all continued moving within the same DEC-053 cascade. No structure/navigation content changed. **Correction (same day, caught before this pass finished):** the dependency reference to 00_Project_Governance corrected to v1.16, since it moved again after this row was written. Not bumping the version again for this. |
| v1.14 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.17, 01_Product_Strategy_v1.14, and 02_Experience_Strategy_v1.17, following DEC-054. No structure/navigation content changed. **Correction (same day):** the dependency reference to 00_Project_Governance corrected to v1.18, since 00 moved again later in the same cleanup pass. Not bumping the version again for this. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.19, 01_Product_Strategy_v1.15, and 02_Experience_Strategy_v1.18, following DEC-055 (logo wordmark font resolved, logo formally implemented). No structure/navigation content changed. **Correction (same day):** the 00_Project_Governance reference corrected to v1.20, since 00 moved again later in this same cleanup pass. **Further correction (same day, full folder grep audit):** the Premium status cross-reference to 10_Database_Architecture, pre-existing drift stuck at v1.8, corrected to v1.10. Not bumping the version again for this. **Further correction (DEC-068 cascade — Phase 6 reminder-scheduling architecture):** the Premium status cross-reference updated to 10_Database_Architecture_v1.12. Not bumping the version again for this either. **Further correction (DEC-069 cascade — reminders CHECK constraint loosening, new audit_action enum value):** the Premium status cross-reference updated to 10_Database_Architecture_v1.13. Not bumping the version again for this either. **Further correction (DEC-070 cascade — reminder lifecycle fix):** the Premium status cross-reference updated to 10_Database_Architecture_v1.14. Not bumping the version again for this either. **Further correction (DEC-071 cascade — post_renewal_checkin paused-exclusion fix):** the Premium status cross-reference updated to 10_Database_Architecture_v1.15. Not bumping the version again for this either. **Further correction (DEC-080 cascade — Phase 8 architecture forks resolved):** the Premium status cross-reference updated to 10_Database_Architecture_v1.16. Not bumping the version again for this either. **Further correction (DEC-080 same-day extension — Phase 8 technical-planning gaps):** the Premium status cross-reference updated to 10_Database_Architecture_v1.17. Not bumping the version again for this either. **Further correction (DEC-080 live-testing extension):** the Premium status cross-reference updated to 10_Database_Architecture_v1.18. Not bumping the version again for this either. **Further correction (DEC-081/082 cascade — Phase 8 closed out):** the Premium status cross-reference updated to 10_Database_Architecture_v1.19, and the Depends On field's 01_Product_Strategy citation updated to v1.16. Not bumping the version again for this either. |
| v1.16 | Frozen | **Records DEC-083** (Phase 9+10 built and deployed): the Premium status cross-reference updated to `10_Database_Architecture_v1.20`, with a note that `is_premium`/`premium_expires_at`/`premium_source` now have real readers/writers (`razorpay-verify-payment`, `user_has_active_premium(uuid)`) rather than being planned-but-unimplemented. Updated the Depends On field to 00_Project_Governance_v1.21, 01_Product_Strategy_v1.17, and 02_Experience_Strategy_v1.19. No other structure/navigation content changed. **Further correction (same day, second-order cascade closure):** the Premium status cross-reference to `10_Database_Architecture`, and the Depends On field's 00/01 citations, all one hop stale after tonight's DEC-085 cascade, corrected to v1.21, v1.22, and v1.18 respectively. Not bumping the version again for this. |
| v1.17 | Current | Housekeeping pass, not tied to a new DEC: updated the Depends On field to 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19, and 02_Experience_Strategy_v1.20, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No structure/navigation content changed. **Further correction (documentation audit pass):** the Single Source of Truth section's `10_Database_Architecture` body citation, left stale, corrected to v1.22. Not bumping the version again for this either. |
