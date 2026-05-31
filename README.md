<div align="center">

<img src="./assets/skipr-hero.png" alt="skipr — build real software with AI, and actually own it." width="880">

<br/><br/>

[![status](https://img.shields.io/badge/status-pre--launch-3ddc84?style=flat-square)](#roadmap)
[![landing](https://img.shields.io/badge/landing-live-3ddc84?style=flat-square)](./landing)
[![stack](https://img.shields.io/badge/landing-Astro%20%2B%20Vercel-111?style=flat-square)](./landing)
[![product](https://img.shields.io/badge/product-desktop%20app%20(planned)-00ADD8?style=flat-square)](./docs/design.md)
[![not affiliated](https://img.shields.io/badge/not%20affiliated%20with-Anthropic-9aa?style=flat-square)](#a-note-on-branding)

</div>

---

**skipr** is the friendly way for **non-technical founders to build real software with AI — and
actually own it.** It guides you from idea to a shipped app — Claude Code, your files on your
machine, your GitHub, your deploy — **without living in the terminal**, and **without the black box**
of no-code tools.

```text
$ skipr new my-app
✓ Claude Code ready — no terminal
✓ spec written from your idea
✓ building — your files, your machine
✓ pushed to your GitHub
✓ deployed — Vercel + Supabase
your app is live — and it's yours.
```

## The problem

No-code tools (Lovable, Base44) get you moving fast, then trap you: the **80/20 wall**, a **black
box** you can't see into, and **lock-in**. What actually predicts success isn't how well you prompt —
it's whether you **understand and control** what's built. skipr gives you that, without the terminal.

## Not a black box

| With skipr | No-code black boxes |
|---|---|
| The code lives on your machine | Code you can't see or move |
| Your own GitHub repo | Locked into their platform |
| A deploy you understand | A black-box deploy |
| You learn and level up | You stay dependent |

## How it works

Five guided steps, no terminal required, on a stack the AI knows well:

**setup → spec → code → GitHub → deploy** &nbsp;·&nbsp; Claude Code · GitHub · Supabase · Vercel

## Repository layout

```text
.
├── landing/                       # Astro + Vercel marketing site + waitlist (LIVE, en + es)
│   ├── src/                       #   hero, anti-black-box, how-it-works, waitlist, articles
│   └── supabase/migrations/       #   owned waitlist table (INSERT-only RLS)
├── docs/
│   ├── design.md                  # the "why": research, audience, differentiator, vision
│   ├── constitution.md            # non-negotiable principles (v1.1.0)
│   └── superpowers/specs/         # the repositioning design doc
└── specs/
    ├── 001-landing-waitlist/      # the landing (built)
    └── 003-skipr-repositioning/   # re-message + rebrand to skipr (this work)
```

Built with **Spec-Driven Development** (Spec Kit): every feature is `spec → plan → tasks →
implement`, gated by the constitution.

## The landing (live)

Static-first **Astro + Vercel**, dark terminal aesthetic, **English + Spanish**:

- **Waitlist** in our **own Supabase** table (INSERT-only RLS) — works with **JavaScript disabled**,
  honeypot anti-spam, idempotent.
- **Articles** as a content collection; full SEO/OG/sitemap.
- **Lighthouse ≥ 95**; no secrets committed (gitleaks in CI).

```bash
cd landing
pnpm install
cp .env.example .env      # SUPABASE_* or WAITLIST_DRY_RUN=1
pnpm dev                  # http://localhost:4321
pnpm test && pnpm test:e2e
```

See [`landing/README.md`](./landing/README.md) for details.

## Roadmap

- [x] Landing repositioned to skipr (message, anti-black-box, en + es)
- [ ] Validate demand (collect signups; watch real non-technical founders)
- [ ] MVP — guided desktop app: setup → spec → code → GitHub → deploy
- [ ] Expand: more of the flow, cross-tool (Codex, Gemini CLI)

## A note on branding

**skipr is an independent project and is not affiliated with Anthropic.** "Claude" and "Claude Code"
are trademarks of their respective owner.

---

<div align="center"><sub>Built for founders who want to own what they build.</sub></div>
