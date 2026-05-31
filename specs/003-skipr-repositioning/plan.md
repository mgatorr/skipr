# Implementation Plan: skipr Repositioning — Re-message the Landing

**Branch**: `003-skipr-repositioning` | **Date**: 2026-05-31 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/003-skipr-repositioning/spec.md`

## Summary

Re-message and rebrand the already-built landing (`landing/`, Astro + Vercel, Supabase waitlist) from
"Sorrel / token-cost" to **skipr — build real software with AI, and actually own it**. Replace the
hero/value-prop, add an **anti-black-box** section (vs Lovable/Base44) and a **"how it works"**
five-step section (setup → spec → code → GitHub → deploy), rebrand everything to **skipr** (copy,
assets, README, package, repo), regenerate the OG + hero images to a guided-flow visual, rewrite the
launch article ("from no-code to software you own") and retire the token-cost one, and add **i18n**
(English primary, Spanish secondary). The waitlist, progressive enhancement, disclaimer, aesthetic,
and quality budgets are preserved. This is a re-message, not a rebuild.

## Technical Context

**Language/Version**: TypeScript 5.x on Node.js 20+ (unchanged)

**Primary Dependencies**: Astro 5 (`@astrojs/vercel`, `@astrojs/sitemap`, **built-in i18n
routing**), `@supabase/supabase-js`, `sharp` (OG/hero generation); Vitest + Playwright + `@lhci/cli`

**Storage**: Owned Supabase `waitlist` table (unchanged). Articles are Markdown content files.

**Testing**: Vitest (existing pure logic unchanged), Playwright (update copy assertions; add
anti-black-box + how-it-works presence + i18n smoke + zero-residual-brand checks), Lighthouse CI

**Target Platform**: Vercel (static + one on-demand endpoint), responsive mobile + desktop

**Project Type**: Web application (existing `landing/`); this feature modifies it

**Performance Goals**: Lighthouse ≥ 95 (Performance, SEO, Accessibility) on landing + article, both
locales

**Constraints**: no secrets in repo/bundle; form works without JS; **zero residual "Sorrel"/
"Cockpit"** anywhere user-visible or in assets; English ships first, Spanish second

**Scale/Scope**: 1 landing (en + es), 1 launch article, retire 1 article, new hero/OG, repo rename

## Constitution Check

*GATE: Must pass before Phase 0. Re-check after Phase 1. (Constitution v1.1.0.)*

| Principle | Status | How this plan satisfies it |
|-----------|--------|----------------------------|
| I. Validated Pain First | ✅ PASS | The landing validates the repositioned value prop (build-real-software-and-own-it) before the product. |
| II. Security & Privacy First | ✅ PASS | `SUPABASE_URL`/`SUPABASE_ANON_KEY` via env only; INSERT-only RLS; gitleaks tree+history; no secret in client bundle. |
| III. Frictionless, Friendly Setup | ➖ N/A | This is the marketing landing, not the product. |
| IV. Open-Core Honesty | ➖ N/A | Landing is marketing; no license logic. |
| V. Test-First for Real Logic | ✅ PASS | Real logic (validateEmail/honeypot/waitlist) is unchanged and already test-covered; new work is content/UI, covered by e2e presence + i18n smoke + brand-residue checks. |
| VI. Phase Discipline | ✅ PASS | Still the validation phase; ships nothing of the product platform. |
| VII. Honest, Neutral Branding & Language | ✅ PASS | This feature *implements* the policy: brand skipr, not affiliated with Anthropic, no "Claude" in the name; English primary + Spanish secondary. |

**Result**: No violations → Complexity Tracking empty.

## Project Structure

### Documentation (this feature)

```text
specs/003-skipr-repositioning/
├── plan.md, research.md, data-model.md, quickstart.md
├── contracts/   (i18n-routing.md, brand-consistency.md, waitlist-endpoint.md[unchanged])
└── tasks.md     (/speckit-tasks)
```

### Source Code (changes under landing/)

```text
landing/
├── astro.config.mjs                 # add i18n: defaultLocale 'en', locales ['en','es'], prefixDefaultLocale:false
├── src/
│   ├── i18n/
│   │   └── ui.ts                     # NEW: translation strings (en, es) + locale helper
│   ├── components/
│   │   ├── Hero.astro                # REWRITE: "Build real software with AI — and actually own it"
│   │   ├── AntiBlackBox.astro        # NEW: contrast vs Lovable/Base44 (you own code/repo/control)
│   │   ├── HowItWorks.astro          # NEW: 5 steps setup→spec→code→GitHub→deploy
│   │   ├── Disclaimer.astro          # keep (not affiliated)
│   │   ├── WaitlistForm.astro        # keep (Supabase); strings via i18n
│   │   └── Terminal.astro            # keep; new guided-flow content
│   ├── layouts/
│   │   └── BaseLayout.astro          # rebrand skipr; lang + hreflang per locale
│   ├── pages/
│   │   ├── index.astro               # EN landing (default locale, no prefix)
│   │   ├── es/index.astro            # ES landing
│   │   └── articles/...              # index + [...slug] (locale-aware links)
│   ├── content/articles/
│   │   ├── from-no-code-to-software-you-own.md          # NEW launch article
│   │   └── how-much-context-your-mcp-servers-waste.md   # set draft: true (retired)
│   ├── scripts/
│   │   ├── make-hero.mjs             # REGEN: skipr guided-flow hero (not token dashboard)
│   │   └── make-og.mjs               # REGEN: skipr OG cards
│   └── styles/theme.css              # keep terminal-dark; minor additions
├── public/og/                        # regenerated skipr cards
└── tests/{unit,e2e}/                 # update copy; add anti-black-box/how-it-works/i18n/brand-residue

README.md (root) + landing/README.md  # rebrand skipr
assets/skipr-hero.png                  # regenerated (rename from sorrel-hero.png)
```

**Structure Decision**: Modify the existing static-first Astro site. Use Astro's **built-in i18n
routing** (`en` as default with no URL prefix, `es` under `/es/`) — no extra dependency. Strings live
in `src/i18n/ui.ts`. Only `/api/waitlist` stays on-demand; everything else prerendered, so the
Lighthouse budget and the no-JS waitlist are preserved.

## Complexity Tracking

> No constitution violations — section intentionally empty.
