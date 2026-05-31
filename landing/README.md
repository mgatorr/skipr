# skipr — landing + waitlist + articles

Marketing site for **skipr** (repo working name: `cockpit`). Astro + Vercel, static-first, with a
single on-demand endpoint for the waitlist. English (primary) + Spanish (secondary, `/es/`).

> skipr is an independent tool and is **not affiliated with Anthropic**.

## Stack

- **Astro 5** (static output, built-in i18n) + `@astrojs/vercel` (one serverless endpoint) +
  `@astrojs/sitemap`
- **Supabase** (Postgres) for the owned waitlist — INSERT-only RLS policy, server-side
- **Vitest** (unit) + **Playwright** (e2e) + **Lighthouse CI** (≥ 95 perf/seo/a11y)

## Local development

```bash
pnpm install
cp .env.example .env   # fill SUPABASE_* for real submissions, or set WAITLIST_DRY_RUN=1
pnpm dev               # http://localhost:4321
```

### Environment variables (never commit real values)

| Var                 | Where               | Purpose                                              |
| ------------------- | ------------------- | ---------------------------------------------------- |
| `SUPABASE_URL`      | Vercel env (server) | Project URL, e.g. `https://<ref>.supabase.co`        |
| `SUPABASE_ANON_KEY` | Vercel env (server) | Anon key — used server-side with INSERT-only RLS     |
| `PUBLIC_SITE_URL`   | build               | Canonical/OG/sitemap base URL                        |
| `WAITLIST_DRY_RUN`  | dev/test            | `1` skips the real Supabase insert (no creds needed) |

## Database

The waitlist lives in a dedicated Supabase project. Apply `supabase/migrations/0001_waitlist.sql`
(SQL Editor or `supabase db push`). It creates `public.waitlist` (`email` unique, `source`,
`created_at`) with RLS allowing **INSERT only** for the anon role — the anon key can add leads but
cannot read, update, or delete the list (reading requires the service role / dashboard).

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

Vercel. Set the project **root directory** to `landing/`, add the `SUPABASE_*` env vars, and PRs
get preview deploys automatically. Do **not** set `WAITLIST_DRY_RUN` in production.

When you later want to email the list, export it from Supabase and send the broadcast from your
email provider of choice — no email sending is wired into this phase.
