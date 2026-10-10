import { test, expect } from '@playwright/test';
import { commit } from './stone.js';

test.beforeEach(() => commit('(UserGlobals at: #TidewaterAcceptanceModel) clear'));

test('browsers on different workers see each other\'s changes', async ({ browser }) => {
  const one = await browser.newPage();
  const two = await browser.newPage();
  await one.goto('/');
  await two.goto('/');
  await expect(one.locator('[tw-view][tw-connected]')).toBeAttached();
  await expect(two.locator('[tw-view][tw-connected]')).toBeAttached();
  const worker = async (page) => (await page.locator('[tw-view]').first().getAttribute('tw-view')).split('.')[0];
  expect(await worker(one)).not.toEqual(await worker(two));

  await one.getByRole('textbox').fill('milk');
  await one.getByRole('button', { name: 'Add' }).click();

  await expect(one.getByRole('listitem')).toHaveText(['milk']);
  await expect(two.getByRole('listitem')).toHaveText(['milk']);
});
