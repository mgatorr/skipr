---
description: "Task list for feature 003 — skipr repositioning (re-message the landing)"
---

# Tasks: skipr Repositioning — Re-message the Landing

**Input**: Design documents from `specs/003-skipr-repositioning/`

**Tests**: INCLUDED (constitution Principle V). For UI/content, tests are acceptance/e2e presence;
for real logic (unchanged waitlist) the existing unit tests are reused. Write tests before the
matching implementation.

**Organization**: by user story. All paths under `landing/` unless noted.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: different files, no dependency on incomplete tasks.

---

## Phase 1: Setup

- [X] T001 Configure Astro i18n in `landing/astro.config.mjs` (`defaultLocale: 'en'`, `locales: ['en','es']`, `routing.prefixDefaultLocale: false`)
- [X] T002 [P] Create `landing/src/i18n/ui.ts` with `en`/`es` string dictionaries (same keys) and a `t(locale)` helper (es falls back to en)
- [X] T003 [P] Add a locale helper for locale-aware paths + a locale switcher util in `landing/src/i18n/`

---

## Phase 2: Foundational (Blocking)

**⚠️ Must complete before user stories.**

- [X] T004 Rebrand `landing/src/layouts/BaseLayout.astro` to **skipr** (brand, footer, default title/description) and add `<html lang>` + `hreflang` alternates (en/es/x-default) per locale
- [X] T005 [P] Update `landing/package.json` name → `skipr-landing` and `landing/.env.example` comments to skipr (no behavior change)

**Checkpoint**: i18n + skipr shell ready.

---

## Phase 3: User Story 1 — Understand skipr / anti-black-box (P1) 🎯 MVP

**Goal**: hero communicates "build real software with AI — and actually own it" and the anti-black-box
differentiator; brand is skipr with zero residual.

**Independent Test**: a first-time reader (ex-Lovable) states what skipr is, that they keep
ownership/control (not a black box); brand reads skipr; no "Sorrel"/"Cockpit" anywhere.

### Tests (write first)

- [X] T006 [P] [US1] E2E: hero value prop + no-terminal/guided framing + anti-black-box (Lovable/Base44; keep code/repo/control) + "not affiliated" disclaimer + mobile CTA, in `landing/tests/e2e/landing-content.spec.ts`
- [X] T007 [P] [US1] E2E brand-residue: built `dist/` contains no `Sorrel`/`Cockpit`, in `landing/tests/e2e/brand.spec.ts`

### Implementation

- [X] T008 [US1] Rewrite `landing/src/components/Hero.astro` (headline "Build real software with AI — and actually own it" + sub; strings via i18n; guided framing; CTA)
- [X] T009 [P] [US1] Create `landing/src/components/AntiBlackBox.astro` (explicit contrast vs Lovable/Base44: you keep the code, the repo, the control, and you learn)
- [X] T010 [US1] Compose `Hero` + `AntiBlackBox` into `landing/src/pages/index.astro`
- [X] T011 [P] [US1] Rewrite `landing/scripts/make-hero.mjs` → skipr guided-flow hero; output `assets/skipr-hero.png` and remove `assets/sorrel-hero.png`
- [X] T012 [P] [US1] Rewrite `landing/scripts/make-og.mjs` → skipr OG cards
- [X] T013 [US1] Regenerate assets (`pnpm hero && pnpm og`) and point README/OG meta to `skipr-hero.png` (depends on T011, T012)
- [X] T014 [US1] Rebrand all remaining user-visible copy Sorrel→skipr across `landing/src`; confirm zero residual

**Checkpoint**: English repositioned landing message is live and on-brand — MVP shippable.

---

## Phase 4: User Story 2 — How it works (P1)

**Goal**: the 5 guided steps (setup → spec → code → GitHub → deploy) are clear and convey ownership.

**Independent Test**: a reader can describe the five steps in order after one read.

- [X] T015 [P] [US2] E2E: the 5 steps present and in order, in `landing/tests/e2e/how-it-works.spec.ts`
- [X] T016 [US2] Create `landing/src/components/HowItWorks.astro` (5 steps, ownership framing, no terminal; strings via i18n)
- [X] T017 [US2] Add `HowItWorks` to `landing/src/pages/index.astro`

**Checkpoint**: the "how" makes "build real software" believable.

---

## Phase 5: User Story 3 — Waitlist (P1)

**Goal**: the waitlist keeps working; only its copy is localized.

**Independent Test**: valid email → success; invalid → inline; no-JS → still works (unchanged).

- [X] T018 [P] [US3] E2E waitlist (happy/no-JS/invalid) with new copy, update `landing/tests/e2e/waitlist.spec.ts`
- [X] T019 [US3] Localize `landing/src/components/WaitlistForm.astro` strings via i18n (keep Supabase endpoint + behavior)

**Checkpoint**: lead capture intact under the new message.

---

## Phase 6: User Story 4 — Launch article (P2)

**Goal**: new launch article in the new narrative; token-cost article retired.

**Independent Test**: new article renders with SEO/OG + CTA, in the index; token-cost article gone.

- [X] T020 [P] [US4] E2E article: "from no-code to software you own" renders + SEO/OG + CTA; token-cost article not indexed, update `landing/tests/e2e/articles.spec.ts`
- [X] T021 [US4] Write `landing/src/content/articles/from-no-code-to-software-you-own.md` (draft:false, CTA, ogImage)
- [X] T022 [US4] Set `landing/src/content/articles/how-much-context-your-mcp-servers-waste.md` → `draft: true` (retire)
- [X] T023 [P] [US4] Add an OG card for the new article in `landing/scripts/make-og.mjs` + regenerate

**Checkpoint**: content carries the new narrative.

---

## Phase 7: User Story 5 — Spanish locale (P3)

**Goal**: the landing is available in Spanish (secondary); English already shipped.

**Independent Test**: `/` English, `/es/` Spanish; `lang`/`hreflang` correct; switch keeps equivalent page.

- [X] T024 [P] [US5] E2E i18n smoke (`/` en, `/es/` es, `lang`/`hreflang`), in `landing/tests/e2e/i18n.spec.ts`
- [X] T025 [US5] Fill the Spanish (`es`) dictionary in `landing/src/i18n/ui.ts` for hero, anti-black-box, how-it-works, waitlist, disclaimer, nav
- [X] T026 [US5] Create `landing/src/pages/es/index.astro` (Spanish landing reusing the components at `es` locale)
- [X] T027 [US5] Add a locale switcher in the header (`BaseLayout`) and make article links locale-aware

**Checkpoint**: en + es both live.

---

## Phase 8: Polish & Cross-Cutting

- [X] T028 [P] Rebrand `README.md` (root) and `landing/README.md` to skipr
- [X] T029 [P] Update `landing/lighthouserc.json` to assert `/`, `/es/`, and the article; run `pnpm lighthouse` ≥ 95
- [X] T030 Verify unit tests (validateEmail/honeypot/waitlist unchanged) still pass; adjust any copy refs
- [X] T031 Run the full suite green: `pnpm check`, `pnpm lint`, `pnpm test`, `pnpm test:e2e`, `pnpm build`
- [X] T032 [P] Rename the GitHub repo `sorrel` → `skipr` (`gh repo rename skipr`) and update the git remote
- [X] T033 Final checks: `grep -riE 'sorrel|cockpit' landing/dist` clean; no secrets in `dist/client`; `gitleaks detect` clean (tree + history)
- [X] T034 Run `quickstart.md` verification end-to-end (all acceptance scenarios, both locales)

---

## Dependencies & Execution Order

- **Setup (P1)** → **Foundational (P2, blocks all)** → **US1 → US2 → US3** (share `index.astro`,
  sequential on that file) → **US4** (independent) → **US5** (needs the en components from US1/US2) →
  **Polish**.
- US4 can run in parallel with US2/US3; US5 depends on the components existing (US1/US2) and the `es`
  strings (T025).

### Parallel opportunities

- Setup: T002, T003. Foundational: T005 (after T004).
- US1: tests T006/T007; impl T009, T011, T012 in parallel.
- Polish: T028, T029, T032.

---

## Implementation Strategy

### MVP first (US1 only)

Setup → Foundational → **US1** delivers the repositioned **English** landing (new message +
anti-black-box + skipr brand, zero residual). **Stop & validate**, deploy preview. Then US2 (how it
works), US3 (waitlist copy), US4 (article), US5 (Spanish), Polish.

## Notes

- [P] = different files, no dependency. Verify tests fail before implementing UI where applicable.
- Never commit secrets; provider keys via env; CI scans tree + history. English commits.
- Brand rule: zero residual `Sorrel`/`Cockpit` in user-visible code or committed assets (SC-004).
