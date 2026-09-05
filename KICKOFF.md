> **HISTORICAL / SUPERSEDED (2026-09).** The current product is **GitHub-first escape-complexity**: terminal taught + Claude Code + harness (`setup-harness`). This document describes an earlier Cockpit / Spec Kit kickoff and **must not be read as current truth**. Start at the [root README](./README.md), [docs/novice-guide.md](./docs/novice-guide.md), and [docs/ARCHIVE.md](./docs/ARCHIVE.md).


# Cockpit — Kickoff

This repo is set up for **Spec-Driven Development with Spec Kit**. Everything is documented:

- **Why / full design:** [`docs/design.md`](docs/design.md)
- **Constitution (non-negotiable principles):** [`docs/constitution.md`](docs/constitution.md) (canonical; Spec Kit also keeps a working copy at `.specify/memory/constitution.md`)
- **Specs (build in this order):**
  1. [`specs/001-landing-waitlist/spec.md`](specs/001-landing-waitlist/spec.md) — **BUILD FIRST**: landing + email waitlist + one launch article (Astro + Vercel). Validate demand, collect a launch list.
  2. [`specs/002-cockpit-mvp/spec.md`](specs/002-cockpit-mvp/spec.md) — the product: free Go CLI installer + paid Charm TUI (hero = per-server MCP token-cost analyzer).

The active feature (`/.specify/feature.json`) is **001-landing-waitlist**.

---

## ▶ Paste this prompt into a NEW conversation (opened in this repo)

> We're building **Cockpit** with Spec-Driven Development (Spec Kit). Start by reading
> `docs/design.md` (the full rationale), `docs/constitution.md` (the principles), and the
> active spec `specs/001-landing-waitlist/spec.md`. We are building **feature 001
> (landing + waitlist + first article) FIRST** to validate demand before the product — do NOT
> start the Go product (`002-cockpit-mvp`) yet.
>
> Confirm you've absorbed the design and constitution, then run the Spec Kit flow for
> feature 001: `/speckit-plan`, then `/speckit-tasks`, then `/speckit-implement` — pausing for
> my approval between phases. Honor the constitution (security/secrets, no platform creep,
> test-first for real logic, neutral branding / not affiliated with Anthropic). Keep the
> landing in the product's dark "terminal" aesthetic (monospace, green accent), match
> Lighthouse ≥ 95, and make sure the waitlist stores emails in a list we own with no secrets
> committed.
>
> Before planning, ask me only the decisions still open: (a) confirm **Astro + Vercel**;
> (b) the **email/waitlist provider** (Buttondown / Resend Audiences / ConvertKit); (c) the
> **working product name** (Cockpit / Helm / Conductor) and domain. Then proceed.

---

## Open decisions to resolve at kickoff
- **Landing stack:** Astro + Vercel (recommended) — confirm.
- **Waitlist provider:** own the list (Buttondown / Resend Audiences / ConvertKit).
- **Product name + domain:** Cockpit / Helm / Conductor (+ buy the domain).
- **Store (later, for the product):** Polar or Lemon Squeezy; launch price ~$29 one-time.

## Reminders
- This is a commercial product line; the **CLI installer is open-core (MIT)**, the **TUI is
  paid**. The landing is marketing (no license logic).
- Reuse assets/approach from the public `claude-mcp-stack` repo (catalog `registry.json`,
  hero/GIF aesthetic) — it is also the top-of-funnel.
- Commit identity: GitHub noreply; English everywhere; secret scan before any push.
