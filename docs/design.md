# Cockpit — Design & Rationale

**Date:** 2026-05-31
**Status:** Approved design (brainstormed). Ready for Spec-Driven Development (Spec Kit).
**Working name:** Cockpit (alternatives: Helm, Conductor — to finalize). Neutral brand;
**not affiliated with Anthropic** (avoid "Claude" in the product name for trademark safety).

> This document is the **why** behind Cockpit. A fresh conversation should read this, then
> the constitution (`.specify/memory/constitution.md`) and the **active** spec. We build in
> order: **`specs/001-landing-waitlist` first** (validate demand + collect a launch list),
> then `specs/002-cockpit-mvp` (the Go product). Run `/speckit-plan → /speckit-tasks →
> /speckit-implement` on the active feature. See `KICKOFF.md` for the exact starting prompt.

## 1. One-liner

**A friendly control layer for piloting Claude Code** — start by setting it up, end by
flying it. Ships as a free open-source CLI installer plus a paid TUI dashboard whose hero
feature shows **how much context each MCP server is costing you**.

## 2. The problem (why this exists — validated by research)

Pains found in 2026 market research (sources at the bottom):

1. **Setting up Claude Code + MCP is painful.** First-time config can take ~1h; docs are
   fragmented; Windows/WSL suffers; connecting many MCP servers **bloats the context window**
   — developers measured **30–40% of context wasted on tool schemas that are never used**;
   silent "Connection closed" errors; **secrets stored in plaintext**; token cost climbs.
2. **Spec-Kit is brittle.** Upstream changes blow up specs; spec↔implementation drift; stale
   specs silently mislead agents; maintenance overhead.
3. **Non-technical / vibe-coders** hit docs that assume technical knowledge; agents fail on
   multi-step flows; the #1 mistake is building for months before talking to customers.
4. **Ghostty** is the terminal of choice for "AI coders" (GPU-fast, handles TUIs); the
   typical AI workflow is multi-pane (Claude Code + logs + tests).

**Why now:** Claude Code adoption is high and the MCP ecosystem exploded, so the setup +
context-cost pain is widespread and **unaddressed by a polished, visual tool**.

## 3. What sells (why this shape is monetizable)

Indie precedent: boilerplates and dev-tools sell well as **one-time purchases** (ShipFast
$1M+), one-time pricing still produces recurring revenue, and the winning pattern is **build
for your own audience + market well**. We already have a free, public asset
(`claude-mcp-stack`) that doubles as the **top-of-funnel**.

## 4. The product, in phases (MVP now, ambition later)

"All three ideas at once" would be a platform — and building a platform before validating is
the #1 documented failure. So Cockpit is **one product line in phases**, each sellable alone.
**Validation comes first**: we ship a landing + waitlist + one article to prove demand and
build a launch list BEFORE writing the Go product.

- **Phase −1 — Landing + waitlist + first article (`specs/001-landing-waitlist`) — BUILD
  FIRST.** A marketing site (Astro + Vercel) in the product aesthetic, an email waitlist we
  own, and one SEO/RRSS launch article (the token-cost angle). Goal: validate demand, collect
  emails, seed organic + social positioning. Cheap, fast, de-risks everything after it.
- **Phase 0 — MVP (`specs/002-cockpit-mvp`):** free CLI installer + a minimal paid TUI. Built
  once the waitlist shows traction; launches to that list.
- **Phase 1 (v1.1):** TUI also manages skills/hooks + profiles/projects.
- **Phase 2 (v2, paid major upgrade):** Spec-Kit flows from the TUI ("make Claude Code
  friendly" vision).
- **Pro add-on (later):** Spec-Driven-Development guardrails that detect drift / re-plan on
  upstream change (addresses pain #2).

## 5. MVP scope (Phase 0)

### 5.1 `cockpit` CLI installer — FREE / open-source (MIT, public repo)

The **funnel**. A single Go binary that:
- detects OS + target client (Claude Desktop/Cowork `claude_desktop_config.json`, or Claude
  Code `.mcp.json`);
- checks prerequisites (`uvx`, `node`/`npx`) and **asks before any system-level install**;
- reads the curated catalog (the `registry.json` from the public `claude-mcp-stack`);
- prompts for required secrets (never written anywhere but the client config);
- performs a **backup-first, non-destructive merge** into the client config (port the
  `merge_server.py` logic to Go — back up to a timestamped `.bak`, preserve unrelated keys);
- runs a lightweight **liveness** check per server.

### 5.2 `cockpit` TUI dashboard — PAID (license-gated)

Run `cockpit` with no args → Charm (Bubble Tea/Lipgloss) TUI. Minimal MVP surface:
- **Server list with on/off toggles** — enable/disable MCP servers by safely editing the
  client config (backup-first).
- 🌟 **Token-cost analyzer (hero feature):** spawn each MCP server over stdio, run
  `tools/list`, measure the byte/token weight of the returned tool schemas, and show
  **per-server context cost + total**, with a "you could save N tokens" hint. This is the
  standout: it **quantifies pain #1 visually** and nothing on the market does it.
- Apply changes (backup-first write).

### 5.3 Licensing

Light license-key gate for the TUI (signed offline key or store API check). **No aggressive
DRM** — accept that any local paid CLI is soft-gated; optimize for honest-buyer UX, not
piracy prevention.

### 5.4 Relationship to `claude-mcp-stack`

`claude-mcp-stack` stays the **agent-first** path ("paste the link to an agent") and the
**catalog source** (`registry.json`). Cockpit is the **binary** path for people who'd rather
download a tool and get a visual dashboard. Shared catalog, complementary UX, shared funnel.

## 6. Why Go + Charm

- **Single static binary, no runtime** → trivial install for buyers; sidesteps the
  Windows/WSL pain from the research; feels premium.
- **Charm (Bubble Tea + Lipgloss + Huh)** is the indie gold standard for beautiful TUIs —
  matches the "Ghostty-tier" aesthetic a paid product needs.
- Trade-off accepted: re-implement the small Python helpers (`merge_server`, registry
  validation) in Go. They are small and well-specified.

## 7. Monetization & go-to-market

- **Open-core + one-time/majors** (chosen): free OSS CLI = funnel; **Pro TUI = one-time
  purchase** (launch **$29**), each **major** repurchased at a discount.
- **Store:** Polar or Lemon Squeezy (license keys, EU VAT handled).
- **GTM:** CTA from the public `claude-mcp-stack` repo → Pro; Show HN / Product Hunt; X/indie
  audience; reuse the hero-banner + GIF asset pipeline. Content hook: *"I measured how much
  context your MCP servers waste."*

## 8. Architecture (units & data flow)

```
catalog (registry.json from claude-mcp-stack)
        │
        ▼
 cockpit (Go single binary)
   ├── cmd/installer   → detect, prereqs (ask-first), prompt secrets, merge (backup-first), liveness   [FREE]
   ├── internal/catalog → fetch/parse registry.json                                                    [FREE]
   ├── internal/config  → safe backup-first JSON merge (port of merge_server.py)                       [FREE]
   ├── internal/probe   → spawn server over stdio, tools/list, measure schema token cost               [PAID core]
   ├── tui/             → Bubble Tea dashboard: toggles + token-cost analyzer                           [PAID]
   └── internal/license → light key validation                                                          [PAID gate]
        │
        ▼
 user's client config (claude_desktop_config.json / .mcp.json), backed up before write
```

Each unit is independently testable: catalog parse, config merge (preserves unrelated keys),
probe/measurement (deterministic given a fake server), license check, TUI (Charm `teatest`).

## 9. Testing & CI

- Go tests per unit; merge test proves unrelated keys survive; probe test uses a fake stdio
  server; TUI snapshot tests via `teatest`.
- CI: `go vet` + `golangci-lint` + `go test` + cross-platform `go build` (matrix) + gitleaks.
- Reuse the security posture from `claude-mcp-stack`: never commit secrets; placeholder-only
  fixtures; secret scan over tree + history.

## 10. Risks & mitigations

| Risk | Mitigation |
|------|------------|
| Soft license enforcement | Accept it; optimize honest-buyer UX, not DRM |
| Cross-platform spawn of `uvx`/`npx` for probing | Abstract a runner; test on macOS/Linux/Windows in CI |
| Trademark (Anthropic/Claude) | Neutral product name + "not affiliated" disclaimer |
| Scope creep into the platform | Phase gates; MVP = installer + 2 TUI features only |
| Token-cost estimate accuracy | Label as estimate; measure real schema bytes + documented tokenizer heuristic |

## 11. Decision log (the "why", at a glance)

- **Mix of A+B+C → phased single product:** avoids the build-a-platform-too-early trap.
- **MVP = CLI installer + minimal TUI:** more "wow" than a plain installer, still shippable.
- **Go + Charm:** premium single-binary TUI; frictionless install.
- **Open-core, one-time + paid majors:** matches dev-tool buying psychology and uses the
  existing public repo as a funnel.
- **Hero = token-cost analyzer:** turns the most-cited, unaddressed pain into a visible,
  demoable value prop.

## 12. Sources

- https://thepromptshelf.dev/blog/claude-code-mcp-setup-guide/
- https://www.computeleap.com/blog/claude-code-agentic-dev-stack-2026/
- https://www.augmentcode.com/blog/what-spec-driven-development-gets-wrong
- https://medium.com/activated-thinker/spec-driven-development-isnt-broken-it-will-collapse-c00609f72496
- https://www.businessofapps.com/insights/ai-disruption-in-2026-what-saas-founders-are-actually-doing/
- https://www.termdock.com/en/blog/best-terminal-emulator-ai-cli-2026
- https://indiepattern.com/stories/marc-lou/
- https://www.highsignal.io/how-marc-lou-makes-millions-from-great-marketing/
