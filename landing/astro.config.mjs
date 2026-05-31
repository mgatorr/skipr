// @ts-check
import { defineConfig } from 'astro/config';
import vercel from '@astrojs/vercel';
import sitemap from '@astrojs/sitemap';

// Static-first: pages and articles are prerendered for the Lighthouse budget.
// Only `src/pages/api/waitlist.ts` opts out (`export const prerender = false`)
// so the Resend API key stays server-side and never ships to the browser.
export default defineConfig({
  site: process.env.PUBLIC_SITE_URL || 'https://sorrel.dev',
  output: 'static',
  adapter: vercel(),
  integrations: [sitemap()],
});
