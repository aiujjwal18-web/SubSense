# 05 Design System v1.33

## Document Control

| Field | Value |
| --- | --- |
| Document ID | DS-001 |
| Product | SubSense |
| Version | v1.33 |
| Status | Frozen implementation baseline |
| Source of Truth | Reusable visual and interaction standards |
| Depends On | 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19, 02_Experience_Strategy_v1.20, 03_Information_Architecture_v1.17, 04_Experience_Blueprint_v1.25 |

## Purpose

This document defines reusable visual, interaction, feedback, accessibility, and responsive standards for SubSense.

It does not define screen-specific layouts. Those belong to `04_Experience_Blueprint_v1.25.md`.

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

Finalized visual direction: an amber-on-obsidian brand system (no formal name given in the source brand kit; referred to here descriptively pending a name), superseding **"Ledger Dark"** (DEC-049/050) per DEC-057. Ledger Dark itself superseded the original "Monochrome precision" near-black/single-accent palette (DEC-042). The restraint principle still applies to decoration, but the two-shade blue system is gone: DEC-057 defines only two accent colors (a warm amber primary and a white secondary), reserved for identity/CTA use exactly as the prior two-shade system was.

"Restrained" applies to decoration, not to legibility of primary actions or interactive affordances. A primary action or interactive affordance that is hard to notice at rest is not restraint — it works against EXP-002 (User Control First) and EXP-012 (Five Second Rule) in `02_Experience_Strategy`. This clarification exists because DEC-043's first-draft button and card hover values were too subtle to be usable in practice; see the Micro-interactions section below and DEC-044.

## Color Palette

Finalized per DEC-065 ("Cyber Lime"), superseding the amber/white values below (DEC-057), which themselves superseded "Ledger Dark" (DEC-049/050) and DEC-042's "Monochrome precision" values before that.

Surfaces:

| Token | Hex | Use |
| --- | --- | --- |
| Page | #050505 | App background — the deepest layer, recedes behind everything (unchanged across every reskin to date) |
| Surface 1 | #121212 | Card, sidebar, nav bars — **reintroduced as its own tier under DEC-065**, reversing DEC-057's collapse to a single shared value (the amber kit's own source only gave one card/elevated tier; this kit gives two again) |
| Surface 2 | #1A1A1E | Elevated surface, modal, dropdown, icon tile — the second tier DEC-065 reintroduced |
| Border | #2A2A2E | Default hairline — **moved from an alpha-white token to a solid hex under DEC-065** |
| Border Strong | #3A3A3F | Emphasized divider — inferred under DEC-065 (the source kit gives only one border value); kept as its own tier rather than collapsed to Border, because it has a real, live job today (the Secondary button's hover-state border), not spare capacity — collapsing it would have silently removed a working state distinction. Flagged for live confirmation, same discipline as every other inferred value in this document's history |
| Disabled | #334155 | New explicit token under DEC-065, defined for future use — not retrofitted onto the existing, already-uniform `disabled:opacity-50` utility every disabled state uses today, since nothing currently renders an explicit disabled fill and there was no visible complaint to fix |

Text:

| Token | Hex | Use |
| --- | --- | --- |
| Text Primary | #F1F5F9 | Body and heading text — **updated under DEC-065** ("Metallic Silver," replacing the amber kit's #FFFFFF) |
| Text Secondary | #94A3B8 | Supporting text — **updated under DEC-065** ("Muted Chrome," replacing #A3A3A3) |
| Text Muted | #737373 | Placeholders, captions, hints — unchanged under DEC-065; the new brand kit does not name this token, so the existing inferred value carries forward rather than being guessed at again |

Brand accent — reserved for identity and calls-to-action only, never for status meaning:

| Token | Hex | Use |
| --- | --- | --- |
| Primary | #A3E635 | Default/rest primary button fill, active highlights, key metrics — **the headline change under DEC-065** ("Cyber Lime," replacing amber #FFC800 entirely), paired with dark (Page, #050505) text for contrast, same logic as the amber kit before it — never Text Primary (#F1F5F9) on this fill, an explicit accessibility rule carried forward from the source kit |
| Secondary Accent | #38BDF8 | **New role under DEC-065** ("Cool Steel Blue") — the second color in the wordmark's 45-degree gradient (see Logo below), plus status-tag/interactive-state uses. Deliberately not extended to the button-ring/Border Beam/GlowingEffect gradient pairing below — those recolor to Primary + Text Primary instead, keeping this blue exclusive to the wordmark so it stays a rare, special treatment rather than a color repeated on every decorative surface in the app |
| Accent Subtle Background | rgba(163,230,53,0.15) | Badge/pill background, checked-toggle track — re-derived from the new Primary at the same opacity the amber kit used for its own accent-subtle background |
| Accent Subtle Text | #A3E635 | Text on accent subtle background (reuses Primary directly) |

Status colors — shared across the Status System, Renewal Urgency Indicator, and Lifecycle Status Component below. Deliberately independent of the brand accent so status meaning is never diluted by branding (see DEC-042, carried forward under every reskin since, including DEC-065) — the Cyber Lime kit does not define status colors at all, so these carry forward unchanged:

| Token | Hex | Use |
| --- | --- | --- |
| Status Neutral | #94A3B8 | Normal / Paused / Archived |
| Status Amber | #F59E0B | Upcoming / Pending — kept as its own distinct token, independent of brand color per the rule above |
| Status Green | #059669 | Active / Renewal Confirmed / Paid |
| Status Red | #DC2626 | Critical / Failed / Overdue; destructive button text/border |

**Usage discipline added under DEC-065 (60-30-10 principle):** status colors must stay confined to small indicators — a badge, a border, a dot — and must never fill an entire card background or the canvas. This isn't a change to the hex values above (the new brand kit doesn't specify any), it's an explicit statement of a rule that was previously only implicit: status color occupies its own small "accent-tier" sliver of attention, distinct from and never competing with the brand Primary's own restrained footprint. Confirmed via full-codebase investigation during the DEC-065 pass that no component anywhere violates this today — every status-color consumer (`RenewalUrgencyBadge`, `SubscriptionCard`'s lifecycle badge, `badge.tsx`'s destructive variant, `dropdown-menu.tsx`'s destructive item, `button.tsx`'s destructive variant) is already either opacity-scoped or confined to a small badge/chip/menu-row element, never a full surface fill.

Light-mode counterparts — for surfaces that must render on white (Resend email templates, share previews; the product itself remains dark-first). **Resolved under DEC-073**, closing the gap DEC-057 opened and DEC-065 carried forward unchanged: neutral tokens (Page, Surface, Border, Text Primary, Text Secondary) are unaffected by any reskin and stay as-is. The single "Accent (light)" token is retired and replaced by two separate light-mode-safe values, since Cyber Lime's dark-mode Primary (#A3E635, a bright yellow-green) fails WCAG AA contrast on white directly — roughly 1.9:1, far short of the 4.5:1 text minimum — the same reason DEC-065 itself pairs that hex with dark text, never light, on dark surfaces:

| Token | Hex | Use |
| --- | --- | --- |
| Page (light) | #FFFFFF | Card background |
| Surface (light) | #F1F5F9 | Outer email/page background |
| Border (light) | #E2E8F0 | Card border, footer divider |
| Text Primary (light) | #0F172A | Body copy, headings |
| Text Secondary (light) | #64748B | Footer/fine-print copy |
| Accent Fill (light) | #A3E635 | Button background only — raw Primary hex, paired with dark text per the rule below, never white text |
| Accent Text (light) | #4D7C0F | Wordmark span, any other accent-colored *text* use — a darkened, same-hue derivative of Primary (~5:1 contrast on white), not the raw dark-mode hex, since that fails contrast used directly as text color |

Button text on the Accent Fill (light) background is Text Primary (light) (#0F172A), not white — mirrors the in-app Primary button rule (DEC-065: "dark Page-colored text... never Text Primary on this fill") applied to the light-mode surface's own dark-neutral token instead of the dark-mode Page hex, since #050505 would look like an error on a light card.

**Resolved under DEC-058:** the interactive canvas dot-grid background candidate previously noted here is dropped. The main app uses the flat Page background token (#050505) above with no animated background layer at all — not a paused/static rendering of the dot-grid asset, no background component beyond the plain color. This closes the "candidate, not yet adopted" status the dot-grid note carried under DEC-057.

A CSS `offset-path` perimeter-tracing animation — "Border Beam," a fifth externally-sourced reference component, introduced under DEC-058 — is adopted as the product's single piece of persistent ambient motion, scoped to run exactly once on the outer app shell/frame and never repeated per-card or per-screen-section. It requires no new npm package (pure CSS plus the existing `cn` utility). Before use: strip the supplied demo file's heading (`bg-clip-text`/gradient-text treatment, a banned pattern under the project's design-review skill — the demo is not part of the component itself); confirm whether the project's Tailwind config is v3 (`tailwind.config.js`, matching the supplied snippet's `theme.extend.animation`/`keyframes` format) or v4 (CSS-based `@theme`) before wiring in its keyframe, since the two are not interchangeable; and recolor `colorFrom`/`colorTo` from the supplied demo defaults (`#ffaa40`/`#9c40ff`) to brand tokens (Primary/Secondary) — the default pairing is a widely-recognized generic-component-library gradient and must not ship as-is. Because this is meant to read as a brand signature rather than a focal effect, keep contrast and speed low (slower duration, lower opacity) so it does not visually compete with the Primary button's own amber accent.

**Retuned under DEC-062:** the original `size=200`/`duration=30s`/`borderWidth=1` values (chosen deliberately subtle per DEC-058) proved barely visible in practice once DEC-061 removed the structural Header obstruction that had been hiding the beam behind an opaque bar — against a full-viewport perimeter, a 200px beam completing one lap every 30s only lit any given point for about a second every half-minute. Retuned to `size=320`, `duration=10s`, `borderWidth=2` on the same single shell mount point (`AppLayout.tsx`) — no relocation, no structural change. Net effect is still one slow-ish, low-contrast ambient trace, staying within DEC-058's "quiet signature, not a focal effect" intent, just tuned from "practically imperceptible" to "visible."

**Recolored under DEC-065:** `colorFrom`/`colorTo` move from the amber-kit pairing (`#FFC800`/`#FFFFFF`) to `#A3E635`/`#F1F5F9` (Primary + Text Primary) — not the new Secondary Accent blue. The wordmark's lime-to-blue gradient (see Logo below) is deliberately kept exclusive to the wordmark rather than reused here, so it stays a rare, special treatment instead of a recurring decorative texture across every ambient effect in the app. The same recolor (Primary/Text Primary, not Secondary Accent) applies to the GlowingEffect card-glow treatment described under Cards below.

## Typography

Per DEC-057, the single-family IBM Plex Sans system below is superseded by a four-family system, one per role, taken directly from the new brand kit. **Confirmed unchanged under DEC-065** — the Cyber Lime kit doesn't address fonts at all, so there's no source justification to touch this system a second time; same logic applied to every other token a brand kit doesn't cover.

| Role | Family | Weight | Use |
| --- | --- | --- | --- |
| Primary Display | Syne | Heavy / Ultra-Bold | Primary brand logotype/wordmark, major impact statements, hero text |
| Secondary Display | Cabinet Grotesk | Light / Regular | Secondary logo balance, section titles, headline complements |
| Primary Subhead & Action | Plus Jakarta Sans | Bold | UI headers, card titles, button labels, emphasized action calls |
| Secondary Body & UI | Inter | Regular / Medium | General body text, descriptions, numerical data points, dense UI lists |

Font loading is a genuine new setup requirement, not yet done — Syne, Plus Jakarta Sans, and Inter are all available on Google Fonts; Cabinet Grotesk is not (it is a Fontshare font) and needs either the Fontshare CDN link or self-hosted font files. Tracked as the first step in `NEXT_SESSION_AGENDA.md` for the next Cursor/Claude Code session, ahead of any component work. IBM Plex Sans and Space Grotesk both remain installed-but-unused dependencies once this lands — neither is removed from `package.json`, since removing an installed font dependency is out of scope for a visual-direction decision.

Brand contrast pairing per the source kit: Syne Heavy in Primary (#FFC800) paired with Cabinet Grotesk in Secondary/white (#FFFFFF) for hero branding, to maintain strong visual weight distribution between the two display roles.

## Logo

**Per DEC-060**, SubSense's icon mark is a real, pre-rendered image asset (`src/assets/subsense-logo-icon.png`), not an abstracted SVG monogram — this reverses DEC-055's "S"-curve monogram entirely. The asset is cropped from a user-supplied brand concept image (a glossy, two-tone, multi-layer bezel treatment on a rounded-square tile) that would not have been practical to recreate faithfully in hand-built SVG/CSS. Because it is a raster asset rather than a token-driven component, its own colors are baked in at export time rather than tracking the Primary/Popover CSS variables automatically if the palette changes again — a real, accepted trade-off, since only the icon itself required the source image's pixel-level fidelity. The wordmark and tagline, by contrast, remain live, accessible, re-themeable text, not rasterized.

Per DEC-055, the wordmark previously used the same `font-heading` family (IBM Plex Sans) as every other heading; reopened under DEC-057 to Syne (Heavy/Ultra-Bold), per the brand kit's Primary Display Font guidance — unchanged again under DEC-060 and DEC-065. **Per DEC-060**, the wordmark and tagline both moved from a single flat color to a two-tone split: "SubSense" renders as "Sub" in Primary immediately followed by "Sense" in a second treatment.

**Per DEC-065, superseding the two-tone-flat-color treatment above for "Sense" specifically:** "Sub" stays a flat Primary (#A3E635) fill; "Sense" now renders a 45-degree linear gradient from Primary to Secondary Accent (`#A3E635` -> `#38BDF8`), applied via `bg-clip-text`/`text-transparent` referencing the CSS tokens directly (not literal hex), so it stays in sync if either color moves again. Confirmed via full-codebase investigation that the literal text wordmark renders in exactly three places in the entire app, and nowhere else: `AuthPage.tsx` (sign-in/sign-up), `ForgotPasswordPage.tsx`, and `ResetPasswordPage.tsx` — the main authenticated app's `TopBar` (DEC-061) renders the icon only, no wordmark text, at all. The gradient applies consistently across all three; this is already a narrow, contained surface, not a conflict with the 60-30-10 restraint principle applied elsewhere under DEC-065.

**Also per DEC-065:** `AuthPage.tsx`'s wordmark and tagline drop the kinetic/typewriter animation entirely, rendering as plain static text — the same static pattern `Logo.tsx` already used on the Forgot/Reset Password screens, rather than the two sequenced `KineticText` typewriter instances described in earlier versions of this section. This was a deliberate scope pull-forward: it resolves part of what would otherwise have been an open question for DEC-066 (retiring the rest of the DEC-056 pre-auth exception — see below), and it simplifies the gradient implementation, since a static span takes a gradient cleanly with no cursor-color conflict to solve. `KineticText.tsx` is deleted outright — confirmed to have zero other consumers anywhere in the codebase, matching the precedent set when `GradientButton.tsx` was deleted the same way. The tagline itself changes from "Track smarter. Renew wiser." to **"Think wiser. Choose smarter."** under this same decision — a real copy change, not just a recolor; the tagline's two clauses keep the same neutral/accent color split pattern as before (first clause neutral, second in Primary), just with the new copy and no animation.

**Per DEC-060**, reversing DEC-055's distinction: the identical icon asset renders in every context — in-app navigation (the `TopBar`, per DEC-061 — previously the Header) and the pre-authentication entry screen alike — rather than an icon-only mark reserved for in-app use and a separate full lockup reserved for marketing/pre-authentication contexts. The only remaining difference between contexts is composition, not asset: the icon alone (in-app nav) versus icon plus wordmark (pre-authentication hero, and `Logo.tsx`'s lockup on the Forgot/Reset Password screens). **Not touched under DEC-065:** a new logo concept exists (an interlocking two-piece "S" mark, lime + silver, on a rounded-square tile with a lime backlit glow) but the only reference available is a glossy, multi-layer 3D concept render, not a flat production-ready asset — using it as-is would not scale down cleanly to a 16-32px nav icon. `src/assets/subsense-logo-icon.png` (DEC-060) stays in place unchanged; replacing it is a flagged, explicit follow-up for once a real production asset exists, not part of this pass. Vector source and export sizes for the current image asset are maintained as a brand kit package outside this document, same as before.

## Pre-Authentication Screen Exception — Retired (DEC-066)

**Retired under DEC-066.** Per DEC-056, the three pre-authentication screens (sign-in/sign-up, forgot password, reset password) formerly carried a deliberate, scoped visual exception. DEC-056 always described this exception as non-permanent, with DEC-057 explicitly noting a dedicated reskin pass would retire it later, sequenced after the main app. DEC-065 (Cyber Lime reskin) already resolved the typography-motion piece; DEC-066 retires the remaining three pieces, landing all three screens on the same standards defined elsewhere in this document:

- **Card visual standard**: the 28px-radius glass-morphism treatment (translucent, blurred, corner glow, light-sheen overlay) is retired. These three screens now use the standard opaque card treatment (see Card visual standard below) — `rounded-lg border border-border bg-card p-8 text-center`, matching the majority page-level card pattern elsewhere in the app. Padding is deliberately kept at `p-8` rather than the page-level `p-6` majority — see the Cards section below for the reasoning (a pre-auth card's role is closer to a centered dialog than a dense in-page section).
- **Background**: the particle/sparkle field (`SparklesCore`) is removed outright, with no replacement effect — not even a static/paused rendering. These screens now use the same flat Page-token canvas (#050505) as every other screen. Its three backing `@tsparticles/*` npm packages are removed from the project entirely, confirmed fully unused once the component was deleted.
- **Typography motion**: already resolved under DEC-065 — the wordmark and tagline are now plain static text (`KineticText` deleted), not part of DEC-066's own scope.
- **Primary button**: the custom pill-shaped interactive hover button is retired, replaced by the standard `Button` component. `AuthPage`'s Sign in/Create account CTA specifically takes `variant="gradient"` (DEC-063's existing treatment) — a deliberate distinction, not an oversight: the sign-in/sign-up screen is the app's "front door," reasoned to deserve the same highest-prominence treatment as the app's other primary CTAs (Add/Save Subscription). `ForgotPasswordPage`/`ResetPasswordPage`'s own submit buttons are not touched and stay on `variant="default"` — a considered choice (utility/recovery flows, not the front door), not an inconsistency to fix later.

Two small follow-up polish fixes landed in the same DEC-066 pass, once the surrounding elements were standardized and made a pre-existing, unrelated issue newly visible: the "Continue with Google" button's undocumented `rounded-full` override was removed (this project locks a single standard corner radius everywhere, with no carved-out exception for this button, and no rationale for the override existed anywhere in the codebase); and the hero/card layout gap — which read as a stark, oversized void once the particle background and glass effects that previously gave it visual texture were removed — was tightened by replacing a `justify-between` layout mechanism with `justify-center`, reusing the row's own existing `gap-16` value rather than inventing a new number.

This section is kept for historical record of what the exception covered and why it existed (the reasoning in the paragraph below is unchanged as a record of DEC-056's original logic) — as of DEC-066, none of it describes current behavior. These three screens now follow the same Card visual standard, Background, and Button standards as every other screen in the product; there is no longer a documented exception to track here.

*Historical reasoning (DEC-056, no longer in effect):* this exception existed because DEC-043's Card visual standard and the No Visual Noise / Five Second Rule principles (`02_Experience_Strategy`, EXP-012/013) were written for data-scanning surfaces, where structural consistency prevents users from re-learning a pattern card to card. The pre-authentication screens were reasoned to be a single, one-time first-impression surface with no cards to compare against each other and no financial data on screen, where that reasoning didn't apply as strongly. DEC-066 reverses this conclusion in favor of full consistency, now that a stable, finished brand kit (Cyber Lime) exists to land these screens on without risk of reworking them a second time.

## Icon System

Finalized per DEC-043, closing the "Icons" scope item above:

| Property | Value |
| --- | --- |
| Library | Lucide |
| Weight | Single line weight only (no filled/duo-tone variants) |
| Inline size | 20px (inside buttons, list rows, form fields) |
| Standalone size | 24px (icon-only buttons, empty-state illustrations) |
| Color | `Text Secondary` at rest; `Primary` only when the icon sits inside an active/selected control |

Rules:

- Icons never carry status meaning alone (status is color plus label, per the Status System rule below); an icon is a navigational or category cue, not a state indicator.
- One icon per concept across the product — do not swap icons for the same action between screens.
- Lucide was chosen because it is the default icon set for the shadcn/ui components already used by the Component Library stack, avoiding a second icon dependency. (Originally scaffolded under Lovable; unaffected by DEC-053's move to Cursor, since shadcn/ui is a codebase dependency, not a Lovable-specific one.)

**Subscription Card icon, per DEC-059:** no subscription ever renders a real third-party brand logo. Every catalog category maps to one fixed, generic Lucide icon, rendered inline (a component, not an image fetched from a URL):

| Category | Icon |
| --- | --- |
| Entertainment | `Tv` |
| Music | `Headphones` |
| Productivity | `Briefcase` |
| Education | `BookOpen` |
| Utilities | `Wrench` |
| AI Tools | `Bot` |
| Other | `Layers` |

This replaces the DEC-043/046 approach of sourcing and displaying each service's actual brand logo (`subscription_catalog.logo_url`, Simple Icons/Wikimedia-sourced) — that column is no longer read anywhere in the frontend; see the Card visual standard note below and `10_Database_Architecture` for its schema-level status. The subscription's real name still displays as plain text on the card, but only set in the app's own type system (Plus Jakarta Sans per DEC-057) — never a brand's own logotype, wordmark styling, or proprietary font.

## Spacing & Grid

Finalized per DEC-043, closing the "Grid and spacing" scope item above. All spacing must be drawn from this 4px-based scale — no ad hoc pixel values:

| Token | Value | Typical use |
| --- | --- | --- |
| space-1 | 4px | Icon-to-label gap, tight inline spacing |
| space-2 | 8px | Form field internal spacing, badge padding |
| space-3 | 12px | Related-item gaps inside a card |
| space-4 | 16px | Default gap between stacked elements |
| space-5 | 24px | Gap between cards in a list or grid; section spacing inside a page |
| space-6 | 32px | Page gutter on mobile; spacing between major page sections |
| space-7 | 48px | Page gutter on desktop |
| space-8 | 64px | Large section breaks on wide/marketing-adjacent layouts only |

Applied defaults:

- Card internal padding: 20px (between space-4 and space-5, reserved specifically for card padding rather than added as a numbered token).
- Gap between cards: 24px (space-5).
- Page gutter: 32px desktop, 16-24px mobile depending on viewport, per the Responsive Rules below.

## Micro-interactions

Finalized per DEC-044, closing the "Interaction patterns" scope item above and correcting the two DEC-043 values noted in Visual Direction.

### Timing Scale

| Token | Duration | Easing | Use |
| --- | --- | --- | --- |
| motion-hover | 120ms | ease-out | Hover/press feedback on buttons, cards, icons, inputs |
| motion-toggle | 200ms | ease-out | Toggles, dropdowns, tab switches, toast enter, list load-in |
| motion-dialog | 320ms | ease-out | Dialog/modal enter, page-level transitions |
| motion-exit | 150ms | ease-in | Toast and dialog exit — closing is faster than opening so overlays get out of the way without lingering |

### Button States

All four button variants share the same timing (motion-hover for rest/hover/press, a shared focus ring on `:focus-visible`):

| Variant | Rest | Hover | Press | Focus-visible |
| --- | --- | --- | --- | --- |
| Primary | Primary (#A3E635) fill, dark (Page, #050505) text — per the brand kit's explicit "dark text for maximum punch" instruction, carried forward unchanged from the amber kit's own accessibility rule | Inset dark ring (rgba(5,5,5,0.35)), fill unchanged | Fill dims to 85% opacity; scale(0.98) — inferred, flagged for live confirmation | 3px ring, rgba(163,230,53,0.45) |
| Secondary | **Rewritten under DEC-065**: persistent lime border + tinted fill (`border-secondary-foreground bg-secondary`, i.e. 1px #A3E635 border, rgba(163,230,53,0.08) fill, #A3E635 text) — replacing the prior hover-only-emphasis outline treatment, per the brand kit's own Secondary CTA guidance | Fill deepens to rgba(163,230,53,0.14) | Fill deepens further to rgba(163,230,53,0.20) — a genuine 3-step base/hover/active progression, not the 2-state treatment used before | Same 3px accent ring |
| Destructive | Transparent fill, 1px Border, Status Red text | Status Red at 12% opacity fill, 1px Status Red border | Status Red at 20% opacity fill | 3px ring, rgba(220,38,38,0.4) |
| Icon | Same as Secondary, square/icon-only | Same as Secondary | Same as Secondary | Same as Secondary; must still carry an accessible label |

Primary's rest state uses the brand kit's lime fill with dark text, per its explicit instruction — this is a source-given value, not inferred; the explicit accessibility rule (never Text Primary on Primary fill) carries forward from the amber kit unchanged. The press-state opacity-dim value is inferred and flagged for live confirmation once seen built, the same way DEC-044's original values needed real prototyping before they were trusted. Destructive buttons never use the brand accent, keeping it reserved for identity/CTA and avoiding needless alarm at rest (consistent with the Notification Philosophy's "avoid fear-based language" in `02_Experience_Strategy`) — the red only strengthens on hover/press, once the user is actually engaging the control.

**Adopted under DEC-063**, reversing the earlier "not yet a complete, working component... not adopted" status: the rotating conic-gradient ring treatment is a real, shared `variant="gradient"` on the app's `buttonVariants` system (`src/components/ui/button.tsx`) — not a separate, hand-rolled component — so it inherits the same shared focus-visible ring, disabled handling, and sizing as every other variant for free. Scoped to exactly 5 real primary call-to-action buttons app-wide at the time of DEC-063: `TopBarActions`' "Add Subscription," `DecisionWorkspacePage`'s and `SubscriptionsListPage`'s "Add your first subscription" empty-state buttons, and `AddSubscriptionPage`'s "Save Subscription" submit. **Per DEC-066**, a 6th call site was added: `AuthPage`'s Sign in/Create account submit CTA, replacing the retired custom pill button — a deliberate "front door deserves the same emphasis" distinction from `ForgotPasswordPage`/`ResetPasswordPage`, whose submit buttons stay on `variant="default"` and are not part of this scope expansion. Still not a universal Primary-button replacement — every other Primary, Secondary, Destructive, and Icon button keeps the flat/outline treatment defined in the table above unchanged. Includes a `prefers-reduced-motion` fallback (Tailwind's `motion-reduce:` variant — freezes rotation, keeps the same 3-color gradient statically) — the first reduced-motion handling anywhere in the codebase, scoped to this variant only; Border Beam's own reduced-motion gap (noted in the Logo/Component Families section) remains a separate, not-yet-addressed follow-up. Because `border-0` is required on this variant (avoiding a 1px gap in the gradient from the base style's `bg-clip-padding`), its focus indication relies entirely on the ring (no `border-color` component from `focus-visible:border-ring` the way every other variant gets) — confirmed live to read clearly against both the rotating gradient and the surrounding page background. **Recolored under DEC-065**: the gradient's hardcoded hex (both the `motion-reduce:` fallback and the inline `style` background) moves from amber/white (`#FFC800`/`#FFFFFF`) to `#A3E635`/`#F1F5F9`.

### Button Loading State

Applies wherever a button triggers an async Path A or Path B call (the View/Edit Controller's Saving state, a Confirmation Dialog's confirm action, the Premium Test Mode payment flow): the label is replaced by an inline spinner (a rotating ring, 800ms linear infinite — a functional state indicator, not decorative motion) plus a short in-progress label; the button dims slightly (85% opacity) and stops accepting input. Fill color does not change, so the control reads as busy, not broken or disabled.

### Card Interaction State

Interactive cards — Subscription Card, AI Decision Card, Savings Opportunity Card, Shared Activity Card, Insights Preview Card, and any other card whose whole surface opens something on click — get identical hover and keyboard-focus treatment: border shifts from Border to Primary and background shifts from Surface 1 to Surface 2, together, at motion-hover (120ms ease-out); focus-visible additionally adds the same 3px accent ring used on buttons. This supersedes the DEC-043 "1px Border Strong outline" value in the Card visual standard below, which proved too small a shade difference to notice. Non-interactive cards (a display-only Financial Context Card variant, the Empty State Card) receive no hover or focus treatment — they are not clickable as a whole surface.

### Toggle State

Rest: Border-colored track, Text Secondary thumb. Checked: Accent Subtle Background track, Primary thumb. Both track and thumb-position transition at motion-hover (150ms ease-out is acceptable here as a rounding of the 120ms token for the two-property transition). Toggles are keyboard-operable (Space/Enter), expose `role="switch"` and `aria-checked`, and carry the same focus-visible ring as buttons.

### Toast Motion

Enter: fade plus an 8px rise, at motion-toggle (200ms ease-out). Exit: fade only, at motion-exit (150ms ease-in) — no reverse-slide, so dismissal feels quick rather than performative. Applies to transient confirmations such as "Reminder sent" or "Changes saved."

### Dialog Motion

Enter: backdrop fades in while the dialog panel fades and scales from 0.98 to 1.0, at motion-dialog (320ms ease-out) — a confirmation dialog is asking for the user's attention before a meaningful or destructive action, so it is allowed to take a beat longer than a toast. Exit: reverses at motion-exit (150ms ease-in), since closing should feel immediate.

### List Load-in

The first 6-8 items in a card list (Decision Workspace, My Subscriptions) fade in and rise 8px with a 40ms stagger between items, at motion-toggle timing; remaining items appear immediately rather than continuing the stagger indefinitely. This runs once per navigation into the list, not on every re-render.

### No-Motion Rule

Purely informational elements — status badges, the Lifecycle Status Badge, the Renewal Urgency Indicator, and list-item metadata text that is not itself clickable — receive no hover, focus, or entrance motion. They do not accept input, and animating them would contradict No Visual Noise (EXP-013) by drawing attention to elements the user cannot act on.

### Reduced Motion

All entrance, stagger, and scale effects above (list load-in, dialog scale-in, toast rise) must be wrapped so that `prefers-reduced-motion: reduce` collapses them to a plain opacity fade with no translate, scale, or stagger delay. Hover/press/focus feedback (color and ring changes) is unaffected, since it is a state indicator rather than motion in the vestibular-trigger sense.

## Layout Standards

Rules:

- Primary surfaces use consistent page gutters, per the Spacing & Grid scale above.
- Cards must not be nested inside other cards.
- Tool and dashboard areas should be dense but readable.
- Sections should not become marketing-style hero layouts inside the app.
- Primary task areas remain visually dominant.
- Supporting information should not compete with the main decision.

## Component Families

### Global Navigation

Reusable:

- TopBar.
- TopBarActions.
- Sidebar.
- Logo/Home.
- Profile menu.
- Breadcrumb or page header pattern.

**Per DEC-061:** the single, full-width "Header" bar previously named here is retired as a distinct opaque top bar. It is replaced by three independent pieces: a background-less `TopBar` strip (mobile hamburger control plus the Logo/Home link) spanning the full width above the Sidebar+Main row; a `TopBarActions` cluster (Search, Add Subscription, Notifications, Profile menu — the same controls Header previously held) that floats independently, fixed to the top-right corner of the viewport rather than living inside a shared bar; and the Sidebar+Main content row beneath both, with Sidebar and Main remaining structurally and visually independent of each other (no shared background or frame). This was needed because Border Beam (DEC-058), traced around the outer app shell's perimeter, was structurally invisible across the top edge wherever it passed behind Header's opaque, full-width background — painting underneath it rather than being visible through it. Border Beam's own animation-parameter visibility, and a possible glow-card extension to two Decision Workspace cards, remain open and are not resolved by this restructure alone; tracked in `NEXT_SESSION_AGENDA.md`.

The collapsible, hover-expand/mobile-overlay sidebar pattern noted here as a candidate enhancement is resolved and built: the existing Sidebar was extended with internal hover-state (desktop: hovering expands it from icon-only to full labels; mobile: the existing drawer/overlay behavior is unaffected, since touch devices have no hover), replacing its prior manual collapse/toggle button entirely. This is a factual correction to this section's previously-stale "not yet decided" status, not a new decision — the underlying candidate-component adoption was already recorded under DEC-057/058; only this line's own status text had not been updated to match.

### Cards

Reusable:

- AI Decision Card.
- Subscription Card.
- Financial Context Card.
- Empty State Card.
- Confirmation Card.
- Savings Opportunity Card.

Card behavior is standardized. Card content is owned by the Experience Blueprint.

Card visual standard (finalized per DEC-043, hover/focus corrected per DEC-044, background treatment superseded per DEC-057, **corrected against actual shipped behavior per DEC-066** — see note below) — the intended uniform frame for every card type:

| Property | Value |
| --- | --- |
| Background | **Corrected under DEC-066:** opaque Surface 1 (`bg-card`), no blur, no translucency — confirmed via full-codebase investigation to be the actual majority pattern across 9 of 10 shipped page-level card instances (`DecisionWorkspacePage`'s 2 sections, `SubscriptionDetailsPage`'s 7 sections). The glass-morphism description this row previously carried (per DEC-057's brand-kit guidance) was never actually built app-wide — only `SubscriptionCard.tsx`'s individual list tile uses a translucent `bg-card/70 backdrop-blur-md` treatment, which is now understood as that one component's own distinct exception, not the general page-level card standard. This is a factual correction to what this document claimed, not a new visual decision — the code was already this way before DEC-066, the documentation had simply drifted from it |
| Border | 1px solid Border |
| Corner radius | 8px (unchanged — no brand kit to date has specified a radius, so the frozen DEC-049 value carries forward) |
| Padding | 20px for card components generally; page-level section containers (Dashboard/Details) use 24px (`p-6`) in practice; the three former pre-authentication screens (now standard cards per DEC-066) use 32px (`p-8`) — a deliberate exception, not an oversight: padding is not one of this project's locked brand tokens (color/typography/radius/motion are; spacing is not), the majority pattern itself already varies by card role (`SubscriptionCard`'s tile uses a narrower value than a page-level section), and a pre-authentication card's role — a single, standalone focal element on an otherwise-empty page — is structurally closer to a centered dialog than a dense in-page section, justifying the extra breathing room |
| Elevation at rest | None (no drop shadow) |
| Hover/focus (interactive cards only) | Border -> Primary, 120ms ease-out; see Micro-interactions. The Surface 1 -> Surface 2 background shift from the original pre-DEC-057 standard no longer applies the same way now that Surface 1/2 are reintroduced as genuinely distinct tiers under DEC-065 — reconfirm this shift still reads correctly against the new, more separated tier values |

Card-to-card visual variety must come from content, never from structure: the category icon and its color (per the Subscription Card icon table in the Icon System section above — **corrected under DEC-059**, this is a fixed generic category icon, not a real per-service brand logo), status color, and copy (the subscription's real name, in the app's own type system). Do not vary corner radius, padding, border, or add rotation/skew between instances of the same card type — this was evaluated and rejected under DEC-043 because it works against the Five Second Rule and No Visual Noise principles (`02_Experience_Strategy`, EXP-012, EXP-013) on a surface where users are scanning financial data quickly; the move to a glass background under DEC-057 does not reopen this rule — every card still gets the same glass treatment, not a per-card one. Motion (hover/press feedback, load-in stagger, per Micro-interactions above) and AI copy tone (per DEC-045, `02_Experience_Strategy`) are the sanctioned sources of "human" personality instead.

A mouse-tracking glowing-border effect (an externally-sourced reference component, already compatible with this project's `motion/react` convention with no changes needed) is noted as a candidate enhancement to the hover/focus border treatment above. **Scoped under DEC-058:** this effect renders only on Subscription Cards whose renewal falls within the Critical or Upcoming urgency window (2 days or fewer, or 3-7 days, per the Renewal Components thresholds below) — reuse the same `computeRenewalUrgency` classification already used for the Renewal Urgency Indicator rather than a new, separately-tuned distance check. Normal-tier cards (more than 7 days out) get no glow and keep the plain glass treatment defined above; this is deliberate, not a staged rollout — the effect is meant to signal urgency, not to decorate every card.

**Second, distinct use under DEC-062:** the same `GlowingEffect` component is also applied, unconditionally (no urgency gating), to `DecisionWorkspacePage`'s "Today's Financial Context" and "Recommended Reviews" sections — the page's two highest-priority destinations for a user's attention. This is a deliberately separate meaning from the urgency use above (page-section importance, not renewal urgency) sharing only the visual mechanism, not the semantics; "AI Insights," "Upcoming Renewals," "Shared Payment Activity," and "Potential Savings" remain plain, unglowing sections. Any future third use of this effect should be checked against both existing meanings before shipping, so the distinction doesn't quietly blur.

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

Rest/hover/press/focus states and the loading state for all variants are defined in Micro-interactions above.

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

Status meaning must not depend only on color. Status colors are defined in the Color Palette section above and are shared across this system, the Renewal Urgency Indicator, and the Lifecycle Status Component — independent of the brand accent. Per the No-Motion Rule in Micro-interactions, status indicators carry no hover or entrance motion.

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

Copy tone and variety for these patterns is defined in `02_Experience_Strategy`'s AI Copy Tone subsection (DEC-045); this document owns their visual/structural presentation only.

### Financial Components

Reusable:

- Annual Cost Preview.
- Financial Summary Pattern.
- Today's Financial Context.
- Shared Balance Summary.
- Spending Summary.
- Savings Opportunity.

### Renewal Components

Renewal Urgency Indicator states, with frozen day-thresholds against `subscriptions.next_renewal_date` per DEC-054:

- Normal: more than 7 days until renewal.
- Upcoming: 3 to 7 days until renewal.
- Critical: 2 days or fewer until renewal.
- Overdue: renewal date has already passed.

Urgency is derived client-side from the renewal date; it is not a stored column. The thresholds reuse the already-frozen `two_day`/`seven_day` reminder windows rather than introducing a second, independently-tunable "how soon is soon" number. **Housekeeping correction (this pass):** Overdue was previously listed here as "Future... reserved, not yet in scope" — stale; it has since shipped (the renewal-date display work that unified "Overdue by N days"/"Due today"/"Renews in N days" labels across every render site) and is live today. Not tied to a new DEC — a factual status correction, matching the same pattern as the sidebar hover-expand and Global Navigation status corrections elsewhere in this document's history.

The indicator should create awareness without creating unnecessary anxiety.

### Lifecycle Components

Lifecycle Status Component supports, matching the live `lifecycle_status` enum (DEC-036):

- Active.
- Review Due.
- Renewal Confirmed.
- Paused.
- Archived.

## View -> Edit Pattern

All editable areas follow:

View State -> Edit -> Edit State -> Save Changes or Cancel Changes -> View State

Requirements:

- View state is default.
- Edit mode is intentional.
- Cancel restores prior state.
- Save confirms success or explains error.

### Card Quick Actions (DEC-064)

A narrow, explicitly-scoped exception to the pattern above: `SubscriptionCard` carries a small "Paid"/"Paused"/"Resume" quick-action row that writes directly, without entering the full Edit state. This is deliberate, not a precedent for bypassing View -> Edit generally — the two writes involved (`lifecycle_status` toggling between `active`/`paused`, and `next_renewal_date` recomputed via a pick-date -> confirm dialog) are each single-field, low-ambiguity actions with an immediate, visible result (the card's own badge/glow updates), unlike a full subscription edit's multiple interdependent fields. "Paid"'s date-confirm step still satisfies the "destructive actions require confirmation where data impact is meaningful" rule below, even though it bypasses the Edit state itself. Buttons are adaptive per lifecycle status: an archived card shows neither button; a paused card shows only "Resume" (returns to `active`); every other card shows both "Paid" and "Paused." Scoped to the card only — `SubscriptionDetailsPage` and `DecisionWorkspacePage`'s row items do not carry these buttons and continue to rely on the full View -> Edit flow.

## Feedback Components

Reusable feedback includes:

- Success message.
- Error message.
- Inline validation.
- Toast notification.
- Empty state.
- Loading state.
- Confirmation dialog.

Toast and dialog motion are defined in Micro-interactions above.

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

Skeletons are preferred for page-level loading where structure is known. Skeletons pulse via opacity (not a moving gradient sweep, which would reintroduce the decorative-shine look the brand direction already rejected).

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

Visible focus states are implemented as the shared focus-visible ring defined in Micro-interactions, applied consistently to buttons, interactive cards, toggles, and form inputs.

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
| Color palette and typography finalized | Complete |
| Logo defined | Complete |
| Spacing/grid scale defined | Complete |
| Card visual standard defined | Complete |
| Icon system defined | Complete |
| Micro-interaction states defined | Complete |

## Version History

| Version | Status | Summary |
| --- | --- | --- |
| v1.0 | Frozen | Initial Design System architecture. |
| v1.2 | Frozen | Implementation Freeze alignment and expanded reusable standards. Updated dependency references to 01_Product_Strategy_v1.3 and 04_Experience_Blueprint_v1.3. |
| v1.3 | Frozen | Finalized the "Monochrome precision" color palette, typography (Space Grotesk/IBM Plex Sans), status color scale, and logo, closing the "no hex values defined yet" gap, per DEC-042. Updated dependency references to 00_Project_Governance_v1.3, 01_Product_Strategy_v1.5, 02_Experience_Strategy_v1.3, 03_Information_Architecture_v1.3, and 04_Experience_Blueprint_v1.4. |
| v1.4 | Frozen | Finalized the spacing/grid scale, the card visual standard (radius, padding, border, no-shadow, content-driven variety rule), and the icon system (Lucide), closing the remaining "Grid and spacing," "Elevation," and "Icons" gaps, per DEC-043. Updated dependency reference to 00_Project_Governance_v1.4. |
| v1.5 | Frozen | Added the full Micro-interactions section (timing scale, button/card/toggle states, loading state, toast/dialog motion, no-motion rule, reduced-motion fallback) per DEC-044, closing the "Interaction patterns" scope item. Corrected the DEC-043 primary-button rest color and card hover treatment, both found insufficiently visible in prototyping. Added a Visual Direction clarification that "restrained" applies to decoration, not to primary-action/affordance legibility. Updated dependency references to 00_Project_Governance_v1.5 and 02_Experience_Strategy_v1.5. |
| v1.6 | Frozen | Updated dependency references to 00_Project_Governance_v1.6 and 02_Experience_Strategy_v1.6, and cross-referenced the AI Information Pattern to 02's new AI Copy Tone subsection, following the AI copy tone closure under DEC-045. No visual/structural content in this document changed. |
| v1.7 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, 03_Information_Architecture_v1.5, and 04_Experience_Blueprint_v1.6, closing a citation-integrity gap found during the DEC-045 pass. No visual/structural content in this document changed. |
| v1.8 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.8, 01_Product_Strategy_v1.7, 02_Experience_Strategy_v1.8, 03_Information_Architecture_v1.5, and 04_Experience_Blueprint_v1.6, and the Experience Blueprint cross-reference in Purpose, as part of the cascade patching 11_API_Integration_Architecture's own internal reference-integrity gaps. No visual/structural content in this document changed. |
| v1.9 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.9, 01_Product_Strategy_v1.8, 02_Experience_Strategy_v1.9, 03_Information_Architecture_v1.6, and 04_Experience_Blueprint_v1.7, as part of the cascade closing 11's Depends On completeness and Supersedes-field fix. No visual/structural content in this document changed. |
| v1.10 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.10, 01_Product_Strategy_v1.9, 02_Experience_Strategy_v1.10, 03_Information_Architecture_v1.7, and 04_Experience_Blueprint_v1.8, as part of the cascade recording DEC-046 (catalog `logo_url` column and expansion). No visual/structural content in this document changed. |
| v1.11 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.11, 01_Product_Strategy_v1.10, 02_Experience_Strategy_v1.11, 03_Information_Architecture_v1.8, and 04_Experience_Blueprint_v1.9, as part of the cascade recording DEC-047 and its version bump to 10_Database_Architecture_v1.7, batched with the notification-template SQL patch (file 23). No visual/structural content in this document changed. |
| v1.12 | Frozen | Recorded DEC-049: adopted "Ledger Dark" as the finalized visual direction, superseding DEC-042's Monochrome Precision palette and two-family type system. Replaced the surface/text/brand-accent/status color tables with the Ledger Dark values; split the single Accent token into a two-shade Primary/Secondary system (correcting an initial draft where Secondary read brighter than Primary) and renamed the remaining "Accent" references in Micro-interactions, Card Interaction State, Toggle State, and the Icon System to Primary; consolidated the Space Grotesk/IBM Plex Sans type pairing into a single IBM Plex Sans family (Space Grotesk retained only as the logo wordmark, flagged for explicit confirmation); reduced the Card visual standard's corner radius from 12px to 8px. Border Strong, Text Muted, and the Primary button's press-state color were not specified by the DEC-049 research and are inferred here from the existing palette family rather than sourced — flagged inline for confirmation once seen live, consistent with how DEC-044's own values needed real prototyping. Light-mode/email counterparts are unchanged and remain Monochrome-Precision-derived; whether they should also move to Ledger Dark is a separate, open decision. No dependency-reference changes — this bump is scoped to 05 and 06 only. |
| v1.13 | Frozen | Recorded DEC-050, closing the open question DEC-049 left unresolved: Light-mode counterparts now derive from Ledger Dark instead of Monochrome Precision, for brand consistency across the in-app product and its emails. Updated the Light-mode counterparts table (Surface, Border, Text Primary, Text Secondary all moved to the same Tailwind slate family used elsewhere in Ledger Dark; Accent (light) reuses Secondary's dark-mode hex for contrast, mirroring the original design's logic of using a more saturated shade for light backgrounds). Also clarified that Border Strong, Text Muted, and the Primary press-state color (flagged in v1.12) are value updates to CSS custom properties that already exist in the codebase from the original Monochrome Precision build (DEC-042/043/044), not new tokens to invent. Corresponding updates made to files 24 and 25 (Supabase Auth and Resend email templates): hex values, 12px->8px card radius, and font-family — Space Grotesk is now used only for the "SubSense" wordmark span, with headings/CTA/body moved to IBM Plex Sans to match the in-app single-family type system. **Correction (same day, caught during implementation):** Border Strong, Text Muted, and the Primary press-state color did *not* already exist in the codebase — Claude Code confirmed all three were genuinely new tokens (added as `--border-strong`, `--muted-foreground-2`, `--primary-active`), contradicting this entry's assumption above; the values themselves were still correct and are now live. Also corrected this document's own Depends On field, which had never been updated across either the v1.12 or v1.13 bump (still cited 00/02 at v1.11 and 03/04 at pre-reskin versions) — now 00 v1.13, 02 v1.13, 03 v1.10, 04 v1.11 — and the matching Purpose-section cross-reference to 04. Not bumping the version again for the Depends On/cross-reference fix — same-day completion of this document's own intended scope. |
| v1.14 | Frozen | Recorded DEC-053: the Icon System's Lucide rationale no longer names Lovable as the current stack (shadcn/ui is a codebase dependency, not tool-specific; the Lovable mention is now framed as historical/original-scaffolding only). Updated dependency reference to 01_Product_Strategy_v1.11 and 04_Experience_Blueprint_v1.12. No visual/token content changed. |
| v1.15 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.14, 02_Experience_Strategy_v1.14, 03_Information_Architecture_v1.11, and 04_Experience_Blueprint_v1.13, and the screen-layout cross-reference in Purpose to 04_Experience_Blueprint_v1.13 -- all drifted stale as this same DEC-053 cascade continued outward from v1.14. No visual/token content changed. |
| v1.16 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 00_Project_Governance_v1.15, 01_Product_Strategy_v1.12, 02_Experience_Strategy_v1.15, 03_Information_Architecture_v1.12, and 04_Experience_Blueprint_v1.14, and the screen-layout cross-reference to 04_Experience_Blueprint_v1.14, as the same DEC-053 cascade settled to its final versions. No visual/token content changed. |
| v1.17 | Frozen | Housekeeping pass, not tied to a new DEC: updated dependency references to 01_Product_Strategy_v1.13, 02_Experience_Strategy_v1.16, 03_Information_Architecture_v1.13, and 04_Experience_Blueprint_v1.15, and the screen-layout cross-reference to 04_Experience_Blueprint_v1.15, as 01/02/03/04 continued moving within the same DEC-053 cascade. No visual/token content changed. **Correction (same day, caught before this pass finished):** the dependency reference to 00_Project_Governance corrected to v1.16, since it moved again after this row was written. Not bumping the version again for this. |
| v1.18 | Frozen | Recorded DEC-054: froze Renewal Urgency Indicator day-thresholds against `subscriptions.next_renewal_date` (Critical <= 2 days, Upcoming 3-7 days, Normal > 7 days), reusing the already-frozen `two_day`/`seven_day` reminder windows rather than a new independent number; noted urgency is derived client-side, not a stored column. Also corrected a genuine content error found during Phase 4 (Subscription Management) implementation: the Lifecycle Status Component list named Created and Cancelled, neither of which exists in the live `lifecycle_status` enum (DEC-036), and omitted `review_due`, which does — corrected to Active, Review Due, Renewal Confirmed, Paused, Archived to match the live schema. This second fix is a correction against an already-decided schema, not a new decision. **Correction (same day, caught while cascading this same pass):** the Depends On field did in fact need updating — 00, 01, 02, 03, and 04 all bumped their own versions in the same DEC-054 cascade (each closing their own stale 00_Project_Governance citation), so this field now cites 00_Project_Governance_v1.17, 01_Product_Strategy_v1.14, 02_Experience_Strategy_v1.17, 03_Information_Architecture_v1.14, and 04_Experience_Blueprint_v1.16. Not bumping the version again for this. **Further correction (same day, later cleanup pass):** the 00_Project_Governance citation corrected to v1.18, since 00 moved again to close the 10/11/12/13/14/15/16/09 citation drift found in a follow-up audit. Not bumping the version again for this. |
| v1.19 | Frozen | Recorded DEC-055: closed the logo wordmark font question DEC-049 had left flagged as unconfirmed — the "SubSense" wordmark uses IBM Plex Sans (`font-heading`, same as every other heading) rather than Space Grotesk, since the logo is now actually being implemented in code. Updated the Logo section to describe the built implementation: token-driven (Primary/Popover CSS variables, not hardcoded hex) icon-only mark for in-app nav and a full icon+wordmark lockup for marketing/landing contexts and the pre-auth entry screen. **Correction (same day):** the Depends On field did in fact need updating — 00, 01, 02, 03, and 04 all moved within this same cleanup pass, so this field now cites 00_Project_Governance_v1.20, 01_Product_Strategy_v1.15, 02_Experience_Strategy_v1.18, 03_Information_Architecture_v1.15, and 04_Experience_Blueprint_v1.17. **Further correction (same day, full folder grep audit):** the Purpose section's screen-layout cross-reference, separate from the Depends On field, was still stuck at 04_Experience_Blueprint_v1.15 — corrected to v1.17. Not bumping the version again for this. |
| v1.20 | Frozen | Recorded DEC-056: added a new "Pre-Authentication Screen Exception" section documenting the sign-in/sign-up, forgot-password, and reset-password screens' deliberate, scoped departure from the frozen Card visual standard and No Visual Noise/Five Second Rule principles — a particle/sparkle background, a 28px-radius glass-morphism card (translucent, blurred, corner glow, light-sheen overlay) in place of the 8px opaque no-shadow standard, kinetic/typewriter text motion on the wordmark and tagline (new tagline copy: "Track smarter. Renew wiser."), and a custom pill-shaped hover button replacing the standard Button component for that one control. Scoped explicitly to those three screens only; every other screen is unaffected and the standards above remain frozen as written. |
| v1.21 | Frozen | Recorded DEC-057: adopted a new user-supplied brand kit as SubSense's revised visual direction, superseding "Ledger Dark" (DEC-049/050). Replaced the Color Palette (amber #FFC800 / white #FFFFFF accents, two-tier near-black surfaces #050505 page / #0B0C0E card, inferred neutral-gray text tiers flagged for confirmation, status colors and light-mode/email tokens carried forward unchanged) and Typography (four-family system: Syne, Cabinet Grotesk, Plus Jakarta Sans, Inter, replacing single-family IBM Plex Sans). Reopened the Logo wordmark font under DEC-057 (moved from IBM Plex Sans to Syne, per the brand kit's own primary-display-font guidance) and its fill color (Primary blue to Primary amber). Promoted glass-morphism from the DEC-056 pre-auth-only exception to the app-wide Card visual standard (8px radius unchanged, not specified by the source). Updated the Button States table (Primary fill/text per the brand kit's explicit instruction, Secondary treatment inferred and flagged). Added candidate-component notes (dot-grid background, gradient button, glowing-border card, collapsible sidebar) pointing to `NEXT_SESSION_AGENDA.md` for adaptation detail rather than duplicating it here. Added a status note to the Pre-Authentication Screen Exception section: not yet superseded, scheduled for its own reskin pass after the main app. No dependency-reference changes — this bump is scoped to 05 itself, matching how DEC-049's original v1.12 bump was also scoped. |
| v1.22 | Frozen | Recorded DEC-058: resolved the three motion/background candidates left open after DEC-057. Retired the dot-grid animated background candidate outright — the main app background is the flat Page token with no animation. Scoped the glowing-border card candidate to render only on cards in the Critical/Upcoming renewal-urgency window (<=7 days), reusing the existing `computeRenewalUrgency` classification. Added a fifth reference component, Border Beam (CSS `offset-path` perimeter animation), scoped to run once on the outer app shell only, never per-card, as the product's single ambient/brand motion signature — with explicit pre-adoption requirements (strip the demo's gradient-text heading, confirm Tailwind v3 vs. v4 config format before wiring its keyframe, recolor off the demo's default orange/violet to brand tokens, keep contrast/speed low). No dependency-reference changes — this bump is scoped to 05 itself. |
| v1.23 | Frozen | Recorded DEC-059: reverses part of DEC-043/046 — no subscription card renders a real per-service brand logo any longer. Added a fixed category-to-Lucide-icon table to the Icon System (Entertainment->Tv, Music->Headphones, Productivity->Briefcase, Education->BookOpen, Utilities->Wrench, AI Tools->Bot, Other->Layers), rendered inline with no URL/image fetch. Corrected the Card visual standard's "card-to-card variety" paragraph to name the category icon, not "real per-service brand icon," as the sanctioned source of per-instance visual difference; the subscription's real name still displays, but only in the app's own type system, never a brand's own lettering. `subscription_catalog.logo_url` is no longer read anywhere in the frontend — see `10_Database_Architecture` for its schema-level status. No dependency-reference changes — this bump is scoped to 05 itself. **Housekeeping note (this pass):** this row and v1.22's were also swapped back into correct numeric order — a pre-existing transcription error had them reversed in this table; not a new decision, no version bump for the fix itself. |
| v1.24 | Frozen | Recorded DEC-060: real image asset (`src/assets/subsense-logo-icon.png`) replaces the abstracted SVG monogram (DEC-055) as the icon everywhere — in-app and pre-authentication alike, reversing DEC-055's icon-only-in-app-vs-full-lockup-marketing split; the icon's own colors are now baked into the raster asset rather than tracked via CSS tokens, a real accepted trade-off. Rewrote the Logo section to describe the new asset, the two-tone wordmark/tagline color split ("Sub"/Primary + "Sense"/Foreground; tagline's clauses split Foreground then Primary; copy and font both unchanged), and the new additive `KineticText` prop (`hideCursorOnComplete`) that prevents a double-cursor overlap when sequencing two typewriter instances. No dependency-reference changes — this bump is scoped to 05 itself. |
| v1.25 | Frozen | Recorded DEC-061: retired the single full-width Header bar (Global Navigation's reusable pattern list) as a distinct opaque top bar, replacing it with a background-less TopBar strip (hamburger + Logo/Home) above the Sidebar+Main row, plus an independently-floating TopBarActions cluster (Search/Add Subscription/Notifications/Profile menu) fixed to the top-right corner — fixing Border Beam's structural invisibility across the top edge, previously painted-under by Header's opaque background. Also corrected this section's stale "not yet decided" status on the hover-expand/mobile-overlay sidebar pattern (a housekeeping fix, not a new decision — the underlying candidate-component adoption was already recorded under DEC-057/058, only the status line hadn't caught up): the pattern is built, replacing Sidebar's prior manual toggle button with internal hover-state on desktop. Border Beam's own animation-parameter visibility and a possible glow-card extension to two Decision Workspace cards remain open, tracked in `NEXT_SESSION_AGENDA.md`. No dependency-reference changes — this bump is scoped to 05 itself. |
| v1.26 | Frozen | Recorded DEC-062: retuned Border Beam's animation parameters (`size` 200 to 320, `duration` 30s to 10s, `borderWidth` 1 to 2, colors unchanged) on its existing shell mount point, closing the "still barely visible" follow-up from v1.25 without relocating it. Extended `GlowingEffect` (the renewal-urgency glow-card effect, DEC-058) to a second, distinct meaning — unconditional page-section importance — on `DecisionWorkspacePage`'s "Today's Financial Context" and "Recommended Reviews" sections. No dependency-reference changes — this bump is scoped to 05 itself. |
| v1.27 | Frozen | Recorded DEC-063: reversed the Button States section's "GradientButton... not adopted into the frozen standard" note — the rotating conic-gradient ring is now a real `variant="gradient"` on the shared `buttonVariants` system, scoped to 5 primary call-to-action buttons app-wide, with a `prefers-reduced-motion` fallback (the codebase's first). No dependency-reference changes — this bump is scoped to 05 itself. |
| v1.28 | Frozen | Recorded DEC-064: added a new "Card Quick Actions" subsection under View -> Edit Pattern documenting `SubscriptionCard`'s Paid/Paused/Resume buttons as a narrow, explicitly-scoped write-path exception to the full Edit flow. **Housekeeping correction (same pass, not tied to a new DEC):** the Renewal Components' Overdue state, previously listed as "Future... reserved, not yet in scope," was stale — corrected to reflect that it shipped earlier this session (the renewal-date display unification work) and is live today. No dependency-reference changes — this bump is scoped to 05 itself. |
| v1.29 | Frozen | Recorded DEC-065: adopted the "Cyber Lime" brand-kit reskin, superseding DEC-057's amber kit at the token level. Rewrote the Color Palette section: Surface 1/2 reintroduced as genuinely distinct tiers (#121212/#1A1A1E, reversing DEC-057's collapse to one shared value); Border moved from alpha-white to solid hex (#2A2A2E); Border Strong kept as its own inferred tier (#3A3A3F) rather than collapsed, since it has a real live job (Secondary button hover); new explicit Disabled token (#334155) defined, not yet retrofitted onto the existing uniform `disabled:opacity-50`; Primary Accent amber (#FFC800) -> lime (#A3E635), the headline change; new Secondary Accent role (#38BDF8, "Cool Steel Blue") added, reserved for the wordmark gradient and status-tag/interactive-state uses, deliberately not extended to the Border Beam/GlowingEffect/gradient-button pairing (those recolor to Primary+Text Primary instead, keeping blue exclusive to the wordmark); Text Primary/Secondary updated (#F1F5F9/#94A3B8); status colors unchanged, with a new explicit 60-30-10 usage-discipline note added and confirmed via full-codebase investigation that no component violates it today. Recolored Border Beam and GlowingEffect to Primary/Text Primary. Rewrote the Secondary button to a persistent lime border+tinted-fill with a genuine 3-step base/hover/active progression, replacing the prior hover-only-emphasis treatment. Added a 45-degree lime-to-blue gradient on "Sense" in the wordmark (confirmed via code investigation the wordmark renders in exactly 3 places app-wide — `AuthPage`/`ForgotPasswordPage`/`ResetPasswordPage` — the main app's `TopBar` is icon-only). Dropped `AuthPage`'s kinetic/typewriter wordmark animation for static text, deleting `KineticText.tsx` outright (zero other consumers); tagline copy changed to "Think wiser. Choose smarter." Typography, light-mode/email counterparts, and the new 3D-concept logo icon asset remain explicitly out of scope/deferred. No dependency-reference changes — this bump is scoped to 05 itself. |
| v1.31 | Current | Recorded DEC-073: resolved the light-mode/email accent gap DEC-057 opened and DEC-065 carried forward unchanged. The single "Accent (light)" token (#1E40AF) is retired and replaced by two values: Accent Fill (light) (#A3E635, raw Cyber Lime Primary, button backgrounds only) and a new Accent Text (light) (#4D7C0F, a darkened same-hue derivative for text/wordmark use) — the raw Primary hex fails WCAG AA as text on white (~1.9:1), so a text-safe derivative was needed rather than reused as-is; the derivative reaches ~5:1. Button text on Accent Fill (light) is Text Primary (light) (#0F172A), not white, mirroring the in-app Primary button's dark-text-on-lime rule. Neutral light-mode tokens (Page, Surface, Border, Text Primary/Secondary) are unchanged. No dependency-reference changes — this bump is scoped to 05 itself. **Further correction (DEC-079 cascade — Phase 7 AI runtime architecture):** the Depends On field's and the Purpose section's 04_Experience_Blueprint citations updated to v1.19. Not bumping the version again for this. **Further correction (DEC-079 same-day extension — Phase 7 batch response shape and AI Insights merge resolved during implementation planning):** the same two citations updated to 04_Experience_Blueprint_v1.20. Not bumping the version again for this either. **Further correction (DEC-080 cascade — Phase 8 architecture forks resolved):** the same two citations updated to 04_Experience_Blueprint_v1.21. Not bumping the version again for this either. **Further correction (DEC-082 — doc 04 v1.22, premium AI Insight split):** the same two citations updated to 04_Experience_Blueprint_v1.22. Not bumping the version again for this either. **Further correction (DEC-082 — doc 01 v1.16, lower-cost-alternatives note assigned to Phase 9):** the Depends On field's 01_Product_Strategy citation updated to v1.16. Not bumping the version again for this either. |
| v1.32 | Frozen | Housekeeping pass, not tied to a new DEC: updated the Depends On field and the Purpose section's screen-layout cross-reference to 00_Project_Governance_v1.21, 01_Product_Strategy_v1.17, 02_Experience_Strategy_v1.19, 03_Information_Architecture_v1.16, and 04_Experience_Blueprint_v1.24, as part of the cascade recording DEC-083 (Phase 9+10 built and deployed). No visual-standard content changed. **Further correction (same day, second-order cascade closure):** the Depends On field's 00/01 citations, one hop stale after tonight's DEC-085 cascade, corrected to v1.22 and v1.18. Not bumping the version again for this. |
| v1.33 | Current | Housekeeping pass, not tied to a new DEC: updated the Depends On field and the Purpose section's screen-layout cross-reference to 00_Project_Governance_v1.23, 01_Product_Strategy_v1.19, and 04_Experience_Blueprint_v1.25, as part of the cascade recording DEC-087 (Phase 11+12 — Developer/Test Utilities and Testing/QA — built and tested). No visual-standard content changed. |
| v1.30 | Frozen | Recorded DEC-066: retired the DEC-056 Pre-Authentication Screen Exception in full — renamed that section to reflect its retirement rather than deleting it, preserving the historical reasoning. Removed the particle/sparkle background (`SparklesCore`, confirmed used only on the 3 pre-auth screens) and its 3 `@tsparticles/*` npm dependencies entirely, no replacement effect. Collapsed the 28px-radius glass-morphism pre-auth card to the standard opaque card treatment, closing a real doc-vs-shipped-code gap found during investigation: corrected the Card visual standard table's stale claim that glass-morphism is the universal card background (per DEC-057) — the actual shipped standard across 9 of 10 page-level card instances (Dashboard/Details sections) is opaque `bg-card` with no blur; only `SubscriptionCard.tsx`'s individual list tile is genuinely glass, now understood as that one component's own exception rather than the general standard. Replaced the custom pill-shaped `InteractiveHoverButton` with the standard `Button` component (deleted outright, zero other consumers), with `AuthPage`'s CTA specifically taking `variant="gradient"` as a deliberate "front door" distinction from `ForgotPasswordPage`/`ResetPasswordPage` (which stay on `variant="default"`, not touched) — added a sixth `variant="gradient"` call site to the existing DEC-063 paragraph. Documented two follow-up polish fixes: the Google Sign-in button's undocumented `rounded-full` override removed (falls back to standard `rounded-lg`, no documented exception found), and the hero/card layout gap tightened (`lg:justify-between` -> `lg:justify-center`, redundant `lg:mr-8 xl:mr-16` removed, reusing the existing `gap-16` value). Card padding deliberately kept at `p-8` for the three former pre-auth screens (not the page-level `p-6` majority) — documented as a genuine exception, not an oversight, since padding is not one of this project's locked brand tokens and a pre-auth card's role is structurally closer to a centered dialog than a dense in-page section. No dependency-reference changes — this bump is scoped to 05 itself. **Further correction (doc 04/08 follow-up — closing DEC-067's own flagged doc 04 gap):** the Depends On field's 04_Experience_Blueprint citation and the Purpose section's screen-layout cross-reference both updated to v1.18. Not bumping the version again for this. **Further correction (documentation audit pass):** the Depends On field's 02_Experience_Strategy and 03_Information_Architecture citations, left one hop stale, corrected to v1.20 and v1.17. Not bumping the version again for this either. |
