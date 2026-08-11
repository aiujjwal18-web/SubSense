# 00 Project Governance v1.23

## Document Control

| Field | Value |
| --- | --- |
| Document ID | GOV-001 |
| Product | SubSense |
| Version | v1.23 |
| Status | Frozen implementation baseline |
| Source | Consolidated from SubSense ChatGPT context |
| Governing Phase | Architecture Freeze v1.0 plus IR-009 Implementation Freeze |
| Owner | Product Team |

## Purpose

This document defines how SubSense product, UX, architecture, implementation, and documentation decisions are governed.

It is the highest-level control document for the repository. No downstream document may contradict this governance without a formal change-control update.

## Dependencies

| Type | Documents |
| --- | --- |
| Depends On | None |
| Provides Input To | All SubSense documentation |
| Related Documents | 08_Decision_Log_v1.62, 09_Implementation_Readiness_v1.11 |

## Product Vision

Build the most trusted AI-assisted subscription decision platform that helps users understand recurring spending, stay informed before renewals, and make confident subscription decisions without taking control away from them.

## Product Mission

Help users become aware of recurring subscription spending through timely reminders, financial context, and AI-assisted decision support while ensuring users always remain in control of renewal, cancellation, sharing, and payment decisions.

## Product Philosophy

SubSense assists decisions. It does not execute financial actions on the user's behalf.

SubSense may:

- Inform users.
- Explain cost and renewal context.
- Prioritize subscriptions needing attention.
- Recommend review actions.
- Generate reminders.

The user always:

- Decides.
- Renews.
- Cancels directly with the provider.
- Shares.
- Pays.
- Confirms or dismisses recommendations.

The application never directly controls third-party subscriptions.

## Governance Principles

| ID | Principle | Standard |
| --- | --- | --- |
| GP-001 | User Control First | Users retain final control over financial decisions. |
| GP-002 | Decision Support Over Automation | AI supports decisions but never executes subscription actions. |
| GP-003 | Simplicity Before Features | Every feature must solve a real user problem. |
| GP-004 | One Screen, One Responsibility | Each screen answers one primary user question. |
| GP-005 | One Component, One Responsibility | Each component has one clear purpose. |
| GP-006 | Architecture Before Features | Structural decisions are stabilized before scope expands. |
| GP-007 | Reuse Before Creation | Existing components and patterns are reused before new ones are created. |
| GP-008 | Progressive Complexity | Complexity is revealed only when it becomes useful. |

## Controlled Vocabulary

| Approved Term | Deprecated or Restricted Terms | Notes |
| --- | --- | --- |
| Decision Workspace | Dashboard, Decision Center | Primary authenticated home screen. |
| My Subscriptions | Subscription List | User-owned subscription library. |
| Add Subscription | Create Subscription | Subscription creation workflow. |
| Subscription Details | Subscription Information | View and review a subscription. |
| Archive | Delete | User-facing removal uses reversible archive where possible. |
| AI Insight | AI Recommendation Card | AI output must be explanatory, not directive. |
| Review Subscription | Manage Subscription | Used when prompting a decision review. |
| Renewal Confirmed | Renewed | Status label after user confirmation. |
| Developer/Test Utilities | Capstone Mode | Internal test features for evaluation. |
| Razorpay Test Mode | Payment Simulation | Non-production payment demonstration. |

## Document Ownership Matrix

| Topic | Source of Truth |
| --- | --- |
| Governance | 00_Project_Governance_v1.23 |
| Product strategy | 01_Product_Strategy_v1.19 |
| Experience principles | 02_Experience_Strategy_v1.20 |
| Navigation and structure | 03_Information_Architecture_v1.17 |
| Screen implementation guidance | 04_Experience_Blueprint_v1.25 |
| Reusable visual standards | 05_Design_System_v1.33 |
| Component specifications | 06_Component_Library_v1.28 |
| Architecture index | 07_Product_Architecture_v1.23 |
| Historical decisions | 08_Decision_Log_v1.62 |
| Implementation baseline | 09_Implementation_Readiness_v1.11 |
| Database architecture | 10_Database_Architecture_v1.22 |
| API and integrations | 11_API_Integration_Architecture_v1.14 |
| Backend architecture | 12_Backend_Architecture_v1.15 |
| Frontend architecture | 13_Frontend_Architecture_v1.21 |
| Testing strategy | 14_Testing_Strategy_v1.17 |
| Deployment architecture | 15_Deployment_Architecture_v1.13 |
| Implementation roadmap | 16_Implementation_Roadmap_v1.25 |

## MVP Scope Governance

MVP includes:

- Google-based authentication through Supabase Auth.
- Manual subscription creation and management.
- Subscription catalog and custom subscription entry.
- Decision Workspace.
- My Subscriptions.
- Subscription Details.
- Shared subscriptions and split tracking.
- Renewal reminders.
- Email-first notification through Resend.
- AI renewal guidance using OpenAI.
- Duplicate awareness and lower-cost suggestion support.
- Annual and monthly spending awareness.
- INR and USD support.
- Razorpay Test Mode for premium-feature demonstration.
- Developer/Test Utilities for capstone evaluation.

MVP excludes:

- Automatic bank import.
- Automatic email scanning.
- OCR receipt scanning.
- Automatic subscription cancellation.
- Production payment processing.
- Browser extension.
- Mobile applications.
- Enterprise administration.
- Live subscription-provider integrations.

## AI Governance

AI may:

- Generate renewal insight text.
- Explain spending and annualized cost.
- Identify likely duplicate services.
- Suggest review prompts.
- Suggest lower-cost alternatives as informational guidance.

AI must never:

- Cancel subscriptions.
- Renew subscriptions.
- Charge users.
- Modify business entities automatically.
- Claim objective superiority without clear criteria.
- Override user choice.

## Business Rules Governance

All business rules use stable IDs, such as `BR-001`.

Core locked rules include:

| Rule ID | Rule |
| --- | --- |
| BR-001 | AI never performs user actions. |
| BR-002 | Only authenticated users may access subscription data. |
| BR-006 | First login provisions a user profile. |
| BR-007 | Returning users must not create duplicate profiles. |
| BR-008 | Authentication must complete before user-specific data loads. |

Business rules must be referenced by database constraints, APIs, backend services, frontend validation, and tests rather than duplicated informally.

## Architecture Change Control

After IR-009, every architectural change follows:

1. Proposal.
2. Impact analysis.
3. Review.
4. Approval.
5. Decision Log update.
6. Affected document update.
7. Version increment.
8. Re-freeze if the change affects the implementation baseline.

Approval requirements:

| Change Category | Approval Required |
| --- | --- |
| UI copy/content | Product Owner |
| UX behavior | Product and UX |
| Business rules | Product and Architecture |
| Database schema | Architecture |
| API contracts | Architecture |
| Security | Architecture and Security |
| External integrations | Architecture |

## Documentation Completeness Standard

Every publication-quality document should include, where applicable:

- Document control.
- Purpose.
- Scope.
- Dependencies.
- Principles.
- Architecture or design specification.
- Standards.
- Business rules.
- Traceability.
- Implementation notes.
- Validation checklist.
- Version history.

## Versioning Policy

| Version Segment | Meaning |
| --- | --- |
| Major | Structural or architectural change. |
| Minor | Approved clarification or non-breaking governance update. |
| Patch | Typo, formatting, or editorial fix. |

## Traceability Standard

All implementation work must be traceable through:

Product requirement -> Architecture decision -> Business rule -> Database -> API -> Backend service -> Frontend component -> Test case -> Deployment validation.

## Validation Checklist

| Check | Status |
| --- | --- |
| Product vision defined | Complete |
| Product mission defined | Complete |
| AI boundary defined | Complete |
| MVP scope defined | Complete |
| Controlled vocabulary defined | Complete |
| Ownership matrix defined | Complete |
| Change control defined | Complete |
| Documentation standard defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Archived | Initial governance framing. |
| v1.1 | Frozen | Architecture Freeze governance baseline. |
| v1.2 | Frozen | Implementation Freeze alignment and 17-document package mapping. Updated Document Ownership Matrix and Related Documents to reference the current versions of 01, 04, 08, 10, 14, and 16 after DEC-034 corrected their internal title/version drift. |
| v1.3 | Frozen | Updated Document Ownership Matrix and Related Documents to reference 01_Product_Strategy_v1.5, 02_Experience_Strategy_v1.3, 03_Information_Architecture_v1.3, 04_Experience_Blueprint_v1.4, 05_Design_System_v1.3, 06_Component_Library_v1.3, 07_Product_Architecture_v1.3, 08_Decision_Log_v1.5, 13_Frontend_Architecture_v1.1, 14_Testing_Strategy_v1.2, 15_Deployment_Architecture_v1.1, and 16_Implementation_Roadmap_v1.3 — the last three of these were already stale against the Retention Policy (DEC-041) bump to 16 in addition to the brand kit finalization (DEC-042) that prompted this pass. |
| v1.4 | Frozen | Updated Document Ownership Matrix and Related Documents to reference 02_Experience_Strategy_v1.4, 05_Design_System_v1.4, 06_Component_Library_v1.4, 07_Product_Architecture_v1.4, 08_Decision_Log_v1.6, 13_Frontend_Architecture_v1.2, and 16_Implementation_Roadmap_v1.4, following the spacing/card/icon system closure under DEC-043. |
| v1.5 | Frozen | Updated Document Ownership Matrix and Related Documents to reference 02_Experience_Strategy_v1.5, 05_Design_System_v1.5, 06_Component_Library_v1.5, 07_Product_Architecture_v1.5, 08_Decision_Log_v1.7, 13_Frontend_Architecture_v1.3, and 16_Implementation_Roadmap_v1.5, following the micro-interaction system closure under DEC-044. |
| v1.6 | Frozen | Updated Document Ownership Matrix and Related Documents to reference 02_Experience_Strategy_v1.6, 05_Design_System_v1.6, 06_Component_Library_v1.6, 07_Product_Architecture_v1.6, 08_Decision_Log_v1.8, 13_Frontend_Architecture_v1.4, and 16_Implementation_Roadmap_v1.6, following the AI copy tone closure under DEC-045. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix to reference 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, 03_Information_Architecture_v1.5, 04_Experience_Blueprint_v1.6, 05_Design_System_v1.8, 06_Component_Library_v1.8, 07_Product_Architecture_v1.8, 08_Decision_Log_v1.10, 13_Frontend_Architecture_v1.6, 14_Testing_Strategy_v1.4, 15_Deployment_Architecture_v1.3, and 16_Implementation_Roadmap_v1.8 — closing stale governance references in 01, 03, and 04 (some several versions behind) and a badly stale 13 reference in 14 (v1.1 against a real v1.4), found during a citation-integrity check prompted by the DEC-045 pass. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix and Related Documents to reference 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, 03_Information_Architecture_v1.5, 04_Experience_Blueprint_v1.6, 05_Design_System_v1.8, 06_Component_Library_v1.8, 07_Product_Architecture_v1.8, 08_Decision_Log_v1.10, 09_Implementation_Readiness_v1.1, 10_Database_Architecture_v1.3, 11_API_Integration_Architecture_v1.1, 12_Backend_Architecture_v1.1, 13_Frontend_Architecture_v1.6, 14_Testing_Strategy_v1.4, 15_Deployment_Architecture_v1.3, and 16_Implementation_Roadmap_v1.8 — triggered by patching 11's own stale internal references (to 01, 03, and 14), per the user's approved clarification that DEC-030 pins document 11's identity/source-of-truth status, not a frozen version number. This cascaded through 09, 10, and 12 (their first version bump since Implementation Freeze) and back through every document that cites them or this document. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix and Related Documents to reference 09_Implementation_Readiness_v1.2 and 11_API_Integration_Architecture_v1.2, following the fix to 11's Depends On completeness (added 01, 03) and Supersedes field (corrected self-reference to v1.0), and the correction to 09's Architecture Integrity Review acknowledging the intentional 11/12 mutual Depends On relationship as a companion-doc contract rather than a circular build-order dependency. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix and Related Documents to reference 01_Product_Strategy_v1.9, 02_Experience_Strategy_v1.10, 03_Information_Architecture_v1.7, 04_Experience_Blueprint_v1.8, 05_Design_System_v1.10, 06_Component_Library_v1.9, 07_Product_Architecture_v1.10, 09_Implementation_Readiness_v1.3, 10_Database_Architecture_v1.5, 11_API_Integration_Architecture_v1.3, 12_Backend_Architecture_v1.3, 13_Frontend_Architecture_v1.8, 14_Testing_Strategy_v1.6, 15_Deployment_Architecture_v1.4, and 16_Implementation_Roadmap_v1.10, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion) — bumping 10_Database_Architecture rippled through every document that cites it or one of its own citers. |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix and Related Documents to reference 01_Product_Strategy_v1.10, 02_Experience_Strategy_v1.11, 03_Information_Architecture_v1.8, 04_Experience_Blueprint_v1.9, 05_Design_System_v1.11, 06_Component_Library_v1.10, 07_Product_Architecture_v1.11, 08_Decision_Log_v1.14 (closing a citation gap that predated DEC-046 -- this table had been citing 08 at a stale v1.11), 09_Implementation_Readiness_v1.4, 10_Database_Architecture_v1.7, 11_API_Integration_Architecture_v1.4, 12_Backend_Architecture_v1.4, 13_Frontend_Architecture_v1.9, 14_Testing_Strategy_v1.7, 15_Deployment_Architecture_v1.5, and 16_Implementation_Roadmap_v1.11, as part of the cascade recording DEC-047 (post_renewal_checkin fixed offset, finalized notification_templates copy) -- batched with the notification-template SQL patch (file 23) per the user's chosen deferral. |
| v1.12 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix to reference 02_Experience_Strategy_v1.12, 03_Information_Architecture_v1.9, 04_Experience_Blueprint_v1.10, 05_Design_System_v1.12, 06_Component_Library_v1.11, 07_Product_Architecture_v1.12, 13_Frontend_Architecture_v1.10, 14_Testing_Strategy_v1.8, and 16_Implementation_Roadmap_v1.12, as part of the multi-hop cascade recording DEC-049 ("Ledger Dark" visual direction: 05/06 changed directly; 00, 02, 07, 13, 16 cite 05/06 directly; 03, 04, 14 in turn cite 00/02/13). Also corrected the Historical decisions row from 08_Decision_Log_v1.14 to v1.16 -- this table had drifted two versions behind after DEC-048 (which did not name 00 among its affected documents and so did not trigger this cascade). Deliberately did not chase the next hop (01, 11, 15 each cite 14_Testing_Strategy at its old version number) -- 14's own content did not change, only its header version, so this is left as low-stakes drift for the next natural cascade, consistent with how DEC-048's drift was tolerated until this pass. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix's Reusable visual standards row to 05_Design_System_v1.13 and the Historical decisions row to 08_Decision_Log_v1.17, as part of the cascade recording DEC-050 (Ledger Dark extended to light-mode/email surfaces). Also corrected the Navigation/structure and Screen guidance rows to 03_Information_Architecture_v1.10 and 04_Experience_Blueprint_v1.11, both of which had fallen one version behind after this pass's own edits to 03/04, caught during a final sweep. A follow-up pre-PRD audit found this same pass had still left the Related Documents table (08 citation) and the Governance/Experience-principles/Component-specifications/Architecture-index/Frontend-architecture/Implementation-roadmap Ownership Matrix rows one or two versions behind their own most recent bumps — all now corrected to 00 v1.13, 02 v1.13, 06 v1.12, 07 v1.13, 08 v1.18 (recording DEC-051, PRD light-mode consistency), 13 v1.11, 16 v1.13. Not bumping the version again for this — same-day completion of this entry's own intended scope, not a new change. |
| v1.14 | Frozen | Recorded DEC-053: frontend tooling moved from Lovable to Cursor. Updated the Ownership Matrix and Related Documents to reference 01_Product_Strategy_v1.11, 04_Experience_Blueprint_v1.12, 05_Design_System_v1.14, 06_Component_Library_v1.13, 07_Product_Architecture_v1.14, 08_Decision_Log_v1.20, 11_API_Integration_Architecture_v1.5, 12_Backend_Architecture_v1.5, 13_Frontend_Architecture_v1.12, 14_Testing_Strategy_v1.9, 15_Deployment_Architecture_v1.6, and 16_Implementation_Roadmap_v1.14 — the full set of documents touched by this cascade. This document's own body never named Lovable directly, so no content beyond citations changed. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: this DEC-053 cascade rippled a second time through nearly every document it touched (02, 03, 04, 05, 06, 07, 08, 11, 12, 13, 14, 15, 16 each needed a further citation bump after their v1.14-round dependents moved again), so the Ownership Matrix and Related Documents are refreshed here to the fully-settled final versions in one pass: 00 v1.15 (self), 01 v1.11, 02 v1.14, 03 v1.11, 04 v1.13, 05 v1.15, 06 v1.14, 07 v1.16, 08 v1.22, 09 v1.4, 10 v1.7, 11 v1.6, 12 v1.6, 13 v1.13, 14 v1.10, 15 v1.7, 16 v1.15. Also caught this document's own self-referential Governance row, and the Architecture index/Historical decisions rows, still showing v1.14/v1.15/v1.21 after 07 and 08 moved once more later in the same pass -- now corrected. Not bumping the version again for this. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: 09 and 10 bumped once more after the previous pass, forcing a third full ripple through 01, 02, 03, 04, 05, 06, 07, 11, 12, 13, 14, 15, 16, 08, and this document. Refreshed the Ownership Matrix and Related Documents to the fully-settled final versions: 00 v1.16 (self), 01 v1.13, 02 v1.16, 03 v1.13, 04 v1.15, 05 v1.17, 06 v1.16, 07 v1.17, 08 v1.23, 09 v1.5, 10 v1.8, 11 v1.7, 12 v1.8, 13 v1.15, 14 v1.12, 15 v1.8, 16 v1.16. This is expected to be the final settling point of the DEC-053 cascade — 09 and 10 have no further upstream dependency left to move. |
| v1.17 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix and Related Documents to reference 05_Design_System_v1.19, 08_Decision_Log_v1.24, and 16_Implementation_Roadmap_v1.17, following DEC-054 (frozen Renewal Urgency Indicator day-thresholds, plus the doc 05 Lifecycle Status content correction). **Correction (caught during a later audit pass, same day):** this row's own edit missed refreshing the 01, 02, 03, 04, and 07 rows, which had already moved earlier in this same cascade — left stale at v1.13, v1.16, v1.13, v1.15, and v1.17 respectively. Not bumping the version again for this; folded into the next entry below along with the Phase 4 citation drift cleanup. |
| v1.18 | Frozen | Housekeeping pass, not tied to a new DEC: refreshed the Ownership Matrix and Related Documents to the fully-settled versions after closing the citation drift deliberately deferred since the DEC-054 pass (10, 11, 12, 13, 14, 15, 16) plus the v1.17 entry's own missed rows (01, 02, 03, 04, 07): 01 v1.14, 02 v1.17, 03 v1.14, 04 v1.16, 07 v1.19, 09 v1.6, 10 v1.9, 11 v1.8, 12 v1.9, 13 v1.17, 14 v1.13, 15 v1.9, 16 v1.18, and 08 v1.25 (08's own Depends On citing this document's new version required 08 to bump once more; both settled together in one pass rather than round-tripped). **Correction (same day):** 09 and 07 each moved once more after this row was first written (09 to close its own stale 11 citation, 07 to close this same round of drift) — both corrected above rather than left one hop behind. Not bumping the version again for this. |
| v1.19 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Ownership Matrix (Reusable visual standards, Historical decisions) and Related Documents to reference 05_Design_System_v1.19 and 08_Decision_Log_v1.26, following DEC-055 (logo wordmark font resolved to IBM Plex Sans, logo formally implemented). |
| v1.20 | Frozen | Housekeeping pass, not tied to a new DEC: the DEC-055 citation ripple reached 09-15 (each moved once to close its own stale downstream citations). Updated the Ownership Matrix and Related Documents to reference 09_Implementation_Readiness_v1.7, 10_Database_Architecture_v1.10, 11_API_Integration_Architecture_v1.9, 12_Backend_Architecture_v1.10, 13_Frontend_Architecture_v1.18, 14_Testing_Strategy_v1.14, and 15_Deployment_Architecture_v1.10. **Correction (same day):** a fuller sweep found this table's own Product strategy, Experience principles, Navigation and structure, Screen implementation guidance, Component specifications, and Implementation roadmap rows had been missed in this and the prior pass — corrected to 01_Product_Strategy_v1.15, 02_Experience_Strategy_v1.18, 03_Information_Architecture_v1.15, 04_Experience_Blueprint_v1.17, 06_Component_Library_v1.18, and 16_Implementation_Roadmap_v1.19. **Further correction (same day, full folder grep audit):** this table's own Governance (self-reference) and Architecture index rows were also still stale — corrected to 00_Project_Governance_v1.20 (self) and 07_Product_Architecture_v1.20. Not bumping the version again for this. **Further correction (same day, DEC-056 login-page visual exception cascade):** the Reusable visual standards and Historical decisions rows, plus Related Documents, updated to 05_Design_System_v1.20 and 08_Decision_Log_v1.27. Not bumping the version again for this either. **Further correction (DEC-057 brand kit cascade):** the same three fields updated again to 05_Design_System_v1.21 and 08_Decision_Log_v1.28. Not bumping the version again for this. **Further correction (DEC-058 motion-system cascade):** the same three fields updated again to 05_Design_System_v1.22 and 08_Decision_Log_v1.29. Not bumping the version again for this either. **Further correction (DEC-059 generic-icon cascade):** the Reusable visual standards, Component specifications, Historical decisions, and Database architecture rows, plus Related Documents, updated to 05_Design_System_v1.23, 06_Component_Library_v1.19, 08_Decision_Log_v1.30, and 10_Database_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-060/061 logo-asset and Header-restructure cascade):** the Reusable visual standards and Historical decisions rows, plus Related Documents, updated to 05_Design_System_v1.25 and 08_Decision_Log_v1.32. Not bumping the version again for this either. **Further correction (DEC-062/063/064 cascade — glow-card dual meaning, gradient button scoped adoption, Paid/Paused quick-actions):** the Reusable visual standards, Component specifications, and Historical decisions rows, plus Related Documents, updated to 05_Design_System_v1.28, 06_Component_Library_v1.20, and 08_Decision_Log_v1.35. Not bumping the version again for this either. **Further correction (DEC-065/066 cascade — Cyber Lime reskin, DEC-056 pre-auth exception retirement):** the Reusable visual standards, Component specifications, and Historical decisions rows, plus Related Documents, updated to 05_Design_System_v1.30, 06_Component_Library_v1.21, and 08_Decision_Log_v1.37. Not bumping the version again for this either. **Further correction (DEC-067 cascade — Decision Workspace 7-day filter + Recommended Reviews placeholder):** the Component specifications and Historical decisions rows, plus Related Documents, updated to 06_Component_Library_v1.22 and 08_Decision_Log_v1.38. Not bumping the version again for this either. **Further correction (same day, full grep audit):** the Backend architecture row was found still citing 12_Backend_Architecture_v1.10, three cascades stale — 12 actually moved to v1.11 during the DEC-059 pass and this row was missed at the time. Corrected to 12_Backend_Architecture_v1.11. Not bumping the version again for this. **Further correction (doc 04/08 follow-up — closing DEC-067's own flagged doc 04 gap):** the Screen implementation guidance and Historical decisions rows, plus Related Documents, updated to 04_Experience_Blueprint_v1.18 and 08_Decision_Log_v1.39. Not bumping the version again for this either. **Further correction (DEC-068 cascade — Phase 6 reminder-scheduling architecture: Supabase Cron, hourly send / daily generation split):** the Database architecture, API and integrations, Backend architecture, and Historical decisions rows, plus Related Documents, updated to 10_Database_Architecture_v1.12, 11_API_Integration_Architecture_v1.10, 12_Backend_Architecture_v1.12, and 08_Decision_Log_v1.40. Not bumping the version again for this either. **Further correction (same day):** Related Documents' 09_Implementation_Readiness citation corrected to v1.8, since 09 moved again later in this same cleanup pass (its own API Document Note citing 11's new version). Not bumping the version again for this either. **Further correction (DEC-069 cascade — reminders CHECK constraint loosening, new audit_action enum value):** the Database architecture and Historical decisions rows, plus Related Documents, updated to 10_Database_Architecture_v1.13 and 08_Decision_Log_v1.41. Not bumping the version again for this either. **Further correction (DEC-070 cascade — reminder lifecycle fix, stale reminders on renewal-date change/pause):** the Database architecture and Historical decisions rows, plus Related Documents, updated to 10_Database_Architecture_v1.14 and 08_Decision_Log_v1.42. Not bumping the version again for this either. **Further correction (DEC-071 cascade — post_renewal_checkin paused-exclusion fix):** the Database architecture and Historical decisions rows, plus Related Documents, updated to 10_Database_Architecture_v1.15 and 08_Decision_Log_v1.43. Not bumping the version again for this either. **Further correction (DEC-072 cascade — auth email template branding-parity drift fix and change-email scope decision):** the Historical decisions row, plus Related Documents, updated to 08_Decision_Log_v1.44. Not bumping the version again for this either. **Further correction (DEC-073 cascade — light-mode/email accent tokens resolved to Cyber Lime):** the Reusable visual standards, Component specifications, and Historical decisions rows, plus Related Documents, updated to 05_Design_System_v1.31, 06_Component_Library_v1.23, and 08_Decision_Log_v1.45. Not bumping the version again for this either. **Further correction (DEC-074 cascade — real logo icon added to email templates):** the Historical decisions row, plus Related Documents, updated to 08_Decision_Log_v1.46. Not bumping the version again for this either. **Further correction (DEC-075 cascade — Password changed Security notification template added to doc 24):** the Historical decisions row, plus Related Documents, updated to 08_Decision_Log_v1.47. Not bumping the version again for this either. **Further correction (DEC-076/077 cascade — Vercel SPA rewrite bug found and fixed, Magic Link sign-in confirmed unimplemented and deferred):** the Historical decisions row, Related Documents, and the Deployment architecture row updated to 08_Decision_Log_v1.49 and 15_Deployment_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-078 cascade — Send Reminder Now Developer/Test Utilities deliverable confirmed unbuilt, deferred to Phase 11):** the Historical decisions row, plus Related Documents, updated to 08_Decision_Log_v1.50. Not bumping the version again for this either. **Further correction (DEC-079 cascade — Phase 7 AI runtime architecture: lazy-generate trigger model, top-3-urgent workspace batch, gpt-4o-mini, duplicate detection deferred to Phase 9):** the Historical decisions row, plus Related Documents, updated to 08_Decision_Log_v1.51; the Screen implementation guidance row updated to 04_Experience_Blueprint_v1.19; the Implementation roadmap row updated to 16_Implementation_Roadmap_v1.20. Not bumping the version again for this either. **Further correction (DEC-079 same-day extension — Phase 7 batch response shape and AI Insights merge resolved during implementation planning):** the Historical decisions row, plus Related Documents, updated to 08_Decision_Log_v1.52; the Screen implementation guidance row updated to 04_Experience_Blueprint_v1.20; the API and integrations row updated to 11_API_Integration_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-080 cascade — Phase 8 architecture forks resolved: payment-request generation trigger, Share entry point, equal-split rebalancing, member-removal non-cascade):** the Database architecture, Screen implementation guidance, and Historical decisions rows, plus Related Documents, updated to 10_Database_Architecture_v1.16, 04_Experience_Blueprint_v1.21, and 08_Decision_Log_v1.53. Not bumping the version again for this either. **Further correction (DEC-080's remaining component-spec gap closed — doc 06 v1.24, three new components for the Shared Subscriptions page):** the Component specifications row updated to 06_Component_Library_v1.24. Not bumping the version again for this either. **Further correction (DEC-080 same-day extension — Phase 8 technical-planning gaps: member-join generation trigger, nullable user_id for unlinked-member reminders/notifications, accepted rounding remainder and RLS-gap tradeoffs):** the Database architecture row, plus Related Documents, updated to 10_Database_Architecture_v1.17. Not bumping the version again for this either. **Further correction (DEC-080 live-testing extension — equal-split divisor and pending-request sync fixed, member-account-linking trigger, subscriptions_select_shared_member RLS grant, owner-gating and mutation-success-audit fixes):** the Database architecture and Historical decisions rows, plus Related Documents, updated to 10_Database_Architecture_v1.18 and 08_Decision_Log_v1.54. Not bumping the version again for this either. **Further correction (DEC-081/082 cascade — Phase 8 closed out: Phase 6 Cron/JWT-gateway regression found and fixed, plus premium feature-gating decided for AI Insights):** the Database architecture and Historical decisions rows, plus Related Documents, updated to 10_Database_Architecture_v1.19 and 08_Decision_Log_v1.55. Not bumping the version again for this either. **Further correction (DEC-082 — doc 04 v1.22, premium AI Insight split recorded on the Decision Workspace blueprint):** the Screen implementation guidance row updated to 04_Experience_Blueprint_v1.22. Not bumping the version again for this either. **Further correction (DEC-082 — doc 01 v1.16, lower-cost-alternatives note assigned to Phase 9):** the Product strategy row updated to 01_Product_Strategy_v1.16. Not bumping the version again for this either. |
| v1.22 | Frozen | Housekeeping pass, not tied to a new DEC: updated Related Documents and the Historical decisions row to 08_Decision_Log_v1.58, the Component specifications row to 06_Component_Library_v1.27, and the API and integrations row to 11_API_Integration_Architecture_v1.13, as part of the cascade recording DEC-085 (currency-drop fix, Cost Comparison Card rename). Not bumping again for DEC-084 (Frontend-only AuthContext fix, doc 08 v1.57) — that version was superseded by v1.58 before this table was next refreshed, so this pass cites the fully-settled v1.58 directly rather than round-tripping through v1.57. **Further correction (same day, second-order cascade closure):** bumping this document's own version created a fresh round of one-hop-stale citations in every document that depends on 00 or 01 — rather than leaving that for a later pass, closed it now: Related Documents' 09_Implementation_Readiness citation (missed in the edit above) corrected to v1.10; the Ownership Matrix's Governance (self), Product strategy, Architecture index, Implementation baseline, Database architecture, Backend architecture, Frontend architecture, and Testing strategy rows corrected to 00 v1.22 (self), 01 v1.18, 07 v1.22, 09 v1.10, 10 v1.21, 12 v1.14, 13 v1.20, and 14 v1.16. Docs 02, 03, 04, 05 (Depends On citing 00/01), 08 (Depends On citing 00), 11 (body citations to 01/10/12/14), 13 (body citation to 10), 14 (body citation to 01), 15 (Depends On citing 14), and 16 (body citations to 01/10/14) were each corrected directly in their own files, with a same-day further-correction note folded into each document's existing latest Version History row rather than triggering another version bump — the same deliberate stop-the-regress precedent this project used for doc 10's "not re-bumped, to avoid triggering a second full recascade" call. Not bumping this document's version again for this. **Further correction (same day, DEC-085 live-verification closure):** Related Documents' and the Historical decisions row's 08_Decision_Log citations updated to v1.59 (doc 08's DEC-085 items confirmed live, plus a GitHub Actions deploy-gap bug found and fixed during that verification). Not bumping this document's version again for this either. **Further correction (DEC-086 cascade — idle-session-timeout closure, the fourth and final DEC-083 item, now built and live-verified):** Related Documents' and the Historical decisions row's 08_Decision_Log citations updated to v1.60, and the Implementation roadmap row updated to 16_Implementation_Roadmap_v1.23 (Phase 9+10 now recorded as fully closed). Not bumping this document's version again for this either. |
| v1.21 | Frozen | **Records DEC-083 cascade** (Phase 9+10 — Insights, Premium Gating, Razorpay Demo Purchase — built and deployed): the Related Documents field and the Ownership Matrix's Product strategy, Screen implementation guidance, Component specifications, Historical decisions, Database architecture, API and integrations, and Implementation roadmap rows updated to 01_Product_Strategy_v1.17, 04_Experience_Blueprint_v1.24, 06_Component_Library_v1.26, 08_Decision_Log_v1.56, 10_Database_Architecture_v1.20, 11_API_Integration_Architecture_v1.12, and 16_Implementation_Roadmap_v1.21. This is a single consolidated pass rather than a round-tripped one, closing this session's full documentation cascade in one sweep. Not a new DEC itself — DEC-083 was recorded in doc 08. **Correction (same day, full grep audit):** a fuller sweep found this table's own Governance (self-reference), Experience principles, Navigation and structure, Reusable visual standards, Architecture index, Backend architecture, Frontend architecture, and Testing strategy rows all one hop stale (each doc having moved once more later in this same cascade to close its own internal citation gaps) — corrected to 00_Project_Governance_v1.21 (self), 02_Experience_Strategy_v1.19, 03_Information_Architecture_v1.16, 05_Design_System_v1.32, 07_Product_Architecture_v1.21, 12_Backend_Architecture_v1.13, 13_Frontend_Architecture_v1.19, and 14_Testing_Strategy_v1.15; the Screen implementation guidance, Component specifications, and Implementation baseline rows also corrected to 04_Experience_Blueprint_v1.24, 06_Component_Library_v1.26, and 09_Implementation_Readiness_v1.9. Not bumping the version again for this. |
| v1.23 | Current | Housekeeping pass, not tied to a new DEC: updated Related Documents and the Ownership Matrix's Screen implementation guidance, Architecture index, Historical decisions, and Implementation roadmap rows to 04_Experience_Blueprint_v1.25, 07_Product_Architecture_v1.23, 08_Decision_Log_v1.61, and 16_Implementation_Roadmap_v1.24, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). **Further correction (same day, second-order cascade closure):** bumping this document's own version, plus doc 01, 05, and 13 each bumping in turn, left the Ownership Matrix's own Governance (self), Product strategy, Reusable visual standards, and Frontend architecture rows one hop stale — corrected to 00 v1.23 (self), 01 v1.19, 05 v1.33, and 13 v1.21. Not bumping the version again for this. **Further correction (recording DEC-088 — Phase 13 closed by documenting as-built deployment reality):** Related Documents and the Ownership Matrix's Historical decisions, Deployment architecture, and Implementation roadmap rows updated to 08_Decision_Log_v1.62, 15_Deployment_Architecture_v1.13, and 16_Implementation_Roadmap_v1.25. A fuller sweep also found the Component specifications, Implementation baseline, Database architecture, API and integrations, Backend architecture, and Testing strategy rows one or more hops stale from the earlier DEC-087 cascade (never fully re-settled in this table) — corrected to 06_Component_Library_v1.28, 09_Implementation_Readiness_v1.11, 10_Database_Architecture_v1.22, 11_API_Integration_Architecture_v1.14, 12_Backend_Architecture_v1.15, and 14_Testing_Strategy_v1.17. Not bumping the version again for this either. **Further correction (documentation audit pass):** the Ownership Matrix's Experience principles and Navigation and structure rows, left one hop stale, corrected to 02_Experience_Strategy_v1.20 and 03_Information_Architecture_v1.17. Not bumping the version again for this either. |
