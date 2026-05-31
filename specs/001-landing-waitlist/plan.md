# Implementation Plan: Landing + Waitlist + First Article (Sorrel)

**Branch**: `001-landing-waitlist` | **Date**: 2026-05-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-landing-waitlist/spec.md`

## Summary

Ship a static-first marketing site for **Sorrel** (working repo name: `cockpit`) that (1) explains
the product and its hero — a per-server MCP token-cost analyzer — in a dark "terminal" aesthetic,
(2) captures emails into an **owned** list — our own **Supabase** table with an INSERT-only RLS
policy — working even with JavaScript disabled and protected against bots, and (3) hosts an
extensible **articles** section seeded with one launch article, with full SEO/social metadata.
Built with **Astro + Vercel**: pages and articles are statically prerendered for Lighthouse ≥ 95;
a single on-demand endpoint (`/api/waitlist`) performs the server-side Supabase insert so no key
ever reaches the browser or the repo.

## Technical Context

**Language/Version**: TypeScript 5.x on Node.js 20+

**Primary Dependencies**: Astro 5 (`@astrojs/vercel`, `@astrojs/sitemap`),
`@supabase/supabase-js`, Zod (bundled with Astro content collections),
Vitest + Playwright + `@lhci/cli` (dev/test)

**Storage**: Our own **Supabase** Postgres table `public.waitlist` (INSERT-only RLS). No leads in
the repo. Articles are Markdown/MDX content files under version control.

**Testing**: Vitest (unit — email validation, honeypot, Supabase insert mapping), Playwright (e2e —
form submit happy/no-JS/duplicate paths, SEO meta presence), Lighthouse CI (perf/SEO/a11y budgets)

**Target Platform**: Vercel (static assets + one Node serverless function for `/api/waitlist`);
modern evergreen browsers, fully responsive mobile + desktop

**Project Type**: Web application (Astro frontend + a single serverless endpoint), isolated in
`landing/` so it does not collide with the future Go product at the repo root (`002-cockpit-mvp`)

**Performance Goals**: Lighthouse ≥ 95 for Performance, SEO, Accessibility on the landing and the
article; first paint fast enough that a visitor can join the waitlist in < 15 s (SC-001)

**Constraints**: No secrets in repo or history (env vars only); form must work without JS
(progressive enhancement); 0 silent lead losses; no `Claude` in the product name; English only

**Scale/Scope**: One landing page, one articles index, N article pages (1 at launch), one waitlist
endpoint, one shared layout/theme. Designed so a new article = one new content file (FR-009/SC-005).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | How this plan satisfies it |
|-----------|--------|----------------------------|
| I. Validated Pain First | ✅ PASS | The entire feature exists to validate demand and collect a launch list before building the product. |
| II. Security & Privacy First (NON-NEGOTIABLE) | ✅ PASS | `SUPABASE_URL` / `SUPABASE_ANON_KEY` only via env; never logged; never committed. Anon key + INSERT-only RLS means a leaked key cannot read or delete the list. CI runs `gitleaks` over tree **and** history. |
| III. Single Binary, Frictionless Install | ➖ N/A | Marketing site, not the Go binary. Noted; no action. |
| IV. Open-Core Honesty | ➖ N/A | Landing is marketing only — contains no license logic or crippleware. |
| V. Test-First for Real Logic (NON-NEGOTIABLE) | ✅ PASS | Email validation, honeypot check, and the Supabase insert mapping are built test-first with Vitest (failing test → minimal code). Playwright covers the form + SEO contracts. |
| VI. Phase Discipline (No Premature Platform) | ✅ PASS | This is Phase −1 validation; it ships nothing of the product platform. |
| VII. Honest, Neutral Branding | ✅ PASS | Brand = **Sorrel** (no "Claude"); a visible "not affiliated with Anthropic" disclaimer; all copy/commits in English; token-savings framed as a measured estimate. |

**Result**: No violations → Complexity Tracking left empty.

## Project Structure

### Documentation (this feature)

```text
specs/001-landing-waitlist/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (waitlist endpoint + article schema)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
landing/                          # Astro site (this feature, isolated from the future Go product)
├── astro.config.mjs              # Astro 5 + @astrojs/vercel + @astrojs/sitemap, site URL
├── package.json
├── tsconfig.json
├── lighthouserc.json             # Lighthouse CI budgets (≥95 perf/seo/a11y)
├── public/
│   ├── robots.txt                # allow + sitemap reference
│   └── og/                       # hand-made social cards (landing + launch article)
├── src/
│   ├── components/
│   │   ├── Hero.astro            # value prop + token-cost angle + primary CTA
│   │   ├── WaitlistForm.astro    # POSTs to /api/waitlist; JS-enhanced inline states
│   │   ├── ArticleCard.astro
│   │   ├── Disclaimer.astro      # "not affiliated with Anthropic"
│   │   └── Terminal.astro        # decorative terminal/monospace framing
│   ├── content/
│   │   ├── config.ts             # content collection schema (articles)
│   │   └── articles/
│   │       └── how-much-context-your-mcp-servers-waste.md   # launch article
│   ├── layouts/
│   │   ├── BaseLayout.astro      # <head> SEO/OG/canonical, theme, header/footer
│   │   └── ArticleLayout.astro   # article wrapper + CTA + structured data
│   ├── lib/
│   │   ├── validateEmail.ts      # pure, unit-tested
│   │   ├── honeypot.ts           # pure, unit-tested
│   │   └── waitlist.ts           # Supabase insert (anon key) — boundary-tested
│   ├── pages/
│   │   ├── index.astro           # landing (prerendered)
│   │   ├── articles/
│   │   │   ├── index.astro       # blog index (prerendered)
│   │   │   └── [...slug].astro    # per-article pages (prerendered from collection)
│   │   └── api/
│   │       └── waitlist.ts       # POST endpoint, `export const prerender = false`
│   └── styles/
│       └── theme.css             # dark terminal tokens: bg, mono font, green accent
└── tests/
    ├── unit/                     # Vitest: validateEmail, honeypot, waitlist mapping
    └── e2e/                      # Playwright: submit happy/no-JS/duplicate, SEO meta, OG

.github/workflows/
└── landing.yml                   # CI: astro check + eslint, vitest, build, gitleaks, lighthouse
```

**Structure Decision**: Web application isolated under `landing/`. The site is static-first; only
`src/pages/api/waitlist.ts` is rendered on demand (`prerender = false`) so the Supabase key stays
server-side. Articles are an Astro **content collection**, so adding an article is a single content
file with no code change (FR-009/SC-005). The Go product (`002-cockpit-mvp`) will later live at the
repo root without touching `landing/`.

## Complexity Tracking

> No constitution violations — section intentionally empty.
