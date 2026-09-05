> **HISTORICAL / SUPERSEDED (2026-09).** The current product is **GitHub-first escape-complexity**: terminal taught + Claude Code + harness (`setup-harness`). This document describes an earlier desktop / no-terminal (or Spec Kit / Cockpit) pivot and **must not be read as current truth**. Start at the [root README](../README.md), [novice-guide.md](./novice-guide.md), and [ARCHIVE.md](./ARCHIVE.md).


# skipr — Design & Rationale

**Date:** 2026-05-31
**Status:** Approved design (repositioned from "Cockpit/Sorrel"). Ready for Spec-Driven Development.
**Name:** skipr (domain **skipr.dev**, owned). Neutral brand; **not affiliated with Anthropic**
(the product name avoids "Claude").

> This is the **why** behind skipr. The original framing (a Go+Charm TUI whose hero was an MCP
> token-cost analyzer) was invalidated by research and replaced. The full repositioning rationale
> and sources live in `docs/superpowers/specs/2026-05-31-skipr-repositioning-design.md`. We build in
> phases: **validate first** (`specs/001-landing-waitlist`, the landing), then the **MVP** of the
> product. This constitution-aligned doc outranks none of the constitution.

## 1. One-liner

**skipr — build real software with AI, and actually own it.** The skipper that takes the helm so you
can fly: skipr guides a non-technical founder from idea to a shipped, *real* app — Claude Code
guided, files on their machine, their GitHub, their deploy — without living in the terminal. It
teaches you to fish; it is not a black box.

## 2. The problem (research-backed)

- **The #1 blocker to getting value from AI coding is the "harness," not the model, the setup, or
  tokens.** Failures are workflow: the agent loses context, drifts from spec, duplicates code,
  ignores conventions. *"Not a model problem, a configuration problem — the fix is in the harness"*
  (HumanLayer). The predictor of success is **comprehension**, not technical background.
- **Non-experts hit walls:** the "80/20 wall" (the last mile — edge cases, security, integration —
  needs the very skills they were promised they wouldn't need) and the "month-3 wall" (feature
  silos → duplicated logic, cascading breakage). 40–62% of AI-generated code has security flaws.
  Result: **disillusionment**, drifting back to no-code.
- **It's a big, funded market:** vibe-coding raised ~**$8B VC in 2025**; non-technical founders
  already pay (~$350/mo of subs) and reach paying customers in 4–6 weeks. The least experienced gain
  the most from AI.

**The gap:** solutions to the harness exist but are **for experts/teams** (Spec Kit, Kiro, BMAD;
Galileo/Braintrust/Helicone). **Nobody does it friendly for the non-technical solo builder.**

## 3. Who it's for

**Primary:** the **non-technical solo founder** who has already tried no-code / vibe-coding tools
(Lovable, Base44), shipped their first little things, and now **wants more — real software they own
and control** — but for whom the terminal is a wall (doesn't know `cd`, `pwd`, permissions, how to
drive Claude Code). Real validation personas: **Jose** and **Goñi**.

**Not for:** terminal-native developers (they don't need it) and people who want a black box that
hides the code (that's no-code's job, and it's why those projects stall).

## 4. The differentiator (the heart)

**Control + ownership + learning — the anti-black-box.** Lovable/Base44 hand you a fish in a black
box; skipr teaches you to fish without the pain of the rod. The emotional payload matters: the
non-technical founder wants the **dignity of having built and understood it** — to *feel like a
builder*. This is also what the research says actually works (comprehension), so it's strategy and
substance at once. The landing names the contrast with Lovable/Base44 explicitly.

## 5. Product vision (to validate, not build yet)

A **desktop app (GUI)** — "like the Claude app, but much better, and for building real software" —
that wraps the real developer flow and removes the terminal:

1. **Guided setup** — install/run Claude Code without touching a terminal.
2. **Idea → spec** — guided Spec-Driven Development (Spec Kit) so the agent doesn't drift and the
   founder understands what's being built.
3. **Spec → code** — drive Claude Code with guardrails, in plain language; the file tree and tabs
   are visible — never a black box.
4. **Code → GitHub** — their repo, on their machine, explained ("this is GitHub, this is a commit").
5. **GitHub → deploy** — a real, owned deploy they understand.

**Default guided stack:** **Supabase + Vercel + GitHub + Claude Code** — generous free tiers,
one-click deploy, and so well-known that the AI guides them well.

**Cross-tool, later:** the guidance is tool-agnostic — Claude Code first, then Codex / Gemini CLI.
**Token-cost awareness** ("don't waste it") is one feature, never the hero.

## 6. Form factor — desktop GUI

A desktop GUI (Tauri preferred: small binary, OS webview, terminal-dark look in CSS). A TUI was
rejected: the audience does not live in a terminal, and "windows of conversations / file tree /
tabs" plus a non-technical audience point to a GUI. The free CLI/core can still exist as a funnel
and shared engine.

## 7. Monetization & go-to-market

- **Open-core:** a free tier (the funnel) + **Pro** (one-time purchase, majors at a discount). Pro
  is where active guidance/automation lives.
- **GTM:** the landing validates demand and collects a waitlist; first users are Jose/Goñi and
  similar founders. Content/article angle: *"from no-code to software you actually own."*

## 8. Phases (validate first)

- **Phase −1 — Landing + waitlist (`specs/001-landing-waitlist`):** validate demand, collect a list.
- **Phase 0 — MVP:** a guided build-and-own slice (likely: guided setup + first guided
  spec→code→GitHub→deploy). Built right after the foundations, kept **small**, steered by watching
  real non-technical users. Its own ideation precedes its first spec.
- **Phase 1+ — Expand:** more of the flow, cross-tool, active guidance (token budget, model choice).

## 9. Language

English-first for the product and landing; **Spanish as the secondary locale** (i18n: `en` + `es`).
Repo artifacts and commit messages stay in English.

## 10. Competition & why we fit the gap

- **Anthropic's own desktop app** targets non-technical users — but it's a general Claude Code
  surface, not a guided "build real software and own it" flow with a default stack and learning.
- **Conductor / Crystal / Nimbalyst / Opcode** compete on multi-agent orchestration for developers,
  not on friendly build-and-own for non-experts.
- **Lovable / Base44** are the black box skipr defines itself against.

Our defensible wedge: **friendly + ownership + guided full flow + cross-tool**, for the non-expert.

## 11. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Non-technical users are hard to monetize / churn | Target the *serious* solo founder who wants to ship for real (already pays for subs) |
| Ambitious to build (a guided client ≈ IDE with training wheels) | Phase discipline: validate with the landing + Jose/Goñi before building |
| Hiding complexity recreates the month-3 wall | skipr helps you **understand and control**, never hides — comprehension is the product |
| Active space (spec/guardrails) | Differentiate on friendly-for-non-experts + ownership + cross-tool; execution quality |
| Platform owner (Anthropic) expands | Stay cross-tool and own the "build-and-own for non-experts" niche, not a generic wrapper |

## 12. Decision log (the "why")

- **Repositioned from token-cost analyzer → build-real-software-and-own-it:** research showed the
  token angle is a power-user/me-too space; the real, underserved pain is the non-expert harness.
- **Audience = non-technical solo founder (ex-Lovable):** large, funded, underserved; the user's own
  first validators (Jose, Goñi).
- **Anti-black-box is the heart:** control + ownership + learning; the emotional and the empirical
  align (comprehension predicts success).
- **GUI desktop, not TUI:** the audience isn't terminal-native.
- **Validate before building:** landing first; MVP only after demand shows.

## 13. Sources

- https://beginnersinai.org/why-ai-coding-agents-fail/
- https://codingwithvibe.com/vibe-coding-success-rate-non-developer/
- https://appbuilderguides.com/news/vibe-coding-disillusionment-2026/
- https://www.businessofapps.com/insights/what-vibe-coding-gets-right-and-where-engineers-take-over/
- https://learn.builtthisweek.com/ai-coding-tools/the-5-best-ai-coding-tools-for-non-technical-founders-in-2026
- https://www.augmentcode.com/tools/best-spec-driven-development-tools
- https://nimbalyst.com/blog/best-claude-code-gui-tools-2026/
- https://docs.bswen.com/blog/2026-03-21-claude-code-terminal-vs-desktop/
