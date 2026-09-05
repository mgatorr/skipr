# skipr (repo working name: cockpit)

**Current product (read this first):** GitHub-first **escape AI complexity**.
Lean path: terminal taught (not hidden) + Claude Code CLI + `setup-harness`
+ short guides. L0/L1 usable now.

Start at the [root README](./README.md), [docs/novice-guide.md](./docs/novice-guide.md),
and [`examples/photo-trip`](./examples/photo-trip/) (step 0 fail/pass, no Claude yet).
Vendored skill: [`skills/setup-harness/`](./skills/setup-harness/).

`docs/design.md` and `docs/constitution.md` are **historical / superseded**.
They describe earlier desktop / no-terminal / Spec Kit / waitlist eras. Do
**not** treat them as current product truth — see [docs/ARCHIVE.md](./docs/ARCHIVE.md)
and the banners at the top of those files.

Brand shown to users is **skipr**; the repo dir keeps the `cockpit` working name.

## Status (2026-09-05)

| Layer | Status |
|---|---|
| **Product surface** | **This GitHub repo** — README (carta) + `docs/novice-guide.md` + vendored `skills/setup-harness/` + `examples/photo-trip` |
| **skipr.dev** (`landing/`) | **GitHub redirect stub** — static `landing/public/` only (Astro waitlist source removed) |
| **Personal site** | Embedding under mariogarridotorres.com is **later** — product docs live on GitHub first |

**Product promise:** skipr helps creators and builders **escape AI complexity** — lean CLI + harness + Claude Code, terminal taught not hidden. L0/L1 usable now; optional L2 tracks in `docs/l2/`.

Older framing (desktop app that hides the terminal for non-technical founders / anti-Lovable) is **superseded** for the current track.

Merged: **#2** GitHub carta, **#3** domain stub. Active follow-up: public readiness / language policy.

## Language

- **Canonical product language = English** (README, docs, skills, commits, PR bodies).
- **Working conversation language** with the human is configurable: set `Working language: es` (or `en`, …) in a project `CLAUDE.md`, or `SKIPR_LOCALE` / `LANG`. Default **`en`**.
- Full policy: [`docs/language.md`](./docs/language.md). Spanish novice guide stays secondary under `docs/es/`.

For *this* repo's agent sessions with Mario: prefer Spanish in chat replies when he writes in Spanish; keep commits and repo artifacts in English.

## Guardrails (current track)

- **Security/secrets (non-negotiable)**: never commit secrets; provider keys via env only; CI secret
  scan (gitleaks) over tree **and** history; file/config edits are backup-first.
- **Test-first for real logic**: installer OS gate, checkers, and any file/config edit that can lose
  work. The Astro waitlist under `landing/src` is gone; the static stub does not require `pnm test`.
- **Frictionless & friendly**: audience is non-technical creators/builders — teach the terminal, never a black box.
- **Neutral branding**: brand is **skipr**; not affiliated with Anthropic; no "Claude" in the product name.
- **Phase discipline**: GitHub-first carta before reopening a full marketing site or personal-site embedding.
