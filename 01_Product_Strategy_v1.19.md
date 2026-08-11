# 01 Product Strategy v1.19

## Document Control

| Field | Value |
| --- | --- |
| Document ID | PST-001 |
| Product | SubSense |
| Version | v1.19 |
| Status | Frozen implementation baseline |
| Source of Truth | Product strategy |
| Depends On | 00_Project_Governance_v1.23 |

## Purpose

This document defines what SubSense is, who it serves, what problem it solves, what belongs in the MVP, and what remains outside the current release.

## Executive Summary

SubSense is an AI-assisted subscription decision platform for individuals and small shared groups. It helps users understand recurring subscription spending, receive contextual renewal reminders, manage shared subscription payments, and make informed renewal decisions.

The product focuses on awareness and decision support, not direct subscription control.

## Problem Statement

Modern users pay for recurring subscriptions across entertainment, productivity, AI tools, education, cloud services, fitness, and memberships. These payments often renew automatically, which creates several problems:

- Users forget renewal dates.
- Users underestimate annual spending.
- Duplicate or overlapping services go unnoticed.
- Shared subscription payments become difficult to track.
- Cancellation decisions are delayed until after renewal.
- Existing tools mostly report spending after the fact.

## Target Users

Primary users:

- Individuals with multiple recurring subscriptions.
- Students and professionals paying for AI, productivity, streaming, learning, and utility subscriptions.

Secondary users:

- Families sharing subscriptions.
- Roommates splitting streaming or software costs.
- Couples managing shared digital services.
- Small friend groups with recurring shared expenses.

Excluded from MVP:

- Enterprise teams.
- Large organizations.
- Procurement departments.
- Full business spend management.

## Value Proposition

SubSense helps users answer:

- What am I paying for?
- What renews soon?
- How much does this cost me annually?
- Is this subscription still worth reviewing?
- Who owes what for shared subscriptions?
- What should I pay attention to today?

## Product Pillars

| Pillar | Meaning |
| --- | --- |
| Subscription Awareness | Know what subscriptions exist. |
| Renewal Awareness | Know when renewals occur. |
| Financial Awareness | Understand monthly and annual cost. |
| AI Decision Support | Receive contextual, explainable insight before renewal. |
| Shared Subscription Management | Track split amounts and reminder status. |

## Product Principles

- User control first.
- Decision support over automation.
- Workflow first.
- Explainable AI.
- Savings before spending.
- MVP discipline.
- Email-first communication.
- Decision support, never decision execution.

## MVP Scope

### Included

- Google Sign-In through Supabase Auth.
- Email/password support where needed by Supabase Auth.
- User profile and preferences.
- Subscription catalog.
- Custom subscription creation.
- Add, view, edit, archive subscriptions.
- Billing frequency support: monthly, every 28 days, yearly, and custom.
- Currency support: INR and USD.
- Monthly equivalent and annual equivalent calculations.
- Decision Workspace.
- Upcoming renewal visibility.
- AI insight and renewal review prompts.
- Duplicate subscription awareness.
- Shared subscriptions.
- Shared member management.
- Payment request status: pending and paid.
- Email reminders through Resend.
- Post-renewal review prompt.
- Payment rail awareness (UPI AutoPay, card e-mandate, app-store billing, or manual) with rail-appropriate cancellation guidance.
- Insights for recurring spend and annual cost.
- Razorpay Test Mode for premium demonstration.
- Developer/Test Utilities for capstone evaluation.

### Excluded

- Automatic bank account integrations.
- Automatic Gmail/Outlook scanning.
- Apple/Google subscription sync.
- Browser extension.
- Android usage detection.
- OCR receipt scanning.
- Production billing and live Razorpay payments.
- Automated third-party cancellation.
- Enterprise roles and permissions.
- Mobile app.

## AI Strategy

AI is used to turn renewal reminders into decision moments.

AI responsibilities:

- Generate reminder context.
- Explain annualized subscription cost.
- Suggest when a subscription should be reviewed.
- Identify possible duplicates.
- Suggest lower-cost alternatives as informational context — **built (DEC-083, doc 08 v1.56)** as an intra-portfolio category-average cost comparison on the premium-gated Phase 9 Insights page (`16_Implementation_Roadmap_v1.25`), not a true lower-cost-alternative claim: no competitor or market-pricing data exists anywhere in this schema. The shipped card label was flagged during DEC-083 as overpromising what the comparison actually delivers; renamed to "Worth a Second Look" under DEC-085 (doc 08 v1.62), committed, pushed, and live-verified.
- Produce user-friendly explanations.

AI boundaries:

- AI does not update subscriptions automatically.
- AI does not execute payment, cancellation, renewal, or downgrade actions.
- AI does not claim one option is objectively better unless the criteria are explicit.
- AI output must be explainable and reviewable.

## Reminder Strategy

Supported reminders:

- Seven days before renewal.
- Two days before renewal.
- Renewal day.
- Post-renewal check-in.
- Shared payment reminder.
- Developer-triggered test reminder.
- Monthly digest (DEC-041) — see Retention Strategy below.
- Lapsed-user re-engagement (DEC-041) — see Retention Strategy below.

The user may configure reminder timing where supported, but the product remains email-first for MVP.

## Retention Strategy (DEC-041)

Renewal-triggered reminders alone leave a gap: a user with one or two subscriptions on far-apart renewal dates could receive no email, and have no reason to open SubSense, for months. Retention is addressed even at MVP/capstone scale rather than deferred, because a product with no return mechanism cannot demonstrate its core value loop regardless of build stage.

**Active user (MVP definition)**: a user whose `users.last_login_at` falls within the trailing 30 days.

**Retention metric**: Day 30 retention rate — of users who reached Activation (added at least one subscription, per the Activation Rate metric above), the percentage still active 30 days after their activation date. Target: at least 40 percent. This target is directional for a capstone-scale MVP, not a benchmarked figure, and should be revisited once real usage data exists.

**Monthly digest**: every user with at least one non-archived subscription receives one email per calendar month, independent of any renewal date, summarizing standing monthly/annual spend and any AI insights generated since the last digest. This guarantees a minimum one-touchpoint-per-month cadence regardless of individual renewal timing.

**Lapsed-user re-engagement**: a user whose `last_login_at` exceeds 45 days receives a single re-engagement email (capped at one per rolling 45-day window), framed the same way as all other AI/product copy per `02_Experience_Strategy`'s AI Experience Standard — informational and calm ("here is where your money is going"), never fear-based or manipulative urgency copy.

Both mechanisms reuse the existing reminder/notification infrastructure (`reminders`, `notification_templates`, Resend email delivery) rather than introducing a new subsystem, per `GP-007` Reuse Before Creation.

## Subscription Strategy

Subscription creation uses a searchable catalog. If a service is missing, users can create a custom subscription.

Custom subscriptions:

- Are saved to the user's account immediately.
- May be reviewed before becoming part of the global catalog.
- Should not pollute the master catalog with duplicates or misspellings.

## Sharing Strategy

Shared subscriptions allow users to:

- Add members.
- Edit member details.
- Remove members from active splits.
- Preserve payment history.
- Define split amounts.
- Track paid and pending status.
- Send email reminders.

Payment history should not be lost when a member is removed from an active split.

## Currency and Billing Strategy

MVP currencies:

- INR.
- USD.

Supported billing frequencies:

- Monthly.
- Every 28 days.
- Yearly.
- Custom.

The database remains extensible for additional currencies and billing intervals.

Each subscription also records its payment rail: UPI AutoPay, card e-mandate, app-store billing, or manual. SubSense never cancels or modifies a mandate on the user's behalf; it uses the rail only to tell the user where to go to cancel it themselves, consistent with the Product Philosophy in `00_Project_Governance_v1.23`.

## Freemium and Capstone Strategy

Free tier:

- Core subscription management.
- Standard reminders.
- Basic insights.

Premium demonstration:

- Razorpay Test Mode simulates upgrade flow.
- No live financial processing is part of MVP.
- Premium access may be demonstrated through Developer/Test Utilities.

Future premium features may include advanced AI insights, expanded reporting, and additional reminder capabilities.

## Solution Architecture Summary

| Layer | Technology |
| --- | --- |
| Frontend | Cursor (AI-assisted local development, DEC-053), building directly against the Subsense-web repository |
| Hosting | Vercel |
| Domain | `subsense.co.in`, registered business domain and support email (DEC-048) |
| Backend | Supabase / backend services |
| Database | Supabase PostgreSQL |
| Authentication | Supabase Auth plus Google Sign-In |
| AI | OpenAI API |
| Email | Resend |
| Payments | Razorpay Test Mode |
| Version Control | GitHub |
| CI/CD | GitHub Actions, future-ready |

## Success Criteria

The MVP succeeds when users can:

- Create an account.
- Add subscriptions quickly.
- View active subscriptions in one place.
- Understand monthly and annual recurring spend.
- Receive renewal reminders.
- Review AI-supported subscription guidance.
- Manage shared subscription payments.
- Complete core flows without architectural or UX ambiguity.

### Measurable MVP Success Metrics (DEC-040)

Capability checklist above defines *what* must work. The following numeric targets define *how well*, and are the pass/fail bar for the Exit Criteria in `14_Testing_Strategy_v1.17` and the Week 3 checkpoint in that same document:

| Metric | Target | Measured By |
| --- | --- | --- |
| Activation rate | At least 80 percent of new accounts add one subscription within the first session | Onboarding flow analytics/event log |
| Time to first subscription | Median under 3 minutes from account creation to first saved subscription | Timestamp diff, account creation to `subscriptions` insert |
| Reminder delivery success rate | At least 99 percent of due reminders result in a `notifications` row with delivered status within 15 minutes of the scheduled time | `reminder_history` and `notifications` audit per `10_Database_Architecture_v1.22` |
| AI insight generation success rate | At least 95 percent of AI insight requests return a usable recommendation rather than the fallback "insight unavailable" state | `ai_recommendations` success/fallback ratio, per `11_API_Integration_Architecture_v1.14` error AI_003 |
| Shared payment completion rate | At least 90 percent of `payment_requests` reach a final paid or archived state within 14 days of creation | `payment_requests` status/age query |
| Core flow error rate | Under 1 percent of Path A/Path B requests on primary flows (add subscription, mark paid, generate insight) return an unhandled error | Error logs / `audit_logs` |
| Demo acceptance | All 12 Critical E2E Test Scenarios in `14_Testing_Strategy_v1.17` pass with zero Critical defects open | QA sign-off per Exit Criteria |

These targets are frozen alongside this document; the pass/fail bar itself does not change without change control, though the underlying analytics implementation may evolve.

DEC-040 measures activation and correctness; none of its seven metrics measure whether a user stays. The Day 30 retention rate defined under Retention Strategy (DEC-041) above is the eighth metric in this family and uses the same measurement discipline: a numeric target, not a task checklist.

## Future Roadmap

Future enhancements:

- Email import.
- Bank transaction intelligence.
- Usage detection.
- Browser extension.
- Mobile app.
- Subscription cancellation assistant.
- Price increase alerts.
- Family workspace.
- Advanced reports.
- Expanded currencies.
- Live billing and production payment support.

## Validation Checklist

| Check | Status |
| --- | --- |
| Problem defined | Complete |
| Audience defined | Complete |
| MVP scope defined | Complete |
| AI boundary defined | Complete |
| Payment boundary defined | Complete |
| Technical stack defined | Complete |
| Deferred scope defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.1 | Frozen | Architecture Freeze product strategy. |
| v1.2 | Frozen | Implementation Freeze alignment, Razorpay Test Mode, tooling, and documentation package references. |
| v1.3 | Frozen | Added payment rail awareness (UPI AutoPay, card e-mandate, app-store, manual) to MVP scope per DEC-032. Corrected title/Document Control version to match filename (was misstated as v1.2) and added measurable MVP success metrics per DEC-040. |
| v1.4 | Frozen | Added Retention Strategy: active-user definition, Day 30 retention metric, monthly digest, and lapsed-user re-engagement reminder, plus two new reminder types, per DEC-041. |
| v1.5 | Frozen | Updated dependency reference to 00_Project_Governance_v1.3 and cross-references to 14_Testing_Strategy_v1.2, following the brand kit finalization under DEC-042. |
| v1.6 | Frozen | Corrected a stale dependency reference (00_Project_Governance_v1.3, three governance version bumps behind) to 00_Project_Governance_v1.8, and updated the two 14_Testing_Strategy cross-references to v1.3. This was a housekeeping fix flagged during the DEC-045 pass and closed out separately; no new decision or scope change. |
| v1.7 | Frozen | Corrected the stale `11_API_Integration_Architecture_v1.0` cross-reference in the Measurable MVP Success Metrics table (AI insight generation success rate, error AI_003) to v1.1, and updated the dependency reference to 00_Project_Governance_v1.8, as part of the cascade patching 11's own internal reference-integrity gaps. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 00_Project_Governance_v1.9 and the Measurable MVP Success Metrics cross-reference to 11_API_Integration_Architecture_v1.2, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 00_Project_Governance_v1.10, the Reminder delivery success rate cross-reference to 10_Database_Architecture_v1.5, the AI insight generation success rate cross-reference to 11_API_Integration_Architecture_v1.3, and the two Testing Strategy cross-references to 14_Testing_Strategy_v1.6, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion) and its version bump to 10_Database_Architecture. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 00_Project_Governance_v1.11, the Reminder delivery success rate cross-reference to 10_Database_Architecture_v1.7, the AI insight generation success rate cross-reference to 11_API_Integration_Architecture_v1.4, and the two Testing Strategy cross-references to 14_Testing_Strategy_v1.7, as part of the cascade recording DEC-047 and its version bump to 10_Database_Architecture, batched with the notification-template SQL patch (file 23). A follow-up pre-PRD audit caught the dependency reference to 00_Project_Governance and the two Testing Strategy cross-references both one further version behind (00 to v1.13, 14 to v1.8) -- now corrected. Not bumping the version again for this. |
| v1.11 | Frozen | Recorded DEC-053: the Solution Architecture Summary's Frontend row changed from Lovable to Cursor (AI-assisted local development, building directly against the Subsense-web repo), the API Testing row (Postman) was removed as no longer planned, and a new Domain row was added for the registered `subsense.co.in` business domain (DEC-048). Authentication row unchanged — Google Sign-In via Supabase Auth remains the plan. |
| v1.12 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and Product Philosophy cross-reference to 00_Project_Governance_v1.15, the two Testing Strategy cross-references to 14_Testing_Strategy_v1.10, and the AI insight generation success rate cross-reference to 11_API_Integration_Architecture_v1.6 -- all had drifted stale as the DEC-053 cascade continued to settle. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated the two Testing Strategy cross-references to 14_Testing_Strategy_v1.11, the Reminder delivery success rate cross-reference to 10_Database_Architecture_v1.8, and the AI insight generation success rate cross-reference to 11_API_Integration_Architecture_v1.7, as all continued moving within the same DEC-053 cascade. **Correction (same day, caught before this pass finished):** the dependency reference and Product Philosophy cross-reference to 00_Project_Governance corrected to v1.16, and the two Testing Strategy cross-references corrected to 14_Testing_Strategy_v1.12, since both moved again after this row was written. Not bumping the version again for this. |
| v1.14 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and Product Philosophy cross-reference to 00_Project_Governance_v1.17, following DEC-054 (frozen Renewal Urgency Indicator day-thresholds). **Correction (same day):** the dependency reference corrected to 00_Project_Governance_v1.18, since 00 moved again later in the same cleanup pass (closing the 10/11/12/13/14/15/16/09 citation drift). Not bumping the version again for this. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 00_Project_Governance_v1.19, following DEC-055 (logo wordmark font resolved, logo formally implemented). **Correction (same day):** corrected to 00_Project_Governance_v1.20, since 00 moved again later in this same cleanup pass. **Further correction (same day, full folder grep audit):** four pre-existing stale body citations found and fixed, predating today's DEC-055 cascade entirely — the Product Philosophy cross-reference (00, one more version behind than the Depends On field itself), the Exit Criteria/Week-3-checkpoint and Demo Acceptance cross-references to 14_Testing_Strategy (stuck at v1.12), the Reminder Delivery metric's cross-reference to 10_Database_Architecture (stuck at v1.8), and the AI Insight metric's cross-reference to 11_API_Integration_Architecture (stuck at v1.7) — all now corrected to 00 v1.20, 14 v1.14, 10 v1.10, 11 v1.9. Not bumping the version again for this. **Further correction (DEC-068 cascade — Phase 6 reminder-scheduling architecture):** the Reminder Delivery metric's cross-reference and the AI Insight metric's cross-reference updated to 10_Database_Architecture_v1.12 and 11_API_Integration_Architecture_v1.10. Not bumping the version again for this either. **Further correction (DEC-069 cascade — reminders CHECK constraint loosening, new audit_action enum value):** the Reminder Delivery metric's cross-reference updated to 10_Database_Architecture_v1.13. Not bumping the version again for this either. **Further correction (DEC-070 cascade — reminder lifecycle fix):** the Reminder Delivery metric's cross-reference updated to 10_Database_Architecture_v1.14. Not bumping the version again for this either. **Further correction (DEC-071 cascade — post_renewal_checkin paused-exclusion fix):** the Reminder Delivery metric's cross-reference updated to 10_Database_Architecture_v1.15. Not bumping the version again for this either. **Further correction (DEC-079 same-day extension — Phase 7 implementation planning):** the AI Insight metric's cross-reference updated to 11_API_Integration_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-080 cascade — Phase 8 architecture forks resolved):** the Reminder Delivery metric's cross-reference updated to 10_Database_Architecture_v1.16. Not bumping the version again for this either. **Further correction (DEC-080 same-day extension — Phase 8 technical-planning gaps):** the Reminder Delivery metric's cross-reference updated to 10_Database_Architecture_v1.17. Not bumping the version again for this either. **Further correction (DEC-080 live-testing extension):** the Reminder Delivery metric's cross-reference updated to 10_Database_Architecture_v1.18. Not bumping the version again for this either. |
| v1.16 | Frozen | Recorded DEC-082 (doc 08 v1.55): the AI Strategy's "Suggest lower-cost alternatives as informational context" bullet — previously listed here with no owning build phase — now cross-references Phase 9 Insights (`16_Implementation_Roadmap_v1.20`) as where it's assigned, and notes it's gated to premium users only, decided now but not yet built. **Same-day cascade:** the Reminder Delivery metric's cross-reference updated to 10_Database_Architecture_v1.19 (DEC-081/082 closing out Phase 8 — Phase 6 Cron/JWT-gateway regression fixed, plus this same premium-gating decision). No other AI Strategy or MVP Success Metrics content changed. |
| v1.17 | Frozen | **Records DEC-083** (Phase 9+10 built and deployed, doc 08 v1.56): the lower-cost-alternatives AI Strategy bullet updated from "decided, not yet built" to built — describes what actually shipped (an intra-portfolio category-average cost comparison, not a true competitor-pricing comparison, since no such data exists in this schema), cross-references `16_Implementation_Roadmap_v1.21`, and flags the shipped card label as pending a rename per DEC-083. Fixed two pre-existing stale cross-references caught during this document's own grep check: the AI insight generation success rate metric's `11_API_Integration_Architecture` citation was stuck at v1.11, corrected to v1.12; the Reminder delivery success rate metric's `10_Database_Architecture` citation was stuck at v1.19, corrected to v1.20. No other AI Strategy or MVP Success Metrics content changed. **Correction (same day, full grep audit):** the Depends On field and the Product Philosophy cross-reference (payment-rail note) to `00_Project_Governance`, found stuck at v1.20, corrected to v1.21, since 00 moved again later in this same cleanup pass. Not bumping the version again for this. |
| v1.18 | Frozen | Housekeeping pass, not tied to a new DEC: the AI insight generation success rate metric's `11_API_Integration_Architecture` citation, stuck at v1.12, corrected to v1.13, and the Depends On field's `00_Project_Governance` citation corrected to v1.22, as part of the cascade recording DEC-085 (currency-drop fix, Cost Comparison Card rename). The AI Strategy bullet's own "shipped card label pending a rename" flag from v1.17 above is now resolved by DEC-085 — not re-edited in this pass since it already correctly names the rename as pending, not yet stating it as done; the actual rename is documented in doc 06 and doc 08, not here. **Further correction (same day, second-order cascade closure):** three more one-hop-stale live citations found and fixed — the Product Philosophy cross-reference to `00_Project_Governance` (stuck at v1.21, corrected to v1.22), and the MVP Success Metrics table's two `14_Testing_Strategy` citations plus its `10_Database_Architecture` citation (all stuck at their pre-tonight versions, corrected to v1.16 and v1.21 respectively). Not bumping the version again for this. **Further correction (same day, second-order audit continued):** the AI Strategy bullet's own "shipped card label pending a rename" note was itself stale — DEC-085 has since renamed the card to "Worth a Second Look" (committed and pushed, live verification pending) — rewritten to state this, and its `16_Implementation_Roadmap` citation corrected from v1.21 to v1.22. Not bumping the version again for this either. **Further correction (DEC-086 cascade — idle-session-timeout closure, doc 08 v1.60, doc 16 v1.23):** the AI Strategy bullet's `16_Implementation_Roadmap` citation corrected to v1.23, and its "live verification pending" language updated to "live-verified," since DEC-085's live verification is now confirmed complete. **Note (this pass):** this table's v1.16/v1.18/v1.17 rows were found physically out of chronological order and were reordered — no row's narration text was altered. Not bumping the version again for either correction. |
| v1.19 | Current | Housekeeping pass, not tied to a new DEC: updated the lower-cost-alternatives AI Strategy bullet's `16_Implementation_Roadmap` citation to v1.24 and its `doc 08` citation to v1.61, and the Depends On field's `00_Project_Governance` citation to v1.23, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). **Further correction (same day):** the Product Philosophy section's own `00_Project_Governance` body citation (payment-rail note), missed in the pass above, updated to v1.23. Not bumping the version again for this. **Further correction (recording DEC-088 — Phase 13 closed by documenting as-built deployment reality):** the lower-cost-alternatives AI Strategy bullet's `16_Implementation_Roadmap` citation updated to v1.25 and its `doc 08` citation to v1.62. Not bumping the version again for this either. **Further correction (documentation audit pass):** the MVP Success Metrics table's `10_Database_Architecture` and `11_API_Integration_Architecture` citations and the Exit Criteria / Demo acceptance rows' `14_Testing_Strategy` citations, all left stale, corrected to v1.22, v1.14, and v1.17. Not bumping the version again for this either. |
