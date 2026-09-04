> **Domain stub (2026-09-04):** Astro marketing site abandoned. `skipr.dev` serves a tiny
> static page that points (and auto-redirects) to https://github.com/mgatorr/skipr.
> Product presentation lives on the GitHub repo root (`README.md`, `docs/`, `skills/`).

# skipr.dev — GitHub stub

Static Vercel deploy from `landing/public/`. No Astro build, no waitlist API, no Neon.

## Deploy

Vercel project **root directory** = `landing/`. `vercel.json` sets `framework: null` and
`outputDirectory: public`. Old Astro sources under `src/` are leftover and unused by deploy.

```bash
# from landing/
vercel --prod --yes
```

## Local preview

```bash
npx serve public
```
