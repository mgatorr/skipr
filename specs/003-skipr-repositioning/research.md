# Phase 0 Research: skipr Repositioning

Most decisions were settled in the repositioning brainstorm (`docs/superpowers/specs/2026-05-31-...`)
and `docs/design.md`. The remaining items are implementation choices for re-messaging the landing.

## 1. i18n — Astro built-in routing, English default, Spanish secondary

- **Decision**: Use Astro's **built-in i18n** in `astro.config.mjs`: `i18n: { defaultLocale: 'en',
  locales: ['en','es'], routing: { prefixDefaultLocale: false } }`. English stays at `/` (no prefix,
  ships first); Spanish at `/es/`. UI strings live in `src/i18n/ui.ts` (`en` + `es` dictionaries) with
  a small `t(locale)` helper. `BaseLayout` sets `<html lang>` and emits `hreflang` alternates.
- **Rationale**: No extra dependency; static prerender per locale keeps the Lighthouse budget; English
  is shippable alone, Spanish added as a second locale per the constitution's language policy.
- **Alternatives considered**: `astro-i18next`/heavy i18n libs (unnecessary for a small landing);
  prefixing the default locale (worse URLs for the primary English audience).

## 2. Rebrand Sorrel → skipr (zero residual)

- **Decision**: Systematic rename across copy, `BaseLayout` brand/footer, `package.json` name, root +
  `landing/` READMEs, and `specs/001` references. Regenerate image assets and **rename the files**
  (`assets/sorrel-hero.png` → `assets/skipr-hero.png`, OG cards). A CI/grep check asserts **zero**
  `Sorrel`/`Cockpit` strings remain in user-visible code or committed assets.
- **Rationale**: SC-004 demands no residual brand; renaming asset files avoids stale references.
- **Note**: `docs/`, the repo dir name (`cockpit`), and historical specs keep their names where they
  are history; the rule targets user-visible brand + the landing.

## 3. New hero + OG visual — the guided flow, not the token dashboard

- **Decision**: Rewrite `make-hero.mjs` (and OG) to depict the **guided five-step flow / "feel
  powerful"** in the same dark-terminal premium style (sharp → PNG). The token-cost dashboard hero is
  removed.
- **Rationale**: FR-005 — the hero must convey "build real software, guided", not token observability.

## 4. New sections as Astro components

- **Decision**: `AntiBlackBox.astro` (explicit contrast with Lovable/Base44: you keep code/repo/
  control, and you learn) and `HowItWorks.astro` (5 steps: setup → spec → code → GitHub → deploy, on
  Supabase + Vercel + GitHub + Claude Code). `Hero.astro` rewritten. All strings via `src/i18n/ui.ts`.
- **Rationale**: FR-001/002/003; keeps the component model and the static budget.

## 5. Articles — rewrite + retire

- **Decision**: New `from-no-code-to-software-you-own.md` (launch article, CTA). The token-cost
  article gets `draft: true` so it leaves the index/sitemap but stays in history (FR-006).
- **Rationale**: Carry the new narrative; don't dilute with the old angle.

## 6. Tests

- **Decision**: Update existing e2e copy assertions to skipr; add e2e checks for the anti-black-box
  section, the 5-step section, an **i18n smoke** (`/` English, `/es/` Spanish, `lang`/`hreflang`), and
  a **brand-residue** check (no "Sorrel"/"Cockpit" in the built `dist/`). Unit logic (validateEmail/
  honeypot/waitlist) is unchanged.
- **Rationale**: Principle V + SC-004/006.

## Resolved unknowns

| Unknown | Resolution |
|---------|------------|
| i18n approach | Astro built-in, `en` default no-prefix + `/es/`, strings in `src/i18n/ui.ts` |
| Brand residue | grep/CI check for zero `Sorrel`/`Cockpit`; rename asset files |
| Hero visual | regenerate to guided-flow (sharp) |
| New sections | `AntiBlackBox` + `HowItWorks` components |
| Old article | `draft: true` (retired, kept in history) |
| Repo rename | `gh repo rename sorrel skipr` during implement |
