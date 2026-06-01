# skipr (repo working name: cockpit)

Spec-Driven Development with Spec Kit. Read `docs/design.md` (rationale) and
`docs/constitution.md` (non-negotiable principles, v1.1.0) before contributing. Brand shown to users
is **skipr** (domain skipr.dev); the repo dir keeps the `cockpit` working name.

**Product:** skipr is a friendly desktop app for **non-technical founders to build real software
with AI and own it** — guided idea → spec → code → GitHub → deploy, without the terminal, and not a
black box like no-code tools. (Repositioned from the old "Cockpit/Sorrel" token-cost concept.)

Build order: `specs/001-landing-waitlist` (the landing, built) → `specs/003-skipr-repositioning`
(re-message + rebrand the landing to skipr) → product MVP (Phase 2, to be re-ideated;
`specs/002-cockpit-mvp` is SUPERSEDED).

<!-- SPECKIT START -->
Active feature: **003-skipr-repositioning**
Plan: `specs/003-skipr-repositioning/plan.md`
<!-- SPECKIT END -->

## Guardrails (constitution v1.1.0)

- **Security/secrets (non-negotiable)**: never commit secrets; provider keys via env only; CI secret
  scan (gitleaks) over tree **and** history; file/config edits are backup-first.
- **Test-first for real logic**: the waitlist logic (email validation, honeypot, Neon insert) is
  built test-first (Vitest); e2e via Playwright.
- **Frictionless & friendly**: the product audience is non-technical — no terminal, never a black box.
- **Neutral branding & language**: brand is **skipr**; not affiliated with Anthropic; no "Claude" in
  the product name. **English primary, Spanish secondary** (i18n en + es). Repo artifacts/commits in English.
- **Performance**: Lighthouse ≥ 95 (Performance, SEO, Accessibility) on landing + article.
- **Phase discipline**: validate (landing) before building the product.
