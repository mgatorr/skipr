import { test, expect } from '@playwright/test';

const SLUG = 'how-much-context-your-mcp-servers-waste';

test.describe('Articles (US3)', () => {
  test('the launch article is listed on the articles index', async ({ page }) => {
    await page.goto('/articles');
    const link = page.getByRole('link', { name: /how much context/i });
    await expect(link).toBeVisible();
  });

  test('the article renders with SEO + OG metadata and a waitlist CTA', async ({ page }) => {
    await page.goto(`/articles/${SLUG}`);

    await expect(page.getByRole('heading', { level: 1 })).toContainText(/how much context/i);

    // SEO / social metadata
    await expect(page.locator('link[rel="canonical"]')).toHaveAttribute('href', new RegExp(SLUG));
    await expect(page.locator('meta[name="description"]')).toHaveAttribute('content', /.{20,}/);
    await expect(page.locator('meta[property="og:type"]')).toHaveAttribute('content', 'article');
    await expect(page.locator('meta[property="og:image"]')).toHaveAttribute('content', /\.png$/);

    // structured data present
    await expect(page.locator('script[type="application/ld+json"]')).toHaveCount(1);

    // waitlist CTA inside the article
    await expect(page.getByRole('button', { name: /join the waitlist/i })).toBeVisible();
  });
});
