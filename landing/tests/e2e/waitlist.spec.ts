import { test, expect } from '@playwright/test';

// Runs against the preview server started with WAITLIST_DRY_RUN=1 (no real Resend call).

test.describe('Waitlist — JS enhanced', () => {
  test('valid email shows an inline success state', async ({ page }) => {
    await page.goto('/');
    await page.getByLabel(/email/i).fill('e2e-user@example.com');
    await page.getByRole('button', { name: /join the waitlist/i }).click();
    await expect(page.locator('#waitlist-status')).toHaveClass(/status--ok/);
  });

  test('invalid email is blocked with an inline error (no navigation)', async ({ page }) => {
    await page.goto('/');
    await page.getByLabel(/email/i).fill('not-an-email');
    await page.getByRole('button', { name: /join the waitlist/i }).click();
    await expect(page.locator('#waitlist-status')).toHaveClass(/status--err/);
    await expect(page).toHaveURL('/');
  });
});

test.describe('Waitlist — no JavaScript (progressive enhancement)', () => {
  test.use({ javaScriptEnabled: false });

  test('native form submit still works and reveals a success state', async ({ page }) => {
    await page.goto('/');
    await page.getByLabel(/email/i).fill('nojs-user@example.com');
    await page.getByRole('button', { name: /join the waitlist/i }).click();
    await expect(page).toHaveURL(/#wl-success$/);
    await expect(page.locator('#wl-success')).toBeVisible();
  });
});
