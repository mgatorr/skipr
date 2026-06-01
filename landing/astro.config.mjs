// @ts-check
import { defineConfig } from 'astro/config';
import vercel from '@astrojs/vercel';
import sitemap from '@astrojs/sitemap';

// Static-first: pages and articles are prerendered for the Lighthouse budget.
// Only `src/pages/api/waitlist.ts` opts out (`export const prerender = false`)
// so the Supabase key stays server-side and never ships to the browser.
export default defineConfig({
  site: process.env.PUBLIC_SITE_URL || 'https://skipr.dev',
  output: 'static',
  adapter: vercel(),
  devToolbar: { enabled: false },
  // English is the primary locale (served at /, no prefix); Spanish is secondary (/es/).
  i18n: {
    defaultLocale: 'en',
    locales: ['en', 'es'],
    routing: { prefixDefaultLocale: false },
  },
  integrations: [sitemap()],
});
