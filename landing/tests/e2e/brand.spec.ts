import { test, expect } from '@playwright/test';

// SC-004: zero residual "Sorrel"/"Cockpit" in the *visible* content. We check
// rendered text (not raw HTML), since the dev server embeds the repo path
// ("cockpit") in module URLs — a false positive that does not exist in the build.
test.describe('Brand consistency', () => {
  for (const path of ['/', '/es/', '/articles', '/articles/from-no-code-to-software-you-own']) {
    test(`no residual old brand on ${path}`, async ({ page }) => {
      await page.goto(path);
      const text = (await page.locator('body').innerText()).toLowerCase();
      expect(text).not.toContain('sorrel');
      expect(text).not.toContain('cockpit');
      expect(text).toContain('skipr');
    });
  }
});
