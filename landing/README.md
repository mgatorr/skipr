# skipr — landing + waitlist + articles

Marketing site for **skipr** (repo working name: `cockpit`). Astro + Vercel, static-first, with a
single on-demand endpoint for the waitlist. English (primary) + Spanish (secondary, `/es/`).

> skipr is an independent tool and is **not affiliated with Anthropic**.

## Stack

- **Astro 5** (static output, built-in i18n) + `@astrojs/vercel` (one serverless endpoint) +
  `@astrojs/sitemap`
- **Neon** (Postgres, via the Vercel Marketplace) for the owned waitlist — connection string used
  server-side only
- **Vitest** (unit) + **Playwright** (e2e) + **Lighthouse CI** (≥ 95 perf/seo/a11y)

## Local development

```bash
pnpm install
cp .env.example .env   # fill DATABASE_URL for real submissions, or set WAITLIST_DRY_RUN=1
pnpm dev               # http://localhost:4321
```

### Environment variables (never commit real values)

| Var                | Where               | Purpose                                                  |
| ------------------ | ------------------- | -------------------------------------------------------- |
| `DATABASE_URL`     | Vercel env (server) | Neon connection string — secret, used server-side only   |
| `PUBLIC_SITE_URL`  | build               | Canonical/OG/sitemap base URL                            |
| `WAITLIST_DRY_RUN` | dev/test            | `1` skips the real insert and returns success (no creds) |

> Vercel's Neon integration injects `DATABASE_URL` automatically; you don't set it by hand in prod.

## Database

The waitlist lives in our own **Neon** Postgres (created from the Vercel Marketplace). Apply
`db/migrations/0001_waitlist.sql` once — via the Neon SQL Editor or `psql "$DATABASE_URL" -f
db/migrations/0001_waitlist.sql`. It creates `waitlist` (`email` unique, `source`, `created_at`).
Access is gated by the connection string, which is a secret used only in the server-rendered
`/api/waitlist` endpoint — it never reaches the client.

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

Vercel. Set the project **root directory** to `landing/`, add **Neon** from the Vercel Marketplace
(it injects `DATABASE_URL`), and PRs get preview deploys automatically. Do **not** set
`WAITLIST_DRY_RUN` in production.

When you later want to email the list, export it from Neon and send the broadcast from your
email provider of choice — no email sending is wired into this phase.
