---
description: "Task list for feature 001 — Sorrel landing + waitlist + first article"
---

# Tasks: Landing + Waitlist + First Article (Sorrel)

**Input**: Design documents from `specs/001-landing-waitlist/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: INCLUDED — the spec defines an Independent Test per story and the constitution mandates
test-first for real logic (Principle V). Write tests first; ensure they FAIL before implementation.

**Organization**: Grouped by user story. All paths are under `landing/` unless noted.

> **Update (post-implementation):** the waitlist store was switched from Resend Audiences to our
> own **Supabase** table (`public.waitlist`, INSERT-only RLS) — see `research.md` §2. Task
> descriptions mentioning Resend now apply to the Supabase insert; env vars are `SUPABASE_URL` /
> `SUPABASE_ANON_KEY`. Migration: `landing/supabase/migrations/0001_waitlist.sql`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1 / US2 / US3 (maps to spec.md user stories)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize the Astro site under `landing/`.

- [X] T001 Create `landing/` directory structure (`src/{components,content,layouts,lib,pages,styles}`, `public/og`, `tests/{unit,e2e}`) per plan.md
- [X] T002 Initialize Astro 5 project in `landing/` with deps: `@astrojs/vercel`, `@astrojs/sitemap`, `resend`, and dev deps `vitest`, `@playwright/test`, `@lhci/cli`, `eslint`, `prettier`
- [X] T003 [P] Configure `landing/astro.config.mjs` (Vercel adapter, `@astrojs/sitemap`, `site` URL from `PUBLIC_SITE_URL`, static output)
- [X] T004 [P] Configure `landing/tsconfig.json`, eslint + prettier configs
- [X] T005 [P] Create dark terminal theme tokens in `landing/src/styles/theme.css` (bg, monospace stack, single green accent)
- [X] T006 [P] Add scripts to `landing/package.json` (`dev`, `test`, `test:e2e`, `build`, `lighthouse`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared layout, SEO head, env handling, and page shell that every story builds on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T007 Create `landing/src/layouts/BaseLayout.astro` with SEO `<head>` (title, meta description, canonical, Open Graph + Twitter card tags), theme import, header/footer, and a disclaimer slot
- [X] T008 [P] Create `landing/public/robots.txt` (allow crawl + reference `sitemap.xml`) and confirm sitemap integration emits non-draft URLs
- [X] T009 [P] Add server-side env handling + `landing/.env.example` (`RESEND_API_KEY`, `RESEND_AUDIENCE_ID`, `PUBLIC_SITE_URL`) and ensure `.env` is git-ignored (no secrets committed)
- [X] T010 Create `landing/src/pages/index.astro` shell using `BaseLayout` (sections filled by US1/US2)
- [X] T011 [P] Add `landing/vitest.config.ts` and `landing/playwright.config.ts` with test directories wired

**Checkpoint**: Foundation ready — user stories can begin.

---

## Phase 3: User Story 1 - Join the waitlist (Priority: P1) 🎯 MVP

**Goal**: A visitor submits their email and it lands in the owned Resend Audience with a clear
success state; invalid/duplicate/no-JS/bot cases handled per the endpoint contract.

**Independent Test**: Submit a valid email → stored in the Resend Audience + success shown; invalid/
empty → inline validation; double-submit → idempotent success; JS disabled → still works.

### Tests for User Story 1 (write first, must FAIL) ⚠️

- [X] T012 [P] [US1] Unit test `validateEmail` (valid/invalid/empty/overlong/whitespace) in `landing/tests/unit/validateEmail.test.ts`
- [X] T013 [P] [US1] Unit test `honeypot` (empty→proceed, non-empty→silent success) in `landing/tests/unit/honeypot.test.ts`
- [X] T014 [P] [US1] Unit test `waitlist` payload mapping with Resend SDK mocked (create→ok, already-exists→success, 5xx→provider error) in `landing/tests/unit/waitlist.test.ts`
- [X] T015 [P] [US1] E2E test waitlist (happy submit, **no-JS** submit, duplicate→success, invalid→inline error) in `landing/tests/e2e/waitlist.spec.ts`

### Implementation for User Story 1

- [X] T016 [P] [US1] Implement pure `validateEmail` in `landing/src/lib/validateEmail.ts`
- [X] T017 [P] [US1] Implement pure `honeypot` check in `landing/src/lib/honeypot.ts`
- [X] T018 [US1] Implement `waitlist.ts` (build Resend payload, `contacts.create`, map already-exists→success, 5xx→provider error; never log email/secret) in `landing/src/lib/waitlist.ts` (depends on T016)
- [X] T019 [US1] Implement `POST /api/waitlist` endpoint with `export const prerender = false`, handling form-encoded + JSON, honeypot, validation, and contract responses in `landing/src/pages/api/waitlist.ts` (depends on T016–T018)
- [X] T020 [US1] Implement `WaitlistForm.astro` (native `method="POST"` form that works without JS + a small JS enhancement for inline states + hidden honeypot) in `landing/src/components/WaitlistForm.astro`
- [X] T021 [US1] Wire `WaitlistForm` and `?waitlist=success|invalid|error` server states into `landing/src/pages/index.astro`
- [X] T022 [US1] Security check: confirm no `RESEND_*` secret or raw email reaches the client bundle (`grep -r re_ landing/dist` clean) and nothing is logged

**Checkpoint**: Waitlist works end-to-end (JS + no-JS), idempotent, no secrets leaked — MVP shippable.

---

## Phase 4: User Story 2 - Understand the product and its value (Priority: P1)

**Goal**: From the page alone a visitor grasps what Sorrel is, the MCP context-bloat pain, the hero
(token-cost analyzer), that it's coming soon, and that it's not affiliated with Anthropic.

**Independent Test**: A first-time reader can state what it is, the core benefit, and that it's
pre-launch — from the page alone; on mobile the CTA is reachable.

### Tests for User Story 2 (write first, must FAIL) ⚠️

- [X] T023 [P] [US2] E2E test landing content (value prop + token-cost angle + waitlist CTA + "not affiliated with Anthropic" present; CTA reachable at mobile viewport) in `landing/tests/e2e/landing-content.spec.ts`

### Implementation for User Story 2

- [X] T024 [P] [US2] Implement `Hero.astro` (value prop + "measure your MCP context cost" angle + primary CTA + coming-soon framing) in `landing/src/components/Hero.astro`
- [X] T025 [P] [US2] Implement `Disclaimer.astro` ("not affiliated with Anthropic") in `landing/src/components/Disclaimer.astro`
- [X] T026 [P] [US2] Implement `Terminal.astro` decorative monospace/green framing in `landing/src/components/Terminal.astro`
- [X] T027 [US2] Compose `Hero` + value prop + coming-soon + `Disclaimer` into `landing/src/pages/index.astro` (depends on T024–T026)
- [X] T028 [US2] Ensure responsive layout + reachable mobile CTA in `landing/src/styles/theme.css` and components

**Checkpoint**: Landing communicates the product and is fully responsive.

---

## Phase 5: User Story 3 - Read the launch article (SEO/RRSS) (Priority: P2)

**Goal**: An extensible articles section with one launch article rendering at its own URL with valid
SEO/OG metadata, a sitemap entry, and a waitlist CTA; adding an article = one content file.

**Independent Test**: The article renders with correct SEO + OG, is linked from `/articles`, has a
CTA; adding a new Markdown file makes it appear in the index with no code change.

### Tests for User Story 3 (write first, must FAIL) ⚠️

- [X] T029 [P] [US3] E2E test article (renders at its URL with title/description/canonical/OG, has waitlist CTA, appears in `/articles`; a second content file appears with no code change) in `landing/tests/e2e/articles.spec.ts`

### Implementation for User Story 3

- [X] T030 [P] [US3] Define `articles` content collection Zod schema (title, description, publishDate, slug, ogImage, draft, canonical) in `landing/src/content/config.ts`
- [X] T031 [P] [US3] Implement `ArticleLayout.astro` (per-frontmatter SEO/OG, structured data, waitlist CTA) in `landing/src/layouts/ArticleLayout.astro`
- [X] T032 [P] [US3] Implement `ArticleCard.astro` (title, description, date, link) in `landing/src/components/ArticleCard.astro`
- [X] T033 [US3] Write launch article *"How much context are your MCP servers wasting?"* (draft:false, CTA) in `landing/src/content/articles/how-much-context-your-mcp-servers-waste.md`
- [X] T034 [US3] Implement articles index (non-draft, newest first) in `landing/src/pages/articles/index.astro` (depends on T030, T032)
- [X] T035 [US3] Implement article page in `landing/src/pages/articles/[...slug].astro` using `ArticleLayout` (depends on T030, T031)
- [X] T036 [US3] Add hand-made OG cards (landing + launch article) in `landing/public/og/`

**Checkpoint**: All three stories independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: CI, performance budgets, security scan, and docs.

- [X] T037 [P] Add GitHub Actions CI in `.github/workflows/landing.yml`: `astro check` + eslint, vitest, `astro build`, **gitleaks over tree + full history**, Lighthouse CI
- [X] T038 [P] Add `landing/lighthouserc.json` budgets (≥95 Performance/SEO/Accessibility on landing + article)
- [X] T039 Run Lighthouse locally on landing + article and meet ≥95 (SC-004); fix regressions
- [X] T040 [P] Add `landing/README.md` (local dev + env + deploy notes from quickstart.md)
- [X] T041 Run `quickstart.md` verification end-to-end (all acceptance scenarios)
- [X] T042 Final `gitleaks detect` over tree + history; confirm 0 secrets/PII (SC-006)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies.
- **Foundational (Phase 2)**: depends on Setup — **blocks all user stories**.
- **User Stories (Phase 3–5)**: depend on Foundational. US1 → US2 share `index.astro` (sequential on
  that file); US3 is independent of US1/US2. With staff, US3 can run parallel to US1/US2.
- **Polish (Phase 6)**: depends on the desired stories being complete.

### Within Each User Story

- Tests written and FAILING before implementation.
- Pure libs (`validateEmail`, `honeypot`) before `waitlist.ts` before the endpoint before the form.
- Components before the page that composes them.

### Parallel Opportunities

- Setup: T003, T004, T005, T006 in parallel.
- Foundational: T008, T009, T011 in parallel (after T007).
- US1 tests T012–T015 in parallel; impl T016 + T017 in parallel.
- US2 components T024–T026 in parallel.
- US3 T030–T032 in parallel.
- Polish: T037, T038, T040 in parallel.

---

## Parallel Example: User Story 1

```bash
# Tests first (all fail):
Task: "Unit test validateEmail in landing/tests/unit/validateEmail.test.ts"
Task: "Unit test honeypot in landing/tests/unit/honeypot.test.ts"
Task: "Unit test waitlist mapping in landing/tests/unit/waitlist.test.ts"
Task: "E2E waitlist (happy/no-JS/duplicate/invalid) in landing/tests/e2e/waitlist.spec.ts"

# Then pure libs in parallel:
Task: "Implement validateEmail in landing/src/lib/validateEmail.ts"
Task: "Implement honeypot in landing/src/lib/honeypot.ts"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1 Setup → 2. Phase 2 Foundational → 3. Phase 3 US1 (waitlist).
4. **STOP and VALIDATE**: submit lands in the Resend Audience, no-JS works, no secrets leaked.
5. Deploy preview to Vercel and demo. This alone validates demand (the point of the phase).

### Incremental Delivery

- US1 (waitlist) → US2 (clear positioning) → US3 (SEO/RRSS article). Each is an independent increment.

---

## Notes

- [P] = different files, no dependencies. [Story] label maps each task to a spec user story.
- Verify tests fail before implementing (Principle V).
- Never commit secrets; provider keys via env only; CI scans tree + history (Principle II).
- Commit after each task or logical group; English commit messages; GitHub noreply identity.
