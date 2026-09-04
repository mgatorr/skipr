import { test, expect } from '@playwright/test';

// Optional footer updates form (not the hero CTA). Runs against WAITLIST_DRY_RUN=1.

test.describe('Optional updates — JS enhanced', () => {
  test('valid email shows an inline success state', async ({ page }) => {
    await page.goto('/');
    const form = page.locator('#waitlist');
    await form.getByLabel(/email/i).fill('e2e-user@example.com');
    await form.getByRole('button', { name: /get updates/i }).click();
    await expect(form.locator('.js-status')).toHaveClass(/status--ok/);
  });

  test('invalid email is blocked with an inline error (no navigation)', async ({ page }) => {
    await page.goto('/');
    const form = page.locator('#waitlist');
    await form.getByLabel(/email/i).fill('not-an-email');
    await form.getByRole('button', { name: /get updates/i }).click();
    await expect(form.locator('.js-status')).toHaveClass(/status--err/);
    await expect(page).toHaveURL('/');
  });
});

test.describe('Optional updates — no JavaScript (progressive enhancement)', () => {
  test.use({ javaScriptEnabled: false });

  test('native form submit still works and reveals a success state', async ({ page }) => {
    await page.goto('/');
    const form = page.locator('#waitlist');
    await form.getByLabel(/email/i).fill('nojs-user@example.com');
    await form
      .getByRole('button', { name: /get updates/i })
      .click({ force: true, noWaitAfter: true });
    await expect(page).toHaveURL(/#wl-success$/);
    await expect(page.locator('#wl-success')).toBeVisible();
  });
});
