# skipr — App Screens (design mockups)

Visual mockups for the **skipr desktop app** (the product MVP, Phase 2), produced by
Claude Design in the same risograph-zine language as the live landing. These are a
**design reference / starting point**, not production code — the MVP's tech stack is an
open decision (see `docs/MVP-KICKOFF.md`).

## How to view

Open `index.html` in a browser. It renders the screens with React + Babel Standalone loaded
from a CDN (needs an internet connection); the source components live in `app/`.

## What's here

- `app/app-ui.css` — the app's design system (sibling of the landing's `theme.css`).
- `app/ui-kit.jsx` — shared UI primitives.
- `app/design-canvas.jsx` — the canvas that lays the screens out.
- `app/screens-onboarding.jsx` — setup / sign-in flow (no terminal).
- `app/screens-home-plan.jsx` — home + plan/spec view.
- `app/screens-build.jsx` — the build screen (Claude Code working, in plain language).
- `app/screens-skills-conn-cost.jsx` — skills, connections (GitHub/Vercel/Supabase) and cost.
- `app/screens-deploy-settings.jsx` — deploy + settings.
- `screenshots/` — rendered captures (`app-onboarding*.png`, `app-diagram.png`).

## Map to the product flow

These screens illustrate the 5-step flow from `docs/MVP-KICKOFF.md`:
`setup → spec → build → own (GitHub) → ship (deploy)`, with zero terminal exposure.

## Provenance

Claude Design hand-off (May 2026). Rescued from a temporary bundle into the repo so the
MVP team/agent has the visual starting point versioned and at hand.
