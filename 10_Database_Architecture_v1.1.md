# 10 Database Architecture v1.0

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DB-001 |
| Product | SubSense |
| Version | v1.0 |
| Status | Frozen implementation baseline |
| Source of Truth | Supabase PostgreSQL schema and RLS architecture |
| Depends On | 09_Implementation_Readiness_v1.0 |

## Purpose

This document defines the database architecture for SubSense, including bounded domains, entity ownership, table strategy, identifiers, RLS model, migration order, and implementation standards.

## Database Philosophy

The database supports the product. It does not define the product.

Modeling order:

Business Domain -> Business Entity -> Relationships -> Business Rules -> Database Entity -> Table Specification -> SQL

## Platform

| Area | Technology |
| --- | --- |
| Database | Supabase PostgreSQL |
| Authentication source | Supabase Auth |
| Security | Row Level Security |
| Primary keys | UUID |
| Business IDs | Human-readable prefixed identifiers |
| Stable states | PostgreSQL ENUMs |

## Bounded Domains

| Domain | Purpose |
| --- | --- |
| Identity | Users, profiles, preferences |
| Subscription Management | Subscriptions, catalog, categories |
| Shared Subscription | Shared ownership and payment requests |
| Reminder Engine | Reminder configuration and execution history |
| AI Decision Support | AI-generated recommendations |
| Notifications | Email and notification records |
| Billing | Premium plans and Razorpay Test Mode transactions |
| System and Audit | Logs, configuration, operational audit |

## Entity Inventory

| Entity | Owner Module | Table |
| --- | --- | --- |
| User | Authentication | users |
| User Profile | Profile | user_profiles |
| User Preferences | Profile | user_preferences |
| Subscription Category | My Subscriptions | subscription_categories |
| Subscription Catalog | Add Subscription | subscription_catalog |
| Subscription | My Subscriptions | subscriptions |
| Shared Subscription | Shared Subscriptions | shared_subscriptions |
| Shared Member | Shared Subscriptions | shared_members |
| Payment Request | Shared Subscriptions | payment_requests |
| Reminder | Reminder Engine | reminders |
| Reminder History | Reminder Engine | reminder_history |
| AI Recommendation | Decision Workspace | ai_recommendations |
| Notification | Notification Service | notifications |
| Notification Template | Notification Service | notification_templates |
| Premium Plan | Billing | premium_plans |
| Payment Transaction | Billing | payment_transactions |
| Audit Log | System | audit_logs |
| System Setting | System | system_settings |

## Identifier Standard

| Entity | Internal ID | Business ID |
| --- | --- | --- |
| User | UUID | USR- |
| Subscription | UUID | SUB- |
| Reminder | UUID | REM- |
| Shared Subscription | UUID | SHR- |
| Payment Request | UUID | PAY- |
| AI Recommendation | UUID | AIR- |
| Notification | UUID | NOT- |
| Audit Log | UUID | AUD- |

UUIDs are primary keys. Business IDs are secondary identifiers for traceability.

## ENUM Standard

Use PostgreSQL ENUMs for stable shared values:

- account_status.
- theme.
- currency.
- billing_frequency.
- lifecycle_status.
- payment_method.
- review_status.
- delivery_status.
- transaction_status.
- notification_channel.
- trigger_source.
- actor_type.
- audit_action.

## Core Identity Tables

### users

Purpose:

- Stores SubSense application identity metadata.
- Supabase Auth remains the source of authentication.

Key columns:

- id UUID primary key.
- user_code unique.
- auth_user_id unique FK to auth.users.
- email unique.
- auth_provider.
- account_status.
- email_verified.
- last_login_at.
- created_at.
- updated_at.
- archived_at.

RLS:

- Users can read their own record.
- Inserts are backend controlled.
- Updates are limited.
- Delete disabled; archive only.

### user_profiles

Purpose:

- Stores profile information independent of authentication.

Key columns:

- id.
- user_id unique FK to users.
- display_name.
- profile_photo_url.
- country.
- timezone.
- default_currency.
- created_at.
- updated_at.

RLS:

- Owner only.

### user_preferences

Purpose:

- Stores configurable user behavior.

Key columns:

- id.
- user_id unique FK to users.
- email_notifications.
- reminder_default_days.
- theme.
- dashboard_layout.
- created_at.
- updated_at.

RLS:

- Owner only.

## Master Data Tables

### subscription_categories

Purpose:

- Standardized subscription classification.

Access:

- Authenticated users read.
- Admin/service role writes.

### subscription_catalog

Purpose:

- Known subscription providers such as Netflix, Spotify, ChatGPT.

Access:

- Authenticated users read.
- Admin/service role writes.
- Future user-created entries may be owner-only until approved.

### premium_plans

Purpose:

- Defines Free and Premium demonstration plans.

Access:

- Authenticated users read.
- Admin/service role writes.

### notification_templates

Purpose:

- Reusable email and notification templates.

Access:

- Backend services read.
- Admin/service role writes.

## Business Data Tables

### subscriptions

Purpose:

- User-owned subscription records.

Typical fields:

- user_id.
- catalog_id.
- custom_name.
- cost.
- currency.
- billing_frequency.
- next_renewal_date.
- payment_method: enum, one of `upi_autopay`, `card_emandate`, `app_store`, `manual`.
- payment_reference_note: optional text, e.g. UPI app name or mandate reference, for the user's own recall.
- lifecycle_status.
- monthly_equivalent.
- annual_equivalent.
- created_at.
- updated_at.
- archived_at.

`payment_method` and `payment_reference_note` exist because cancellation paths in India differ fundamentally by rail — a UPI AutoPay mandate can only be cancelled from the originating UPI app, never by SubSense (DEC-032). Subscription Details surfaces rail-specific guidance from this field rather than implying SubSense can act on it, preserving GP-001 and BR-001.

### shared_subscriptions

Purpose:

- Represents shared ownership or shared cost context for a subscription.

### shared_members

Purpose:

- Stores participant details, amount owed, and active/inactive membership.

### payment_requests

Purpose:

- Tracks split payment requests and status.

### reminders

Purpose:

- Defines scheduled reminders for subscriptions and shared payments.

### ai_recommendations

Purpose:

- Stores generated AI insights and recommendation context.

AI does not own business state.

### notifications

Purpose:

- Stores notification delivery records.

### payment_transactions

Purpose:

- Stores Razorpay Test Mode premium transaction history.

No production payment processing is part of MVP.

## System Data Tables

### reminder_history

Purpose:

- Immutable record of every reminder execution attempt.

Rules:

- Append-only.
- No update.
- No delete.

### audit_logs

Purpose:

- Immutable record of security-sensitive and business-significant events.

Access:

- Admin/service roles only.
- No direct end-user access.

### system_settings

Purpose:

- Application-wide configuration not specific to one user.

Access:

- Backend read.
- Admin write.
- No end-user access.

## RLS Security Model

Principle:

- Least privilege.

Security layers:

Authentication -> RLS -> Application Business Rules -> Frontend

Actor roles:

| Role | Purpose |
| --- | --- |
| Authenticated User | Normal app user |
| Service Role | Backend automation |
| Administrator | Platform administration |
| Anonymous | No data access |

## Table Security Matrix

| Table Category | Read | Create | Update | Delete |
| --- | --- | --- | --- | --- |
| User-owned | Owner | Owner or backend | Owner | Archive only |
| Shared | Owner/member | Owner | Owner | Archive |
| Master data | Authenticated users | Admin | Admin | Admin |
| Infrastructure | Restricted | Service/Admin | Service/Admin | Never or admin-only |

## Delete Strategy

Business data uses soft delete:

Delete intent -> archived_at populated -> excluded from active views

Physical deletes are not part of normal MVP behavior.

## Migration Order

1. ENUM types.
2. Core identity tables.
3. Master data tables.
4. Business data tables.
5. System data tables.
6. Indexes.
7. RLS enablement.
8. RLS policies.
9. Seed data.
10. Validation queries.

## Database Validation Checklist

| Check | Status |
| --- | --- |
| Entity domains defined | Complete |
| Table ownership defined | Complete |
| Identifier standard defined | Complete |
| ENUM standard defined | Complete |
| RLS model defined | Complete |
| Soft delete policy defined | Complete |
| Migration order defined | Complete |
| API dependency noted | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Database architecture frozen after IR-002 and IR-009. |
| v1.1 | Current | Added `payment_method` ENUM and `payment_reference_note` field to `subscriptions` per DEC-032. Non-breaking additive change. |
