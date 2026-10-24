# skipr

**Current product:** GitHub-first escape from AI complexity.
Lean path: terminal taught + Claude Code CLI + `setup-harness` + short guides.
L0/L1 usable now.

Start at the [root README](./README.md), [docs/novice-guide.md](./docs/novice-guide.md),
and [`examples/photo-trip`](./examples/photo-trip/).
Vendored skills: [`skills/setup-harness/`](./skills/setup-harness/) and [`skills/fdd/`](./skills/fdd/).

Default method: **FDD · Fast Driven Development**. Follow [`skills/fdd/SKILL.md`](./skills/fdd/SKILL.md).
Older eras are on the tag `era-spec-kit`. See [docs/ARCHIVE.md](./docs/ARCHIVE.md).

Brand shown to users is **skipr**.

@.skipr/rules.md

## Language

- **Canonical product language = English** (README, docs, skills, commits, PR bodies, file names).
- **Working conversation language** is configurable: `Working language:` in a project `CLAUDE.md`, or `SKIPR_LOCALE` / `LANG`. Default **`en`**.
- Policy: [`docs/language.md`](./docs/language.md).
- Match the human's language in chat when they write in another language. Keep repo artifacts in English.

## Guardrails

- **Security/secrets:** never commit secrets; provider keys via env only; CI secret scan (gitleaks) over tree and history; file and config edits are backup-first.
- **Test-first for real logic:** installer OS gate, checkers, and any file or config edit that can lose work.
- **Frictionless and friendly:** audience is non-technical creators and builders — teach the terminal, never a black box.
- **Neutral branding:** brand is **skipr**; not affiliated with Anthropic; no "Claude" in the product name.
