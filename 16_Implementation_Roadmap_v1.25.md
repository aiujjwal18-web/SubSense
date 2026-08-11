# 16 Implementation Roadmap v1.25

## Document Control

| Field | Value |
| --- | --- |
| Document ID | ROAD-001 |
| Product | SubSense |
| Version | v1.25 |
| Status | Frozen implementation baseline |
| Source of Truth | Development sequence and implementation handoff |
| Depends On | 00 through 15, including external 11_API_Integration_Architecture_v1.14 |

## Purpose

This document defines the recommended implementation sequence for SubSense after architecture and implementation readiness are frozen.

It is designed for Cursor (DEC-053), Supabase, and supporting backend/API implementation.

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
- Vercel setup; Cursor local development environment configured.
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

- `10_Database_Architecture_v1.22.md`.

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

- `03_Information_Architecture_v1.17.md`.
- `05_Design_System_v1.33.md`.
- `06_Component_Library_v1.28.md`.

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
- Renewal Urgency Indicator (C-012) uses the frozen day-thresholds from DEC-054 (Critical <= 2 days, Upcoming 3-7 days, Normal > 7 days), computed client-side from `next_renewal_date` — not a stored column.

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
- Implement the `monthly_digest` and `lapsed_reengagement` scheduled jobs per the Retention Policy (DEC-041, `01_Product_Strategy`).

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
- Implement the AI Copy Tone rules from `02_Experience_Strategy` (DEC-045) in the `ai-generate-insight` prompt design.

Deliverables:

- AI Insight service.
- AI recommendation persistence.
- AI UI states.
- AI failure handling.

Acceptance:

- AI explains recommendations.
- AI does not modify subscription state.

Note (DEC-079): duplicate subscription detection, named in doc 18's PRD pillar copy ("What We're Building") but never actually part of this phase's goals/deliverables/acceptance above, is deliberately deferred to Phase 9 (Insights) — see that phase's goals below, updated to name it explicitly. Structurally different from this phase's single-subscription `ai-generate-insight` loop (duplicate detection compares across a user's whole active list, not one subscription at a time), and no schema/equivalence-mapping for it exists yet in `10_Database_Architecture`.
- AI output remains user-owned decision support.
- Generated copy varies sentence structure across cards rather than reusing one template.

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
- Detect and surface duplicate/overlapping subscription spend (deferred from Phase 7, DEC-079) — a savings-opportunity signal, not a per-subscription renewal insight.
- Summarize AI insights.
- Suggest lower-cost alternatives as informational context (per `01_Product_Strategy_v1.19`'s AI Strategy; previously listed there but not assigned to any build phase — folded in here per DEC-082).

Deliverables:

- Insights page — **built and deployed (DEC-083)**, premium-exclusive, gated both client-side and server-side via `user_has_active_premium(uuid)`; see `04_Experience_Blueprint_v1.25` and `08_Decision_Log_v1.62` for the free/premium AI Insight split this pairs with.
- Spending summary — built: monthly spend per active currency. Annual spend and category breakdown were **not built**, out of scope for this pass.
- Financial reports — not built; no dedicated reports view exists beyond the Insights page's own cards.
- Duplicate/overlap detection — built: exact and category-overlap detection across the caller's own subscriptions.
- AI insight summary — built: a server-side templated lead sentence states the currency totals directly from `spendSummary`, with one OpenAI call restricted to a short qualitative framing sentence only, guarded at the code level against restating any figure (DEC-085). This closes the earlier non-deterministic currency-drop issue; **live verification is complete** (2-currency portfolio confirmed across multiple regenerations and page reloads, both totals present every time, matching the Spend Summary card) — see `08_Decision_Log_v1.62`'s v1.59 Version History row.
- Lower-cost-alternative suggestions (DEC-082) — built as an **intra-portfolio category-average cost comparison** only; no competitor or market-pricing data exists anywhere in the schema, so no true lower-cost-alternative claim is made. The shipped label was renamed from "Lower-Cost Alternatives" to **"Worth a Second Look"** (DEC-085), with per-item copy rewritten to name the specific percentage above the category average. **Live visual verification is complete** — confirmed rendering correctly with real percentages against both the Insights page's Summary and Duplicate & Overlap Detection cards.
- Savings opportunities — **not built**. The Decision Workspace's "Potential Savings" placeholder (doc 06 C-007) remains unbuilt and predates this phase; DEC-083 notes it could reuse the same deterministic engine built for the cost comparison card, a bundling opportunity tracked as a discussion item in `NEXT_SESSION_AGENDA.md`, not a Phase 9 deliverable.

### Phase 9.5: Mid-Build Stress Test Checkpoint (Week 3)

Goals:

- Verify RLS boundaries, Edge Function auth boundaries, accessibility, and demo-critical load paths before building the remaining lower-risk phases.

Deliverables:

- Checkpoint results against the criteria in `14_Testing_Strategy_v1.17`.
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

- Test payment flow — **built and deployed (DEC-083)**: `razorpay-create-order`/`razorpay-verify-payment` Edge Functions (doc 11 §5.5/5.6), Razorpay Test Mode checkout, live-verified end to end with a real test-card payment.
- Payment transaction record — built: `payment_transactions` row inserted before checkout, flipped to `verified` via a compare-and-swap conditional update, idempotent on `razorpay_payment_id`.
- Premium status UI — built: Profile page's Plan Comparison Card and Upgrade flow; `user_profiles.is_premium`/`premium_expires_at`/`premium_source` (DEC-038) now has real readers for the first time, checked server-side via `user_has_active_premium(uuid)`.

Restrictions:

- No live payment processing in MVP.

**Phase 9+10 status: fully closed.** All four issues Phase 9+10's combined live-testing pass surfaced (DEC-083) are now fixed and live-verified: the full-page-reload-on-navigation bug was root-caused (Supabase's `GoTrueClient` re-notifying `onAuthStateChange` on every tab refocus, triggering `AuthContext.tsx`'s full state reset regardless of whether the identity actually changed) and fixed under DEC-084; the AI-summary currency-drop and Cost Comparison Card naming issues were both fixed under DEC-085 and confirmed live-working (see Phase 9's deliverables above); and session-idle-timeout, the fourth and last open item, was designed, built, and live-verified under DEC-086 (30s warning / 40s sign-out at demo-week values, per-tab tracking, Razorpay-checkout suspension confirmed not to interrupt an in-progress payment). None of these ever blocked the payment flow itself from working.

### Phase 11: Developer/Test Utilities

**Status: built and deployed (DEC-087, `08_Decision_Log_v1.62`).**

Goals:

- Centralize validation tools.
- Support capstone demonstration.

Utilities — all 5 built, behind a single `dev-utilities` Edge Function with four actions plus Razorpay's existing flow:

- Send Reminder Now — built (`trigger_reminder`).
- Test AI Response — built (`build_prompt`; dry-run and real-call modes, production `ai-generate-insight`/`insights-generate-summary` invoked unmodified, never edited).
- Test Email Payload — built (`render_email`; render-only, zero Resend calls).
- Test Razorpay Payment — built (reuses the existing `UpgradeButton`/Test Mode checkout exactly, no separate payment path).
- View integration status — built (`integration_status`; 4 read-only health checks, Supabase/OpenAI/Resend/Razorpay).

Restrictions:

- Authenticated and protected.
- No secrets exposed.
- Not normal end-user navigation.
- **Narrowed further, mid-session (DEC-087):** restricted to a 3-account allowlist, not any authenticated user — checked both client-side (redirect before render) and server-side (403, the real boundary) in the Edge Function itself.

### Phase 12: Testing and QA

**Status: built and tested, deliberately lightweight, not a full RTM cycle (DEC-087, `08_Decision_Log_v1.62`).** Rescoped from the goals below after the user directly challenged whether a full Requirements Traceability Matrix added real value given Phases 1-10's own extensive live-testing — agreed, and this phase focused instead on the three areas genuinely unverified: one continuous end-to-end run, a targeted RLS/premium-gating spot-check (not a full redo of Phase 8's audit), and accessibility (the one genuinely new category, never checked before this phase). All 9 live tests run this session passed.

Original goals (see DEC-087 for the actual rescoped execution):

- Execute business-first testing strategy.
- Validate RTM coverage. **Not done as a formal RTM/checklist/UAT cycle — deliberately, per DEC-087.**
- Run E2E flows. **Done: one continuous signup-through-idle-timeout run.**
- Run security and RLS checks. **Done, scoped: `shared_subscriptions` visibility and premium gating, both confirmed holding.**
- Run accessibility checks. **Done: WCAG 2.1 AA via axe/Lighthouse on the 4 doc-14-named screens (Decision Workspace, Add Subscription, Subscription Details, Shared Subscriptions) — zero Critical/Serious findings confirmed on all 4, after one real bug found and fixed (a global button's accessible name missing at mobile widths).**

Deliverables:

- Test results. **Live-verified, not a written formal report — see DEC-087.**
- Defect log. **6 real bugs found and fixed this session, all detailed in DEC-087: a payment-reminder back-dating bug, a nested-interactive-controls accessibility violation, a false-negative in the Resend health check, an entirely unbuilt Decision Workspace widget, an unbuilt placeholder hidden from view, and a mobile-viewport accessible-name bug.**
- UAT sign-off. **Not produced as a formal document — out of scope for this lightweight pass, per DEC-087.**
- Release checklist. **Not produced as a formal document — out of scope for this lightweight pass, per DEC-087.**

Dependencies:

- `14_Testing_Strategy_v1.17.md`.

### Phase 13: Deployment

**Closed via DEC-088.** This phase's originally-planned staging→approval→production pipeline was never built; production deployment has instead been live and continuous since Phase 6. See `15_Deployment_Architecture`'s "As-Built Deployment Record" section for the full account.

Goals, as originally planned, and their actual disposition:

- Deploy to staging — not done; no staging tier was ever stood up (accepted gap, not an oversight — see DEC-088).
- Validate environment configuration — done informally, per-deploy, rather than as a discrete staging step.
- Run smoke tests — done informally after each deploy (application startup, auth, protected routes, relevant service health), not as a single documented gate.
- Deploy to production after approval — done, but continuously since Phase 6 rather than as a gated one-time release; every phase (DEC-068 through DEC-087) shipped straight to production via Vercel (frontend) and GitHub Actions (Edge Functions), both auto-triggered on push to `main`.

Deliverables, as originally planned, and their actual disposition:

- Staging deployment — not produced; out of scope for this capstone's timeline (rejected in DEC-088's rationale alongside the alternative of standing one up now).
- Production deployment — done; live since Phase 6.
- Deployment verification checklist — exists as a spec in `15_Deployment_Architecture`, never run as a single documented pass/fail gate; equivalent ground covered informally per phase via live-testing recorded per-DEC in `08_Decision_Log`.
- Rollback plan — exists as `15_Deployment_Architecture`'s Rollback Strategy plus its new As-Built Deployment Record; in practice, rollback has always meant `git revert` on `main` followed by the same forward auto-deploy pipeline (e.g. DEC-085's GitHub Actions manual re-run), never exercised as a genuine incident rollback.

Dependencies:

- `15_Deployment_Architecture_v1.13.md`.

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
| Retention reminders (monthly digest, lapsed re-engagement) | Yes |
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
| v1.1 | Frozen | Inserted Phase 9.5 Mid-Build Stress Test Checkpoint (Week 3) per DEC-033. Corrected title/Document Control version to match filename (was misstated as v1.0) and updated dependency references to 10_Database_Architecture_v1.1 and 14_Testing_Strategy_v1.1. |
| v1.2 | Frozen | Added `monthly_digest` and `lapsed_reengagement` scheduled jobs to Phase 6 and the MVP Acceptance Checklist, per the Retention Policy (DEC-041). |
| v1.3 | Frozen | Updated Phase 3 dependency references to 03_Information_Architecture_v1.3, 05_Design_System_v1.3, and 06_Component_Library_v1.3; updated Phase 9.5/12 references to 14_Testing_Strategy_v1.2 and Phase 13 reference to 15_Deployment_Architecture_v1.1, following the brand kit finalization under DEC-042. |
| v1.4 | Frozen | Updated Phase 3 dependency references to 05_Design_System_v1.4 and 06_Component_Library_v1.4, following the spacing/card/icon system closure under DEC-043. |
| v1.5 | Frozen | Updated Phase 3 dependency references to 05_Design_System_v1.5 and 06_Component_Library_v1.5, following the micro-interaction system closure under DEC-044. |
| v1.6 | Frozen | Updated Phase 3 dependency references to 05_Design_System_v1.6 and 06_Component_Library_v1.6, and added the AI Copy Tone implementation note and acceptance criterion to Phase 7, following the AI copy tone closure under DEC-045. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated Phase 3 dependency references to 03_Information_Architecture_v1.5, 05_Design_System_v1.8, and 06_Component_Library_v1.8; updated Phase 9.5/12 references to 14_Testing_Strategy_v1.4 and Phase 13 reference to 15_Deployment_Architecture_v1.3, closing citation-integrity gaps found during the DEC-045 pass. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's external document-11 citation to v1.1, Phase 1's dependency reference to 10_Database_Architecture_v1.3, Phase 3's dependency references to 03_Information_Architecture_v1.5, 05_Design_System_v1.8, and 06_Component_Library_v1.8, the Phase 9.5/12 reference to 14_Testing_Strategy_v1.4, and the Phase 13 reference to 15_Deployment_Architecture_v1.3, as part of the cascade patching 11_API_Integration_Architecture's own internal reference-integrity gaps. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's external document-11 citation to v1.2, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's external document-11 citation to v1.3, the Phase reference to 10_Database_Architecture_v1.5.md, and the Phase 3/9.5/12/13 references to 05_Design_System_v1.10.md, 06_Component_Library_v1.9.md, and 15_Deployment_Architecture_v1.4.md, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's external document-11 citation to v1.4, Phase 1's dependency reference to 10_Database_Architecture_v1.7, and the Phase 3/9.5/12/13 references to 03_Information_Architecture_v1.8, 05_Design_System_v1.11, 06_Component_Library_v1.10, 14_Testing_Strategy_v1.7, and 15_Deployment_Architecture_v1.5, as part of the cascade recording DEC-047 (post_renewal_checkin fixed offset, finalized notification_templates copy), batched with the notification-template SQL patch (file 23). |
| v1.12 | Frozen | Housekeeping pass, not tied to a new DEC: updated Phase 3's dependency references to 03_Information_Architecture_v1.9, 05_Design_System_v1.12, and 06_Component_Library_v1.11, and the Week 3 checkpoint / Phase 13 references to 14_Testing_Strategy_v1.8, as part of the multi-hop cascade recording DEC-049 ("Ledger Dark" visual direction). No phase sequencing or acceptance-criteria content changed. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated Phase 3's dependency references to 05_Design_System_v1.13 and 06_Component_Library_v1.12, as part of the cascade recording DEC-050 (Ledger Dark extended to light-mode/email surfaces). No phase sequencing or acceptance-criteria content changed. A follow-up pre-PRD audit caught Phase 3's remaining dependency reference to 03_Information_Architecture still at v1.9 -- now v1.10. Not bumping the version again for this. |
| v1.14 | Frozen | Recorded DEC-053: Purpose statement updated from "designed for Lovable" to "designed for Cursor," Phase 0's "Vercel/Lovable setup" deliverable split into "Vercel setup; Cursor local development environment configured." Updated the Depends On field's external document-11 citation to v1.5, Phase 3's dependency references to 05_Design_System_v1.14 and 06_Component_Library_v1.13, and the Week 3 checkpoint / Phase 13 references to 14_Testing_Strategy_v1.9 and 15_Deployment_Architecture_v1.6. No phase sequencing or acceptance-criteria content changed. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's external document-11 citation to v1.6, Phase 3's dependency references to 03_Information_Architecture_v1.11, 05_Design_System_v1.15, and 06_Component_Library_v1.14, and the Week 3 checkpoint / Phase 13 references to 14_Testing_Strategy_v1.10 and 15_Deployment_Architecture_v1.7 -- all drifted stale as the DEC-053 cascade continued outward from v1.14. No phase sequencing or acceptance-criteria content changed. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's external document-11 citation to v1.7, Phase 3's dependency references to 03_Information_Architecture_v1.13, 05_Design_System_v1.17, and 06_Component_Library_v1.16, and the Week 3 checkpoint / Phase 13 references to 14_Testing_Strategy_v1.12 and 15_Deployment_Architecture_v1.8, as all continued moving within the same DEC-053 cascade. No phase sequencing or acceptance-criteria content changed. |
| v1.17 | Frozen | Recorded DEC-054: added an acceptance criterion to Phase 4 (Subscription Management) for the Renewal Urgency Indicator's frozen day-thresholds (Critical <= 2 days, Upcoming 3-7 days, Normal > 7 days, computed client-side from `next_renewal_date`). Updated Phase 3's dependency reference to 05_Design_System_v1.18. No other phase sequencing changed. |
| v1.18 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's external document-11 citation to v1.8, closing drift deliberately deferred since the DEC-054 pass. No phase sequencing or acceptance-criteria content changed. |
| v1.19 | Frozen | Housekeeping pass, not tied to a new DEC: updated Phase 3's dependency reference to 05_Design_System_v1.19, following DEC-055 (logo wordmark font resolved, logo formally implemented). No phase sequencing or acceptance-criteria content changed. **Correction (same day):** the Depends On field's external 11_API_Integration_Architecture citation corrected to v1.9, since 11 moved again later in this same cleanup pass. **Further correction (same day, full folder grep audit):** six pre-existing stale citations found and fixed, predating today's DEC-055 cascade entirely — Phase 1's 10_Database_Architecture reference (stuck at v1.8) corrected to v1.10; Phase 3's 03_Information_Architecture reference (stuck at v1.13) corrected to v1.15 and 06_Component_Library reference (stuck at v1.16) corrected to v1.18; the Phase 9.5 and Phase 12 references to 14_Testing_Strategy (both stuck at v1.12) corrected to v1.14; and Phase 13's 15_Deployment_Architecture reference (stuck at v1.8) corrected to v1.10. Not bumping the version again for this. **Further correction (same day, DEC-056 login-page visual exception cascade):** Phase 3's dependency reference updated to 05_Design_System_v1.20. Not bumping the version again for this either. **Further correction (DEC-057 brand kit cascade):** Phase 3's dependency reference updated again to 05_Design_System_v1.21. Not bumping the version again for this. **Further correction (DEC-058 motion-system cascade):** updated again to 05_Design_System_v1.22. Not bumping the version again for this either. **Further correction (DEC-059 generic-icon cascade):** Phase 3's dependency reference updated to 05_Design_System_v1.23 and 06_Component_Library_v1.19; Phase 1's 10_Database_Architecture reference updated to v1.11. Not bumping the version again for this either. **Further correction (DEC-060/061 logo-asset and Header-restructure cascade):** Phase 3's dependency reference updated to 05_Design_System_v1.25. Not bumping the version again for this either. **Further correction (DEC-062/063/064 cascade):** Phase 3's dependency references updated to 05_Design_System_v1.28 and 06_Component_Library_v1.20. Not bumping the version again for this either. **Further correction (DEC-065/066 cascade):** Phase 3's dependency references updated to 05_Design_System_v1.30 and 06_Component_Library_v1.21. Not bumping the version again for this either. **Further correction (DEC-067 cascade):** Phase 3's 06_Component_Library dependency reference updated to v1.22. Not bumping the version again for this either. **Further correction (DEC-068 cascade — Phase 6 reminder-scheduling architecture):** the Depends On field's external 11_API_Integration_Architecture citation updated to v1.10, and Phase 1's 10_Database_Architecture reference updated to v1.12. Not bumping the version again for this either. **Further correction (DEC-073 cascade — light-mode/email accent tokens resolved to Cyber Lime):** Phase 3's dependency references updated to 05_Design_System_v1.31 and 06_Component_Library_v1.23. Not bumping the version again for this either. **Further correction (DEC-076 cascade — Vercel SPA rewrite bug found and fixed):** Phase 13's 15_Deployment_Architecture reference updated to v1.11. Not bumping the version again for this either. |
| v1.20 | Frozen | Recorded DEC-079: formalized Phase 7's (AI Decision Support) runtime architecture before any Edge Function code is written — lazy-generate trigger model (Path A reads cached `ai_recommendations`, `ai-generate-insight` only fires on missing/stale/changed data or a manual Regenerate action, no cron job), a 3-subscription Critical/Upcoming-urgency cap on the Decision Workspace batch call, and `gpt-4o-mini` as the model. Added a Note to Phase 7's Acceptance section stating that duplicate subscription detection (named in doc 18's PRD copy, never actually part of this phase's own goals/acceptance) is deliberately deferred to Phase 9. Phase 9's Goals and Deliverables updated to explicitly name duplicate/overlap detection as a deliverable there, so it's picked up automatically rather than left to be rediscovered. No other phase sequencing or acceptance criteria changed. **Further correction (DEC-079 same-day extension — Phase 7 implementation planning):** the Depends On field's external 11_API_Integration_Architecture citation updated to v1.11 (batch response shape resolved to an `insights[]` array for workspace scope). Not bumping the version again for this either. **Further correction (DEC-080 cascade — Phase 8 architecture forks resolved, plus the remaining component-spec gap closed):** Phase 3's dependency reference updated to 06_Component_Library_v1.24. Not bumping the version again for this either. **Further correction (DEC-080 same-day extension — Phase 8 technical-planning gaps):** Phase 3's `10_Database_Architecture` file reference updated to v1.17. Not bumping the version again for this either. **Further correction (DEC-080 live-testing extension):** Phase 1's `10_Database_Architecture` file reference updated to v1.18. Not bumping the version again for this either. **Further correction (DEC-082 — Phase 8 closed out, premium feature-gating decided for AI Insights):** Phase 1's `10_Database_Architecture` file reference updated to v1.19. Phase 9's Goals and Deliverables updated: added lower-cost-alternative suggestions (previously listed in doc 01's AI Strategy but never assigned to a build phase) as a new goal/deliverable, and the Insights page deliverable annotated as premium-exclusive — decided now, gating logic not yet built, per DEC-082's explicit decide-now-build-later scoping. Not bumping the version again for this either. |
| v1.21 | Frozen | **Records DEC-083** (Phase 9+10 built and deployed, doc 08 v1.56): Phase 9 (Insights) and Phase 10 (Premium Demonstration) Deliverables rewritten from planned-scope bullets to an honest built-vs-not ledger. Phase 9 built: Insights page (premium-exclusive, gated client+server via `user_has_active_premium`), per-currency monthly spend summary, exact/category-overlap duplicate detection, an intra-portfolio category-average cost comparison (not a true lower-cost-alternative claim — no competitor/market-pricing data exists in this schema), and one AI-written summary paragraph. Phase 9 explicitly not built: annual spend, category breakdown, financial reports, and the Decision Workspace's "Potential Savings" placeholder (doc 06 C-007, predates this phase). Phase 10 built: `razorpay-create-order`/`razorpay-verify-payment` Edge Functions, Razorpay Test Mode checkout, `payment_transactions` record-keeping, and the Profile page's Plan Comparison Card/Upgrade flow — live-verified end to end with a real test-mode payment. This phase is recorded as built and deployed, not fully closed: three issues from the combined live-testing pass remain open and are tracked in `NEXT_SESSION_AGENDA.md`, not silently omitted — the Insights AI summary's non-deterministic currency-drop, a full-page-reload-on-navigation bug (confirmed genuine, not yet root-caused), and no session-idle-timeout policy. Updated the Depends On field's external 11_API_Integration_Architecture citation to v1.12. No phase sequencing or acceptance-criteria structure changed. **Correction (same day, full grep audit):** the Phase 9 Deliverables' `04_Experience_Blueprint` cross-reference, found still at v1.23, corrected to v1.24, since 04 moved again later in this same cleanup pass. **Further correction (same day, fuller grep sweep):** six more stale phase-dependency references found and fixed, predating this session's DEC-083 cascade — Phase 1's `10_Database_Architecture` reference (stuck at v1.19) corrected to v1.20; Phase 3's `03_Information_Architecture` (stuck at v1.15), `05_Design_System` (stuck at v1.31), and `06_Component_Library` (stuck at v1.24) references corrected to v1.16, v1.32, and v1.26 respectively; and the Phase 9.5 and Phase 12 references to `14_Testing_Strategy` (both stuck at v1.14) corrected to v1.15; Phase 9's lower-cost-alternatives goal's `01_Product_Strategy` cross-reference (stuck at v1.16) corrected to v1.17. Not bumping the version again for this either. |
| v1.22 | Frozen | Recorded DEC-084 and DEC-085's impact on Phase 9+10 status: the full-page-reload bug (Phase 10 status note) is now root-caused and fixed (DEC-084 — Supabase auth-refresh re-notification triggering AuthContext's full state reset, not a route remount); the AI-summary currency-drop and Cost Comparison Card naming issues (Phase 9 Deliverables) are now fixed (DEC-085 — templated lead sentence with a code-level guard, and a rename to "Worth a Second Look"), live verification pending on both. Only the idle-session-timeout item remains genuinely open. Updated the Depends On field and the Phase 9.5/component-file citations to 11_API_Integration_Architecture_v1.13, 14_Testing_Strategy_v1.16, and 06_Component_Library_v1.27. **Further correction (same day, second-order cascade closure):** three body citations left stuck at pre-tonight versions were corrected — the Phase 8 component-file reference to `10_Database_Architecture_v1.21`, the lower-cost-alternatives AI Strategy cross-reference to `01_Product_Strategy_v1.18`, and a second component-file reference to `14_Testing_Strategy_v1.16` (this one had not actually been updated in the edit above despite being named in its own summary). Not bumping the version again for this. **Further correction (same day, second-order audit continued):** the Insights-page deliverable line's `08_Decision_Log` cross-reference, stuck at v1.56, corrected to v1.58. Not bumping the version again for this either. **Further correction (same day, DEC-085 live-verification closure):** the same cross-reference updated again to v1.59 (DEC-085's items confirmed live, plus a GitHub Actions deploy-gap bug found and fixed during that verification). Not bumping the version again for this either. |
| v1.23 | Frozen | **Closes out Phase 9+10 in full**, the last of DEC-083's four tracked live-testing issues now resolved: DEC-085's currency-drop and Cost Comparison Card fixes are confirmed live-verified (Phase 9 Deliverables' "live verification pending" language removed), and **DEC-086** (session-idle-timeout, the item this row's own predecessor called "genuinely open") is designed, built, and live-verified — per-tab tracking, "Stay signed in" toast action, demo-week 30s/40s thresholds, Razorpay-checkout suspension confirmed not to interrupt an in-progress payment. Phase 10's status note rewritten from "not yet fully closed" to a closed statement naming all four resolutions. Updated the Insights-page deliverable's `08_Decision_Log` cross-reference to v1.60. **Note (this pass):** this table's v1.19-v1.22 rows were found physically out of chronological order (v1.20 preceding v1.19, v1.22 preceding v1.21) — a pre-existing ordering defect, not a content error — and were reordered in this pass; no row's narration text was altered. |
| v1.24 | Frozen | **Recorded DEC-087, closing out Phase 11 (Developer/Test Utilities) and Phase 12 (Testing/QA) in full.** Phase 11's status rewritten from a planned utility list to built-and-deployed: all 5 utilities built behind a single `dev-utilities` Edge Function, and the Restrictions list gained a new bullet recording the mid-session narrowing to a 3-account allowlist (client- and server-side), tighter than this phase's original any-authenticated-user restriction. Phase 12's status rewritten from planned goals/deliverables to a built-and-tested record: deliberately rescoped from a full RTM cycle to a lightweight 3-area pass (E2E, targeted RLS/premium spot-check, accessibility) per the user's own direct challenge to the value of a full cycle given Phases 1-10's own extensive live-testing; each original goal and deliverable annotated with its actual disposition (done, done-but-scoped-differently, or deliberately not produced as a formal document). Full defect detail — 6 real bugs found and fixed this session — lives in DEC-087's own register entry (`08_Decision_Log_v1.61`) rather than repeated here. Updated the Insights-page deliverable's `08_Decision_Log` cross-reference to v1.61 (this document's own bump created that citation drift, closed in the same pass). No other phase sequencing changed. **Further correction (same day, second-order cascade closure):** three more stale citations found and fixed — the Depends On field's external `11_API_Integration_Architecture` citation (stuck at v1.13) to v1.14; the Phase 3 Dependencies list's `03_Information_Architecture`, `05_Design_System`, and `06_Component_Library` citations (stuck at v1.16, v1.32, v1.27) to v1.17, v1.33, and v1.28; and the lower-cost-alternatives AI Strategy cross-reference to `01_Product_Strategy` (stuck at v1.18) to v1.19. Not bumping the version again for this. |
| v1.25 | Current | **Recorded DEC-088, closing out Phase 13 (Deployment) by documenting as-built reality rather than the originally-planned staging→approval→production pipeline.** Each Phase 13 goal and deliverable annotated with its actual disposition: production deployment done and continuous since Phase 6 (Vercel + GitHub Actions, both auto-triggered on push to `main`); staging deployment not done, an accepted gap given the capstone's fixed demo-day timeline; the verification checklist and rollback plan both exist as specs in `15_Deployment_Architecture` but were exercised informally (per-phase live-testing, `git revert`-based fixes) rather than as formal gates/incidents. Updated the Dependencies line's `15_Deployment_Architecture` citation to v1.13. **Further correction (same day):** this document's own body citations to `08_Decision_Log` (Phase 9's Insights-page bullet, Phase 11's status line, Phase 12's status line), stuck at v1.61, updated to v1.62, since doc 08 bumped again in this same DEC-088 pass. No other phase sequencing changed. **Further correction (documentation audit pass):** the Dependencies line's `10_Database_Architecture` citation and two `14_Testing_Strategy` body citations, left stale, corrected to v1.22 and v1.17. Not bumping the version again for this either. |
