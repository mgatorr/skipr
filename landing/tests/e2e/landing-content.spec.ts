import { test, expect } from '@playwright/test';

test.describe('Landing communicates skipr (US1/US2)', () => {
  test('hero value prop, anti-black-box, how-it-works, CTA, disclaimer', async ({ page }) => {
    await page.goto('/');

    // US1: value prop + ownership
    await expect(page.getByRole('heading', { level: 1 })).toContainText(/build real software/i);
    await expect(page.locator('body')).toContainText(/own it/i);

    // US1: anti-black-box, named against no-code tools
    await expect(page.locator('body')).toContainText(/black box/i);
    await expect(page.locator('body')).toContainText(/Lovable|Base44/i);

    // US2: the method — the 5 guided steps
    await expect(page.locator('body')).toContainText(/the method/i);
    for (const step of [/set up/i, /spec/i, /code/i, /github/i, /deploy/i]) {
      await expect(page.locator('body')).toContainText(step);
    }

    // coming soon + CTA + disclaimer (two waitlist forms on the page → take the first)
    await expect(page.locator('body')).toContainText(/coming soon/i);
    await expect(page.getByRole('button', { name: /join the waitlist/i }).first()).toBeVisible();
    await expect(page.locator('body')).toContainText(/not affiliated with Anthropic/i);
  });

  test('CTA is reachable on a mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 720 });
    await page.goto('/');
    const cta = page.locator('#waitlist').getByRole('button', { name: /join the waitlist/i });
    await expect(cta).toBeVisible();
    await cta.scrollIntoViewIfNeeded();
  });
});
