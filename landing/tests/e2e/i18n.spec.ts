import { test, expect } from '@playwright/test';

test.describe('i18n (US5) — English primary, Spanish secondary', () => {
  test('English landing at / with lang=en', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page.getByRole('heading', { level: 1 })).toContainText(/build real software/i);
  });

  test('Spanish landing at /es/ with lang=es', async ({ page }) => {
    await page.goto('/es/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'es');
    await expect(page.getByRole('heading', { level: 1 })).toContainText(/software real/i);
  });

  test('home has hreflang alternates and a locale switcher', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('link[hreflang="es"]')).toHaveCount(1);
    await expect(page.locator('link[hreflang="en"]')).toHaveCount(1);
    await expect(page.getByRole('link', { name: 'ES', exact: true })).toBeVisible();
  });

  test('switching to Spanish lands on the Spanish home', async ({ page }) => {
    await page.goto('/');
    await page.getByRole('link', { name: 'ES', exact: true }).click();
    await expect(page).toHaveURL(/\/es\/?$/);
    await expect(page.locator('html')).toHaveAttribute('lang', 'es');
  });
});
