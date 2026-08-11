# 15 Deployment Architecture v1.13

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DEP-001 |
| Product | SubSense |
| Version | v1.13 |
| Status | Frozen implementation baseline |
| Source of Truth | Deployment, release, environment, and operations architecture |
| Depends On | 14_Testing_Strategy_v1.17 |

## Purpose

This document defines how SubSense moves from source code to production. It covers environments, deployment pipeline, configuration, secrets, database migrations, release governance, rollback, monitoring, logging, and disaster recovery.

## Deployment Philosophy

SubSense follows a progressive environment deployment model:

Developer -> Development -> Staging -> Production

Code always flows forward. Production is never updated directly.

## Deployment Stack

| Layer | Technology |
| --- | --- |
| Frontend | Built in Cursor (DEC-053), deployed to Vercel |
| Backend | Supabase Edge Functions or backend services |
| Database | Supabase PostgreSQL |
| Authentication | Supabase Auth |
| Storage | Supabase Storage, if needed |
| AI | OpenAI |
| Email | Resend |
| Payments | Razorpay Test Mode, live later |
| Source Control | GitHub |
| CI/CD | GitHub Actions, future-ready |

## SPA Routing (Vercel)

Subsense-web is a pure client-side React Router SPA with no server-side routes — every path beyond `/` (`/auth/reset-password`, `/subscriptions/:id`, etc.) only exists as a route React Router matches after the app has already loaded, not as a physical file. Vercel's zero-config Vite build does not add a catch-all rewrite automatically, so a direct external navigation to any nested path (an emailed link, a bookmarked URL, a hard refresh) 404s before React Router ever runs — only in-app `<Link>` navigation ever works, since that never leaves the already-loaded page.

`vercel.json` at the repo root must include a catch-all rewrite so every request resolves to the SPA shell and React Router takes over:

```json
{
  "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }]
}
```

**Found missing in production (DEC-076):** this file did not exist anywhere in the repo as of that decision, and the gap wasn't cosmetic — Supabase's real password-reset email redirects to `/auth/reset-password`, the exact class of path this breaks. Any nested-path deep link (auth recovery flows, direct-linked subscription detail pages, etc.) requires this rewrite to work when reached from outside the running app.

## Environment Strategy

### Development

Purpose:

- Feature implementation.
- Local debugging.
- Developer testing.

Uses:

- Development Supabase project.
- OpenAI development key.
- Resend test configuration.
- Razorpay Test Mode.

### Staging

Purpose:

- Integration testing.
- User acceptance testing.
- Performance validation.
- Release rehearsal.

Staging should mirror production configuration as closely as practical.

### Production

Purpose:

- Live customer environment.

Rules:

- Changes reach production only through approved deployments.
- Production secrets remain isolated.
- Production data is protected by RLS and operational controls.

## Deployment Pipeline

Standard flow:

Developer -> Commit -> GitHub -> CI Pipeline -> Automated Tests -> Staging Deployment -> Approval -> Production Deployment

## Configuration Management

Configuration must be externalized.

Examples:

- Supabase URL.
- Supabase keys.
- JWT configuration.
- OpenAI API key.
- Resend API key.
- Razorpay test keys.
- Environment URLs.

Rules:

- Configuration keys remain identical across environments.
- Only values differ.
- New configuration variables must be introduced across every environment before deployment.
- Configuration is never hardcoded.

## Secret Management

Secrets are stored only in platform-managed secret stores.

Never store secrets in:

- Git repository.
- Frontend bundle.
- Source code.
- Logs.
- Screenshots.
- Documentation examples with real values.

## Database Deployment

Schema changes occur through version-controlled migrations.

Migration flow:

Migration -> Validation -> Backup -> Execute -> Verify

Rules:

- Sequential migration numbering.
- Forward-only production migrations.
- Backup before production execution.
- Post-migration validation.
- No manual production schema modification.
- Rollback or compensating migration plan documented.

## Release Sequence

Recommended production release order:

1. Verify quality gates.
2. Backup database where applicable.
3. Run database migrations.
4. Deploy backend services.
5. Deploy frontend.
6. Run smoke tests.
7. Monitor production.
8. Confirm release completion.

## Deployment Verification Checklist

Every deployment must verify:

- Application startup.
- Authentication.
- Protected routes.
- Database connectivity.
- Decision Workspace availability.
- API health.
- AI service health.
- Email service health.
- Payment service health.
- Critical logs.

Deployment is incomplete until required checks pass.

## Release Governance

Production deployment requires:

- IR-006 quality gates satisfied.
- Successful staging deployment.
- Deployment verification completed.
- Release version assigned.
- Rollback plan documented.
- Approval recorded.

No deployment may bypass release governance.

## Rollback Strategy

Rollback applies to:

- Frontend.
- Backend services.
- Configuration.
- Database where feasible.

Database migrations should be designed with rollback or compensating migration in mind.

## Monitoring

Production monitoring includes:

- Application health.
- API health.
- Database health.
- Authentication failures.
- AI integration failures.
- Email delivery failures.
- Razorpay Test Mode or future payment failures.
- Background job failures.
- Error rates.

## Logging

Production logging includes:

- API errors.
- Background jobs.
- Reminder execution.
- AI failures.
- Email failures.
- Payment failures.
- Security-sensitive events.

Sensitive information must never be logged.

## Disaster Recovery

Recovery assumptions:

- Source code is version-controlled.
- Migrations are version-controlled.
- Environment configuration can be recreated.
- Secrets can be restored from managed stores.
- Database backup exists where required.
- Deployment steps are reproducible.

## Validation Checklist

| Check | Status |
| --- | --- |
| Environment strategy defined | Complete |
| Deployment pipeline defined | Complete |
| Configuration standard defined | Complete |
| Secret management defined | Complete |
| Migration governance defined | Complete |
| Verification checklist defined | Complete |
| Release governance defined | Complete |
| Rollback strategy defined | Complete |
| Monitoring/logging defined | Complete |

## As-Built Deployment Record (DEC-088)

The sections above describe this document's originally-specified progressive-environment architecture (Development -> Staging -> Production, a formal verification gate, and a documented rollback plan). This section records what actually happened for this capstone build, since the two had drifted apart without ever being reconciled.

**No separate staging tier was ever stood up.** Every phase from Phase 6 onward (DEC-068 through DEC-087) deployed straight to production: the frontend via Vercel, auto-triggered on push to `main`; Supabase Edge Functions via a GitHub Actions workflow, also auto-triggered on push. There is one Vercel project and one Supabase project, not the separate development/staging/production instances described above. This was a deliberate, accepted scope call for a solo capstone project on a fixed demo-day timeline, not an oversight discovered late — see DEC-088 for the full reasoning.

**Verification, in practice:** the formal Deployment Verification Checklist above was never run as a single documented pass/fail gate per deployment. Instead, each phase's own live-testing (recorded per-DEC in `08_Decision_Log`) informally covered equivalent ground on a rolling basis — application startup, auth, protected routes, and the relevant service health were re-confirmed by hand after essentially every deploy this build shipped.

**Rollback, in practice:** no dedicated rollback tooling exists. The de facto mechanism has always been `git revert` on `main` followed by the same forward auto-deploy pipeline running again — used, for example, when a failed GitHub Actions run left a stale Edge Function response shape live (DEC-085's verification pass), resolved by simply re-running the same unchanged workflow rather than a formal rollback procedure. This has never been exercised as a genuine incident rollback, only as ordinary iterative fixing.

**Not retired:** the originally-specified architecture above stays documented as the target model for a real multi-environment deployment, should SubSense continue past capstone as a production product — it is not deleted or marked wrong, only annotated with what this build actually did instead.

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Deployment architecture frozen after IR-007 and IR-009. Updated dependency reference to 14_Testing_Strategy_v1.1. |
| v1.1 | Frozen | Updated dependency reference to 14_Testing_Strategy_v1.2, following the brand kit finalization under DEC-042. |
| v1.2 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 14_Testing_Strategy_v1.4, closing a citation-integrity gap found during the DEC-045 pass. |
| v1.3 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 14_Testing_Strategy_v1.4, as part of the cascade patching 11_API_Integration_Architecture's own internal reference-integrity gaps. |
| v1.4 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 14_Testing_Strategy_v1.6, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). |
| v1.5 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 14_Testing_Strategy_v1.7, as part of the cascade recording DEC-047 and its version bump to 10_Database_Architecture_v1.7, batched with the notification-template SQL patch (file 23). A follow-up pre-PRD audit caught this dependency reference one further version behind (v1.7) -- now 14_Testing_Strategy_v1.8. Not bumping the version again for this. |
| v1.6 | Frozen | Recorded DEC-053: the Deployment Stack's Frontend row changed from "Lovable to Vercel" to "Built in Cursor, deployed to Vercel." Updated the dependency reference to 14_Testing_Strategy_v1.9. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 14_Testing_Strategy_v1.10, as 14 continued to move within the same DEC-053 cascade. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 14_Testing_Strategy_v1.12, as 14 continued moving within the same DEC-053 cascade. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 14_Testing_Strategy_v1.13, closing drift deliberately deferred since the DEC-054 pass. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 14_Testing_Strategy_v1.14, following DEC-055 (logo wordmark font resolved, logo formally implemented). |
| v1.11 | Frozen | Recorded DEC-076: added a new SPA Routing (Vercel) section documenting a real production bug found and fixed this session — no `vercel.json` existed anywhere in Subsense-web, so Vercel 404s on direct navigation to any nested client-routed path (no catch-all rewrite configured), confirmed to affect the real password-reset email flow, not just a newly-added template link. Fix: `vercel.json` with a catch-all rewrite to `index.html`, handed to the user as a Claude Code prompt — not yet committed/deployed as of this entry. No Depends On change — 14_Testing_Strategy is still at v1.14. **Further correction (same day, full grep audit):** the Depends On field's 14_Testing_Strategy citation, found stuck at v1.14, corrected to v1.15. Not bumping the version again for this. **Further correction (same day, second-order cascade closure):** the Depends On field's 14_Testing_Strategy citation updated again to v1.16, since 14 moved again in this same closure pass. Not bumping the version again for this either. |
| v1.12 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field's 14_Testing_Strategy citation to v1.17, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No deployment/release content changed. |
| v1.13 | Current | **Recorded DEC-088:** added a new "As-Built Deployment Record" section documenting the actual deployment reality against this document's originally-specified progressive-environment architecture — production-only deployment (Vercel + GitHub Actions) since Phase 6, no staging tier ever stood up, the formal Verification Checklist never run as a single gate (covered informally by each phase's own live-testing instead), and rollback handled in practice via `git revert` plus the same forward auto-deploy pipeline. The originally-specified architecture above is retained as the target model, not deleted or corrected — only annotated with what this build actually did. |
