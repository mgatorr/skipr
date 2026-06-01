# skipr — Product MVP: kickoff brief

You are picking up **skipr** to build the first MVP of the actual product. Read this
whole brief, then START by reading `docs/design.md` and `docs/constitution.md`. Do not
write product code until there is an approved spec.

## What skipr is

A friendly **desktop app** that lets **non-technical founders build real software with AI
— and actually own it**. It guides them from idea → spec → code → GitHub → deploy, in
plain language, **without ever using the terminal**, and **without the black box** of
no-code tools (Lovable, Base44). The engine underneath is **Claude Code**. The user keeps
their code on their machine, their own GitHub repo, their own deploy — and learns as they
build. Tagline: "Build real software with AI — and actually own it."

## Current state (already done)

- **Landing is LIVE at https://skipr.dev** (validating demand): Astro + Vercel, EN/ES,
  waitlist storing real leads in Neon Postgres. Repo: `github.com/mgatorr/skipr` (local
  working dir name is `cockpit`; user-facing brand is always **skipr**).
- Positioning, vision and principles are written. The product (this MVP) is **Phase 2**.

## Your mission

Design and build the **MVP of the skipr desktop app**: a guided, no-terminal experience
that takes a non-technical founder through a real, end-to-end **vertical slice** of the
flow and leaves them owning what they built.

## Non-negotiable principles (from `docs/constitution.md`, v1.1.0)

- **Frictionless & friendly:** audience is non-technical. **No terminal, ever. Never a
  black box.** The user understands and controls what's built and learns along the way.
- **Ownership:** real, readable code in the user's own GitHub repo and their own deploy —
  no lock-in.
- **Neutral branding & language:** brand is **skipr**; **not affiliated with Anthropic**;
  no "Claude" in the product name. **English is primary, Spanish secondary** (i18n en+es).
  Repo artifacts and commit messages are in English.
- **Security:** never commit secrets; provider keys/tokens via env or the OS keychain only.
- **Test-first** for real logic.
- **Phase discipline:** ship the smallest slice that proves the full flow end-to-end before
  adding features.

## The flow to enable (5 guided steps)

`setup → spec → build → own (GitHub) → ship (deploy)`. Default guided stack the product
sets up for the user: **Claude Code + GitHub + Supabase + Vercel** (sensible defaults, not
lock-in — the user can change them).

## How to work: Spec-Driven Development (Spec Kit)

This repo uses Spec Kit. Follow the workflow and DO NOT skip it:
`/speckit-constitution` (already done) → `/speckit-specify` → `/speckit-plan` →
`/speckit-tasks` → `/speckit-implement`. Begin with a **brainstorming pass** to scope the
MVP before any spec. New work goes under `specs/00X-skipr-mvp` (note: `specs/002-cockpit-mvp`
is SUPERSEDED — do not reuse it; treat it as historical).

## Open decisions to make in brainstorming/spec (don't assume these)

1. **Product form & tech stack.** It's a GUI desktop app that orchestrates Claude Code
   under the hood with zero terminal exposure. Choose the framework (e.g. Tauri or Electron
   + a web frontend) and justify it. The visual language must match the landing's
   risograph-zine aesthetic (cream paper, riso inks, Bricolage/Newsreader/IBM Plex Mono).
2. **MVP scope = the minimal vertical slice** that demonstrates value end-to-end. A strong
   candidate: idea → plain-language spec the user approves → Claude Code builds real code →
   it lands in the user's own GitHub repo. Deploy can be the next slice. Decide and justify.
3. **Invisible Claude Code integration:** install/auth/run it without the user touching a
   shell; sensible handling of API auth and the user's GitHub auth.
4. **Onboarding** that gets a non-technical user productive in ~2 minutes.

## Resources in the repo

- `docs/design.md` — the why: research, audience, differentiator, vision.
- `docs/constitution.md` — non-negotiable principles (v1.1.0).
- `docs/product-screens.md` — the product's screens.
- `docs/superpowers/specs/2026-05-31-skipr-repositioning-design.md` — the repositioning.
- `landing/` — reference for brand, tone, i18n and the visual system (theme + fonts).
- `docs/design-assets/app-screens/` — **Claude Design "App Screens" mockups** (risograph-zine
  UI for the desktop app): JSX components, `app-ui.css` design system, a runnable
  `index.html` preview and screenshots. This is the visual starting point for the MVP.

## First steps

1. Read `docs/design.md` and `docs/constitution.md`.
2. Run a **brainstorming** session to scope the MVP: product form, stack, the minimal
   vertical slice, the invisible-Claude-Code mechanics, and the top risks.
3. Present 2–3 approaches with trade-offs and a recommendation; get the owner's approval.
4. Write the spec (`/speckit-specify` → `specs/00X-skipr-mvp`), then `/speckit-plan` and
   `/speckit-tasks`.
5. Implement the slice test-first, with zero terminal exposure and consistent skipr brand.

## Definition of done (MVP)

A non-technical founder can, inside skipr and in plain language: describe an idea → get a
spec they understand and approve → watch real, readable code get built → have it in **their
own GitHub repo** → (ideally) deploy it — **without ever opening a terminal**, and they
understand what they now own.
