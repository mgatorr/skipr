import { test, expect } from '@playwright/test';

// Runs against the dev server started with WAITLIST_DRY_RUN=1 (no real Neon insert).
// The landing has two waitlist forms (hero + footer); these tests target the hero
// form (#waitlist), which also owns the shared no-JS state block.

test.describe('Waitlist — JS enhanced', () => {
  test('valid email shows an inline success state', async ({ page }) => {
    await page.goto('/');
    const form = page.locator('#waitlist');
    await form.getByLabel(/email/i).fill('e2e-user@example.com');
    await form.getByRole('button', { name: /join the waitlist/i }).click();
    await expect(form.locator('.js-status')).toHaveClass(/status--ok/);
  });

  test('invalid email is blocked with an inline error (no navigation)', async ({ page }) => {
    await page.goto('/');
    const form = page.locator('#waitlist');
    await form.getByLabel(/email/i).fill('not-an-email');
    await form.getByRole('button', { name: /join the waitlist/i }).click();
    await expect(form.locator('.js-status')).toHaveClass(/status--err/);
    await expect(page).toHaveURL('/');
  });
});

test.describe('Waitlist — no JavaScript (progressive enhancement)', () => {
  test.use({ javaScriptEnabled: false });

  test('native form submit still works and reveals a success state', async ({ page }) => {
    await page.goto('/');
    const form = page.locator('#waitlist');
    await form.getByLabel(/email/i).fill('nojs-user@example.com');
    // Native submit navigates immediately. force/noWaitAfter avoid racing the
    // click against (a) the form's POST/redirect detaching the node and (b) the
    // dev server's late web-font reflow (prod CLS is ~0.01 thanks to preload).
    await form
      .getByRole('button', { name: /join the waitlist/i })
      .click({ force: true, noWaitAfter: true });
    await expect(page).toHaveURL(/#wl-success$/);
    await expect(page.locator('#wl-success')).toBeVisible();
  });
});
