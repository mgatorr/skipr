# Feature Specification: skipr Repositioning — Re-message the Landing

**Feature Branch**: `003-skipr-repositioning`

**Created**: 2026-05-31

**Status**: Draft

**Input**: Repositioning per `docs/design.md` and constitution v1.1.0. Re-message and rebrand the
already-built landing (`specs/001-landing-waitlist`) from "Sorrel / token-cost" to **skipr — build
real software with AI, and actually own it**. This re-messages the landing; it does not rebuild it.

## Clarifications

### Session 2026-05-31 (decided during repositioning brainstorm)

- Q: Audience? → A: the **non-technical solo founder** who tried Lovable/Base44 and wants the jump
  to real, owned software (personas: Jose, Goñi).
- Q: Hero message? → A: *"Build real software with AI — and actually own it."* Setup→spec→code→
  GitHub→deploy, guided, without the terminal.
- Q: Differentiator? → A: **anti-black-box** — you keep the code, the repo, the control, and you
  learn. Named explicitly against Lovable/Base44.
- Q: Brand/domain? → A: **skipr** / **skipr.dev** (owned). Replaces "Sorrel".
- Q: Language? → A: **English primary**, **Spanish secondary** (i18n: en + es); English ships first.
- Q: Launch article? → A: rewrite to *"from no-code to software you own"*; retire the token-cost
  article (set to draft) so it doesn't dilute the message.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Understand skipr and why it's not a black box (Priority: P1) 🎯 MVP

A non-technical founder (who has tried Lovable/Base44) lands on the page and, from the hero alone,
grasps: skipr lets you **build real software with AI and own it** — guided, without the terminal —
and that, unlike no-code black boxes, **you keep the code, the repo, and the control, and you learn**.

**Why this priority**: This is the entire point of the repositioning — communicating the new value
proposition and the anti-black-box differentiator. Everything else supports it.

**Independent Test**: A first-time reader who used Lovable can state, from the page alone, what skipr
is, that they keep ownership/control (not a black box), and that it's for building real software —
and the brand reads "skipr" with zero residual "Sorrel/Cockpit".

**Acceptance Scenarios**:

1. **Given** the hero, **When** skimmed, **Then** it shows the value prop ("build real software with
   AI, and own it"), the no-terminal/guided framing, a waitlist CTA, and the "not affiliated with
   Anthropic" disclaimer.
2. **Given** the page, **When** read, **Then** an explicit section contrasts skipr with no-code
   black boxes (Lovable/Base44): you keep the code, the repo, the control, and you learn.
3. **Given** any page or asset, **When** inspected, **Then** the brand is "skipr" everywhere (copy,
   title, OG/hero images, footer) with no residual "Sorrel"/"Cockpit".
4. **Given** mobile, **When** viewed, **Then** it is fully responsive and the CTA is reachable.

### User Story 2 - See how it takes me from idea to shipped (Priority: P1)

The visitor understands **how** skipr works: a guided flow of five steps — setup → spec → code →
GitHub → deploy — on a sensible default stack, so they feel it can actually get them to a real,
deployed app.

**Why this priority**: The "how" is what makes "build real software" believable and makes the
non-technical visitor feel powerful rather than overwhelmed.

**Independent Test**: A first-time reader can describe the five-step journey (setup → spec → code →
GitHub → deploy) after reading the section once.

**Acceptance Scenarios**:

1. **Given** the landing, **When** the "how it works" section is read, **Then** the five guided
   steps are clear and in order (setup, spec, code, GitHub, deploy).
2. **Given** the section, **When** read, **Then** it conveys ownership at each step (your files, your
   repo, your deploy) and does not require terminal knowledge.

### User Story 3 - Join the waitlist (Priority: P1)

A convinced visitor joins the waitlist to be notified at launch. (Mechanism unchanged from the
existing landing; the surrounding message is the new skipr one.)

**Why this priority**: Collecting the audience is the goal of this validation phase.

**Independent Test**: Submit a valid email → stored in the owned list + success shown; invalid →
inline validation; works with JavaScript disabled; duplicate → idempotent success.

**Acceptance Scenarios**:

1. **Given** the CTA, **When** a valid email is submitted, **Then** it is captured and a success
   state is shown.
2. **Given** JavaScript disabled, **When** the form is submitted, **Then** it still works.

### User Story 4 - Read the launch article (Priority: P2)

A visitor (often from search/social) reads the launch article *"from no-code to software you own"*
and converts to the waitlist from within it.

**Why this priority**: Organic/social positioning drives the waitlist; the article carries the
repositioned narrative.

**Independent Test**: The article renders at its URL with valid SEO/OG metadata, is linked from the
landing, has a waitlist CTA, and reflects the skipr/anti-black-box narrative; the old token-cost
article no longer appears in the index.

**Acceptance Scenarios**:

1. **Given** the article URL, **When** loaded, **Then** it renders with valid SEO + social-card
   metadata and a sitemap entry.
2. **Given** the articles index, **When** viewed, **Then** the launch article appears and the
   retired token-cost article does not.

### User Story 5 - Read the landing in Spanish (Priority: P3)

A Spanish-speaking visitor can read the landing in Spanish.

**Why this priority**: Spanish is the secondary audience language; English ships first, Spanish
follows as a second locale.

**Independent Test**: The landing is reachable in English (primary) and Spanish (secondary); core
sections (hero, anti-black-box, how-it-works, waitlist) are translated; switching locale keeps the
user on an equivalent page.

**Acceptance Scenarios**:

1. **Given** the English landing, **When** the visitor selects Spanish, **Then** the core content is
   shown in Spanish.
2. **Given** a locale, **When** crawled, **Then** correct language metadata (hreflang/lang) is present.

### Edge Cases

- A visitor arriving from Lovable/Base44 should feel skipr is the **next step**, not a competitor of
  the same kind.
- Social crawler hits a page → the **new** skipr OG/hero card renders (not the old Sorrel one).
- Residual brand: no "Sorrel"/"Cockpit" string remains anywhere user-visible or in assets.
- Locale switch must not break links, the waitlist, or SEO metadata.
- No secrets (provider keys) in the repo or client bundle.

## Requirements *(mandatory)*

### Functional Requirements

#### Message & brand
- **FR-001**: The landing MUST lead with the value proposition *"Build real software with AI — and
  actually own it"* and a sub-message conveying: guided, idea→shipped, your files/GitHub/deploy,
  without the terminal, for non-technical founders building for real.
- **FR-002**: The landing MUST include an explicit **anti-black-box** section contrasting skipr with
  no-code tools (Lovable/Base44): you keep the code, the repo, the control, and you learn.
- **FR-003**: The landing MUST present a **"how it works"** section with the five guided steps in
  order: setup → spec → code → GitHub → deploy.
- **FR-004**: The brand MUST be **skipr** across all copy, page titles, footer, and social/hero
  images, with **zero** residual "Sorrel"/"Cockpit" anywhere user-visible or in committed assets.
- **FR-005**: A new **hero image** MUST convey the guided flow / "feel powerful" (replacing the
  token-cost-dashboard hero).

#### Content
- **FR-006**: The launch article MUST be rewritten to *"from no-code to software you own"* with a
  waitlist CTA; the previous token-cost article MUST be retired from the index (not shown).
- **FR-007**: Adding a future article MUST still require only a new content file (unchanged
  authoring model).

#### Internationalization
- **FR-008**: The landing MUST be available in **English (primary)** and **Spanish (secondary)**,
  with correct per-locale language metadata; English is shippable on its own first.

#### Preserved from the existing landing (must not regress)
- **FR-009**: The waitlist MUST keep storing emails in the owned list, work with JavaScript disabled
  (progressive enhancement) + spam protection, with success/error/validation states.
- **FR-010**: "Coming soon" framing and the "not affiliated with Anthropic" disclaimer MUST remain.
- **FR-011**: Performance/SEO/accessibility budgets MUST remain (Lighthouse ≥ 95) on landing +
  article; full SEO/OG/sitemap/robots remain.
- **FR-012**: No secrets in the repo or client bundle; provider keys via env only; CI secret scan
  over tree + history.

#### Repository / domain
- **FR-013**: The public repository name MUST become **skipr** and the target domain is **skipr.dev**.

### Key Entities

- **Landing content (skipr)**: hero/value prop, anti-black-box contrast, the five-step "how it
  works", CTA, disclaimer — per locale (en, es).
- **Article**: a content file with frontmatter (title, description, date, slug, OG image, draft);
  the launch article carries the "from no-code to software you own" narrative.
- **Waitlist lead**: an email (+ optional source) in the owned list (unchanged mechanism).

## Success Criteria *(mandatory)*

- **SC-001**: A first-time visitor who used Lovable can state, from the page alone, what skipr is and
  that they keep ownership/control (not a black box).
- **SC-002**: A first-time visitor can describe the five-step guided flow after one read.
- **SC-003**: A visitor can join the waitlist in under 15 seconds from first paint.
- **SC-004**: Zero residual "Sorrel"/"Cockpit" strings anywhere user-visible or in committed assets.
- **SC-005**: The launch article is rank-ready (valid SEO + social card + sitemap) and reflects the
  new narrative; the token-cost article is no longer indexed.
- **SC-006**: The landing is available in English and Spanish with correct language metadata.
- **SC-007**: Lighthouse ≥ 95 (Performance, SEO, Accessibility) on landing + article; fully responsive.
- **SC-008**: 0 secrets/personal data in the repo or history (CI-verified).

## Assumptions

- The existing landing stack and waitlist (Astro + Vercel + owned Supabase list) are reused; this is
  a re-message + rebrand + i18n + content refresh, not a rebuild.
- i18n covers the landing's core sections in Spanish; articles may be English-first, with Spanish
  optional per article.
- The token-cost article is retired (set to draft) rather than deleted, to preserve history.
- The GitHub repo rename (`sorrel` → `skipr`) happens as part of this feature.
- The product itself (the desktop app) is out of scope here; this feature only validates demand via
  the landing.
