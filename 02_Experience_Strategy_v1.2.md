# 02 Experience Strategy v1.2

## Document Control

| Field | Value |
| --- | --- |
| Document ID | EXP-001 |
| Product | SubSense |
| Version | v1.2 |
| Status | Frozen implementation baseline |
| Source of Truth | Product experience strategy |
| Depends On | 00_Project_Governance_v1.2, 01_Product_Strategy_v1.3 |

## Purpose

This document defines how SubSense should feel and behave for users. It owns behavioral principles, interaction models, trust patterns, and product-wide UX rules.

It does not define visual styling. Visual styling belongs to `05_Design_System_v1.2.md`.

## Experience Philosophy

SubSense is a decision-support platform, not an administrative dashboard.

Every experience should guide users through:

Understand -> Review -> Decide -> Act

The interface must prioritize comprehension before modification.

## Core User Mental Models

| Area | User Question |
| --- | --- |
| Decision Workspace | What needs my attention today? |
| My Subscriptions | What subscriptions do I have? |
| Add Subscription | How do I add one quickly and correctly? |
| Subscription Details | Should I keep reviewing this subscription? |
| Shared Subscriptions | Who owes what? |
| Insights | Where is my money going? |
| Profile | How do I manage account and preferences? |

## UX Principle Framework

### Group A: Decision Principles

| ID | Principle | Standard |
| --- | --- | --- |
| EXP-001 | Decision-First Design | Present decisions before actions. |
| EXP-002 | User Control First | Users retain complete control over financial decisions. |
| EXP-003 | AI Assists, Users Decide | AI informs, explains, compares, and recommends. Users decide. |

### Group B: Workflow Principles

| ID | Principle | Standard |
| --- | --- | --- |
| EXP-004 | Workflow-First | Design complete workflows rather than isolated pages. |
| EXP-005 | Progressive Disclosure | Reveal complexity only when it becomes relevant. |
| EXP-006 | View -> Edit | Users view information before entering edit mode. |

### Group C: Safety Principles

| ID | Principle | Standard |
| --- | --- | --- |
| EXP-007 | Archive First | Prefer reversible actions over permanent deletion. |
| EXP-008 | Soft Delete | Business data should remain recoverable where possible. |
| EXP-009 | Error Recovery | Users should not lose meaningful work because of recoverable failures. |

### Group D: Experience Principles

| ID | Principle | Standard |
| --- | --- | --- |
| EXP-010 | Adaptive Priority Flow | Preserve the same information priority across devices. |
| EXP-011 | Responsive Structural Consistency | Navigation and workflows remain recognizable on all screen sizes. |
| EXP-012 | Five Second Rule | A user should understand a screen's purpose within five seconds. |
| EXP-013 | No Visual Noise | Every element must support the user's task. |

### Group E: Trust Principles

| ID | Principle | Standard |
| --- | --- | --- |
| EXP-014 | Transparency | Explain recommendations and calculations clearly. |
| EXP-015 | Predictability | Similar actions produce similar outcomes. |
| EXP-016 | Consistency | Use consistent terminology, navigation, components, and AI messaging. |

## Information Hierarchy

Standard product hierarchy:

1. Today's financial context.
2. AI decision support.
3. Primary user task.
4. Supporting information.
5. Administrative actions.

## Navigation Philosophy

Navigation exists to support workflows.

Rules:

- Global navigation remains consistent.
- Logo returns to Decision Workspace.
- Sidebar adapts across desktop and mobile.
- Navigation must not compete with the primary task.
- Authentication remains outside authenticated product navigation.

## Form Philosophy

Forms should:

- Prefer selection over manual typing.
- Use inline validation.
- Preserve progress where possible.
- Show review before save for meaningful changes.
- Use progressive disclosure for advanced details.
- Minimize required inputs.

## Notification Philosophy

Notifications should be timely, explainable, and actionable.

They should:

- Tell the user what is happening.
- Explain why it matters.
- Offer a review action where appropriate.
- Avoid fear-based language.
- Preserve user control.

## AI Experience Standard

AI output must feel like guidance, not command.

Preferred tone:

- "This subscription renews soon."
- "You spend this amount annually."
- "You may want to review it."
- "Here is why this might matter."

Avoid:

- "Cancel this."
- "This is bad."
- "You must switch."
- "We will cancel for you."

## View -> Edit Interaction Model

Editable screens follow:

View state -> Edit action -> Edit state -> Save or Cancel -> View state

This applies to:

- Subscription Details.
- Shared member details.
- Profile.
- Notification preferences.
- Subscription settings.

## Archive and Delete Rules

User-facing destructive behavior should prefer archive.

Use archive when:

- Subscription history should remain available.
- Shared payment history exists.
- Future reporting may need past values.

Use permanent delete only for controlled administrative or temporary development cases.

## Principle Applicability Matrix

| Module | Required Principles |
| --- | --- |
| Decision Workspace | Decision-first, five second rule, AI assists, no visual noise |
| My Subscriptions | Workflow-first, progressive disclosure, responsive consistency |
| Add Subscription | Progressive disclosure, inline validation, annual cost awareness |
| Subscription Details | View -> Edit, archive first, transparency |
| Shared Subscriptions | Workflow-first, error recovery, predictable status updates |
| Insights | Transparency, savings before spending, no visual noise |
| Profile | View -> Edit, user control, consistency |

## Accessibility Experience Requirements

All user-facing flows must support:

- Keyboard navigation.
- Clear focus states.
- Screen-reader-friendly labels.
- Accessible touch targets.
- Plain language errors.
- Color-independent status meaning.

## Validation Checklist

| Check | Status |
| --- | --- |
| Behavioral principles defined | Complete |
| Screen mental models defined | Complete |
| View -> Edit model defined | Complete |
| AI tone boundary defined | Complete |
| Archive-first model defined | Complete |
| Responsive behavior principles defined | Complete |
| Accessibility expectations defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.1 | Frozen | Architecture Freeze experience strategy. |
| v1.2 | Current | Implementation Freeze alignment and principle applicability clarified. Updated dependency reference to 01_Product_Strategy_v1.3. |
