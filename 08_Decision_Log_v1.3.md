# 08 Decision Log v1.3

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DLOG-001 |
| Product | SubSense |
| Version | v1.3 |
| Status | Frozen implementation baseline |
| Source of Truth | Historical decision record |
| Depends On | 00_Project_Governance_v1.2 |

## Purpose

This document records the major product, UX, architecture, technical, security, and governance decisions that define SubSense.

It records why decisions exist. It does not redefine the detailed specifications owned by other documents.

## Decision Entry Standard

Each decision should include:

- Decision ID.
- Date or phase.
- Milestone.
- Category.
- Decision.
- Alternatives considered.
- Rationale.
- Impact.
- Affected documents.
- Status.

## Decision Categories

- Governance.
- Product.
- UX.
- Architecture.
- Technical.
- Security.
- Development.
- Documentation.

## Active Decision Register

| ID | Category | Decision | Rationale | Affected Documents | Status |
| --- | --- | --- | --- | --- | --- |
| DEC-001 | Product | SubSense is an AI-assisted subscription decision platform. | Focuses the product on decision support rather than generic tracking. | 01, 02, 03 | Active |
| DEC-002 | Governance | Users retain final control over financial actions. | Protects trust and avoids over-automation. | 00, 01, 02 | Active |
| DEC-003 | Product | MVP is email-first. | Email is practical for reminders and capstone scope. | 01, 10, 12 | Active |
| DEC-004 | Product | SubSense does not cancel third-party subscriptions. | The app does not control external providers. | 00, 01, 02 | Active |
| DEC-005 | Product | Decision Workspace is the primary authenticated home. | Users need to know what needs attention today. | 02, 03, 04 | Active |
| DEC-006 | UX | Use View -> Edit for editable screens. | Prevents accidental changes and supports trust. | 02, 04, 05, 06 | Active |
| DEC-007 | UX | Archive is preferred over delete. | Preserves history and supports recoverability. | 00, 02, 10 | Active |
| DEC-008 | UX | Search is contextual, not a standalone module. | Avoids unnecessary navigation complexity. | 03, 04 | Active |
| DEC-009 | Product | Profile replaces top-level Settings. | Keeps navigation focused on primary workflows. | 03, 04 | Active |
| DEC-010 | Product | Insights contains both AI insights and financial reports. | Combines analysis without adding another top-level module. | 01, 03, 04 | Active |
| DEC-011 | Product | Google Sign-In is primary authentication. | Reduces onboarding friction and is supported by Supabase Auth. | 01, 09, 13 | Active |
| DEC-012 | Technical | Supabase is the system of record. | Provides Auth, PostgreSQL, RLS, and platform fit for MVP. | 07, 10, 12 | Active |
| DEC-013 | Technical | OpenAI powers AI insights. | Enables recommendation and explanation layer. | 01, 11, 12 | Active |
| DEC-014 | Technical | Resend handles product emails. | Separates product email from auth email. | 01, 11, 12 | Active |
| DEC-015 | Technical | Razorpay is Test Mode only for MVP. | Demonstrates premium flow without live payment risk. | 01, 11, 15 | Active |
| DEC-016 | Architecture | Frontend never talks directly to external providers. | Keeps secrets and provider orchestration server-side. | 11, 12, 13 | Active |
| DEC-017 | Architecture | Use hub-and-spoke integration architecture. | Keeps integrations replaceable and mediated by backend. | 11, 12 | Active |
| DEC-018 | Database | Use UUID primary keys plus business identifiers. | Supports joins and human-readable traceability. | 09, 10 | Active |
| DEC-019 | Database | Use PostgreSQL ENUMs for stable shared states. | Improves type safety and reduces repeated checks. | 10 | Active |
| DEC-020 | Security | Enable RLS and least-privilege access. | Protects data even if application logic fails. | 10, 12 | Active |
| DEC-021 | Backend | Services own transaction boundaries. | Prevents inconsistent state and long-running transactions. | 12 | Active |
| DEC-022 | Backend | Background jobs use the same service layer as APIs. | Ensures business rules are applied consistently. | 12 | Active |
| DEC-023 | Frontend | Component-driven frontend architecture. | Aligns with Lovable, Design System, and Component Library. | 13 | Active |
| DEC-024 | Frontend | Separate client state from server state. | Prevents stale duplicated business data. | 13 | Active |
| DEC-025 | Testing | Use a business-first testing pyramid. | Tests the product flows, not just technical units. | 14 | Active |
| DEC-026 | Testing | Use RTM for requirement-to-test traceability. | Prevents frozen decisions from being missed. | 14 | Active |
| DEC-027 | Deployment | Use progressive environments. | Production is never updated directly. | 15 | Active |
| DEC-028 | Deployment | Store secrets only in managed secret stores. | Prevents secrets from leaking into code or frontend bundles. | 15 | Active |
| DEC-029 | Governance | Publication-quality docs are generated after IR-009. | Avoids documenting unstable implementation decisions. | 00, 09 | Active |
| DEC-030 | Governance | API document remains `11_API_Integration_Architecture_v1.0`. | User already has the completed API document. | 07, 09, 12, 13, 14, 15, 16 | Active |
| DEC-031 | Architecture | SubSense MVP uses Lean Access Architecture: direct Supabase client + RLS for CRUD, Edge Functions only for secret-bearing or cross-cutting logic. | Matches solo/part-time build capacity without changing enforced business rules; RLS becomes the Repository/Service enforcement layer for simple entities. | 07, 11, 12, 13 | Active |
| DEC-032 | Product | Subscriptions record a payment rail (`payment_method`: UPI AutoPay, card e-mandate, app-store billing, or manual) plus an optional reference note. | India-specific cancellation paths differ fundamentally by rail; a UPI mandate can only be cancelled from the originating UPI app, not by SubSense. Surfacing this is cheap and closes the single biggest gap versus India-specific competitors. | 01, 04, 10, 11 | Active |
| DEC-033 | Testing | A dedicated stress-test checkpoint runs at week 3 of implementation, not only bundled into final QA. | Catching RLS, auth-boundary, accessibility, and load issues mid-build leaves time to fix them before the demo, rather than discovering them at the deadline. | 14, 16 | Active |
| DEC-034 | Documentation | Corrected internal title/version drift across 01, 04, 08, 10, 14, 16 (filenames had advanced past internal Document Control fields) and updated stale cross-references in 00, 09, 11, 12, 13, 16 to match. | Filenames and internal versions had diverged, and the governance index and several dependency lists still pointed at superseded versions, risking implementation from the wrong "frozen" source. | 00, 01, 04, 08, 09, 10, 11, 12, 13, 14, 16 | Active |
| DEC-035 | Architecture | Propagated Lean Access Architecture (DEC-031) into 07, 12, and 13, replacing the legacy "API -> Services -> Repositories -> Supabase" backend model and the "frontend never talks to Supabase directly" frontend rule with the two-path model already defined in 11. | DEC-031 named 07, 11, 12, and 13 as affected documents, but only 11 was ever amended, leaving two contradictory backend architectures active in the package at once. | 07, 12, 13 | Active |
| DEC-036 | Database | Added field-level column lists, constraints, indexes, and RLS policy shape for `shared_subscriptions`, `shared_members`, `payment_requests`, `reminders`, `ai_recommendations`, `notifications`, and `payment_transactions`. | These seven tables previously had only a Purpose line in 10, which is not sufficient to generate migrations without an engineer inventing schema during development. | 10 | Active |
| DEC-037 | Security | Refined the `payment_requests` permission model: the parent-owner may update status to any valid value; a linked member may self-report a request as paid, which sets a pending-confirmation state that the owner must confirm before the request is marked fully paid. | 11 allowed "owner or linked member" updates while 10's Table Security Matrix implied owner-only for all Shared-category tables, an unresolved conflict that would break either the "member marks paid" or the "owner confirms paid" flow depending on which document an engineer followed. | 10, 11 | Active |
| DEC-038 | Database | Added `is_premium`, `premium_expires_at`, and `premium_source` to `user_profiles` as the single premium entitlement source of truth, written only by `razorpay-verify-payment`. | 03 assigned premium status to Billing/Profile as its source of truth, but no field existed anywhere in the schema to hold current entitlement state. | 03, 10, 11 | Active |
| DEC-039 | Architecture | Reminder due-date evaluation runs in the user's `user_profiles.timezone`, not server UTC; archived subscriptions are excluded from reminder generation and delivery; Post-Renewal Check-In reminders are generated by a scheduled function evaluating recently-renewed subscriptions, closing the one reminder type in 01 that previously had no generation mechanism. | Reminder generation covered only 3 of the 6 reminder types promised in 01 (7-day, 2-day, renewal-day), and due-today cron logic had no timezone rule, risking missed or duplicate sends for users outside the server's timezone or with archived subscriptions. | 01, 10, 11 | Active |
| DEC-040 | Testing | Added measurable MVP success metrics to 01 (activation rate, time-to-first-subscription, reminder delivery success rate, AI generation success rate, shared-payment completion rate, core flow error rate) and numeric release-gate thresholds to 14's Week 3 checkpoint (load path volume, latency, and error-rate targets). | Success criteria and quality gates were previously binary/task-based with no pass/fail numbers, making "done" a matter of opinion at demo time. | 01, 14 | Active |

## Superseded or Deprecated Decisions

| Deprecated Term or Idea | Replacement | Reason |
| --- | --- | --- |
| Dashboard | Decision Workspace | Better reflects decision-first purpose. |
| Decision Center | Decision Workspace | Controlled vocabulary standardization. |
| Standalone Search module | Contextual search | Scope simplification. |
| Settings as top-level navigation | Profile | Keeps nav focused. |
| Delete user-facing action | Archive | Recoverability and history preservation. |
| Capstone Mode | Developer/Test Utilities | Clearer implementation term. |

## Decision Traceability Links

Traceability chain:

Product decision -> Source document -> Business rule -> Implementation artifact -> Test case -> Deployment verification

Examples:

| Decision | Business Rule | Implementation Artifact | Test Coverage |
| --- | --- | --- | --- |
| AI never acts for user | BR-001 | AI services, frontend copy | AI validation, E2E review flow |
| Auth required for data | BR-002 | RLS, protected routes | Auth tests, RLS tests |
| First login provisions profile | BR-006 | Auth service, users/profile tables | Onboarding flow tests |
| No duplicate profile on returning login | BR-007 | Auth service | Onboarding regression |
| Auth before data load | BR-008 | Frontend route guards, API auth | Protected route tests |

## Decision Statistics

| Category | Count in This Consolidated Register |
| --- | --- |
| Governance | 4 |
| Product | 9 |
| UX | 5 |
| Architecture | 6 |
| Technical | 5 |
| Security | 3 |
| Testing | 3 |
| Deployment | 2 |
| Database | 2 |
| Documentation | 1 |

## Maintenance Rules

- New decisions receive a permanent `DEC-` ID.
- Superseded decisions remain in the log.
- Affected documents must be listed.
- Implementation changes after IR-009 require change control.

## Validation Checklist

| Check | Status |
| --- | --- |
| Decision IDs defined | Complete |
| Categories defined | Complete |
| Active decisions recorded | Complete |
| Deprecated terms recorded | Complete |
| Traceability examples included | Complete |
| Maintenance rules defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.1 | Frozen | Architecture Freeze decision log. |
| v1.2 | Frozen | Implementation Freeze alignment and consolidated active decisions. |
| v1.3 | Current | Recorded Lean Access Architecture (DEC-031), payment rail field (DEC-032), and week-3 stress-test checkpoint (DEC-033) under change control. Corrected title/Document Control version to match filename (was misstated as v1.2) and recorded documentation normalization (DEC-034), Lean Access propagation to 07/12/13 (DEC-035), database build-grade schema (DEC-036), shared-payment permission model (DEC-037), premium entitlement source of truth (DEC-038), reminder completeness and timezone handling (DEC-039), and measurable success metrics/test thresholds (DEC-040). |
