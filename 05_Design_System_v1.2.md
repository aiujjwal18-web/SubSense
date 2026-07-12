# 05 Design System v1.2

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DS-001 |
| Product | SubSense |
| Version | v1.2 |
| Status | Frozen implementation baseline |
| Source of Truth | Reusable visual and interaction standards |
| Depends On | 00_Project_Governance_v1.2, 01_Product_Strategy_v1.2, 02_Experience_Strategy_v1.2, 03_Information_Architecture_v1.2, 04_Experience_Blueprint_v1.2 |

## Purpose

This document defines reusable visual, interaction, feedback, accessibility, and responsive standards for SubSense.

It does not define screen-specific layouts. Those belong to `04_Experience_Blueprint_v1.2.md`.

## Design System Scope

The Design System owns:

- Color system.
- Typography.
- Grid and spacing.
- Elevation.
- Icons.
- Buttons.
- Forms.
- Inputs.
- Cards.
- Status indicators.
- Navigation components.
- Feedback components.
- Empty states.
- Loading states.
- Accessibility rules.
- Responsive rules.
- Interaction patterns.

## Experience Principles Implemented

The Design System implements:

- Decision-first design.
- Workflow-first design.
- Progressive disclosure.
- View -> Edit.
- Five Second Rule.
- Adaptive priority flow.
- Responsive structural consistency.
- No visual noise.

## Visual Direction

SubSense should feel:

- Calm.
- Financially trustworthy.
- Modern.
- Clear.
- Medium-density.
- Focused.
- Not decorative for its own sake.

The product uses a dark-first SaaS style, soft elevated surfaces, restrained motion, and clean financial hierarchy.

## Layout Standards

Rules:

- Primary surfaces use consistent page gutters.
- Cards must not be nested inside other cards.
- Tool and dashboard areas should be dense but readable.
- Sections should not become marketing-style hero layouts inside the app.
- Primary task areas remain visually dominant.
- Supporting information should not compete with the main decision.

## Component Families

### Global Navigation

Reusable:

- Header.
- Sidebar.
- Logo/Home.
- Profile menu.
- Breadcrumb or page header pattern.

### Cards

Reusable:

- AI Decision Card.
- Subscription Card.
- Financial Context Card.
- Empty State Card.
- Confirmation Card.
- Savings Opportunity Card.

Card behavior is standardized. Card content is owned by the Experience Blueprint.

### Forms

Standard components:

- Text input.
- Search input.
- Dropdown.
- Currency selector.
- Frequency selector.
- Date picker.
- Validation message.
- Toggle.
- Checkbox.

### Buttons

Button hierarchy:

- Primary.
- Secondary.
- Destructive.
- Icon.
- Future floating action button.

Button rules:

- Primary buttons should represent one clear forward action.
- Destructive actions require confirmation where data impact is meaningful.
- Icon buttons require accessible labels.

### Status System

Reusable statuses:

- Active.
- Renewal Confirmed.
- Paused.
- Cancelled.
- Archived.
- Pending.
- Paid.
- Failed.

Status meaning must not depend only on color.

### AI Information Pattern

Reusable variants:

- AI Decision.
- AI Insight.
- AI Recommendation.
- AI Explanation.

AI presentation must include:

- Context.
- Recommendation or insight.
- Reason.
- User-owned next action.

### Financial Components

Reusable:

- Annual Cost Preview.
- Financial Summary Pattern.
- Today's Financial Context.
- Shared Balance Summary.
- Spending Summary.
- Savings Opportunity.

### Renewal Components

Renewal Urgency Indicator states:

- Normal.
- Upcoming.
- Critical.
- Future: overdue.

The indicator should create awareness without creating unnecessary anxiety.

### Lifecycle Components

Lifecycle Status Component supports:

- Created.
- Active.
- Renewal Confirmed.
- Paused.
- Cancelled.
- Archived.

## View -> Edit Pattern

All editable areas follow:

View State -> Edit -> Edit State -> Save Changes or Cancel Changes -> View State

Requirements:

- View state is default.
- Edit mode is intentional.
- Cancel restores prior state.
- Save confirms success or explains error.

## Feedback Components

Reusable feedback includes:

- Success message.
- Error message.
- Inline validation.
- Toast notification.
- Empty state.
- Loading state.
- Confirmation dialog.

## Empty State Standards

Empty states should:

- State what is missing.
- Explain the value of the first action.
- Provide one primary CTA.
- Avoid lengthy instructions.

Example pattern:

No subscriptions yet.

Add your first subscription to receive AI-powered reminders and spending insights.

## Loading State Standards

Every asynchronous screen supports:

- Loading.
- Empty.
- Success.
- Error.

Skeletons are preferred for page-level loading where structure is known.

## Responsive Rules

The Design System defines how components adapt visually.

Rules:

- Sidebar can collapse or become a mobile drawer.
- Header remains usable across viewports.
- Primary actions remain reachable.
- Cards and lists must not overflow text.
- Layout changes must preserve information priority.

## Accessibility Standards

All reusable components must support:

- Keyboard navigation.
- Screen-reader labels.
- Visible focus states.
- Sufficient contrast.
- Accessible touch targets.
- Non-color-only status meaning.
- Clear form error messages.

## Ownership Matrix

| Design Element | Owner |
| --- | --- |
| UX principles | Experience Strategy |
| Navigation structure | Information Architecture |
| Screen layout | Experience Blueprint |
| Reusable visual standards | Design System |
| Component implementation specs | Component Library |

## Validation Checklist

| Check | Status |
| --- | --- |
| Component families defined | Complete |
| AI pattern defined | Complete |
| Financial pattern defined | Complete |
| Renewal indicator defined | Complete |
| Lifecycle status defined | Complete |
| View -> Edit pattern defined | Complete |
| Accessibility standards defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Initial Design System architecture. |
| v1.2 | Current | Implementation Freeze alignment and expanded reusable standards. |
