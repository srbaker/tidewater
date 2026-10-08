import { test, expect } from '@playwright/test';

test.beforeEach(async ({ request }) => {
  await request.post('/reset');
});

test('clicking the button increments the count', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: '+' }).click();
  await expect(page.locator('p')).toHaveText('1');
});
