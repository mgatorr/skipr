import { test, expect } from '@playwright/test';

test.describe('Landing communicates the product (US2)', () => {
  test('shows value prop, token-cost angle, CTA and the disclaimer', async ({ page }) => {
    await page.goto('/');

    // Value prop + hero angle
    await expect(page.getByRole('heading', { level: 1 })).toContainText(/cost/i);
    await expect(page.locator('body')).toContainText(/MCP server/i);
    await expect(page.locator('body')).toContainText(/context/i);

    // "Coming soon" framing
    await expect(page.locator('body')).toContainText(/coming soon/i);

    // Waitlist CTA
    await expect(page.getByRole('button', { name: /join the waitlist/i })).toBeVisible();

    // Neutral-branding disclaimer
    await expect(page.locator('body')).toContainText(/not affiliated with Anthropic/i);
  });

  test('CTA is reachable on a mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 720 });
    await page.goto('/');
    const cta = page.getByRole('button', { name: /join the waitlist/i });
    await expect(cta).toBeVisible();
    await cta.scrollIntoViewIfNeeded();
  });
});
