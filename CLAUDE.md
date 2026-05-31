# Sorrel (repo working name: cockpit)

Spec-Driven Development with Spec Kit. Read `docs/design.md` (rationale) and
`docs/constitution.md` (non-negotiable principles) before contributing. Brand name shown to users
is **Sorrel**; the repo and the `002-cockpit-mvp` spec keep the `cockpit` working name for now.

Build order: `specs/001-landing-waitlist` (validate demand — Astro + Vercel landing) **first**,
then `specs/002-cockpit-mvp` (the Go + Charm product).

<!-- SPECKIT START -->
Active feature: **001-landing-waitlist**
Plan: `specs/001-landing-waitlist/plan.md`
<!-- SPECKIT END -->

## Guardrails (from the constitution)

- **Security/secrets (non-negotiable)**: never commit secrets; provider keys via env vars only;
  CI secret scan (gitleaks) over tree **and** history; config edits are backup-first.
- **Test-first for real logic**: email validation, honeypot, and the Resend payload mapping are
  built test-first (Vitest); e2e via Playwright.
- **Neutral branding**: not affiliated with Anthropic; no "Claude" in the product name; English
  everywhere; token-savings framed as measured estimates.
- **Performance**: Lighthouse ≥ 95 (Performance, SEO, Accessibility) on landing + article.
- **Phase discipline**: ship the validation phase before any product code.
