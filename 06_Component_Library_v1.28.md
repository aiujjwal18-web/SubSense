# 06 Component Library v1.28

## Document Control

| Field | Value |
| --- | --- |
| Document ID | CL-001 |
| Product | SubSense |
| Version | v1.28 |
| Status | Frozen implementation baseline |
| Source of Truth | Reusable component specifications |
| Depends On | 05_Design_System_v1.33 |

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
| C-019 | Shared Member Row | One member's participation in a shared subscription split. |
| C-020 | Add/Edit Member Form | Capture or update a shared member's details. |
| C-021 | Payment Request Item | One billing-cycle payment request and its actor-scoped actions. |
| C-022 | Tier Badge | Show the user's current plan tier. |
| C-023 | Plan Comparison Card | List available plans and let the user upgrade. |
| C-024 | Upgrade Action | Orchestrate the Razorpay Test Mode checkout flow end to end. |
| C-025 | Insights Upsell Card | Free-tier teaser explaining Insights and prompting upgrade. |
| C-026 | Insights Summary Card | AI-written prose framing over deterministic portfolio signals. |
| C-027 | Spend Summary Card | Deterministic per-currency spend totals. |
| C-028 | Duplicate & Overlap Card | Flag subscriptions duplicating or overlapping by category. |
| C-029 | Cost Comparison Card | Flag a subscription priced above its own category's portfolio average. |

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
- Generated insight/reason text follows the AI Copy Tone rules in `02_Experience_Strategy` (DEC-045): varied phrasing across cards, each figure stated once, no manufactured urgency.

Interaction: hover/focus follows the interactive Card visual standard in `05_Design_System_v1.33` (border -> Primary, background Surface 1 -> Surface 2, per DEC-044).

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

- Show upcoming renewals in chronological order, limited to renewals due within 7 days — Overdue, Critical, or Upcoming urgency per DEC-054's thresholds and DEC-039's `seven_day` window (DEC-067). Renewals beyond that window are not shown here. Paused subscriptions are excluded entirely (DEC-064).

Item content:

- Category icon (per DEC-059 — generic, Lucide, never a real brand logo).
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

Interaction: this card is not itself a click target (the CTA button inside it is); per the Micro-interactions No-Motion Rule, the card surface carries no hover/focus treatment, only its CTA button does.

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
- **Per DEC-064:** a quick-action row (Paid/Paused/Resume) also lives on this card, writing directly without opening the full Edit state — see 05_Design_System's Card Quick Actions subsection for the exact behavior and scoping. Adaptive per lifecycle status: archived shows neither button, paused shows only "Resume," everything else shows both "Paid" and "Paused." "Paid" opens a confirm-before-commit date picker rather than writing immediately. Scoped to this card only — `SubscriptionDetailsPage` and `DecisionWorkspacePage`'s row items do not carry these buttons.

Visual frame: follows the Card visual standard in `05_Design_System_v1.33` (8px radius per DEC-049, unchanged under DEC-057; 20px padding, 1px Border, border -> Primary on hover/focus per DEC-044) exactly like every other card type, **except background** — under DEC-066, the app-wide card standard corrected to opaque (`bg-card`, no blur); this card is the one confirmed exception that keeps the translucent `bg-card/70 backdrop-blur-md` glass-morphism treatment, since it's a repeated per-instance list tile rather than a page-level section container. The only permitted per-instance variation beyond that is the category icon (a fixed, generic Lucide icon per DEC-059 — never a real per-service brand logo) and its natural color — never the card's structure — per DEC-043.

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
- Overdue.

Interaction: informational only — no hover, focus, or entrance motion, per the Micro-interactions No-Motion Rule.

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

Interaction: informational only — no hover, focus, or entrance motion, per the Micro-interactions No-Motion Rule.

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

The Saving state uses the button loading state defined in `05_Design_System_v1.33` Micro-interactions (inline spinner, dimmed, non-interactive, no fill-color change).

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
- Reminder confirmation. **Per DEC-080 (Phase 8):** also covers the owner-triggered "Send Reminder" action on C-021 Payment Request Item (`send-shared-payment-reminder`, doc 11 §5.3) — same variant, no new one needed.
- Payment status confirmation. **Per DEC-080 (Phase 8):** covers two distinct actor-scoped transitions on a `payment_requests` row (DEC-037's permission model, doc 10) — owner confirming Pending or Awaiting Confirmation directly to Paid, and a linked member self-reporting Pending to Awaiting Confirmation ("I've Paid"). Both render through this same variant; the confirm button's label and the transition it commits differ by actor and current status, not by a separate dialog.

Interaction: enter/exit motion follows the Dialog Motion spec in `05_Design_System_v1.33` Micro-interactions (320ms ease-out enter, 150ms ease-in exit). The confirm action inside a destructive variant uses the Destructive button state; Cancel uses Secondary.

### C-018 Loading/Empty/Error State

Purpose:

- Standard wrapper for async data.

Required states:

- Loading.
- Empty.
- Success.
- Error.

### C-019 Shared Member Row

Purpose:

- Summarize one member's participation in a shared subscription split.

Content:

- Display name (or email, for a member with no linked SubSense account — doc 10's `shared_members.user_id` is nullable).
- Amount owed, currency.
- Status: only active members render here — a removed member's row disappears from this list, though their `payment_requests` history is preserved and remains visible in C-021 (per DEC-080's explicit no-cascade-on-removal rule; removal is a soft data state for history preservation, not a visible toggle on this row).

Interaction:

- Edit — opens C-020 Add/Edit Member Form. The amount field is editable only when the parent `shared_subscriptions.split_method` is `custom`; for `equal`, it renders read-only with a short note that it recomputes automatically as members join or leave (DEC-080's rebalance trigger).
- Remove from split — soft-remove (doc 10); does not cancel this member's own open `payment_requests` (DEC-080).

Reuse:

- Shared Subscriptions page, member list.

### C-020 Add/Edit Member Form

Purpose:

- Capture or update one shared member's details.

Inputs:

- Display name.
- Email — required, since it's the only identifier for a member without their own account.
- Amount owed — numeric input for `custom` split; read-only computed display for `equal` split (DEC-080).

States: reuses C-015 View/Edit Controller (View, Edit, Saving, Saved, Error).

Validation:

- Email required.
- Duplicate active email within the same split is blocked (doc 10's partial unique index, `UNIQUE (shared_subscription_id, email) WHERE status = 'active'`) — surfaced as an inline validation message, not a raw database error.
- Amount owed >= 0 (doc 10 CHECK), validated client-side before submit.

Reuse:

- Shared Subscriptions page and Subscription Details' "Manage sharing" action (DEC-080) — both first-time setup and ongoing member management route through this same form.

### C-021 Payment Request Item

Purpose:

- Display one billing-cycle `payment_requests` row and its available actions, scoped by actor per DEC-037's permission model (doc 10).

Content:

- Member name.
- Amount, currency.
- Billing cycle date (`billing_cycle_date`).
- Status badge: Pending, Awaiting Confirmation (`paid_pending_confirmation`), Paid, Cancelled.

Interaction (actor- and status-dependent, per DEC-037):

- Owner, status Pending or Awaiting Confirmation: Mark Paid (direct to Paid) and Send Reminder — both use C-017's existing variants (Payment status confirmation; Reminder confirmation).
- Linked member, status Pending only: I've Paid (self-report, Pending -> Awaiting Confirmation only — cannot set Paid or Cancelled directly).
- Status Paid or Cancelled: no actions, informational only.

Reuse:

- Shared Subscriptions page, per-member payment history list.

### C-022 Tier Badge

Purpose:

- Show the user's current plan tier (Free or Premium) inline near a page heading.

Content:

- Tier label — wraps the existing shadcn Badge primitive; no new visual pattern.

Reuse:

- Profile page, next to the "Profile" heading.

### C-023 Plan Comparison Card

Purpose:

- List the plans available for purchase (`premium_plans`, active rows only) and let the user upgrade.

Content:

- Plan name, price, billing period.
- Current Plan badge (via the locked gating rule, DEC-082) on the user's active plan; Upgrade action on purchasable plans.

Interaction:

- Upgrade — triggers C-024 Upgrade Action.

Reuse:

- Profile page.

### C-024 Upgrade Action

Purpose:

- Orchestrate the Razorpay Test Mode checkout flow end to end: lazy-load the checkout script, create the order, open the Razorpay widget, verify the payment, refresh the user's profile.

States:

- Idle, Processing, Success (toast), Error (toast, retry).

Reuse:

- C-023 Plan Comparison Card's Upgrade button (Profile page). C-025 Insights Upsell Card's CTA routes here rather than duplicating checkout UI.

### C-025 Insights Upsell Card

Purpose:

- Free-tier teaser on the Insights page explaining what Insights offers and prompting upgrade — no live data is fetched for a free-tier user (gated client-side and server-side per DEC-082).

Content:

- Headline, benefit bullet list, single "Upgrade to Premium" CTA.

Interaction:

- Upgrade to Premium — routes to Profile / C-024, reusing the real purchase flow rather than a second checkout UI.

Reuse:

- Insights page, free tier only.

### C-026 Insights Summary Card

Purpose:

- AI-written prose summarizing the user's portfolio spend, overlap, and cost-comparison signals — framing only, never computes or invents a figure itself (same no-fabricated-financial-claims discipline as the rest of the app).

Content:

- One model-generated paragraph over the deterministic inputs already computed by C-027, C-028, and C-029.

Reuse:

- Insights page, premium tier only.

### C-027 Spend Summary Card

Purpose:

- Show deterministic monthly spend totals.

Content:

- One total per active currency present in the user's portfolio — currencies are never combined or converted into one figure.

Reuse:

- Insights page, premium tier only.

### C-028 Duplicate & Overlap Card

Purpose:

- Flag subscriptions that duplicate the same catalog item, or share a category, as a soft signal worth reviewing.

Content:

- Overlapping subscription names, shared category, combined monthly cost.

Reuse:

- Insights page, premium tier only.

### C-029 Cost Comparison Card

Purpose:

- Flag a subscription priced above its own category's average, computed entirely within the user's own portfolio — an intra-portfolio comparison, not a competitor or market-price lookup (no such data exists anywhere in this schema). Framed to prompt the user to review pricing or tier themselves, not to claim a specific cheaper alternative exists.

Content:

- Subscription name, its price, the category's portfolio average.

Naming note: originally shipped under the label "Lower-Cost Alternatives," which overpromised relative to what the card actually does. Renamed to **"Worth a Second Look"** (DEC-085), with per-item copy rewritten to name the specific subscription, its percentage above the category average, and invite the user to review pricing or tier themselves — e.g. "JioSaavn Pro costs ₹149/mo — 11% above your Music average of ₹134/mo. Worth checking if a lower tier fits, or whether you're still getting enough value to justify the difference." Existing Review Subscription/Remind Me Later actions reused; no new CTA, since no competitor-pricing data exists in this schema to back a "switch to X" suggestion. Live verification of the rename (visual confirmation for both an above-average and a below-average subscription) is the first task next session, not yet completed as of this update.

Reuse:

- Insights page, premium tier only.

Note: C-007 Savings Opportunity Card (Decision Workspace, still unbuilt) and this card's deterministic category-average logic could share the same engine once C-007 is actually implemented, rather than needing new design — flagged as a bundling opportunity, not yet wired.

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
| Shared Member Row | Financial Summary Pattern, Add/Edit Member Form |
| Add/Edit Member Form | View/Edit Controller, form components, validation messages |
| Payment Request Item | Confirmation Dialog, Financial Summary Pattern |
| Tier Badge | Badge (shadcn) |
| Plan Comparison Card | Tier Badge, Upgrade Action |
| Upgrade Action | Razorpay checkout script, Financial Summary Pattern |
| Insights Upsell Card | Upgrade Action |
| Insights Summary Card | Spend Summary Card, Duplicate & Overlap Card, Cost Comparison Card |
| Spend Summary Card | Financial Summary Pattern |
| Duplicate & Overlap Card | Financial Summary Pattern |
| Cost Comparison Card | Financial Summary Pattern |

## Accessibility Requirements

All components must include:

- Keyboard access.
- Screen-reader labels.
- Visible focus state.
- Non-color-only status meaning.
- Accessible names for icons.
- Error text tied to inputs.

Visible focus state means the shared focus-visible ring defined in `05_Design_System_v1.33` Micro-interactions, not a component-specific treatment.

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
| v1.2 | Frozen | Implementation Freeze alignment and expanded component inventory. |
| v1.3 | Frozen | Updated dependency reference to 05_Design_System_v1.3 following the brand kit finalization (hex palette, typography, logo) under DEC-042. |
| v1.4 | Frozen | Updated dependency reference to 05_Design_System_v1.4. Added an explicit note to C-010 Subscription Card pointing at the Card visual standard and the DEC-043 rule that only logo/icon color, never card structure, may vary between instances. |
| v1.5 | Frozen | Updated dependency reference to 05_Design_System_v1.5. Added Micro-interaction cross-references to C-003, C-009, C-010, C-012, C-013, C-015, and C-017, and clarified accessibility's "visible focus state" as the shared focus-visible ring, per DEC-044. |
| v1.6 | Frozen | Updated dependency reference to 05_Design_System_v1.6. Added an AI Copy Tone cross-reference to C-003 AI Decision Card, per DEC-045. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 05_Design_System_v1.8, closing a citation-integrity gap found during the DEC-045 pass. No component content changed. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 05_Design_System_v1.8 (and its four downstream cross-references within component specs), as part of the cascade patching 11_API_Integration_Architecture's own internal reference-integrity gaps. No component content changed. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency reference to 05_Design_System_v1.10, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). No component content changed. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and five body cross-references to 05_Design_System_v1.11, as part of the cascade recording DEC-047 and its version bump to 10_Database_Architecture_v1.7, batched with the notification-template SQL patch (file 23). |
| v1.11 | Frozen | Cascade closing DEC-049 (05_Design_System bump to v1.12, "Ledger Dark" visual direction): updated the dependency reference and five body cross-references to 05_Design_System_v1.12; corrected C-010 Subscription Card's hardcoded "12px radius" to "8px radius" and the "Accent" hover-state naming (C-003, C-010) to "Primary" to match 05's renamed token. No component structure, states, or reuse rules changed. |
| v1.12 | Frozen | Cascade closing DEC-050 (05_Design_System bump to v1.13, Ledger Dark extended to light-mode/email): updated the dependency reference and five body cross-references to 05_Design_System_v1.13. No component structure, states, or reuse rules changed. |
| v1.13 | Frozen | Cascade closing DEC-053 (05_Design_System bump to v1.14, Lovable reference removed from Icon System rationale): updated the dependency reference and five body cross-references to 05_Design_System_v1.14. No component structure, states, or reuse rules changed. |
| v1.14 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and five body cross-references to 05_Design_System_v1.15, as 05 continued to move within the same DEC-053 cascade. No component structure, states, or reuse rules changed. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and five body cross-references to 05_Design_System_v1.16, its now-settled final version. No component structure, states, or reuse rules changed. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and five body cross-references to 05_Design_System_v1.17, as 05 continued to move within the same DEC-053 cascade. No component structure, states, or reuse rules changed. |
| v1.17 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and body cross-references to 05_Design_System_v1.18, following DEC-054 (Renewal Urgency Indicator day-thresholds; Lifecycle Status Component content correction). C-012 and C-013's own specs are unchanged — 05 owns the concrete threshold/enum values, this document owns the component shape only. |
| v1.18 | Frozen | Housekeeping pass, not tied to a new DEC: updated the dependency reference and body cross-references to 05_Design_System_v1.19, following DEC-055 (logo wordmark font resolved, logo formally implemented). No component spec content changed. **Further correction (same day, DEC-056 login-page visual exception cascade):** the dependency reference and all five body cross-references updated to 05_Design_System_v1.20. Not bumping the version again for this — the login page's custom hover button and glass card are an explicit, documented exception in 05 itself, not a change to any component spec owned by this document. **Further correction (DEC-057 brand kit cascade):** the dependency reference and all five body cross-references updated again to 05_Design_System_v1.21 (card background now describes glass-morphism as the app-wide standard, not the pre-auth-only exception). Not bumping the version again for this — no component spec owned by this document changed in substance, only the color/background token it points to. **Further correction (DEC-058 motion-system cascade):** updated again to 05_Design_System_v1.23. Not bumping the version again for this either. |
| v1.19 | Frozen | Recorded DEC-059's impact on this document: corrected C-010 Subscription Card's "the only permitted per-instance variation is the real service logo/fallback icon" to describe a fixed, generic category icon (Lucide, per DEC-059) instead — never a real per-service brand logo. Corrected C-005 Renewal List's "Logo or fallback icon" item-content bullet the same way. Updated the dependency reference and cross-reference to 05_Design_System_v1.23. This is a genuine component-spec content correction, not pure housekeeping — the underlying visual/structural frame (radius, padding, border, glass background) is unchanged. **Further correction (DEC-060/061 logo-asset and Header-restructure cascade):** the dependency reference and all five body cross-references updated to 05_Design_System_v1.25. Not bumping the version again for this either. |
| v1.20 | Frozen | Recorded DEC-064's impact on this document: added a quick-action row (Paid/Paused/Resume) to C-010 Subscription Card's Interaction list, cross-referencing 05_Design_System's new Card Quick Actions subsection for the exact behavior — a genuine component-spec content addition, scoped to this card only. Also corrected C-012 Renewal Urgency Indicator's stale "Future: overdue" state to plain "Overdue" (it shipped earlier this session and is live), a housekeeping fix not tied to a new DEC. Updated the dependency reference and all five body cross-references to 05_Design_System_v1.28 (also covering DEC-062/063's citation cascade). |
| v1.21 | Frozen | Cascade closing DEC-065/066 (05_Design_System bump to v1.30, Cyber Lime reskin + DEC-056 retirement): updated the dependency reference and all five body cross-references to 05_Design_System_v1.30. Corrected C-010 Subscription Card's Visual frame paragraph: the shared radius/padding/border/hover language is unchanged, but background is now called out as an explicit exception — under DEC-066 the app-wide card standard corrected to opaque (`bg-card`, no blur), while this card is the one confirmed component that keeps the translucent `bg-card/70 backdrop-blur-md` glass-morphism treatment (a repeated per-instance list tile, not a page-level section container). No other component spec content changed. |
| v1.22 | Frozen | Recorded DEC-067's impact on this document: C-005 Renewal List's Purpose bullet corrected from an unqualified "show upcoming renewals in chronological order" to explicitly state the 7-day cutoff (Overdue/Critical/Upcoming urgency only, per DEC-054/DEC-039) and the paused-subscription exclusion (DEC-064) — a genuine component-spec content correction closing a real gap where the shipped screen's actual filtering behavior was undocumented here. No dependency-reference change — 05_Design_System is still at v1.30, untouched by DEC-067. |
| v1.23 | Frozen | Housekeeping pass, not tied to a new DEC beyond DEC-073 itself: updated the Depends On field and all five body cross-references to 05_Design_System_v1.31, following DEC-073 (light-mode/email accent tokens resolved to Cyber Lime — Accent Fill/Accent Text (light) replacing the single Accent (light) token). No component structure, states, or reuse rules changed — this bump touches only the dependency citation. |
| v1.24 | Frozen | Recorded DEC-080's remaining component-spec gap for Phase 8 (Shared Subscriptions): added three new components — C-019 Shared Member Row, C-020 Add/Edit Member Form, C-021 Payment Request Item — closing the gap where this document had only C-006 (a Decision Workspace summary card) and no per-screen specs for the Shared Subscriptions page itself. Expanded C-017 Confirmation Dialog's two already-existing but previously undefined variant names ("Reminder confirmation," "Payment status confirmation") to state exactly what they cover under DEC-080 — no new dialog component needed, since both slots already existed in this document, just never given concrete behavior before Phase 8 was designed. Updated the Component Inventory table and Component Dependency Matrix accordingly. No dependency-reference change — 05_Design_System is still at v1.31, untouched by this pass. |
| v1.25 | Frozen | Recorded Phase 9+10's (Insights, Premium Gating, Razorpay Demo) component-spec gap: added eight new components — C-022 Tier Badge, C-023 Plan Comparison Card, C-024 Upgrade Action, C-025 Insights Upsell Card, C-026 Insights Summary Card, C-027 Spend Summary Card, C-028 Duplicate & Overlap Card, C-029 Cost Comparison Card — covering the Profile page's plan/upgrade UI and the new Insights page's content, none of which existed in this document before this phase. Noted a bundling opportunity: C-007 Savings Opportunity Card (Decision Workspace, still unbuilt) could reuse C-029's deterministic category-average engine once actually implemented, rather than needing new design. Flagged C-008 Insights Preview Card as likely obsolete now that Insights has its own direct sidebar nav item — not yet confirmed. **Phase 9+10 itself remains open as of this pass** (known bugs unresolved live-tested this session; no DEC entry recorded yet in doc 08) — this update covers component documentation only, not phase closure. Updated the Component Inventory table and Component Dependency Matrix accordingly. No dependency-reference change — 05_Design_System is still at v1.31, untouched by this pass. |
| v1.26 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field and all five body cross-references (interactive Card hover/focus, Saving-state loading spinner, Dialog Motion spec, focus-visible ring, Shared Activity Card visual frame) to 05_Design_System_v1.32, as part of the cascade recording DEC-083 (Phase 9+10 built and deployed — DEC-083 is now the recorded doc 08 entry closing this pass's "no DEC entry recorded yet" note above). No component structure, states, or reuse rules changed. |
| v1.27 | Frozen | Recorded DEC-085's impact on C-029 Cost Comparison Card: renamed from "Lower-Cost Alternatives" to "Worth a Second Look," with per-item copy rewritten to name the specific subscription, its percentage above the category average, and invite the user to review pricing or tier themselves, rather than implying a cheaper alternative exists. Existing Review Subscription/Remind Me Later actions reused, no new CTA. Live verification of the rename (visual confirmation for both an above- and below-average subscription) not yet completed as of this update — flagged, not silently assumed done. No dependency-reference change — 05_Design_System is still at v1.32, untouched by this pass. |
| v1.28 | Current | Housekeeping pass, not tied to a new DEC: updated the Depends On field and all five body cross-references (interactive Card hover/focus, Saving-state loading spinner, Dialog Motion spec, focus-visible ring, Shared Activity Card visual frame) to 05_Design_System_v1.33, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No component structure, states, or reuse rules changed. |
