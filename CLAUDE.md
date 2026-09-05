# skipr (repo working name: cockpit)

Spec-Driven Development with Spec Kit. Read `docs/design.md` (rationale) and
`docs/constitution.md` (non-negotiable principles, v1.1.0) before contributing. Brand shown to users
is **skipr**; the repo dir keeps the `cockpit` working name.

## Status (2026-09-04)

| Layer | Status |
|---|---1|
| **Product surface** | **This GitHub repo** — README (carta) + `docs/novice-guide.md` + vendored `skills/setup-harness/` |
| **skipr.dev** (`landing/`) | **GitHub redirect stub** — static page + redirects to this repo (Astro waitlist abandoned) |
| **Personal site** | Embedding under mariogarridotorres.com is **later** — product docs live on GitHub first |

**Product promise:** skipr helps creators and builders **escape AI complexity** — lean CLI + harness + Claude Code, terminal taught not hidden. L0/L1 usable now; optional L2 tracks in `docs/l2/`.

Older framing (desktop app that hides the terminal for non-technical founders / anti-Lovable) is **superseded** for the current track. Historical design docs under `docs/` and `specs/` remain for context.

Merged: **#2** GitHub carta, **#3** domain stub. Active follow-up: public readiness / language policy.

## Language

- **Canonical product language = English** (README, docs, skills, commits, PR bodies).
- **Working conversation language** with the human is configurable: set `Working language: es` (or `en`, …) in a project `CLAUDE.md`, or `SKIPR_LOCALE` / `LANG`. Default **`en`**.
- Full policy: [`docs/language.md`](./docs/language.md). Spanish novice guide stays secondary under `docs/es/`.

For *this* repo's agent sessions with Mario: prefer Spanish in chat replies when he writes in Spanish; keep commits and repo artifacts in English.

## Guardrails (constitution v1.1.0)

- **Security/secrets (non-negotiable)**: never commit secrets; provider keys via env only; CI secret
  scan (gitleaks) over tree **and** history; file/config edits are backup-first.
- **Test-first for real logic**: waitlist leftover under `landing/src` stays test-first if touched;
  stub/docs/skills changes do not require `pnm test` in `landing/`.
- **Frictionless & friendly**: audience is non-technical creators/builders — teach the terminal, never a black box.
- **Neutral branding**: brand is **skipr**; not affiliated with Anthropic; no "Claude" in the product name.
- **Phase discipine**: GitHub-first carta before reopening a full marketing site or personal-site embedding.
