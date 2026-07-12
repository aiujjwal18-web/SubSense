# 15 Deployment Architecture v1.0

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DEP-001 |
| Product | SubSense |
| Version | v1.0 |
| Status | Frozen implementation baseline |
| Source of Truth | Deployment, release, environment, and operations architecture |
| Depends On | 14_Testing_Strategy_v1.0 |

## Purpose

This document defines how SubSense moves from source code to production. It covers environments, deployment pipeline, configuration, secrets, database migrations, release governance, rollback, monitoring, logging, and disaster recovery.

## Deployment Philosophy

SubSense follows a progressive environment deployment model:

Developer -> Development -> Staging -> Production

Code always flows forward. Production is never updated directly.

## Deployment Stack

| Layer | Technology |
| --- | --- |
| Frontend | Lovable to Vercel |
| Backend | Supabase Edge Functions or backend services |
| Database | Supabase PostgreSQL |
| Authentication | Supabase Auth |
| Storage | Supabase Storage, if needed |
| AI | OpenAI |
| Email | Resend |
| Payments | Razorpay Test Mode, live later |
| Source Control | GitHub |
| CI/CD | GitHub Actions, future-ready |

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

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Current | Deployment architecture frozen after IR-007 and IR-009. |
