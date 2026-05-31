# skipr — Repositioning Design

**Date:** 2026-05-31
**Status:** Draft for review (brainstorming output)
**Supersedes the positioning in:** `docs/design.md` (Sorrel / token-cost hero) and constitution Principle I

> This document repositions the project. The previous framing (Sorrel — a Go+Charm TUI whose
> hero was an MCP token-cost analyzer) was invalidated by research (see §3). The new framing is
> **skipr — the friendly way for non-technical founders to build real software with AI and own it.**
> Only the **landing (feature 001)** is implemented today; everything about the product is vision to
> be validated, not built.

## 1. One-liner

**skipr — build real software with AI, and actually own it.**
The skipper that takes the helm so you can fly: skipr guides a non-technical founder from idea to a
shipped, *real* app — Claude Code guided, files on their machine, their GitHub, their deploy —
without living in the terminal. It teaches you to fish; it is not a black box.

## 2. Who it's for

**Primary:** the **non-technical solo founder** who has already tried no-code / vibe-coding tools
(Lovable, Base44), shipped their first little things, and now **wants more — real software they own
and control** — but for whom the terminal is a wall (doesn't know `cd`, `pwd`, permissions, how to
drive Claude Code).

Real personas (the user's own first validation users): **Jose** and **Goñi** — product-minded,
some technical vocabulary by osmosis, but the console makes everything a chore.

Explicitly **not** for: terminal-native developers (they don't need it) and people who want a fully
automated black box that hides the code (that's Lovable's job, and it's why those projects stall).

## 3. Why this, grounded in research

- **The #1 pain is the "harness," not the model, the setup, or tokens.** Failures are workflow:
  the agent loses context, drifts from spec, duplicates code, ignores conventions. *"Not a model
  problem, a configuration problem — the fix is in the harness."* (HumanLayer). The predictor of
  success is **comprehension**, not technical background.
  ([beginnersinai](https://beginnersinai.org/why-ai-coding-agents-fail/),
  [codingwithvibe](https://codingwithvibe.com/vibe-coding-success-rate-non-developer/))
- **Non-experts hit the 80/20 and "month 3" walls** — last-mile, security (40–62% of AI code has
  flaws), and feature-silo breakage — and get disillusioned, drifting back to no-code.
  ([appbuilderguides](https://appbuilderguides.com/news/vibe-coding-disillusionment-2026/))
- **Big, funded market:** vibe-coding raised **$8B VC in 2025**; non-technical founders already pay
  (~$350/mo of subs) and reach paying customers in 4–6 weeks. The least experienced gain the *most*
  from AI. ([builtthisweek](https://learn.builtthisweek.com/ai-coding-tools/the-5-best-ai-coding-tools-for-non-technical-founders-in-2026))
- **The gap:** solutions to the harness exist but are **for experts/teams** (Spec Kit, Kiro, BMAD;
  Galileo/Braintrust/Helicone). **Nobody does it friendly for the non-technical solo builder.**
  ([Augment](https://www.augmentcode.com/tools/best-spec-driven-development-tools))
- **Platform risk avoided:** unlike "another GUI wrapper for Claude Code" (a saturated space where
  Anthropic ships the official desktop app), a guided *build-and-own* flow across tools sits in the
  gap, not against the platform owner.

## 4. The differentiator (the heart)

**Control + ownership + learning — the anti-black-box.** Lovable/Base44 hand you a fish in a black
box; skipr teaches you to fish without the pain of the rod. The emotional payload matters: the
non-technical founder doesn't just want the result, they want the **dignity of having built and
understood it** — to *feel like a builder*. This is also what the research says actually works
(comprehension), so it's strategy and substance at once.

The landing must **name the contrast explicitly**: *"Not a black box like Lovable or Base44 — you
keep the code, the repo, the control, and you learn as you go."*

## 5. Product vision (to validate, not build yet)

A **desktop app (GUI)** — "like the Claude app, but much better and for building real software" —
that wraps the real developer flow and removes the terminal:

1. **Guided setup** — install/run Claude Code without touching a terminal.
2. **Idea → spec** — guided Spec-Driven Development (the project already uses Spec Kit) so the agent
   doesn't drift; the founder understands what's being built.
3. **Spec → code** — drive Claude Code with guardrails, in plain language, with the file tree and
   tabs visible so it's never a black box.
4. **Code → GitHub** — their repo, on their machine, explained ("this is GitHub, this is a commit").
5. **GitHub → deploy** — real, owned deploy on a default guided stack.

**Default guided stack:** **Supabase + Vercel + GitHub + Claude Code** (generous free tiers,
one-click deploy, and so well-known the AI guides them well).

**Cross-tool, later:** the harness/guidance is tool-agnostic; Claude Code first, then Codex / Gemini
CLI. Token-cost awareness ("don't waste it") becomes *one feature*, never the hero.

**Form factor:** desktop GUI (Tauri preferred — small binary, OS webview, terminal-dark look in
CSS). **Not** a TUI (the audience doesn't live in a terminal).

**Business model:** open-core — a free tier (the funnel) + **Pro** (one-time purchase, majors at a
discount). Pro is where active guidance/automation lives.

**Language:** **English-first** for the product and landing; **Spanish as the secondary locale**
(i18n: `en` + `es`). The landing ships English-first; Spanish is added as a second locale. Repo
artifacts and commit messages stay in English (constitution). The working conversation with the
founder is in Spanish (his native language) — that does not change the product language.

## 6. Scope of the landing repositioning (what we implement NOW)

The landing (feature `001-landing-waitlist`, already built: Astro + Vercel, waitlist in Supabase,
articles, Lighthouse ≥ 95, terminal-dark aesthetic) gets **re-messaged**, not rebuilt:

- **Headline:** *"Build real software with AI — and actually own it."*
- **Sub:** idea → shipped, guided; your files, your GitHub, your deploy; without the terminal; for
  founders who want to build for real, not prototype.
- **Anti-black-box section:** explicit contrast with Lovable/Base44 ("you keep the code & control").
- **How-it-works:** the 5-step flow (setup → spec → code → GitHub → deploy) shown simply.
- **Hero visual:** regenerate `assets/*-hero.png` and the landing `Hero.astro` to convey **the flow
  / "feel powerful"** (not the token-cost dashboard). A "you shipped it" moment.
- **Tone:** bold, striking, makes a newcomer feel powerful, never overwhelmed.
- **Waitlist:** unchanged (Supabase). Keep "coming soon" + "not affiliated with Anthropic."
- **Launch article:** refocus to the angle *"from Lovable to real software"* / build-and-own
  (replacing the token-cost article as the lead piece; the token piece can remain as a secondary
  post or be retired).
- **Rename Sorrel → skipr everywhere:** landing copy/brand, `BaseLayout`, OG + hero assets,
  `specs/001`, `docs/design.md`, `CLAUDE.md`, memory, and the GitHub repo (`sorrel` → `skipr`).
  Domain: **skipr.dev** (already owned).

## 7. Impact on existing docs

- **`docs/design.md`:** rewrite the product framing (audience, pain, differentiator, GUI form
  factor, guided build-and-own flow, stack). Keep the phased-validation discipline.
- **Constitution:** amend **Principle I** ("hero = token-cost analyzer") → "hero = friendly,
  owned, real-software building for non-technical founders; token-cost is one feature." Bump
  **1.0.0 → 1.1.0** (MINOR) per governance. Keep all other principles (security, test-first,
  neutral branding, phase discipline).

## 8. Risks (named, not hidden)

- **Monetizing non-technical users is hard** (churn, disillusionment). Mitigation: target the
  *serious* solo founder who wants to ship for real (they already pay for subs), not casual dabblers.
- **The product is ambitious to build** (a guided client for non-technical users ≈ an IDE with
  training wheels). Mitigation: **phase discipline** — validate with the landing + Jose/Goñi first;
  build the MVP only when the waitlist shows more "Joses."
- **Philosophical tension:** success requires *understanding*. skipr must **help you understand and
  control**, never hide complexity — or it recreates the month-3 wall it's meant to prevent.
- **Active space** (spec/guardrails frameworks). Differentiator is "friendly for non-experts +
  ownership + cross-tool"; execution quality decides.

## 9. Sequence of work

1. **Foundations (ideation):** finalize this design; rewrite `docs/design.md` and amend the
   constitution (Principle I → 1.1.0) so the new vision is canonical. This is "all the bases."
2. **Landing first (100%):** re-message the landing per §6 (spec → plan → implement), English-first.
   It is the validation asset.
3. **MVP, spec by spec:** the founder builds the product MVP **right after the foundations** — not
   waiting for full validation, but kept **small** and steered by watching Jose/Goñi. The MVP
   product is a large, independent sub-project: it gets its **own ideation/brainstorm** before its
   first spec, then proceeds one capability at a time (SDD: spec → plan → implement).

Validation runs **in parallel**: ship the landing, collect "Joses," and let real usage steer the
MVP slices. **Watch Jose and Goñi try to use Claude Code** and log every point they get stuck — that
defines the MVP better than any research.

## 10. Open questions for the spec/plan stage

- Exact MVP slice of the product (not landing) — deferred until validation.
- Whether to keep or retire the token-cost article.
- Whether the rename of the GitHub repo happens now or with the rest.
