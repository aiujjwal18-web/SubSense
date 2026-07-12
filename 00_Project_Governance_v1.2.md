# 00 Project Governance v1.2

## Document Control

| Field | Value |
| --- | --- |
| Document ID | GOV-001 |
| Product | SubSense |
| Version | v1.2 |
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
| Related Documents | 08_Decision_Log_v1.2, 09_Implementation_Readiness_v1.0 |

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
| Governance | 00_Project_Governance_v1.2 |
| Product strategy | 01_Product_Strategy_v1.2 |
| Experience principles | 02_Experience_Strategy_v1.2 |
| Navigation and structure | 03_Information_Architecture_v1.2 |
| Screen implementation guidance | 04_Experience_Blueprint_v1.2 |
| Reusable visual standards | 05_Design_System_v1.2 |
| Component specifications | 06_Component_Library_v1.2 |
| Architecture index | 07_Product_Architecture_v1.2 |
| Historical decisions | 08_Decision_Log_v1.2 |
| Implementation baseline | 09_Implementation_Readiness_v1.0 |
| Database architecture | 10_Database_Architecture_v1.0 |
| API and integrations | 11_API_Integration_Architecture_v1.0 |
| Backend architecture | 12_Backend_Architecture_v1.0 |
| Frontend architecture | 13_Frontend_Architecture_v1.0 |
| Testing strategy | 14_Testing_Strategy_v1.0 |
| Deployment architecture | 15_Deployment_Architecture_v1.0 |
| Implementation roadmap | 16_Implementation_Roadmap_v1.0 |

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
| v1.2 | Current | Implementation Freeze alignment and 17-document package mapping. |
