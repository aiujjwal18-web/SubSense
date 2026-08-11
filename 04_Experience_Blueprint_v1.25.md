# 04 Experience Blueprint v1.25

## Document Control

| Field | Value |
| --- | --- |
| Document ID | SXB-001 |
| Product | SubSense |
| Version | v1.25 |
| Status | Frozen implementation baseline |
| Source of Truth | Screen and journey implementation guidance |
| Depends On | 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19, 02_Experience_Strategy_v1.20, 03_Information_Architecture_v1.17 |

## Purpose

This document translates strategy and information architecture into screen-by-screen implementation guidance.

It answers: if a designer or an AI-assisted builder (Cursor, per DEC-053) starts tomorrow, exactly what experience should be built?

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
- The "AI Insight" content item above was implemented as two separate placeholder UI slots — "AI Insights" and "Recommended Reviews" — pending Phase 7's real AI-generated content, and DEC-067 left merged-vs-split unresolved ("one concept split across two UI slots"). **Resolved during Phase 7 implementation planning (DEC-079 same-day extension, doc 08 v1.52):** both placeholders are deleted and replaced with one merged "AI Insights" section rendering up to 3 AI Decision Cards (C-003) — matching C-003's actual shape (one card per subscription) and DEC-067's own "one concept" framing, since doc 06 never specced a second, distinct "Recommended Reviews" component to preserve. Primary content above intentionally still lists it as one line for this reason.
- Per DEC-079: once Phase 7 ships, this screen's AI Insight batch covers at most the 3 subscriptions currently in Critical or Upcoming renewal urgency (`computeRenewalUrgency`, DEC-054) — not every active subscription — read lazily from cached `ai_recommendations` rows rather than generated live on every load. Subscription Details' own "AI Insight" content item (below) always requests a single insight for that one subscription regardless of urgency tier.
- **Free/premium split — built (DEC-083, doc 08 v1.56; decided at DEC-082, doc 08 v1.55):** the up-to-3 batch above is a premium-tier behavior. A free-tier user's batch is hard-capped at 1 insight (the single highest-urgency subscription), with an inline muted note explaining the cap rather than a partial teaser or upsell card for the other 2 — checked both client-side and server-side via `user_has_active_premium(uuid)` against `user_profiles.is_premium`/`premium_expires_at` (`10_Database_Architecture_v1.22`), which now has real readers for the first time. Premium also gets exclusive access to the Phase 9 Insights page in full (`16_Implementation_Roadmap_v1.25`).
- **"Shared Payment Activity" — built (DEC-087, doc 08 v1.62):** previously a hardcoded static placeholder with no query behind it at all. Now a real `useSharedPaymentActivity` hook, resolved per-row against the viewer's own membership (a user can own one share and be a member of another simultaneously, so a single owner/member flag on the whole share would mislabel half the list). Narrowed to a 7-day window (due date within 7 days, overdue rows deliberately kept, not excluded) with day countdowns, matching the Upcoming Renewals section's own cutoff convention — the unfiltered list of every open payment request stays fully visible on the Shared Subscriptions page, unaffected.
- **"Potential Savings" — still not built, now hidden from view (DEC-087, doc 08 v1.62):** confirmed deliberately out of scope and unbuilt since before this phase (doc 16, doc 06 C-007). The static placeholder previously shown on this screen was removed from view for the live demo — a UI-only change, no calculation logic added. The reusable engine expected to eventually power this (`findCostComparisons`, already built for the Insights page's Cost Comparison Card) is named in a code comment at the removal site.

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

- Per DEC-079 (same-day extension, live-verified): this screen's "AI Insight" content item does not call `ai-generate-insight` for Archived or Paused subscriptions. Archived shows the neutral "unavailable" state with no OpenAI call and no Regenerate action, matching this project's Archive-first principle. Paused shows a static "insight resumes when this subscription is active again" message, extending DEC-064's existing paused-deprioritization pattern (already excluded from urgency, Upcoming Renewals, and Recommended Reviews) to this surface rather than leaving Paused as an accidental exception. Every other lifecycle state requests a real single insight regardless of urgency tier, per DEC-079's original scope.

- Per DEC-080: "Manage sharing" is the entry point for **both** setting up sharing on a not-yet-shared subscription ("Share this subscription," first-time setup: pick split method, add the first member) and managing an already-shared one — not a separate flow, and not a step folded into Add/Edit Subscription. Sits alongside the existing Paid/Paused/Archive quick actions (DEC-064) on this same screen. `shared_subscriptions.subscription_id`'s unique-per-subscription schema means sharing is always an attribute added to a subscription already being tracked here, never an independently-created object.

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
- **Per DEC-083 (Phase 9 built this session):** premium-exclusive entirely, gated both client-side (no network call for a free-tier user) and server-side (the real boundary, since RLS has no premium concept). What actually shipped from this blueprint's Primary content list: Monthly spend (per active currency, never combined/converted), Category analysis in the narrow form of duplicate/overlap detection (same catalog item, or shared category) and an intra-portfolio Cost Comparison against the user's own category average, and AI insights (one AI-written summary paragraph framing the deterministic figures above, never computing or inventing a number itself). **Not built this phase, still open against this blueprint:** Annual spend and Spending trends (a time-series/historical view) — neither exists on the Insights page as shipped. Savings opportunities is covered only in the narrow "priced above your own category's average" sense above, not a broader recommendation engine — no competitor or market-pricing data exists anywhere in this schema to support a stronger claim.

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

Implementation notes:

- **Per DEC-083 (Phase 9+10 built this session):** only "Plan or premium demonstration status" from this blueprint's Primary content list has been built — a Tier Badge, a Plan Comparison Card reading real `premium_plans` rows, and an Upgrade action running the full Razorpay Test Mode checkout flow end to end. Personal information, Google account, Currency, Time zone, Reminder preferences, Notification preferences, and Sign out are all still unbuilt against this blueprint, deliberately out of scope for this pass (scoped strictly to plan comparison and upgrade, per the build's own plan).

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
| v1.3 | Frozen | Added payment method field to Add Subscription and rail-specific cancellation guidance to Subscription Details, per DEC-032. Corrected title/Document Control version to match filename (was misstated as v1.2) and updated dependency reference to 01_Product_Strategy_v1.3. |
| v1.4 | Frozen | Updated dependency references to 00_Project_Governance_v1.3, 01_Product_Strategy_v1.5, and 02_Experience_Strategy_v1.3, following the brand kit finalization under DEC-042. |
| v1.5 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, and 03_Information_Architecture_v1.5 — the 02 reference had been left at v1.3 since the DEC-042 pass despite two subsequent 02 version bumps, found during a citation-integrity check. |
| v1.6 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, and 03_Information_Architecture_v1.5, as part of the cascade patching 11_API_Integration_Architecture's own internal reference-integrity gaps. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.9, 01_Product_Strategy_v1.8, 02_Experience_Strategy_v1.9, and 03_Information_Architecture_v1.6, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.10, 01_Product_Strategy_v1.9, 02_Experience_Strategy_v1.10, and 03_Information_Architecture_v1.7, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.11, 01_Product_Strategy_v1.10, 02_Experience_Strategy_v1.11, and 03_Information_Architecture_v1.8, as part of the cascade recording DEC-047 and its version bump to 10_Database_Architecture_v1.7, batched with the notification-template SQL patch (file 23). |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.12 and 02_Experience_Strategy_v1.12, as part of the cascade recording DEC-049 ("Ledger Dark" visual direction). No screen/journey guidance content changed. |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.13, 02_Experience_Strategy_v1.13, and 03_Information_Architecture_v1.10 (this last one had been left stale at v1.8 since before the v1.10 pass, missed at the time), as part of the cascade recording DEC-050 (Ledger Dark extended to light-mode/email surfaces). No screen/journey guidance content changed. |
| v1.12 | Frozen | Recorded DEC-053: the Purpose statement's "if a designer or Lovable starts tomorrow" updated to name Cursor as the AI-assisted builder, reflecting the tool replacement. Updated dependency reference to 01_Product_Strategy_v1.11. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.14, 02_Experience_Strategy_v1.14, and 03_Information_Architecture_v1.11 -- all three had drifted stale as a direct side effect of this same DEC-053 cascade continuing outward from v1.12. No screen/journey guidance content changed. |
| v1.14 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.15, 01_Product_Strategy_v1.12, 02_Experience_Strategy_v1.15, and 03_Information_Architecture_v1.12, as the same DEC-053 cascade settled to its final versions. No screen/journey guidance content changed. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 01_Product_Strategy_v1.13, 02_Experience_Strategy_v1.16, and 03_Information_Architecture_v1.13, as 01/02/03 continued moving within the same DEC-053 cascade. No screen/journey guidance content changed. **Correction (same day, caught before this pass finished):** the dependency reference to 00_Project_Governance corrected to v1.16, since it moved again after this row was written. Not bumping the version again for this. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.17, 01_Product_Strategy_v1.14, 02_Experience_Strategy_v1.17, and 03_Information_Architecture_v1.14, following DEC-054. No screen/journey guidance content changed. **Correction (same day):** the dependency reference to 00_Project_Governance corrected to v1.18, since 00 moved again later in the same cleanup pass. Not bumping the version again for this. |
| v1.17 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.19, 01_Product_Strategy_v1.15, 02_Experience_Strategy_v1.18, and 03_Information_Architecture_v1.15, following DEC-055 (logo wordmark font resolved, logo formally implemented). No screen/journey guidance content changed. **Correction (same day):** the 00_Project_Governance reference corrected to v1.20, since 00 moved again later in this same cleanup pass. Not bumping the version again for this. |
| v1.19 | Frozen | Recorded DEC-079: added an Implementation notes bullet under Decision Workspace Blueprint stating that once Phase 7 ships, its AI Insight batch covers at most the 3 subscriptions in Critical/Upcoming renewal urgency (`computeRenewalUrgency`, DEC-054), read lazily from cached `ai_recommendations` rather than generated live on every load — and that Subscription Details always requests a single insight regardless of urgency tier. Primary content lists unchanged; this is an operational detail, not a new content item. No dependency-reference change this pass. |
| v1.18 | Frozen | Closed an open question flagged in DEC-067 (doc 08): the Decision Workspace Blueprint's five-item Primary content list names a single "AI Insight" line, but the shipped screen actually renders it as two separate placeholder UI slots — "AI Insights" and "Recommended Reviews" — pending Phase 7's real AI-generated content. User confirmed this is one concept split across two UI slots for now, not two distinct Primary content items, so the Primary content list itself is unchanged; added a new Implementation notes bullet under Decision Workspace Blueprint stating the split explicitly and citing DEC-067, so this isn't left as an undocumented doc-vs-code gap. No dependency-reference change this pass. |
| v1.20 | Frozen | **Same-day extension of DEC-079** (doc 08 v1.52) — Phase 7 implementation planning resolved the merged-vs-split question DEC-067/v1.18 above had left open: both "AI Insights" and "Recommended Reviews" placeholders are deleted and replaced with one merged "AI Insights" section rendering up to 3 AI Decision Cards (C-003), since doc 06 never specced a second, distinct component to preserve as a separate section. Updated the same Implementation notes bullet under Decision Workspace Blueprint to state this resolution directly rather than leave the "currently two slots" framing standing. No dependency-reference change this pass. **Further correction (DEC-079 same-day extension, build completed and live-verified):** added a new Implementation notes bullet under Subscription Details Blueprint stating that Archived and Paused subscriptions are excluded from real AI Insight generation (neutral state for Archived, a static message for Paused, extending DEC-064's paused-deprioritization pattern) — both confirmed live. No dependency-reference change this pass either. |
| v1.21 | Frozen | Recorded DEC-080's entry-point resolution for Phase 8 (Shared Subscriptions): added an Implementation notes bullet under Subscription Details Blueprint stating that the existing "Manage sharing" key action is the entry point for both first-time sharing setup and ongoing management — not a step folded into Add/Edit Subscription, not a separate flow from the Shared Subscriptions landing page — sitting alongside the existing Paid/Paused/Archive quick actions (DEC-064). Primary content and Key actions lists unchanged; this clarifies which existing action owns the setup flow, not a new content item. No dependency-reference change this pass. |
| v1.23 | Frozen | Recorded DEC-083 (doc 08 v1.56): Insights Blueprint and Profile Blueprint both gained an Implementation notes bullet stating what actually shipped this session against each blueprint's original Primary content list, rather than leaving the gap between blueprint and build implicit. Insights: Monthly spend (per currency), duplicate/overlap detection, an intra-portfolio Cost Comparison card, and one AI-written summary paragraph shipped, premium-exclusive and gated both client- and server-side; Annual spend and Spending trends did not ship this phase, flagged as still open against this blueprint. Profile: only "Plan or premium demonstration status" shipped (Tier Badge, Plan Comparison Card, Razorpay Test Mode Upgrade flow); the other seven Primary content items (personal info, Google account, currency, timezone, reminder/notification preferences, sign out) remain unbuilt, deliberately out of this pass's scope. No Depends On change — 00/01/02/03 unchanged since the last bump. |
| v1.22 | Frozen | Recorded DEC-082 (doc 08 v1.55): added a Decision Workspace blueprint bullet under the "AI Insight" content item stating the free/premium AI Insight split — free-tier users get a hard-capped 1-insight batch (highest-urgency subscription only, no partial teaser for the other 2), premium-tier users get the existing up-to-3 batch from DEC-079, checked against `user_profiles.is_premium` (`10_Database_Architecture_v1.19`, a column with no reader anywhere in the built product until this gating logic is actually built). Also notes premium's exclusive full access to the Phase 9 Insights page (`16_Implementation_Roadmap_v1.20`). Decided now per DEC-082's explicit decide-now-build-later scoping; no gating code exists yet. No other Decision Workspace content changed. **Same-day correction:** the Depends On field's 01_Product_Strategy citation updated to v1.16 (same DEC-082, lower-cost-alternatives note assigned to Phase 9). Not bumping the version again for this. |
| v1.24 | Frozen | **Records DEC-083** (Phase 9+10 built and deployed, doc 08 v1.56): the Decision Workspace blueprint's free/premium AI Insight split bullet (added under v1.22 above as "decided now, gating logic not yet built") corrected to describe what's actually built — checked both client- and server-side via `user_has_active_premium(uuid)`, with an inline muted note (not a partial teaser) explaining the free-tier cap. `10_Database_Architecture` and `16_Implementation_Roadmap` cross-references updated to v1.20 and v1.21. Updated the Depends On field to 00_Project_Governance_v1.21, 01_Product_Strategy_v1.17, 02_Experience_Strategy_v1.19, and 03_Information_Architecture_v1.16. No other blueprint content changed. **Further correction (same day, second-order cascade closure):** the free/premium split bullet's `10_Database_Architecture`/`16_Implementation_Roadmap` citations, and the Depends On field's 00/01 citations, all one hop stale after tonight's DEC-085 cascade, corrected to v1.21, v1.22, v1.22, and v1.18 respectively. Not bumping the version again for this. **Further correction (DEC-086 cascade — idle-session-timeout closure, the fourth and final DEC-083 item, now built and live-verified):** the free/premium split bullet's `16_Implementation_Roadmap` citation corrected to v1.23 (Phase 9+10 now recorded as fully closed). Not bumping the version again for this either. |
| v1.25 | Current | **Recorded DEC-087** (Phase 11+12 built and tested, doc 08 v1.61): added two new Implementation notes bullets under Decision Workspace Blueprint. "Shared Payment Activity" corrected from an implied-built Primary content item to its real history — was a static placeholder with no query behind it, now built as a real per-membership-row query, narrowed to a 7-day due-date window with day countdowns, matching Upcoming Renewals' own cutoff convention. "Potential Savings" noted as still genuinely unbuilt (confirmed predating this phase) but now hidden from view rather than left as a visible empty placeholder for the live demo — a UI-only change, not a build. Primary content list itself unchanged; both items were already named there, this only adds their real implementation status. **Further correction (same day, second-order cascade closure):** the Depends On field's 00/01/02/03 citations, all bumped in turn during this same closure pass, corrected to 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19, 02_Experience_Strategy_v1.20, and 03_Information_Architecture_v1.17. Not bumping the version again for this. **Further correction (recording DEC-088 — Phase 13 closed by documenting as-built deployment reality):** the "Shared Payment Activity" and "Potential Savings" bullets' `doc 08` citations updated to v1.62, and the Insights-page premium-access bullet's `16_Implementation_Roadmap` citation to v1.25. Not bumping the version again for this either. **Further correction (documentation audit pass):** the free/premium-split bullet's `10_Database_Architecture` body citation, left stale, corrected to v1.22. Not bumping the version again for this either. |
