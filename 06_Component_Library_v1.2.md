# 06 Component Library v1.2

## Document Control

| Field | Value |
| --- | --- |
| Document ID | CL-001 |
| Product | SubSense |
| Version | v1.2 |
| Status | Frozen implementation baseline |
| Source of Truth | Reusable component specifications |
| Depends On | 05_Design_System_v1.2 |

## Purpose

This document specifies reusable components used to implement SubSense. It defines component IDs, purpose, states, variants, dependencies, reuse locations, and implementation notes.

The Component Library does not redefine visual rules from the Design System or screen layouts from the Experience Blueprint.

## Component Identification Standard

Every reusable component receives a permanent component ID.

Required component fields:

- Component ID.
- Name.
- Purpose.
- Owner document.
- Props or data inputs.
- States.
- Variants.
- Interactions.
- Validation rules.
- Accessibility requirements.
- Dependencies.
- Reuse locations.
- Future extensions.

## Component Inventory

| ID | Component | Purpose |
| --- | --- | --- |
| C-001 | Global Header | Global access to search, add action, notifications, profile. |
| C-002 | Sidebar Navigation | Primary authenticated navigation. |
| C-003 | AI Decision Card | Signature decision-support card. |
| C-004 | Today's Financial Context | Most important financial context for today. |
| C-005 | Renewal List | Chronological renewal timeline. |
| C-006 | Shared Activity Card | Pending shared payment activity. |
| C-007 | Savings Opportunity Card | Explain possible savings opportunity. |
| C-008 | Insights Preview Card | Preview analytical information. |
| C-009 | Empty State Card | Reusable empty state guidance. |
| C-010 | Subscription Card | Subscription summary in My Subscriptions. |
| C-011 | Annual Cost Preview | Live annualized cost summary. |
| C-012 | Renewal Urgency Indicator | Visual urgency cue for upcoming renewals. |
| C-013 | Lifecycle Status Badge | Subscription lifecycle display. |
| C-014 | Financial Summary Pattern | Reusable financial metric layout. |
| C-015 | View/Edit Controller | Standard View -> Edit state transition. |
| C-016 | Search and Filter Bar | Contextual list discovery. |
| C-017 | Confirmation Dialog | Confirm meaningful changes. |
| C-018 | Loading/Empty/Error State | Standard async state wrapper. |

## Core Component Specifications

### C-001 Global Header

Purpose:

- Provide global product controls.

Contains:

- Logo.
- Optional search.
- Add Subscription action.
- Notifications.
- Profile menu.

States:

- Default.
- Search active.
- Notification unread.
- Loading.

Reuse:

- All authenticated screens.

### C-002 Sidebar Navigation

Purpose:

- Provide primary navigation.

Items:

- Decision Workspace.
- My Subscriptions.
- Shared Subscriptions.
- Insights.
- Profile.

States:

- Expanded.
- Collapsed.
- Active item.
- Hover.
- Mobile drawer.

### C-003 AI Decision Card

Purpose:

- Help users make one subscription decision.

Content:

- Subscription name.
- Context.
- AI Insight.
- Financial impact.
- Reason.
- Primary action: Review Subscription.
- Secondary action: Remind Me Later.

States:

- Normal.
- Urgent.
- Resolved.
- Loading.
- Error.

Rules:

- Must not include direct cancel, delete, or provider-control actions.
- Must explain rather than command.

### C-004 Today's Financial Context

Purpose:

- Summarize the most important financial context.

Variants:

- Renewal.
- Savings.
- Shared payment.
- Healthy status.

### C-005 Renewal List

Purpose:

- Show upcoming renewals in chronological order.

Item content:

- Logo or fallback icon.
- Subscription name.
- Renewal date.
- Cost.
- Status indicator.

Interaction:

- Opens Subscription Details.

### C-006 Shared Activity Card

Purpose:

- Display pending shared-subscription actions.

Content:

- Subscription.
- Member.
- Amount.
- Status.

Interaction:

- Opens shared payment details.

### C-007 Savings Opportunity Card

Purpose:

- Explain possible savings.

Content:

- Subscription.
- Alternative or review reason.
- Estimated savings.
- Confidence or caveat.

Action:

- Review Opportunity.

### C-008 Insights Preview Card

Purpose:

- Preview analytical information without turning the dashboard into a reporting screen.

Interaction:

- View Full Insights.

### C-009 Empty State Card

Purpose:

- Help users begin a workflow when no data exists.

Required content:

- Plain empty state title.
- One sentence explaining benefit.
- One primary CTA.

### C-010 Subscription Card

Purpose:

- Summarize one subscription in list/grid views.

Content:

- Name.
- Logo or fallback.
- Cost.
- Billing frequency.
- Next renewal.
- Lifecycle status.
- Renewal urgency.

Interaction:

- Opens Subscription Details.

### C-011 Annual Cost Preview

Purpose:

- Show annualized cost while a user enters subscription billing details.

Inputs:

- Cost.
- Currency.
- Billing frequency.
- Custom interval where applicable.

States:

- Empty.
- Calculated.
- Invalid input.

### C-012 Renewal Urgency Indicator

Purpose:

- Show renewal urgency consistently.

States:

- Normal.
- Upcoming.
- Critical.
- Future: overdue.

### C-013 Lifecycle Status Badge

Purpose:

- Present subscription lifecycle state.

States:

- Created.
- Active.
- Renewal Confirmed.
- Paused.
- Cancelled.
- Archived.

### C-014 Financial Summary Pattern

Purpose:

- Present recurring financial metrics consistently.

Examples:

- Monthly spend.
- Annual spend.
- Shared balance.
- Upcoming spend.
- Potential savings.

### C-015 View/Edit Controller

Purpose:

- Standardize editing behavior.

States:

- View.
- Edit.
- Saving.
- Saved.
- Error.

Rules:

- Cancel returns to prior value.
- Save validates before mutation.

### C-016 Search and Filter Bar

Purpose:

- Contextual discovery within lists.

Reuse:

- My Subscriptions.
- Shared Subscriptions.
- Insights filters.

### C-017 Confirmation Dialog

Purpose:

- Confirm meaningful or destructive actions.

Variants:

- Archive confirmation.
- Reminder confirmation.
- Payment status confirmation.

### C-018 Loading/Empty/Error State

Purpose:

- Standard wrapper for async data.

Required states:

- Loading.
- Empty.
- Success.
- Error.

## Component Dependency Matrix

| Component | Depends On |
| --- | --- |
| AI Decision Card | Financial Summary Pattern, Renewal Urgency Indicator |
| Subscription Card | Lifecycle Status Badge, Renewal Urgency Indicator |
| Annual Cost Preview | Currency formatter, billing frequency rules |
| Shared Activity Card | Status Badge, Financial Summary Pattern |
| View/Edit Controller | Form components, validation messages |
| Confirmation Dialog | Button system, feedback messages |
| Loading/Empty/Error State | Empty State Card, feedback components |

## Accessibility Requirements

All components must include:

- Keyboard access.
- Screen-reader labels.
- Visible focus state.
- Non-color-only status meaning.
- Accessible names for icons.
- Error text tied to inputs.

## Validation Checklist

| Check | Status |
| --- | --- |
| Component IDs defined | Complete |
| Component template defined | Complete |
| Core components specified | Complete |
| Dependencies mapped | Complete |
| Reuse locations identified | Complete |
| Accessibility requirements defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Initial Component Library architecture. |
| v1.2 | Current | Implementation Freeze alignment and expanded component inventory. |
