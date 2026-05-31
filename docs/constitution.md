<!--
Sync Impact Report
- Version: (none) → 1.0.0  (initial adoption, new project)
- Added sections: Core Principles I–VII; Commercial & Licensing; Development Workflow & Quality Gates; Governance
- Templates: plan/spec/tasks templates are generic and compatible; no edits required
- Deferred TODOs: none
-->

# Cockpit Constitution

Cockpit is a friendly control layer for piloting Claude Code: a free, open-source CLI
installer plus a paid TUI dashboard (Go + Charm). These principles are non-negotiable and
govern every contribution. The approved design and rationale live in `docs/design.md`; this
constitution outranks it where they conflict.

## Core Principles

### I. Validated Pain First

Every feature must trace to a real, documented user pain (see `docs/design.md` §2). The MVP
hero — a per-server MCP **token-cost analyzer** — exists because context bloat (30–40% wasted)
is the most-cited, unaddressed Claude Code pain. We do not ship features we cannot tie to a
pain or a sale.

### II. Security & Privacy First (NON-NEGOTIABLE)

- Never write a user's secret anywhere except their own client config; never log or print
  secret values.
- Never commit secrets or personal data; fixtures and examples are placeholder-only; a secret
  scan runs in CI over the working tree and git history.
- Config edits are **backup-first**: write a timestamped backup before any modification and
  never clobber unrelated keys.

### III. Single Binary, Frictionless Install

Cockpit ships as a self-contained Go binary with no runtime dependency. Install must be
trivial on macOS, Linux, and Windows. This is both a UX promise and a moat against the
documented setup pain.

### IV. Open-Core Honesty

The CLI installer is open-source (MIT) and genuinely useful on its own — it is the funnel,
not crippleware. The paid TUI adds visual management and the token analyzer. License
enforcement is light by design: optimize the honest-buyer experience, not anti-piracy DRM.

### V. Test-First for Real Logic (NON-NEGOTIABLE)

Config merge, catalog parsing, the stdio probe/measurement, and license checks are built
test-first (failing test → minimal code). A merge test MUST prove unrelated config keys
survive unchanged. TUI behavior is covered with Charm `teatest` snapshots. CI runs vet, lint,
tests, cross-platform build, and the secret scan.

### VI. Phase Discipline (No Premature Platform)

Cockpit grows in phases (MVP → skills/hooks → Spec-Kit flows → SDD guardrails). Each phase is
independently sellable. We validate the MVP with real buyers before expanding. Building the
platform before validation is forbidden.

### VII. Honest, Neutral Branding

Cockpit is **not affiliated with Anthropic**; the product name avoids "Claude". Marketing
claims (e.g. token savings) are framed as measured estimates with a stated method. All
artifacts and commit messages are in English.

## Commercial & Licensing

- Pricing: one-time purchase for the Pro TUI; each major version is repurchased at a
  discount. No surprise subscriptions for the MVP.
- The free CLI is MIT and public; the Pro TUI is commercial and may live in a private repo.
- Public commits use a privacy-preserving Git identity (GitHub noreply), name without email.

## Development Workflow & Quality Gates

- Spec-Driven Development via Spec Kit: spec → plan → tasks → implement, artifacts under
  `specs/<NNN-feature>/`.
- A change merges only when: tests pass, lint/vet clean, cross-platform build succeeds, the
  secret scan is clean (tree + history), and relevant docs are updated.
- Small, frequent, English commits.

## Governance

This constitution supersedes other practices for this repository. Amendments require a
documented reason, a semantic version bump (MAJOR: principle removal/redefinition; MINOR: new
principle/expanded guidance; PATCH: clarification), and propagation to dependent docs. Every
PR verifies adherence; deviations must be justified in writing or rejected.

**Version**: 1.0.0 | **Ratified**: 2026-05-31 | **Last Amended**: 2026-05-31
