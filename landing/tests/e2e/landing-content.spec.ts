import { test, expect } from '@playwright/test';

test.describe('Landing communicates skipr (US1/US2)', () => {
  test('hero value prop, anti-black-box, how-it-works, CTA, disclaimer', async ({ page }) => {
    await page.goto('/');

    // US1: escape AI complexity + ownership framing
    await expect(page.getByRole('heading', { level: 1 })).toContainText(/escape/i);
    await expect(page.locator('body')).toContainText(/harness/i);

    // Available now (not waitlist-as-product)
    await expect(page.locator('body')).toContainText(/available now/i);
    await expect(page.getByRole('link', { name: /get started/i }).first()).toBeVisible();

    // US1: anti-black-box
    await expect(page.locator('body')).toContainText(/black box/i);

    // US2: the method — lean path steps
    await expect(page.locator('body')).toContainText(/the method/i);
    for (const step of [/set up/i, /open the folder/i, /harness/i, /claude code/i, /level up/i]) {
      await expect(page.locator('body')).toContainText(step);
    }

    await expect(page.locator('body')).toContainText(/not affiliated with Anthropic/i);
  });

  test('CTA is reachable on a mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 720 });
    await page.goto('/');
    const cta = page.getByRole('link', { name: /get started/i }).first();
    await expect(cta).toBeVisible();
    await cta.scrollIntoViewIfNeeded();
  });

  test('docs novice path is available now', async ({ page }) => {
    await page.goto('/docs');
    await expect(page.getByRole('heading', { level: 1 })).toContainText(/get started/i);
    await expect(page.locator('body')).toContainText(/novice path/i);
    await expect(page.locator('body')).toContainText(/grows with you/i);
    await expect(page.locator('#path')).toBeVisible();
  });
});
