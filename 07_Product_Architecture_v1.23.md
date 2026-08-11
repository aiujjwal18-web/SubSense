# 07 Product Architecture v1.23

## Document Control

| Field | Value |
| --- | --- |
| Document ID | PA-001 |
| Product | SubSense |
| Version | v1.23 |
| Status | Frozen implementation baseline |
| Source of Truth | Architecture overview and repository index |
| Depends On | 00 through 06, plus implementation readiness documents |

## Purpose

This document is the entry point for the SubSense documentation repository. It summarizes how the product is architected and where each source of truth lives.

It summarizes. It does not redefine detailed decisions owned by other documents.

## Architecture Layer Model

Documentation dependency flow:

Governance

-> Product Strategy

-> Experience Strategy

-> Information Architecture

-> Experience Blueprint

-> Design System

-> Component Library

-> Implementation Readiness

-> Database, API, Backend, Frontend, Testing, Deployment

-> Implementation Roadmap

## Product Architecture Summary

SubSense is an AI-assisted subscription decision platform. Its architecture is organized around:

- User-controlled subscription management.
- Renewal decision support.
- Shared payment awareness.
- Explainable AI.
- Email-first reminders.
- Supabase-backed authentication and data ownership.
- Backend-mediated external integrations.

## Runtime Architecture

| Layer | Technology | Responsibility |
| --- | --- | --- |
| Frontend | Cursor (AI-assisted local development, DEC-053) | User interface and client experience, built directly against the Subsense-web repository |
| Hosting | Vercel | Frontend deployment |
| Domain | `subsense.co.in` (DEC-048) | Registered business domain and support email |
| Auth | Supabase Auth | Identity, sessions, Google Sign-In |
| Database | Supabase PostgreSQL | System of record |
| Backend/API | Supabase Edge Functions or backend services | Business logic and provider orchestration |
| AI | OpenAI | AI insight generation |
| Email | Resend | Email delivery |
| Payments | Razorpay Test Mode | Premium demonstration |
| Version Control | GitHub | Source repository |
| CI/CD | GitHub Actions | Future-ready automation |

## Source-of-Truth Matrix

| Document | Purpose | Source of Truth |
| --- | --- | --- |
| 00_Project_Governance_v1.23 | Governance and rules | Governance |
| 01_Product_Strategy_v1.19 | Product direction | Product Strategy |
| 02_Experience_Strategy_v1.20 | UX behavior | Experience Strategy |
| 03_Information_Architecture_v1.17 | Product structure | Information Architecture |
| 04_Experience_Blueprint_v1.25 | Screen guidance | Experience Blueprint |
| 05_Design_System_v1.33 | Reusable UI standards | Design System |
| 06_Component_Library_v1.28 | Component specs | Component Library |
| 08_Decision_Log_v1.62 | Historical decisions | Decision Log |
| 09_Implementation_Readiness_v1.11 | Readiness baseline | Implementation Readiness |
| 10_Database_Architecture_v1.22 | Schema and RLS | Database Architecture |
| 11_API_Integration_Architecture_v1.14 | APIs and integrations | API Architecture |
| 12_Backend_Architecture_v1.15 | Services and jobs | Backend Architecture |
| 13_Frontend_Architecture_v1.21 | Frontend engineering | Frontend Architecture |
| 14_Testing_Strategy_v1.17 | Test governance | Testing Strategy |
| 15_Deployment_Architecture_v1.13 | Environments and release | Deployment Architecture |
| 16_Implementation_Roadmap_v1.25 | Build sequence | Implementation Roadmap |

## Module Architecture

| Module | Responsibility |
| --- | --- |
| Authentication | Identity and session access |
| Decision Workspace | Prioritized daily decision support |
| My Subscriptions | Subscription library and management |
| Subscription Details | Review and edit subscription information |
| Shared Subscriptions | Shared member and split payment tracking |
| Insights | Spending and decision analytics |
| Profile | Account, preferences, plan, sign-out |
| Developer/Test Utilities | Integration and evaluation support |

## Data Architecture Summary

Data is grouped into bounded domains:

- Identity.
- Subscription Management.
- Shared Subscription.
- Reminder Engine.
- AI Decision Support.
- Notifications.
- Billing.
- System and Audit.

The database follows:

- UUID primary keys.
- Human-readable business identifiers.
- PostgreSQL ENUMs for stable states.
- Soft delete for business data.
- Append-only operational history where appropriate.
- RLS as database protection.

## Integration Architecture Summary

The API document is maintained separately as `11_API_Integration_Architecture_v1.14.md`.

Per DEC-031 (Lean Access Architecture), SubSense uses two access paths rather than a single uniform pipeline:

- **Path A — Direct Data Access**: the frontend (built in Cursor, DEC-053) uses the Supabase client (`supabase-js`) directly for user-owned CRUD (profile, preferences, subscriptions, shared subscriptions, members, payment requests, and reads of reminders/notifications/AI output/catalog). Row Level Security, defined in `10_Database_Architecture_v1.22`, is the enforcement layer for this path — RLS stands in for a Repository/Service layer for these simple, owner-scoped operations.
- **Path B — Edge Function APIs**: Supabase Edge Functions using the service-role key handle anything touching a provider secret (OpenAI, Resend, Razorpay), anything running on a schedule, and any write to system-owned tables (`ai_recommendations`, `notifications`, `reminder_history`, `audit_logs`, `payment_transactions`).

Architecture rules (unchanged by DEC-031):

- Frontend never talks directly to OpenAI, Resend, or Razorpay.
- All provider access is mediated by exactly one Path B Edge Function per provider.
- Supabase is the system of record.
- JWT is the user trust boundary for both paths.
- Provider keys and the service-role key never reach the frontend.

## Backend Architecture Summary

Backend architecture follows the Lean Access Architecture (DEC-031), not a uniform layered pipeline:

- Path A (user-owned CRUD): Supabase client -> RLS. No custom service or repository code is written for these operations; RLS policies and database triggers (e.g. `calculate_subscription_equivalents()`, `generate_default_reminders()`, `handle_new_user()`) carry the business-rule enforcement that a Service/Repository layer would otherwise own.
- Path B (secret-bearing, scheduled, or system-owned writes): API Handler -> Service -> Provider Client / Repository -> Supabase, as detailed in `12_Backend_Architecture_v1.15`.

Rules:

- Services own transaction boundaries for Path B.
- External API calls do not run inside database transactions.
- Background jobs use the same service layer as interactive Path B requests.
- Repositories do not call services or APIs.
- RLS policies are the authoritative access control for Path A; Path B services must not assume they are the only writer to a Path A table.

## Frontend Architecture Summary

Frontend architecture follows a component-driven structure, with two data-access routes per DEC-031:

Presentation -> Feature Components -> Shared Components -> [Supabase Client for Path A tables, governed by RLS] or [API Client -> Backend Edge Functions for Path B]

Rules:

- Components never access the database directly outside the sanctioned Path A Supabase client calls defined in `11_API_Integration_Architecture_v1.14`; there is no ad hoc query building in components.
- Business entities have one frontend source of truth regardless of which path fetched them.
- Server state remains backend/RLS-authoritative; the frontend never holds a business value RLS or a trigger would reject.
- Optimistic UI is allowed only for safe reversible actions.
- The frontend never talks to OpenAI, Resend, Razorpay, or any Supabase service-role operation — only to RLS-governed Path A tables and Path B Edge Functions.

## Testing and Deployment Summary

Testing:

- Business-first pyramid.
- Requirements Traceability Matrix.
- Quality gates.
- Automated tests where repeatability matters.
- Manual UAT for product acceptance.

Deployment:

- Development -> Staging -> Production.
- GitHub source of truth.
- Externalized configuration.
- Managed secrets.
- Version-controlled migrations.
- Release approval and rollback plan.

## Current Project State

| Phase | Status |
| --- | --- |
| Product Architecture | Frozen |
| Implementation Architecture | Frozen |
| Governance | Frozen |
| Engineering Blueprint | Frozen |
| API Document | User already has completed document |
| Remaining Documentation Package | 16 documents generated in this workspace |

## Validation Checklist

| Check | Status |
| --- | --- |
| Source-of-truth matrix defined | Complete |
| Runtime architecture summarized | Complete |
| Module architecture summarized | Complete |
| Data architecture summarized | Complete |
| Integration boundary referenced | Complete |
| Backend/frontend summaries included | Complete |
| Testing/deployment summaries included | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Product Architecture Overview baseline. |
| v1.2 | Frozen | Implementation Freeze alignment and 17-document package index. Propagated Lean Access Architecture (DEC-031, DEC-035) into the Integration/Backend/Frontend Architecture Summaries, replacing the stale "API -> Services -> Repositories -> Supabase" model, and corrected the Source-of-Truth Matrix to reference the current versions of 01, 04, 08, 10, 14, and 16. |
| v1.3 | Frozen | Updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.3, 01_Product_Strategy_v1.5, 02_Experience_Strategy_v1.3, 03_Information_Architecture_v1.3, 04_Experience_Blueprint_v1.4, 05_Design_System_v1.3, 06_Component_Library_v1.3, 08_Decision_Log_v1.5, 10_Database_Architecture_v1.3, 13_Frontend_Architecture_v1.1, 14_Testing_Strategy_v1.2, 15_Deployment_Architecture_v1.1, and 16_Implementation_Roadmap_v1.3 — the 10 and 16 corrections close references left stale by the earlier Retention Policy (DEC-041) patch; the rest follow the brand kit finalization (DEC-042). |
| v1.4 | Frozen | Updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.4, 02_Experience_Strategy_v1.4, 05_Design_System_v1.4, 06_Component_Library_v1.4, 08_Decision_Log_v1.6, 13_Frontend_Architecture_v1.2, and 16_Implementation_Roadmap_v1.4, following the spacing/card/icon system closure under DEC-043. |
| v1.5 | Frozen | Updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.5, 02_Experience_Strategy_v1.5, 05_Design_System_v1.5, 06_Component_Library_v1.5, 08_Decision_Log_v1.7, 13_Frontend_Architecture_v1.3, and 16_Implementation_Roadmap_v1.5, following the micro-interaction system closure under DEC-044. |
| v1.6 | Frozen | Updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.6, 02_Experience_Strategy_v1.6, 05_Design_System_v1.6, 06_Component_Library_v1.6, 08_Decision_Log_v1.8, 13_Frontend_Architecture_v1.4, and 16_Implementation_Roadmap_v1.6, following the AI copy tone closure under DEC-045. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, 03_Information_Architecture_v1.5, 04_Experience_Blueprint_v1.6, 05_Design_System_v1.8, 06_Component_Library_v1.8, 08_Decision_Log_v1.10, 13_Frontend_Architecture_v1.6, 14_Testing_Strategy_v1.4, 15_Deployment_Architecture_v1.3, and 16_Implementation_Roadmap_v1.8, closing citation-integrity gaps in 01, 03, 04, and 14 found during the DEC-045 pass. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix and the Integration/Frontend Architecture Summaries to reference 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, 03_Information_Architecture_v1.5, 04_Experience_Blueprint_v1.6, 05_Design_System_v1.8, 06_Component_Library_v1.8, 08_Decision_Log_v1.10, 09_Implementation_Readiness_v1.1, 10_Database_Architecture_v1.3, 11_API_Integration_Architecture_v1.1, 12_Backend_Architecture_v1.1, 13_Frontend_Architecture_v1.6, 14_Testing_Strategy_v1.4, 15_Deployment_Architecture_v1.3, and 16_Implementation_Roadmap_v1.8, closing the reference-integrity gap left by 11's own stale internal citations. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.9, 09_Implementation_Readiness_v1.2, and 11_API_Integration_Architecture_v1.2, and the Integration/Frontend Architecture Summary cross-references to 11_API_Integration_Architecture_v1.2, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.10, 01_Product_Strategy_v1.9, 02_Experience_Strategy_v1.10, 03_Information_Architecture_v1.7, 04_Experience_Blueprint_v1.8, 05_Design_System_v1.10, 06_Component_Library_v1.9, 09_Implementation_Readiness_v1.3, 10_Database_Architecture_v1.5, 11_API_Integration_Architecture_v1.3, 12_Backend_Architecture_v1.3, 13_Frontend_Architecture_v1.8, 14_Testing_Strategy_v1.6, 15_Deployment_Architecture_v1.4, and 16_Implementation_Roadmap_v1.10, and the Path A/Path B body cross-references to 10_Database_Architecture_v1.5, 11_API_Integration_Architecture_v1.3, and 12_Backend_Architecture_v1.3, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion) — bumping 10_Database_Architecture rippled through every document that cites it or one of its own citers. |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.11, 01_Product_Strategy_v1.10, 02_Experience_Strategy_v1.11, 03_Information_Architecture_v1.8, 04_Experience_Blueprint_v1.9, 05_Design_System_v1.11, 06_Component_Library_v1.10, 08_Decision_Log_v1.14 (closing the same pre-DEC-046 citation gap as doc 00), 09_Implementation_Readiness_v1.4, 10_Database_Architecture_v1.7, 11_API_Integration_Architecture_v1.4, 12_Backend_Architecture_v1.4, 13_Frontend_Architecture_v1.9, 14_Testing_Strategy_v1.7, 15_Deployment_Architecture_v1.5, and 16_Implementation_Roadmap_v1.11, and the Path A/Path B body cross-references to 10_Database_Architecture_v1.7, 11_API_Integration_Architecture_v1.4, and 12_Backend_Architecture_v1.4, as part of the cascade recording DEC-047, batched with the notification-template SQL patch (file 23). |
| v1.12 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.12, 02_Experience_Strategy_v1.12, 03_Information_Architecture_v1.9, 04_Experience_Blueprint_v1.10, 05_Design_System_v1.12, 06_Component_Library_v1.11, 08_Decision_Log_v1.16 (correcting a two-version drift left over from DEC-048, which did not name this document among its affected documents), 13_Frontend_Architecture_v1.10, 14_Testing_Strategy_v1.8, and 16_Implementation_Roadmap_v1.12, as part of the multi-hop cascade recording DEC-049 ("Ledger Dark" visual direction). Did not chase 01, 11, 15's citation of 14_Testing_Strategy at its old version number -- 14's content is unchanged, only its header version, so this is deliberately left as low-stakes drift for the next cascade. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.13, 02_Experience_Strategy_v1.13, 05_Design_System_v1.13, 06_Component_Library_v1.12, 08_Decision_Log_v1.17, and 16_Implementation_Roadmap_v1.13, as part of the cascade recording DEC-050 (Ledger Dark extended to light-mode/email surfaces). Also corrected the 00, 02, 03, and 04 rows, which had fallen stale (some since before the v1.11 pass) -- caught during this citation sweep. A follow-up pre-PRD audit caught one more stale row (13, still at v1.10) and the 08 row moving again to v1.18 (recording DEC-051, PRD light-mode consistency) -- both now corrected. Not bumping the version again for this. |
| v1.14 | Frozen | Recorded DEC-053: the Runtime Architecture's Frontend row changed from Lovable to Cursor, the API Testing row (Postman) removed, and a new Domain row added for `subsense.co.in`. Updated the Path A description to drop the "Lovable frontend" naming. Updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.14, 01_Product_Strategy_v1.11, 04_Experience_Blueprint_v1.12, 05_Design_System_v1.14, 06_Component_Library_v1.13, 08_Decision_Log_v1.20, 11_API_Integration_Architecture_v1.5, 12_Backend_Architecture_v1.5, 13_Frontend_Architecture_v1.12, 14_Testing_Strategy_v1.9, 15_Deployment_Architecture_v1.6, and 16_Implementation_Roadmap_v1.14 — the full set of documents touched by this cascade. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix's 02, 03, 04, 05, and 06 rows to 02_Experience_Strategy_v1.14, 03_Information_Architecture_v1.11, 04_Experience_Blueprint_v1.13, 05_Design_System_v1.15, and 06_Component_Library_v1.14 -- all five drifted stale as the DEC-053 cascade continued outward from v1.14. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: this DEC-053 cascade settled after a second ripple through its own dependents. Updated the Source-of-Truth Matrix to its fully-settled final versions (00 v1.15, 08 v1.21, 11 v1.6, 12 v1.6, 13 v1.13, 14 v1.10, 15 v1.7, 16 v1.15) and the three remaining body cross-references (Path A/B summaries, component database-access rule) to 10_Database_Architecture_v1.7 (unchanged), 12_Backend_Architecture_v1.6, and 11_API_Integration_Architecture_v1.6. |
| v1.17 | Frozen | Housekeeping pass, not tied to a new DEC: 09 and 10 bumped once more after the previous pass, requiring another full ripple. Updated the Source-of-Truth Matrix to 00_Project_Governance_v1.16, 01_Product_Strategy_v1.13, 02_Experience_Strategy_v1.16, 03_Information_Architecture_v1.13, 04_Experience_Blueprint_v1.15, 05_Design_System_v1.17, 06_Component_Library_v1.16, 08_Decision_Log_v1.23, 09_Implementation_Readiness_v1.5, 10_Database_Architecture_v1.8, 11_API_Integration_Architecture_v1.7, 12_Backend_Architecture_v1.8, 13_Frontend_Architecture_v1.15, 14_Testing_Strategy_v1.12, 15_Deployment_Architecture_v1.8, and 16_Implementation_Roadmap_v1.16; also corrected the API document mention (was stale at v1.4, several rounds behind) and the three body cross-references (RLS enforcement, Path B routing, component database-access rule) to 10_Database_Architecture_v1.8, 12_Backend_Architecture_v1.8, and 11_API_Integration_Architecture_v1.7. This settles every citation this document carries against the fully-resolved DEC-053 cascade. |
| v1.18 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix to reference 00_Project_Governance_v1.17, 01_Product_Strategy_v1.14, 02_Experience_Strategy_v1.17, 03_Information_Architecture_v1.14, 04_Experience_Blueprint_v1.16, 05_Design_System_v1.18, 06_Component_Library_v1.17, 08_Decision_Log_v1.24, and 16_Implementation_Roadmap_v1.17, following DEC-054 (Renewal Urgency Indicator day-thresholds; doc 05 Lifecycle Status content correction). |
| v1.19 | Frozen | Housekeeping pass, not tied to a new DEC: closed the citation drift deliberately deferred since the DEC-054 pass. Updated the Source-of-Truth Matrix to 00_Project_Governance_v1.18, 08_Decision_Log_v1.25, 10_Database_Architecture_v1.9, 11_API_Integration_Architecture_v1.8, 12_Backend_Architecture_v1.9, 13_Frontend_Architecture_v1.17, 14_Testing_Strategy_v1.13, 15_Deployment_Architecture_v1.9, and 16_Implementation_Roadmap_v1.18, and the four body cross-references (API document mention, RLS enforcement, Path B routing, component database-access rule) to 11_API_Integration_Architecture_v1.8, 10_Database_Architecture_v1.9, 12_Backend_Architecture_v1.9, and 11_API_Integration_Architecture_v1.8. **Correction (same day):** the 09_Implementation_Readiness row corrected to v1.6, since 09 moved again later in this same cleanup pass. Not bumping the version again for this. |
| v1.20 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix rows for 00_Project_Governance_v1.19, 05_Design_System_v1.19, and 08_Decision_Log_v1.26, following DEC-055 (logo wordmark font resolved, logo formally implemented). **Correction (same day):** the 01, 02, 03, and 04 rows corrected to 01_Product_Strategy_v1.15, 02_Experience_Strategy_v1.18, 03_Information_Architecture_v1.15, and 04_Experience_Blueprint_v1.17, since all four moved again later in this same cleanup pass. **Further correction (same day):** the 00_Project_Governance row corrected to v1.20, since 00 moved twice more within this same cleanup pass (closing its own 09-15 citation drift). Also updated 09_Implementation_Readiness, 10_Database_Architecture, 11_API_Integration_Architecture, 12_Backend_Architecture, 13_Frontend_Architecture, 14_Testing_Strategy, and 15_Deployment_Architecture rows to v1.7, v1.10, v1.9, v1.10, v1.18, v1.14, and v1.10 respectively, since all seven moved within this same ripple, and the 06_Component_Library row still at v1.17 to v1.18. Not bumping the version again for this. **Further correction (same day, DEC-056 login-page visual exception cascade):** the 05_Design_System and 08_Decision_Log rows updated to v1.20 and v1.27. Not bumping the version again for this either. **Further correction (DEC-057 brand kit cascade):** the same two rows updated again to 05_Design_System_v1.21 and 08_Decision_Log_v1.28. Not bumping the version again for this. **Further correction (DEC-058 motion-system cascade):** updated again to 05_Design_System_v1.22 and 08_Decision_Log_v1.29. Not bumping the version again for this either. **Further correction (DEC-059 generic-icon cascade):** the 05_Design_System, 06_Component_Library, 08_Decision_Log, and 10_Database_Architecture rows updated to v1.23, v1.19, v1.30, and v1.11. Not bumping the version again for this either. **Further correction (DEC-060/061 logo-asset and Header-restructure cascade):** the 05_Design_System and 08_Decision_Log rows updated to v1.25 and v1.32. Not bumping the version again for this either. **Further correction (DEC-062/063/064 cascade):** the 05_Design_System, 06_Component_Library, and 08_Decision_Log rows updated to v1.28, v1.20, and v1.35. Not bumping the version again for this either. **Further correction (DEC-065/066 cascade):** the 05_Design_System, 06_Component_Library, and 08_Decision_Log rows updated to v1.30, v1.21, and v1.37. Not bumping the version again for this either. **Further correction (DEC-067 cascade):** the 06_Component_Library and 08_Decision_Log rows updated to v1.22 and v1.38. Not bumping the version again for this either. **Further correction (same day, full grep audit):** the Source-of-Truth Matrix row and the Path B implementation-pattern body citation were both found still pointing at 12_Backend_Architecture_v1.10, three cascades stale since 12 actually moved to v1.11 during the DEC-059 pass. Both corrected to 12_Backend_Architecture_v1.11. Not bumping the version again for this. **Further correction (doc 04/08 follow-up — closing DEC-067's own flagged doc 04 gap):** the Source-of-Truth Matrix rows updated to 04_Experience_Blueprint_v1.18 and 08_Decision_Log_v1.39. Not bumping the version again for this either. **Further correction (DEC-068 cascade — Phase 6 reminder-scheduling architecture):** the Source-of-Truth Matrix rows and the three body citations (RLS enforcement, Path B implementation pattern, API document note, Path A component-access rule) updated to 10_Database_Architecture_v1.12, 11_API_Integration_Architecture_v1.10, 12_Backend_Architecture_v1.12, and 08_Decision_Log_v1.40. Not bumping the version again for this either. **Further correction (same day):** the Source-of-Truth Matrix's Implementation Readiness row corrected to 09_Implementation_Readiness_v1.8, since 09 moved again later in this same cleanup pass. Not bumping the version again for this either. **Further correction (DEC-069 cascade — reminders CHECK constraint loosening, new audit_action enum value):** the Source-of-Truth Matrix's Database architecture row and the RLS-enforcement body citation updated to 10_Database_Architecture_v1.13, and the Historical decisions row to 08_Decision_Log_v1.41. Not bumping the version again for this either. **Further correction (DEC-070 cascade — reminder lifecycle fix):** the Source-of-Truth Matrix's Database architecture row and the RLS-enforcement body citation updated to 10_Database_Architecture_v1.14, and the Historical decisions row to 08_Decision_Log_v1.42. Not bumping the version again for this either. **Further correction (DEC-071 cascade — post_renewal_checkin paused-exclusion fix):** the Source-of-Truth Matrix's Database architecture row and the RLS-enforcement body citation updated to 10_Database_Architecture_v1.15, and the Historical decisions row to 08_Decision_Log_v1.43. Not bumping the version again for this either. **Further correction (DEC-072 cascade — auth email template branding-parity drift fix and change-email scope decision):** the Historical decisions row updated to 08_Decision_Log_v1.44. Not bumping the version again for this either. **Further correction (DEC-073 cascade — light-mode/email accent tokens resolved to Cyber Lime):** the Source-of-Truth Matrix's 05_Design_System, 06_Component_Library, and Historical decisions rows updated to v1.31, 06_Component_Library_v1.23, and 08_Decision_Log_v1.45. Not bumping the version again for this either. **Further correction (DEC-074 cascade — real logo icon added to email templates):** the Historical decisions row updated to 08_Decision_Log_v1.46. Not bumping the version again for this either. **Further correction (DEC-075 cascade — Password changed Security notification template added to doc 24):** the Historical decisions row updated to 08_Decision_Log_v1.47. Not bumping the version again for this either. **Further correction (DEC-076/077 cascade — Vercel SPA rewrite bug found and fixed, Magic Link sign-in confirmed unimplemented and deferred):** the Historical decisions row and the Source-of-Truth Matrix's Deployment architecture row updated to 08_Decision_Log_v1.49 and 15_Deployment_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-078 cascade — Send Reminder Now Developer/Test Utilities deliverable confirmed unbuilt, deferred to Phase 11):** the Historical decisions row updated to 08_Decision_Log_v1.50. Not bumping the version again for this either. **Further correction (DEC-079 cascade — Phase 7 AI runtime architecture: lazy-generate trigger model, top-3-urgent workspace batch, gpt-4o-mini, duplicate detection deferred to Phase 9):** the Source-of-Truth Matrix's Screen guidance, Historical decisions, and Implementation roadmap rows updated to 04_Experience_Blueprint_v1.19, 08_Decision_Log_v1.51, and 16_Implementation_Roadmap_v1.20. Not bumping the version again for this either. **Further correction (DEC-079 same-day extension — Phase 7 batch response shape and AI Insights merge resolved during implementation planning):** the Source-of-Truth Matrix's Screen guidance, Historical decisions, and API architecture rows, the API Document Note, and the Path A component-access body citation updated to 04_Experience_Blueprint_v1.20, 08_Decision_Log_v1.52, and 11_API_Integration_Architecture_v1.11. Not bumping the version again for this either. **Further correction (DEC-080 cascade — Phase 8 architecture forks resolved):** the Source-of-Truth Matrix's Database architecture, Screen guidance, and Historical decisions rows, plus the RLS-enforcement body citation, updated to 10_Database_Architecture_v1.16, 04_Experience_Blueprint_v1.21, and 08_Decision_Log_v1.53. Not bumping the version again for this either. **Further correction (DEC-080's remaining component-spec gap closed):** the Source-of-Truth Matrix's Component Library row updated to 06_Component_Library_v1.24. Not bumping the version again for this either. **Further correction (DEC-080 same-day extension — Phase 8 technical-planning gaps: member-join generation trigger, nullable user_id for unlinked-member reminders/notifications, accepted rounding remainder and RLS-gap tradeoffs):** the Source-of-Truth Matrix's Database architecture row and the RLS-enforcement body citation updated to 10_Database_Architecture_v1.17. Not bumping the version again for this either. **Further correction (DEC-080 live-testing extension):** the Source-of-Truth Matrix's Database architecture and Historical decisions rows, plus the RLS-enforcement body citation, updated to 10_Database_Architecture_v1.18 and 08_Decision_Log_v1.54. Not bumping the version again for this either. **Further correction (DEC-081/082 cascade — Phase 8 closed out: Phase 6 Cron/JWT-gateway regression found and fixed, plus premium feature-gating decided for AI Insights):** the Source-of-Truth Matrix's Database architecture and Historical decisions rows updated to 10_Database_Architecture_v1.19 and 08_Decision_Log_v1.55. Not bumping the version again for this either. **Further correction (DEC-082 — doc 04 v1.22, premium AI Insight split):** the Source-of-Truth Matrix's Screen guidance row updated to 04_Experience_Blueprint_v1.22. Not bumping the version again for this either. **Further correction (DEC-082 — doc 01 v1.16, lower-cost-alternatives note assigned to Phase 9):** the Source-of-Truth Matrix's Product strategy row updated to 01_Product_Strategy_v1.16. Not bumping the version again for this either. |
| v1.22 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix's Component specifications, Historical decisions, and API and integrations rows, plus the API document filename reference and the component-database-access rule cross-reference, to 06_Component_Library_v1.27, 08_Decision_Log_v1.58, and 11_API_Integration_Architecture_v1.13, as part of the cascade recording DEC-085 (currency-drop fix, Cost Comparison Card rename). No architecture-summary content changed. **Further correction (same day, DEC-085 live-verification closure):** the Source-of-Truth Matrix's Historical decisions row updated to 08_Decision_Log_v1.59 (DEC-085's items confirmed live, plus a GitHub Actions deploy-gap bug found and fixed during that verification). Not bumping the version again for this. **Further correction (DEC-086 cascade — idle-session-timeout closure, the fourth and final DEC-083 item, now built and live-verified):** the Source-of-Truth Matrix's Historical decisions row updated to 08_Decision_Log_v1.60, and the Implementation roadmap row updated to 16_Implementation_Roadmap_v1.23 (Phase 9+10 now recorded as fully closed). Not bumping the version again for this either. **Further correction (same day, recording DEC-087 — Phase 11+12 built and tested):** the Source-of-Truth Matrix's Governance, Product strategy, Experience principles, Navigation and structure, Reusable visual standards, Component specifications, Historical decisions, Frontend architecture, and Implementation roadmap rows updated to 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19, 02_Experience_Strategy_v1.20, 03_Information_Architecture_v1.17, 05_Design_System_v1.33, 06_Component_Library_v1.28, 08_Decision_Log_v1.61, 13_Frontend_Architecture_v1.21, and 16_Implementation_Roadmap_v1.24. Not bumping the version again for this either. |
| v1.23 | Current | Housekeeping pass, not tied to a new DEC: updated the Source-of-Truth Matrix's Screen guidance, Historical decisions, and Implementation roadmap rows to 04_Experience_Blueprint_v1.25, 08_Decision_Log_v1.61, and 16_Implementation_Roadmap_v1.24, as part of the cascade recording DEC-087 (Phase 11+12 built and tested). No architecture-summary content changed. **Further correction (recording DEC-088 — Phase 13 closed by documenting as-built deployment reality):** the Historical decisions, Deployment architecture, and Implementation roadmap rows updated to 08_Decision_Log_v1.62, 15_Deployment_Architecture_v1.13, and 16_Implementation_Roadmap_v1.25. A fuller sweep also found the Implementation Readiness, Database Architecture, API Architecture, Backend Architecture, and Testing Strategy rows one or more hops stale from the earlier DEC-087 cascade — corrected to 09_Implementation_Readiness_v1.11, 10_Database_Architecture_v1.22, 11_API_Integration_Architecture_v1.14, 12_Backend_Architecture_v1.15, and 14_Testing_Strategy_v1.17. Not bumping the version again for this. **Further correction (documentation audit pass):** three body cross-references left one or more hops stale from the same DEC-087/088 cascade (API document filename reference, Path A's RLS-enforcement note, Path B's routing note, and the component-database-access rule) corrected to 11_API_Integration_Architecture_v1.14, 10_Database_Architecture_v1.22, and 12_Backend_Architecture_v1.15. Not bumping the version again for this either. |
| v1.21 | Frozen | **Records DEC-083 cascade** (Phase 9+10 built and deployed): refreshed the Source-of-Truth Matrix to the fully-settled versions in one consolidated pass — 00_Project_Governance_v1.21, 01_Product_Strategy_v1.17, 02_Experience_Strategy_v1.19, 03_Information_Architecture_v1.16, 04_Experience_Blueprint_v1.24, 05_Design_System_v1.32, 06_Component_Library_v1.26, 08_Decision_Log_v1.56, 10_Database_Architecture_v1.20, 11_API_Integration_Architecture_v1.12, and 16_Implementation_Roadmap_v1.21. Also fixed two pre-existing stale body citations caught during this pass's own grep check: the Path A summary's RLS-enforcement cross-reference was still at `10_Database_Architecture_v1.18`, two cascades behind the Matrix's own row, corrected to v1.20; and the Frontend Architecture Summary's component-database-access rule still cited `11_API_Integration_Architecture_v1.11`, corrected to v1.12. **Correction (same day):** the Component specifications row corrected to 06_Component_Library_v1.26, since 06 moved again later in this same cleanup pass. **Further correction (same day, full grep audit):** the Matrix's Implementation Readiness, Backend architecture, Frontend architecture, and Testing strategy rows, plus the Backend Architecture Summary's Path B routing-rule citation, all found one hop stale — corrected to 09_Implementation_Readiness_v1.9, 12_Backend_Architecture_v1.13 (both places), 13_Frontend_Architecture_v1.19, and 14_Testing_Strategy_v1.15. Not bumping the version again for this. No architecture-summary content changed. |
