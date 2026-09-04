# skipr (repo working name: cockpit)

Spec-Driven Development with Spec Kit. Read `docs/design.md` (rationale) and
`docs/constitution.md` (non-negotiable principles, v1.1.0) before contributing. Brand shown to users
is **skipr**; the repo dir keeps the `cockpit` working name.

## Estado (2026-09-04)

| Layer | Status |
|---|---|
| **Product surface** | **This GitHub repo** — README (carta) + `docs/novice-guide.md` + vendored `skills/setup-harness/` |
| **Astro landing** (`landing/`) | **Parked / abandoned for now** — do not ship new landing copy as the product; PR #1 closed without merge. Existing Vercel (skipr.dev) left alone until an explicit teardown ask. |
| **Personal site** | Embedding under mariogarridotorres.com is **later** — product docs live on GitHub first |

**Product promise:** skipr helps creators and builders **escape AI complexity** — lean CLI + harness + Claude Code, terminal taught not hidden. L0/L1 usable now; L2 later.

Older framing (desktop app that hides the terminal for non-technical founders / anti-Lovable) is **superseded** for the current track. Historical design docs under `docs/` and `specs/` remain for context.

Active feature: **006-github-carta** (GitHub README as product presentation). Prior: `003-skipr-repositioning` / `005-landing-escape-complexity` (landing track parked).

## Guardrails (constitution v1.1.0)

- **Security/secrets (non-negotiable)**: never commit secrets; provider keys via env only; CI secret
  scan (gitleaks) over tree **and** history; file/config edits are backup-first.
- **Test-first for real logic**: waitlist/landing logic stays test-first if touched; carta/docs/skills
  changes do not require `pnpm test` in `landing/`.
- **Frictionless & friendly**: audience is non-technical creators/builders — teach the terminal, never a black box.
- **Neutral branding & language**: brand is **skipr**; not affiliated with Anthropic; no "Claude" in
  the product name. **English primary** for repo artifacts; Spanish secondary mirrors OK. Commits in English.
- **Phase discipline**: GitHub-first carta before reopening marketing site or personal-site embedding.
