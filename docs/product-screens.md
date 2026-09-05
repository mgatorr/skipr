> **HISTORICAL / SUPERSEDED (2026-09).** The current product is **GitHub-first escape-complexity**: terminal taught + Claude Code + harness (`setup-harness`). This document describes an earlier desktop / no-terminal (or Spec Kit / Cockpit) pivot and **must not be read as current truth**. Start at the [root README](../README.md), [novice-guide.md](./novice-guide.md), and [ARCHIVE.md](./ARCHIVE.md).


# skipr — Product Screens (reference for the app)

**Date:** 2026-06-01
**Status:** Product reference for the desktop app. Not built yet — this maps the screens to design
and to plan the MVP. Source vision: `docs/design.md` and
`docs/superpowers/specs/2026-05-31-skipr-repositioning-design.md`.

> skipr is a friendly **desktop app** for **non-technical founders** to build real, owned software
> with AI (Claude Code): idea → deployed app, **without the terminal**, keeping their code, their
> GitHub repo and their deploy. The differentiator is the **anti-black-box**: ownership + control +
> learning. Every screen must make a non-technical user feel **powerful and guided, never overwhelmed**.

## Design principles (apply to every screen)

- Plain language, **zero terminal jargon** (no `cd`, `git`, `pwd`, no raw error codes).
- **Progressive disclosure** — never dump everything; reveal depth on demand.
- **Ownership made visible** ("your files", "your repo", "your deploy", "this is yours").
- Calm, confident, a little rebellious ("graduate from no-code"). Friendly, not childish.
- English primary, Spanish secondary. Light + dark per the brand.
- Same design system / branding as the landing.

## Onboarding (first run)

1. **Welcome + connect Claude** — value recap, sign-in, calm tone.
2. **Guided setup** — install/verify Claude Code + prerequisites, **no terminal**: a friendly
   checklist with statuses (ready / in progress / action needed).
3. **Connect GitHub** — so the user owns their repo; explained simply.

## The cockpit (daily use)

4. **Your apps (Home)** — grid of projects + "New app", each with a status (idea / building / live).
5. **Idea → plan (spec)** — user types their idea in plain words; skipr turns it into a clear,
   **approve-before-you-build** plan (Spec-Driven). User edits / approves.
6. **Build workspace** *(the hero screen)* — conversation(s) with the agent in **tabs**; a navigable
   **file tree** + open-file **tabs** with preview/diff; the agent's actions in plain language;
   **Approve / Revert** controls. Never a black box. (Desktop-IDE ergonomics, de-jargoned.)
7. **Skills** — context-aware suggestions based on the user's goal; an **audit** of which skills are
   used / unused; toggle on/off; friendly explanations.
8. **Connections (MCP)** — add/manage services (GitHub, Supabase, etc.), on/off, guided setup,
   **secrets handled safely**.
9. **Model & cost** — which model you're on and whether a cheaper/better one fits; **token spend per
   skill / per MCP / total**, with budget + alerts.
10. **Deploy** — publish to GitHub + Vercel + Supabase, guided, with progress and a "your app is
    live" success state + the link. Emphasize it's all theirs.
11. **Settings** — account, language (EN/ES), connections, theme.

## MVP slice (build first)

Onboarding **1‑2‑3** + **5 (idea → spec)** + **6 (build workspace, minimal)** + **10 (deploy)**.
Skills (7), Connections/MCP (8), and Model & cost (9) come after the MVP validates.

## States to design per screen

For each screen, design the primary state plus one meaningful secondary state where relevant:
empty / loading / error / success. The build workspace (6) keeps file-tree + tabs + conversation
consistent across the app.
