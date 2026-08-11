# 02 Experience Strategy v1.20

## Document Control

| Field | Value |
| --- | --- |
| Document ID | EXP-001 |
| Product | SubSense |
| Version | v1.20 |
| Status | Frozen implementation baseline |
| Source of Truth | Product experience strategy |
| Depends On | 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19 |

## Purpose

This document defines how SubSense should feel and behave for users. It owns behavioral principles, interaction models, trust patterns, and product-wide UX rules.

It does not define visual styling. Visual styling belongs to `05_Design_System_v1.33.md`.

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
| EXP-013 | No Visual Noise | Every element must support the user's task. Restraint applies to decoration; it does not excuse a primary action or interactive affordance from being clearly legible at rest (see DEC-044). |

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

### AI Copy Tone (finalized per DEC-045)

The tone boundary above says what the AI may not say. This section defines the voice inside that boundary, so generated insight text does not read as one template with the subscription name swapped in.

Rules:

- Vary sentence opening and structure across cards shown in the same session — do not reuse the identical sentence skeleton for every subscription (e.g. always "X renews on [date] for [cost]. You spend [annual] annually. You may want to review it.").
- State each figure once per card. Do not restate the same cost or date in a second phrasing within the same card.
- Contractions are permitted ("you're," "it's") — they read more natural without sacrificing clarity, and are not at odds with a financial-trust product.
- No manufactured urgency in the wording itself, even when the Renewal Urgency Indicator's status is Critical. The indicator's color already carries the urgency signal (`05_Design_System`); the copy stays level regardless of status.
- Avoid corporate filler ("leverage," "simply," "seamless") and throat-clearing openers ("I have analyzed your subscription and determined that..."). Lead with the fact.
- Every generated insight still carries the four required elements from the AI Information Pattern in `05_Design_System` (context, insight/recommendation, reason, user-owned next action) — variety is in the phrasing, not the structure or the information provided.

This is a style guide for the `ai-generate-insight` prompt design (Roadmap Phase 7), not a static string table to pull from at runtime.

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
| AI copy tone/variety defined | Complete |
| Archive-first model defined | Complete |
| Responsive behavior principles defined | Complete |
| Accessibility expectations defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.1 | Frozen | Architecture Freeze experience strategy. |
| v1.2 | Frozen | Implementation Freeze alignment and principle applicability clarified. Updated dependency reference to 01_Product_Strategy_v1.3. |
| v1.3 | Frozen | Updated dependency reference to 00_Project_Governance_v1.3 and 01_Product_Strategy_v1.5, and the Design System cross-reference to 05_Design_System_v1.3, following the brand kit finalization under DEC-042. |
| v1.4 | Frozen | Updated dependency reference to 00_Project_Governance_v1.4 and the Design System cross-reference to 05_Design_System_v1.4, following the spacing/card/icon system closure under DEC-043. EXP-012 (Five Second Rule) and EXP-013 (No Visual Noise) are the named rationale for DEC-043's rejection of structural card imperfection. |
| v1.5 | Frozen | Updated dependency reference to 00_Project_Governance_v1.5 and the Design System cross-reference to 05_Design_System_v1.5, following the micro-interaction system closure under DEC-044. Amended EXP-013 to clarify that restraint applies to decoration, not to legibility of primary actions or interactive affordances, per the DEC-044 button/card visibility correction. |
| v1.6 | Frozen | Added the AI Copy Tone subsection to the AI Experience Standard (sentence variety, state-once numbers, contractions permitted, no manufactured urgency, avoid corporate filler) per DEC-045, completing the three-part "human touch" set alongside DEC-043 and DEC-044. Updated dependency reference to 00_Project_Governance_v1.6 and the Design System cross-reference to 05_Design_System_v1.6. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 00_Project_Governance_v1.8 and 01_Product_Strategy_v1.7, and the Design System cross-reference to 05_Design_System_v1.8, closing a citation-integrity gap found during the DEC-045 pass. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.8 and 01_Product_Strategy_v1.7, and the Design System cross-reference to 05_Design_System_v1.8, as part of the cascade patching 11_API_Integration_Architecture's own internal reference-integrity gaps. No AI tone content changed. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.9 and 01_Product_Strategy_v1.8, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. No AI tone content changed. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.10 and 01_Product_Strategy_v1.9, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). No AI tone content changed. |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.11 and 01_Product_Strategy_v1.10, and the Design System forward-reference to 05_Design_System_v1.11, as part of the cascade recording DEC-047 and its version bump to 10_Database_Architecture_v1.7, batched with the notification-template SQL patch (file 23). No experience-strategy content changed. |
| v1.12 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Design System forward-reference to 05_Design_System_v1.12, as part of the cascade recording DEC-049 ("Ledger Dark" visual direction, 05 bumped to v1.12, 06 bumped to v1.11). No experience-strategy content changed. |
| v1.13 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Design System forward-reference to 05_Design_System_v1.13, as part of the cascade recording DEC-050 (Ledger Dark extended to light-mode/email surfaces). Also corrected the Depends On field's 00_Project_Governance citation to v1.13 -- it had been left stale at v1.11 since before the v1.12 pass, missed at the time. No experience-strategy content changed. |
| v1.14 | Frozen | Recorded DEC-053 (Lovable to Cursor tooling change): updated dependency references to 00_Project_Governance_v1.14 and 01_Product_Strategy_v1.11, and the Design System forward-reference to 05_Design_System_v1.14. No AI tone or experience-strategy content changed. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.15 and 01_Product_Strategy_v1.12, and the Design System forward-reference to 05_Design_System_v1.15, as all three continued to move within the same DEC-053 cascade. No AI tone or experience-strategy content changed. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference to 01_Product_Strategy_v1.13 and the Design System forward-reference to 05_Design_System_v1.16, as all continued moving within the same DEC-053 cascade. No AI tone or experience-strategy content changed. **Correction (same day, caught before this pass finished):** the dependency reference to 00_Project_Governance corrected to v1.16 and the Design System forward-reference corrected to 05_Design_System_v1.17, since both moved again after this row was written. Not bumping the version again for this. |
| v1.17 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.17 and 01_Product_Strategy_v1.14, and the Design System forward-reference to 05_Design_System_v1.18, following DEC-054. No AI tone or experience-strategy content changed. **Correction (same day):** the dependency reference to 00_Project_Governance corrected to v1.18, since 00 moved again later in the same cleanup pass. Not bumping the version again for this. |
| v1.18 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field to 00_Project_Governance_v1.19 and the Design System forward-reference to 05_Design_System_v1.19, following DEC-055 (logo wordmark font resolved, logo formally implemented). No AI tone or experience-strategy content changed. **Correction (same day):** the Depends On field corrected to 00_Project_Governance_v1.20 and 01_Product_Strategy_v1.15, since both moved again later in this same cleanup pass. Not bumping the version again for this. **Further correction (same day, DEC-056 login-page visual exception cascade):** the Design System forward-reference updated to 05_Design_System_v1.20. Not bumping the version again for this either. **Further correction (DEC-057 brand kit cascade):** the Design System forward-reference updated again to 05_Design_System_v1.21. Not bumping the version again for this. **Further correction (DEC-058 motion-system cascade):** updated again to 05_Design_System_v1.22. Not bumping the version again for this either. **Further correction (DEC-059 generic-icon cascade):** updated again to 05_Design_System_v1.23. Not bumping the version again for this either. **Further correction (DEC-060/061 logo-asset and Header-restructure cascade):** the Design System forward-reference updated to 05_Design_System_v1.25. Not bumping the version again for this either. **Further correction (DEC-062/063/064 cascade):** the Design System forward-reference updated to 05_Design_System_v1.28. Not bumping the version again for this either. **Further correction (DEC-065/066 cascade):** the Design System forward-reference updated to 05_Design_System_v1.30. Not bumping the version again for this either. **Further correction (DEC-073 cascade — light-mode/email accent tokens resolved to Cyber Lime):** the Design System forward-reference updated to 05_Design_System_v1.31. Not bumping the version again for this either. **Further correction (DEC-082 — doc 01 v1.16, lower-cost-alternatives note assigned to Phase 9):** the Depends On field's 01_Product_Strategy citation updated to v1.16. Not bumping the version again for this either. |
| v1.19 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field to 00_Project_Governance_v1.21 and 01_Product_Strategy_v1.17, as part of the cascade recording DEC-083 (Phase 9+10 built and deployed). **Correction (same day, full grep audit):** the Purpose section's Design System cross-reference, found stuck at 05_Design_System_v1.31, corrected to v1.32. Not bumping the version again for this. No AI tone or experience-strategy content changed. **Further correction (same day, second-order cascade closure):** the Depends On field's 00/01 citations, one hop stale after tonight's DEC-085 cascade bumped both, corrected to v1.22 and v1.18. Not bumping the version again for this either. |
| v1.20 | Current | Housekeeping pass, not tied to a new DEC: updated the Depends On field to 00_Project_Governance_v1.23 and 01_Product_Strategy_v1.19, and the Purpose section's Design System cross-reference to 05_Design_System_v1.33, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No experience-strategy content changed. |
