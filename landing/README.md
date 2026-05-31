# Sorrel — landing + waitlist + articles

Marketing site for **Sorrel** (repo working name: `cockpit`), feature `001-landing-waitlist`.
Astro + Vercel, static-first, with a single on-demand endpoint for the waitlist.

> Sorrel is an independent tool and is **not affiliated with Anthropic**.

## Stack

- **Astro 5** (static output) + `@astrojs/vercel` (one serverless endpoint) + `@astrojs/sitemap`
- **Resend Audiences** for the owned waitlist (server-side only)
- **Vitest** (unit) + **Playwright** (e2e) + **Lighthouse CI** (≥ 95 perf/seo/a11y)

## Local development

```bash
pnpm install
cp .env.example .env   # fill RESEND_* for real submissions, or set WAITLIST_DRY_RUN=1
pnpm dev               # http://localhost:4321
```

### Environment variables (never commit real values)

| Var                  | Where               | Purpose                                          |
| -------------------- | ------------------- | ------------------------------------------------ |
| `RESEND_API_KEY`     | Vercel env (server) | Resend API key — server-side only                |
| `RESEND_AUDIENCE_ID` | Vercel env (server) | The owned waitlist audience                      |
| `PUBLIC_SITE_URL`    | build               | Canonical/OG/sitemap base URL                    |
| `WAITLIST_DRY_RUN`   | dev/test            | `1` skips the real Resend call (no creds needed) |

## Scripts

```bash
pnpm test         # unit tests (Vitest)
pnpm test:e2e     # e2e (Playwright; starts dev server with WAITLIST_DRY_RUN=1)
pnpm build        # static build + serverless endpoint
pnpm og           # regenerate the Open Graph cards in public/og/
pnpm lighthouse   # Lighthouse CI budgets against dist/client
pnpm lint         # eslint + prettier --check
```

## Adding an article

Drop a Markdown file in `src/content/articles/`. It appears in `/articles` and the sitemap
automatically — no code change (set `draft: true` to hide it). Required frontmatter:
`title`, `description`, `publishDate`; optional: `ogImage`, `canonical`, `draft`.

## Deploy

Vercel. Set the project **root directory** to `landing/`, add the `RESEND_*` env vars, and
PRs get preview deploys automatically. Do **not** set `WAITLIST_DRY_RUN` in production.
