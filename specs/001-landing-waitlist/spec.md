# Feature Specification: Landing + Waitlist + First Article (Phase −1, validation)

**Feature Branch**: `001-landing-waitlist`

**Created**: 2026-05-31

**Status**: Draft

**Input**: Approved design `docs/design.md` · Constitution `.specify/memory/constitution.md`

> **Why this is feature 001 (before the product):** validate demand and collect an audience
> BEFORE building the Go product. This directly counters the #1 documented failure (building
> for months before talking to customers) and gives a launch list for the MVP. The Cockpit
> product itself is `specs/002-cockpit-mvp`.

## Clarifications

### Session 2026-05-31 (decided during brainstorming)

- Q: What ships first? → A: A marketing **landing page + email waitlist + one launch
  article**, before the product is built.
- Q: Aesthetic? → A: Same as the product — dark "terminal / trading-desk" look, monospace
  display, green up-tick accent (consistent with the `claude-mcp-stack` hero assets).
- Q: Articles? → A: A blog/articles section for SEO + social positioning, seeded with one
  launch article now and designed to grow.
- Q: Stack (recommended, confirm at planning)? → A: **Astro** (best-in-class for content/SEO
  + speed, static-first, content collections for the blog), deployed on Vercel.
- Q: Waitlist mechanics? → A: Email capture that **we own the list** (provider chosen at
  implementation — e.g. Buttondown / Resend Audiences / ConvertKit), with graceful
  no-JS-fallback and spam protection.

### Session 2026-05-31 (kickoff decisions, finalized)

- Q: Confirm the landing stack? → A: **Astro + Vercel** (confirmed).
- Q: Waitlist store? → A: **Supabase** (our own Postgres table in a dedicated project; INSERT-only
  RLS). Chosen over Resend Audiences because the existing Resend account has a single shared
  Audience; Supabase gives an isolated, owned list. Keys server-side only via env var; never
  committed. Email sending (launch broadcast) is a later phase.
- Q: Product/brand name + domain? → A: **Sorrel** (`sorrel.dev`), chosen after research over
  Cockpit/Helm/Conductor/Sextant for being distinctive, neutral, and free of dev-tool
  collisions. The repo and `specs/002-cockpit-mvp` directory keep the `cockpit` working name
  for now; the **visible brand on the landing is "Sorrel"**.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Join the waitlist (Priority: P1) 🎯 MVP

A visitor lands on the page, immediately understands what Sorrel is and the pain it solves,
and submits their email to join the waitlist; they get a clear confirmation.

**Why this priority**: Collecting an interested audience is the entire point of this phase.

**Independent Test**: Submit a valid email → it is stored in the owned list and the visitor
sees a success state; submit an invalid/empty email → inline validation; double-submit →
no duplicate/clear message.

**Acceptance Scenarios**:

1. **Given** the landing, **When** a visitor submits a valid email, **Then** it is captured in
   the list and a success confirmation is shown.
2. **Given** an invalid or empty email, **When** submitted, **Then** inline validation blocks
   it with a clear message.
3. **Given** JavaScript disabled, **When** the form is submitted, **Then** it still works
   (progressive enhancement / server endpoint).
4. **Given** a bot submission, **When** it hits the form, **Then** basic spam protection
   (honeypot / provider captcha) reduces junk.

### User Story 2 - Understand the product and its value (Priority: P1)

A visitor grasps, from the page alone: what Sorrel is, the pain (MCP context bloat / setup),
the hero (token-cost analyzer), that it's coming soon, and that it's not affiliated with
Anthropic.

**Independent Test**: A first-time reader can state what it is, the core benefit, and that
it's pre-launch, from the page alone.

**Acceptance Scenarios**:

1. **Given** the hero, **When** skimmed, **Then** value prop + the "measure your MCP context
   cost" angle + a waitlist CTA + "not affiliated with Anthropic" are present.
2. **Given** the page, **When** viewed on mobile, **Then** it is fully responsive and the CTA
   is reachable.

### User Story 3 - Read the launch article (SEO/RRSS) (Priority: P2)

A visitor (often arriving from search or social) reads the launch article (e.g. *"How much
context are your MCP servers wasting?"*) and converts to the waitlist from within it.

**Why this priority**: Organic positioning (SEO) and shareable content (RRSS) drive the
waitlist; the blog section must exist and be extensible.

**Independent Test**: The article renders at its own URL with correct SEO metadata (title,
description, Open Graph image, canonical), is linked from the landing, and has a waitlist CTA;
adding a second article requires only a new content file.

**Acceptance Scenarios**:

1. **Given** the article URL, **When** loaded, **Then** it renders with valid SEO + Open
   Graph/social-card metadata and a sitemap entry.
2. **Given** the article, **When** read, **Then** there is a waitlist CTA.
3. **Given** a new content file, **When** added, **Then** it appears in the articles index
   with no code changes.

### Edge Cases

- Email provider/API down → queue or show a friendly retry; never lose the lead silently.
- Duplicate email → idempotent (no error to the user, no duplicate in the list).
- Social crawler hits a page → correct Open Graph card renders.
- No secrets (provider API keys) in the repo → server-side only via env vars.

## Requirements *(mandatory)*

### Functional Requirements

#### Landing & waitlist
- **FR-001**: A single, responsive landing page in the product's dark terminal aesthetic
  (monospace display, green accent), reusing the established visual language.
- **FR-002**: Clear value proposition, the hero benefit (per-server MCP token-cost analyzer),
  a "coming soon" framing, and a prominent waitlist CTA.
- **FR-003**: An email capture form that stores leads in an **owned** list (provider via
  server-side integration); success + error states; inline validation.
- **FR-004**: Work with JavaScript disabled (server endpoint / progressive enhancement) and
  include basic spam protection (honeypot and/or provider captcha).
- **FR-005**: A visible "not affiliated with Anthropic" disclaimer.

#### Articles / SEO
- **FR-006**: A blog/articles section backed by content files (Astro content collections),
  with an index page and per-article pages.
- **FR-007**: Ship **one** launch article (the token-cost angle) with a waitlist CTA.
- **FR-008**: Per-page SEO metadata (title, description, canonical), Open Graph/Twitter cards
  (with an auto or hand-made social image), `sitemap.xml`, and `robots.txt`.
- **FR-009**: Adding a new article requires only a new content file (no code changes).

#### Quality & ops
- **FR-010**: Lighthouse-grade performance/SEO/accessibility (static-first; fast).
- **FR-011**: No secrets in the repo; provider keys only via environment variables; CI secret
  scan over tree + history.
- **FR-012**: Deployable to Vercel; preview deploys on PRs.

### Key Entities
- **Waitlist lead**: an email (+ optional source/UTM) stored in the owned list.
- **Article**: a content file with frontmatter (title, description, date, slug, OG image).
- **Landing content**: hero, value prop, benefit, CTA, disclaimer.

## Success Criteria *(mandatory)*

- **SC-001**: A visitor can join the waitlist in under 15 seconds from first paint.
- **SC-002**: Captured emails reliably reach the owned list (0 silent losses in testing).
- **SC-003**: The launch article ranks-ready: valid SEO + social card, in the sitemap,
  shareable with a correct preview.
- **SC-004**: Lighthouse ≥ 95 for Performance, SEO, and Accessibility on landing + article.
- **SC-005**: Adding a second article needs only a new content file.
- **SC-006**: 0 secrets/personal data in the repo or history (CI-verified).
- **SC-007**: Fully responsive (mobile + desktop).

## Assumptions

- Stack is **Astro + Vercel** (confirm at planning); email via an owned-list provider chosen
  using our own **Supabase** table (INSERT-only RLS) in a dedicated project.
- The visual language reuses the `claude-mcp-stack` hero aesthetic for brand consistency.
- The product (`002-cockpit-mvp`) is built after this validation phase shows demand.
- Product/brand name finalized as **Sorrel** (`sorrel.dev`) for the landing; the $29 launch
  price stays provisional and may be refined before the product launch.
