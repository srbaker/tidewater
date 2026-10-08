import { test, expect } from '@playwright/test';

test.beforeEach(async ({ request }) => {
  await request.post('/reset');
});

test('clicking the button increments the count', async ({ page }) => {
  await page.goto('/');
  await page.getByRole('button', { name: '+' }).click();
  await expect(page.locator('p')).toHaveText('1');
});

test('a click in one browser updates another', async ({ browser }) => {
  const one = await browser.newPage();
  const two = await browser.newPage();
  await one.goto('/');
  await two.goto('/');
  await expect(two.locator('[tw-view][tw-connected]')).toBeAttached();

  await one.getByRole('button', { name: '+' }).click();

  await expect(two.locator('p')).toHaveText('1');
});
