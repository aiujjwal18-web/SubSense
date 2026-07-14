# 07 Product Architecture v1.2

## Document Control

| Field | Value |
| --- | --- |
| Document ID | PA-001 |
| Product | SubSense |
| Version | v1.2 |
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
| Frontend | Lovable | User interface and client experience |
| Hosting | Vercel | Frontend deployment |
| Auth | Supabase Auth | Identity, sessions, Google Sign-In |
| Database | Supabase PostgreSQL | System of record |
| Backend/API | Supabase Edge Functions or backend services | Business logic and provider orchestration |
| AI | OpenAI | AI insight generation |
| Email | Resend | Email delivery |
| Payments | Razorpay Test Mode | Premium demonstration |
| Version Control | GitHub | Source repository |
| API Testing | Postman | Development validation |
| CI/CD | GitHub Actions | Future-ready automation |

## Source-of-Truth Matrix

| Document | Purpose | Source of Truth |
| --- | --- | --- |
| 00_Project_Governance_v1.2 | Governance and rules | Governance |
| 01_Product_Strategy_v1.3 | Product direction | Product Strategy |
| 02_Experience_Strategy_v1.2 | UX behavior | Experience Strategy |
| 03_Information_Architecture_v1.2 | Product structure | Information Architecture |
| 04_Experience_Blueprint_v1.3 | Screen guidance | Experience Blueprint |
| 05_Design_System_v1.2 | Reusable UI standards | Design System |
| 06_Component_Library_v1.2 | Component specs | Component Library |
| 08_Decision_Log_v1.3 | Historical decisions | Decision Log |
| 09_Implementation_Readiness_v1.0 | Readiness baseline | Implementation Readiness |
| 10_Database_Architecture_v1.1 | Schema and RLS | Database Architecture |
| 11_API_Integration_Architecture_v1.0 | APIs and integrations | API Architecture |
| 12_Backend_Architecture_v1.0 | Services and jobs | Backend Architecture |
| 13_Frontend_Architecture_v1.0 | Frontend engineering | Frontend Architecture |
| 14_Testing_Strategy_v1.1 | Test governance | Testing Strategy |
| 15_Deployment_Architecture_v1.0 | Environments and release | Deployment Architecture |
| 16_Implementation_Roadmap_v1.1 | Build sequence | Implementation Roadmap |

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

The API document is maintained separately as `11_API_Integration_Architecture_v1.0.md`.

Per DEC-031 (Lean Access Architecture), SubSense uses two access paths rather than a single uniform pipeline:

- **Path A — Direct Data Access**: the Lovable frontend uses the Supabase client (`supabase-js`) directly for user-owned CRUD (profile, preferences, subscriptions, shared subscriptions, members, payment requests, and reads of reminders/notifications/AI output/catalog). Row Level Security, defined in `10_Database_Architecture_v1.1`, is the enforcement layer for this path — RLS stands in for a Repository/Service layer for these simple, owner-scoped operations.
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
- Path B (secret-bearing, scheduled, or system-owned writes): API Handler -> Service -> Provider Client / Repository -> Supabase, as detailed in `12_Backend_Architecture_v1.0`.

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

- Components never access the database directly outside the sanctioned Path A Supabase client calls defined in `11_API_Integration_Architecture_v1.0`; there is no ad hoc query building in components.
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
| v1.2 | Current | Implementation Freeze alignment and 17-document package index. Propagated Lean Access Architecture (DEC-031, DEC-035) into the Integration/Backend/Frontend Architecture Summaries, replacing the stale "API -> Services -> Repositories -> Supabase" model, and corrected the Source-of-Truth Matrix to reference the current versions of 01, 04, 08, 10, 14, and 16. |
