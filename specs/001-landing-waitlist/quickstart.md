# Quickstart: Sorrel landing (feature 001)

Local dev and verification for the Astro landing under `landing/`.

## Prerequisites

- Node.js 20+ and a package manager (pnpm recommended)
- A Resend account with an Audience created (for real submissions)

## Environment

Create `landing/.env` (git-ignored — **never commit**):

```bash
RESEND_API_KEY=re_xxx           # server-side only
RESEND_AUDIENCE_ID=aud_xxx      # the owned waitlist audience
PUBLIC_SITE_URL=http://localhost:4321
```

In production these are set as Vercel Environment Variables, not in the repo.

## Commands

```bash
cd landing
pnpm install
pnpm dev            # http://localhost:4321
pnpm test           # Vitest unit tests (validateEmail, honeypot, waitlist mapping)
pnpm test:e2e       # Playwright (form happy path, no-JS, duplicate, SEO meta)
pnpm build          # static build + serverless endpoint
pnpm lighthouse     # Lighthouse CI budgets (≥95 perf/seo/a11y)
```

## Verifying the acceptance scenarios

1. **Join the waitlist (US1)**: submit a valid email → success state; check the contact appears in
   the Resend Audience. Submit invalid/empty → inline validation. Submit the same email twice →
   success both times, no duplicate in the audience.
2. **No-JS (US1 / FR-004)**: disable JavaScript, submit the form → it still works (redirect to
   `/?waitlist=success`).
3. **Understand the product (US2)**: load `/` → value prop, token-cost angle, CTA, and the
   "not affiliated with Anthropic" disclaimer are present; resize to mobile → CTA reachable.
4. **Launch article (US3)**: open `/articles/how-much-context-your-mcp-servers-waste` → renders with
   SEO/OG meta, has a waitlist CTA, and appears in `/articles`. Add a second Markdown file under
   `src/content/articles/` → it shows up in the index with no code change.

## Security check (Principle II)

- Confirm no secrets in the repo: `gitleaks detect --no-banner` (CI also scans full history).
- Confirm the Resend key is **not** in the client bundle: `grep -r re_ landing/dist || echo clean`.
