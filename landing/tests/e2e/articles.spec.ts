import { test, expect } from '@playwright/test';

const SLUG = 'from-no-code-to-software-you-own';

test.describe('Articles (US4)', () => {
  test('the launch article is listed; the retired token article is not', async ({ page }) => {
    await page.goto('/articles');
    await expect(page.getByRole('link', { name: /no-code to software/i })).toBeVisible();
    await expect(page.locator('body')).not.toContainText(/how much context/i);
  });

  test('the article renders with SEO + OG metadata and a waitlist CTA', async ({ page }) => {
    await page.goto(`/articles/${SLUG}`);

    await expect(page.getByRole('heading', { level: 1 })).toContainText(/no-code to software/i);

    await expect(page.locator('link[rel="canonical"]')).toHaveAttribute('href', new RegExp(SLUG));
    await expect(page.locator('meta[name="description"]')).toHaveAttribute('content', /.{20,}/);
    await expect(page.locator('meta[property="og:type"]')).toHaveAttribute('content', 'article');
    await expect(page.locator('meta[property="og:image"]')).toHaveAttribute('content', /\.png$/);
    await expect(page.locator('script[type="application/ld+json"]')).toHaveCount(1);

    await expect(page.getByRole('button', { name: /join the waitlist/i })).toBeVisible();
  });
});
