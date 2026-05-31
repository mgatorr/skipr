import { defineConfig, devices } from '@playwright/test';

// e2e runs against a production build/preview with WAITLIST_DRY_RUN=1 so the
// happy path needs no Resend credentials and no email leaves the machine.
export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:4321',
    trace: 'on-first-retry',
  },
  // The Vercel adapter doesn't support `astro preview`, so e2e runs against the
  // dev server, which executes the on-demand endpoint. WAITLIST_DRY_RUN=1 means
  // no Resend credentials are needed and no email leaves the machine.
  webServer: {
    command: 'WAITLIST_DRY_RUN=1 pnpm exec astro dev --port 4321',
    url: 'http://localhost:4321',
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'mobile', use: { ...devices['Pixel 7'] } },
  ],
});
