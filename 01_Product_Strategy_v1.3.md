# 01 Product Strategy v1.3

## Document Control

| Field | Value |
| --- | --- |
| Document ID | PST-001 |
| Product | SubSense |
| Version | v1.3 |
| Status | Frozen implementation baseline |
| Source of Truth | Product strategy |
| Depends On | 00_Project_Governance_v1.2 |

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
- Suggest lower-cost alternatives as informational context.
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

The user may configure reminder timing where supported, but the product remains email-first for MVP.

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

Each subscription also records its payment rail: UPI AutoPay, card e-mandate, app-store billing, or manual. SubSense never cancels or modifies a mandate on the user's behalf; it uses the rail only to tell the user where to go to cancel it themselves, consistent with the Product Philosophy in `00_Project_Governance_v1.2`.

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
| Frontend | Lovable |
| Hosting | Vercel |
| Backend | Supabase / backend services |
| Database | Supabase PostgreSQL |
| Authentication | Supabase Auth plus Google Sign-In |
| AI | OpenAI API |
| Email | Resend |
| Payments | Razorpay Test Mode |
| Version Control | GitHub |
| API Testing | Postman |
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

Capability checklist above defines *what* must work. The following numeric targets define *how well*, and are the pass/fail bar for the Exit Criteria in `14_Testing_Strategy_v1.1` and the Week 3 checkpoint in that same document:

| Metric | Target | Measured By |
| --- | --- | --- |
| Activation rate | At least 80 percent of new accounts add one subscription within the first session | Onboarding flow analytics/event log |
| Time to first subscription | Median under 3 minutes from account creation to first saved subscription | Timestamp diff, account creation to `subscriptions` insert |
| Reminder delivery success rate | At least 99 percent of due reminders result in a `notifications` row with delivered status within 15 minutes of the scheduled time | `reminder_history` and `notifications` audit per `10_Database_Architecture_v1.1` |
| AI insight generation success rate | At least 95 percent of AI insight requests return a usable recommendation rather than the fallback "insight unavailable" state | `ai_recommendations` success/fallback ratio, per `11_API_Integration_Architecture_v1.0` error AI_003 |
| Shared payment completion rate | At least 90 percent of `payment_requests` reach a final paid or archived state within 14 days of creation | `payment_requests` status/age query |
| Core flow error rate | Under 1 percent of Path A/Path B requests on primary flows (add subscription, mark paid, generate insight) return an unhandled error | Error logs / `audit_logs` |
| Demo acceptance | All 12 Critical E2E Test Scenarios in `14_Testing_Strategy_v1.1` pass with zero Critical defects open | QA sign-off per Exit Criteria |

These targets are frozen alongside this document; the pass/fail bar itself does not change without change control, though the underlying analytics implementation may evolve.

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
| v1.3 | Current | Added payment rail awareness (UPI AutoPay, card e-mandate, app-store, manual) to MVP scope per DEC-032. Corrected title/Document Control version to match filename (was misstated as v1.2) and added measurable MVP success metrics per DEC-040. |
