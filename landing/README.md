# skipr.dev — static GitHub stub

**Deploy:** Vercel project root directory = `landing/`. `vercel.json` sets
`framework: null` and `outputDirectory: public`. Only `public/` is served.

Astro waitlist/marketing source was removed (2026-09) so the repo is not
TypeScript-heavy for a parked domain. Historical eras: [docs/ARCHIVE.md](../docs/ARCHIVE.md).

## Local preview

```bash
npx serve public
# or: python3 -m http.server -d public 4173
```

## Production

```bash
# from landing/
vercel --prod --yes
```
