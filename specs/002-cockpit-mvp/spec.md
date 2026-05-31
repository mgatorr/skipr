# Feature Specification: Cockpit MVP (Phase 0)

**Feature Branch**: `002-cockpit-mvp`

**Created**: 2026-05-31

**Status**: Draft

**Input**: Approved design `docs/design.md` · Constitution `.specify/memory/constitution.md`

## Clarifications

### Session 2026-05-31 (decided during brainstorming)

- Q: Product scope across the three ideas (installer / TUI / SDD)? → A: ONE product in
  phases; this spec is Phase 0 (MVP) only — the rest is roadmap.
- Q: MVP shape? → A: CLI installer + a minimal TUI from day one.
- Q: Tech stack? → A: Go + Charm (Bubble Tea / Lipgloss / Huh); single static binary.
- Q: Monetization / openness? → A: Open-core. Free OSS CLI installer; paid TUI (one-time,
  paid major upgrades at a discount).
- Q: MVP hero feature? → A: A per-server MCP token-cost analyzer.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Install the MCP stack with one binary (Priority: P1)

A developer downloads the Cockpit binary and runs it to set up Claude Code: it detects their
OS and client, checks prerequisites (asking before installing anything), prompts for any API
keys, backs up their config, merges the selected servers, and confirms each starts.

**Why this priority**: This is the free funnel and the foundation everything else builds on.

**Independent Test**: On a clean machine, run the binary, accept defaults, provide test keys;
every selected server is present in the client config and passes a liveness check, with any
pre-existing config preserved.

**Acceptance Scenarios**:

1. **Given** prerequisites present and a supported client, **When** the user installs the
   default set, **Then** each server is in the config and passes liveness.
2. **Given** a config with unrelated servers and preferences, **When** Cockpit merges,
   **Then** all pre-existing keys are preserved unchanged.
3. **Given** a missing prerequisite, **When** Cockpit needs it, **Then** it asks for explicit
   confirmation before any system-level install and stops with clear instructions if declined.
4. **Given** a server entry already exists, **When** Cockpit would overwrite it, **Then** it
   asks first.

### User Story 2 - See what each MCP server costs in context (Priority: P1) 🌟 hero

A developer opens the Cockpit TUI and sees each installed MCP server with its **context-token
cost** (size of its `tools/list` schema) and the total, so they can disable the expensive
ones they don't need.

**Why this priority**: This is the paid product's differentiator — it makes the invisible
30–40% context waste visible and actionable. Without it there is no reason to pay.

**Independent Test**: With several servers configured, the TUI lists each with a token-cost
estimate and a total; toggling one off and applying updates the config (backup-first) and the
recomputed total.

**Acceptance Scenarios**:

1. **Given** N configured servers, **When** the TUI loads, **Then** it shows a per-server
   token-cost estimate and a total.
2. **Given** the TUI, **When** the user toggles a server off and applies, **Then** the config
   is updated backup-first and the server no longer loads.
3. **Given** a server that fails to start, **When** measuring, **Then** the TUI shows an error
   state for that row rather than crashing.

### User Story 3 - Unlock the paid TUI with a license (Priority: P2)

A buyer enters their license key once and the TUI unlocks; the CLI installer never requires a
key.

**Why this priority**: Needed to monetize, but not to demonstrate value.

**Independent Test**: Without a key, the installer works fully and the TUI runs in a limited
preview; with a valid key, the TUI unlocks; an invalid key is rejected with a clear message.

**Acceptance Scenarios**:

1. **Given** no license, **When** the user runs the installer, **Then** it works fully.
2. **Given** a valid license, **When** entered, **Then** the TUI unlocks and remembers it.
3. **Given** an invalid license, **When** entered, **Then** it is rejected clearly.

### Edge Cases

- Unsupported/unknown client → ask the user to choose; never write to the wrong place.
- No network when fetching the catalog → use a bundled/cached catalog and warn.
- A server hangs while probing → time out and mark the row, never block the UI.
- Windows path/permission differences → handled; covered by cross-platform build/tests.
- Re-running is idempotent (no duplicate entries, no corruption).
- A secret would be exposed (log/file) → never happens; secrets only go to the client config.

## Requirements *(mandatory)*

### Functional Requirements

#### Installer (free, OSS)
- **FR-001**: Ship as a single self-contained binary for macOS, Linux, and Windows.
- **FR-002**: Detect OS and target client; write to the correct config location.
- **FR-003**: Read the curated catalog (the `claude-mcp-stack` `registry.json`); bundle a
  cached copy as fallback.
- **FR-004**: Verify prerequisites and **ask before any system-level install**; stop with
  manual instructions if declined or failing.
- **FR-005**: Prompt for required secrets; write them only to the client config; never log
  or print secret values.
- **FR-006**: Merge selected servers **backup-first**, preserving all unrelated keys; ask
  before overwriting an existing entry; be idempotent.
- **FR-007**: Run a lightweight liveness check per installed server and report a summary.

#### TUI (paid)
- **FR-008**: Launch a Charm TUI listing configured MCP servers with on/off toggles.
- **FR-009**: For each server, spawn it over stdio, request `tools/list`, and compute a
  **context-token cost estimate** of the returned tool schemas; show per-server cost + total.
- **FR-010**: Toggling and applying updates the config backup-first and reflects in a
  recomputed total; failures show a per-row error state, never a crash.
- **FR-011**: Token cost is presented as an estimate with a stated method.

#### Licensing & commercial
- **FR-012**: The installer requires no license. The TUI is gated by a light license check
  (valid key unlocks and persists; invalid key rejected clearly).
- **FR-013**: Public artifacts contain no secrets/personal data; commit identity is a GitHub
  noreply address.

### Key Entities
- **Catalog / Server entry**: the MCP servers and how to launch them (from `registry.json`).
- **Client config**: the user's existing config Cockpit augments (backup-first).
- **Token-cost report**: per-server schema size + token estimate + total.
- **License**: a key that unlocks the paid TUI.

## Success Criteria *(mandatory)*

- **SC-001**: A new user goes from downloading the binary to working tools in their client in
  one guided session, providing only their API keys.
- **SC-002**: 100% of selected servers with valid credentials are present and pass liveness.
- **SC-003**: 0 pre-existing config keys lost or altered across installs.
- **SC-004**: The TUI shows a per-server token-cost estimate and total for every configured
  server, and disabling a server measurably lowers the total.
- **SC-005**: 0 secrets or personal data in the published repo or its history (CI-verified).
- **SC-006**: The single binary installs and runs on macOS, Linux, and Windows with no extra
  runtime.

## Assumptions

- Target users are developers using Claude Code (Desktop/Cowork and Claude Code CLI).
- The catalog is sourced from the existing public `claude-mcp-stack` repo.
- The marketing **landing site is a separate sub-project** (`002-landing-site`), not part of
  this MVP build (see `docs/design.md` roadmap).
- Token cost is an estimate based on measured schema bytes and a documented tokenizer
  heuristic, not an exact provider billing figure.
- A store (Polar or Lemon Squeezy) issues license keys; exact provider chosen at
  implementation time.
