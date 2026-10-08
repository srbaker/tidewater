import { test, expect } from '@playwright/test';
import { commit } from './stone.js';

test.beforeEach(() => commit('(UserGlobals at: #TidewaterAcceptanceModel) reset'));

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

test('a commit from another session updates the page', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('[tw-view][tw-connected]')).toBeAttached();

  commit('(UserGlobals at: #TidewaterAcceptanceModel) increment');

  await expect(page.locator('p')).toHaveText('1');
});
