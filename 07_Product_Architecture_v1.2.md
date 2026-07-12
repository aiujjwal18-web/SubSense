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
| 01_Product_Strategy_v1.2 | Product direction | Product Strategy |
| 02_Experience_Strategy_v1.2 | UX behavior | Experience Strategy |
| 03_Information_Architecture_v1.2 | Product structure | Information Architecture |
| 04_Experience_Blueprint_v1.2 | Screen guidance | Experience Blueprint |
| 05_Design_System_v1.2 | Reusable UI standards | Design System |
| 06_Component_Library_v1.2 | Component specs | Component Library |
| 08_Decision_Log_v1.2 | Historical decisions | Decision Log |
| 09_Implementation_Readiness_v1.0 | Readiness baseline | Implementation Readiness |
| 10_Database_Architecture_v1.0 | Schema and RLS | Database Architecture |
| 11_API_Integration_Architecture_v1.0 | APIs and integrations | API Architecture |
| 12_Backend_Architecture_v1.0 | Services and jobs | Backend Architecture |
| 13_Frontend_Architecture_v1.0 | Frontend engineering | Frontend Architecture |
| 14_Testing_Strategy_v1.0 | Test governance | Testing Strategy |
| 15_Deployment_Architecture_v1.0 | Environments and release | Deployment Architecture |
| 16_Implementation_Roadmap_v1.0 | Build sequence | Implementation Roadmap |

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

Architecture rules:

- Frontend never talks directly to OpenAI, Resend, or Razorpay.
- Backend mediates all external provider access.
- Supabase is the system of record.
- JWT is the user trust boundary.
- Provider keys never reach the frontend.

## Backend Architecture Summary

Backend architecture follows:

API -> Services -> Repositories -> Supabase

Rules:

- Services own transaction boundaries.
- External API calls do not run inside database transactions.
- Background jobs use the same service layer as interactive requests.
- Repositories do not call services or APIs.

## Frontend Architecture Summary

Frontend architecture follows:

Presentation -> Feature Components -> Shared Components -> API Client -> Backend

Rules:

- Components never access the database directly.
- Business entities have one frontend source of truth.
- Server state remains backend-authoritative.
- Optimistic UI is allowed only for safe reversible actions.

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
| v1.2 | Current | Implementation Freeze alignment and 17-document package index. |
