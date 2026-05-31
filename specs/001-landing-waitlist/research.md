# Phase 0 Research: Landing + Waitlist + First Article

All Technical Context unknowns are resolved below. Kickoff decisions (stack, provider, brand) were
fixed before planning; the remaining items are best-practice/integration choices.

## 1. Framework & rendering — Astro 5, static-first with one on-demand endpoint

- **Decision**: Astro 5 with `output: 'static'` (the default) plus `@astrojs/vercel`. The landing,
  articles index, and article pages are **prerendered**. Only `src/pages/api/waitlist.ts` opts out
  with `export const prerender = false`, becoming a Node serverless function on Vercel.
- **Rationale**: Static HTML gives the Lighthouse ≥ 95 budget (SC-004) almost for free and removes
  client-side JS from the critical path. Keeping a single server endpoint means the Resend API key
  never ships to the browser and never needs an in-repo store (Principle II).
- **Alternatives considered**: Full `output: 'server'` (worse perf, unnecessary SSR for static
  content); Next.js (heavier for a content site, against "static-first"); pure static with a 3rd-
  party form action (would either expose a provider key client-side or lose control of the list).

## 2. Waitlist provider — Resend Audiences via server-side SDK

- **Decision**: Capture emails in an owned **Resend Audience**. The endpoint calls
  `resend.contacts.create({ audienceId: RESEND_AUDIENCE_ID, email, unsubscribed: false })` with the
  `resend` Node SDK. Both `RESEND_API_KEY` and `RESEND_AUDIENCE_ID` come from Vercel env vars.
- **Rationale**: We own the list (exportable, reusable for launch email), the SDK call is trivial,
  and the same provider can later send the launch broadcast. Server-side only → no secret exposure.
- **Idempotency / duplicates (Edge Case + FR)**: Treat a duplicate email as success. Resend returns
  an error when a contact already exists in the audience; the endpoint maps that specific case to a
  200/"you're already on the list" response rather than surfacing an error (idempotent UX, SC-002).
- **Provider-down (Edge Case)**: On a 5xx/network failure, return a friendly retry state and a
  non-200 status so the no-JS fallback shows an error page; never silently drop the lead. (MVP does
  not add a durable queue; failures are surfaced, not swallowed.)
- **Alternatives considered**: Buttondown (newsletter-first; fine, but Resend doubles as our
  transactional sender), ConvertKit/Kit (heavier automation than we need now).

## 3. Progressive enhancement & spam protection

- **Decision**: A native `<form method="POST" action="/api/waitlist">` works with **no JS**: the
  endpoint responds with a redirect to `/?waitlist=success` (or an error variant) that renders a
  server state. With JS, a small inline script intercepts submit, POSTs via `fetch`, and renders
  inline success/error/validation without navigation.
- **Spam protection**: A **honeypot** field (visually hidden, e.g. `company`) — any non-empty value
  is silently treated as success but not stored. Honeypot logic is a pure, unit-tested function.
  Hook for an optional provider/CAPTCHA later, but honeypot is the MVP baseline (FR-004).
- **Rationale**: Progressive enhancement satisfies FR-004 and Acceptance Scenario 3 (JS disabled);
  the honeypot is zero-friction for humans and catches naive bots without a third-party dependency.

## 4. SEO, social cards & sitemap

- **Decision**: `BaseLayout.astro` renders per-page `<title>`, meta description, canonical, and
  Open Graph/Twitter tags. `@astrojs/sitemap` generates `sitemap.xml`; `public/robots.txt` allows
  crawl and references the sitemap. OG images are **hand-made** PNGs in `public/og/` (one for the
  landing, one for the launch article) for the MVP; dynamic OG generation is a later option.
- **Rationale**: Meets FR-008/SC-003 (valid SEO + correct social preview + sitemap entry) with the
  least moving parts. Hand-made cards avoid an image-render dependency on the critical path.
- **Alternatives considered**: `@vercel/og`/Satori dynamic cards (nice later, unneeded for 1–2
  pages now).

## 5. Articles as a content collection

- **Decision**: An Astro **content collection** `articles` with a Zod schema (title, description,
  publishDate, slug, ogImage, draft). Article pages render from `getCollection('articles')`; the
  index lists non-draft entries sorted by date. Launch article: *"How much context are your MCP
  servers wasting?"* with an in-body waitlist CTA.
- **Rationale**: Adding an article becomes a single Markdown file (FR-006/FR-009/SC-005); the schema
  enforces the metadata SEO needs.

## 6. Aesthetic — dark "terminal / trading-desk"

- **Decision**: Dark background, monospace display type (system mono stack, optional self-hosted
  `JetBrains Mono` subset to avoid render-blocking), a single green up-tick accent. Tokens live in
  `src/styles/theme.css`. Reuse the visual language of the public `claude-mcp-stack` hero assets.
- **Rationale**: Brand consistency with the product (FR-001) and a distinctive, fast, low-asset
  look that helps the performance budget.

## 7. Testing & CI

- **Decision**: Vitest for pure logic (`validateEmail`, `honeypot`, `waitlist` payload mapping,
  with the Resend SDK mocked at the boundary). Playwright for e2e (submit happy path, **no-JS**
  submit, duplicate→success, inline validation, presence of SEO/OG tags). Lighthouse CI asserts
  ≥ 95 budgets. GitHub Actions runs: `astro check` + eslint, vitest, `astro build`, **gitleaks over
  tree + full history**, then Lighthouse CI against the build. Vercel provides PR preview deploys.
- **Rationale**: Satisfies Principle V (test-first for real logic), Principle II (secret scan
  tree+history), FR-010/FR-011/FR-012 and SC-004/SC-006.

## Resolved unknowns

| Unknown | Resolution |
|---------|------------|
| Rendering mode | Static-first; only `/api/waitlist` is on-demand |
| Provider integration | Resend `contacts.create` with audienceId, server-side |
| Duplicate handling | Map "already exists" to success (idempotent) |
| No-JS support | Native form POST → redirect; JS enhances to inline |
| Spam | Honeypot (pure, tested); CAPTCHA optional later |
| OG images | Hand-made PNGs for MVP |
| Secret scanning | gitleaks over tree + history in CI |
