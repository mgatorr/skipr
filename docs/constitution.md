> **HISTORICAL / SUPERSEDED (2026-09).** The current product is **GitHub-first escape-complexity**: terminal taught + Claude Code + harness (`setup-harness`). This document describes an earlier desktop / no-terminal (or Spec Kit / Cockpit) pivot and **must not be read as current truth**. Start at the [root README](../README.md), [novice-guide.md](./novice-guide.md), and [ARCHIVE.md](./ARCHIVE.md).


<!--
Sync Impact Report
- Version: 1.0.0 → 1.1.0  (repositioning: Cockpit → skipr; guidance updated across principles)
- Product renamed: Cockpit → skipr
- Modified principles (concept kept, guidance updated to the repositioned product):
  - I Validated Pain First: hero changed from "MCP token-cost analyzer" to "friendly, guided
    building of real, owned software for non-technical founders (anti-black-box vs Lovable/Base44)"
  - III Single Binary → "Frictionless, Friendly Setup": generalized beyond a Go binary; the
    audience is non-technical, so no terminal / no prior dev knowledge required
  - IV Open-Core Honesty: free tier + paid Pro (guided/active capabilities), not CLI+TUI
  - V Test-First: generalized to the real logic of the current stack (no Charm/stdio specifics)
  - VI Phase Discipline: phases updated to validate (landing) → MVP (build-and-own) → expand
  - VII Branding: brand is "skipr"; ADDED a Language policy (English primary, Spanish secondary)
- Added sections: Language policy (within Principle VII)
- Removed sections: none (no principle added or removed)
- Templates: plan/spec/tasks templates are generic and remain compatible; no edits required
- Deferred TODOs: none
-->

# skipr Constitution

skipr is the friendly way for non-technical founders to build real software with AI and own it:
guided from idea to a shipped app (Claude Code + Spec Kit, your files, your GitHub, your deploy)
without living in the terminal — and without the black box of no-code tools. These principles are
non-negotiable and govern every contribution. The approved design and rationale live in
`docs/design.md`; this constitution outranks it where they conflict.

## Core Principles

### I. Validated Pain First

Every feature must trace to a real, documented user pain (see `docs/design.md`). The hero is the
**friendly, guided building of real, owned software for non-technical founders** — the
anti-black-box alternative to no-code tools (Lovable/Base44): you keep your code, your GitHub, your
deploy, and you learn as you go. Token-cost awareness is **one feature, not the hero**. We do not
ship features we cannot tie to a pain or a sale.

### II. Security & Privacy First (NON-NEGOTIABLE)

- Never write a user's secret anywhere except their own config/project; never log or print secret
  values.
- Never commit secrets or personal data; fixtures and examples are placeholder-only; a secret scan
  runs in CI over the working tree and git history.
- Edits to a user's files or config are **backup-first**: write a timestamped backup before any
  modification and never clobber unrelated content.

### III. Frictionless, Friendly Setup (NON-NEGOTIABLE)

> **Superseded guidance:** “MUST NOT require the terminal” belonged to the desktop/no-terminal pivot. **Current L0 product teaches the terminal** (Ghostty or yours) with Claude Code + harness. See [ARCHIVE.md](./ARCHIVE.md) and the root README.

skipr's audience is non-technical. Setup and everyday use MUST NOT require the terminal or prior
developer knowledge. Install must be trivial on macOS, Windows, and Linux. Every flow keeps the user
**in control and informed** — their files, their repo, their deploy — and never becomes a black box.

### IV. Open-Core Honesty

The free tier is genuinely useful on its own — it is the funnel, not crippleware. Pro adds the
guided, active capabilities. License enforcement is light by design: optimize the honest-buyer
experience, not anti-piracy DRM.

### V. Test-First for Real Logic (NON-NEGOTIABLE)

Real logic — file/config edits, the decision points of guided flows, integrations, and anything
that can lose a user's work — is built test-first (failing test → minimal code). A file/config edit
test MUST prove unrelated content survives unchanged. CI runs lint, tests, build, and the secret
scan.

### VI. Phase Discipline (No Premature Platform)

skipr grows in phases, each validated before the next: **validate demand** (landing + waitlist) →
**MVP** (a guided build-and-own slice) → **expand** (more of the flow, cross-tool, active guidance).
Building the platform before validation is forbidden. The MVP is steered by watching real
non-technical users.

### VII. Honest, Neutral Branding & Language

- The brand is **skipr**; it is **not affiliated with Anthropic** and the product name avoids
  "Claude".
- Marketing claims (e.g. "build real software", token savings) are honest and, where measured,
  framed as estimates with a stated method.
- **Language:** English is the **primary** language for the product and the landing; Spanish is the
  **secondary** locale (i18n: `en` + `es`). All repo artifacts and commit messages are in English.

## Commercial & Licensing

- Pricing: a free tier plus a one-time purchase for Pro; each major version is repurchased at a
  discount. No surprise subscriptions for the MVP.
- The free tier is public; Pro is commercial and may live in a private repo.
- Public commits use a privacy-preserving Git identity (GitHub noreply), name without email.

## Development Workflow & Quality Gates

- Spec-Driven Development via Spec Kit: spec → plan → tasks → implement, artifacts under
  `specs/<NNN-feature>/`.
- A change merges only when: tests pass, lint clean, build succeeds, the secret scan is clean
  (tree + history), and relevant docs are updated.
- Small, frequent, English commits.

## Governance

This constitution supersedes other practices for this repository. Amendments require a documented
reason, a semantic version bump (MAJOR: principle removal/redefinition; MINOR: new
principle/expanded guidance; PATCH: clarification), and propagation to dependent docs. Every PR
verifies adherence; deviations must be justified in writing or rejected.

**Version**: 1.1.0 | **Ratified**: 2026-05-31 | **Last Amended**: 2026-05-31
