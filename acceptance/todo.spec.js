import { test, expect } from '@playwright/test';
import { commit } from './stone.js';

test.beforeEach(() => commit('(UserGlobals at: #TidewaterAcceptanceModel) clear'));

async function openTwo(browser) {
  const one = await browser.newPage();
  const two = await browser.newPage();
  await one.goto('/');
  await two.goto('/');
  await expect(one.locator('[tw-view][tw-connected]')).toBeAttached();
  await expect(two.locator('[tw-view][tw-connected]')).toBeAttached();
  return [one, two];
}

test('adding an item shows it on every open page', async ({ browser }) => {
  const [one, two] = await openTwo(browser);

  await one.getByRole('textbox').fill('milk');
  await one.getByRole('button', { name: 'Add' }).click();

  await expect(one.getByRole('listitem')).toHaveText(['milk']);
  await expect(two.getByRole('listitem')).toHaveText(['milk']);
});

test('a blank item shows an error on that page only', async ({ browser }) => {
  const [one, two] = await openTwo(browser);

  await one.getByRole('button', { name: 'Add' }).click();
  await expect(one.getByText("Item can't be blank")).toBeVisible();

  commit("(UserGlobals at: #TidewaterAcceptanceModel) add: 'eggs'");

  await expect(two.getByRole('listitem')).toHaveText(['eggs']);
  await expect(one.getByRole('listitem')).toHaveText(['eggs']);
  await expect(one.getByText("Item can't be blank")).toBeVisible();
  await expect(two.getByText("Item can't be blank")).toHaveCount(0);
});

test('typing a filter narrows that page\'s list as you type', async ({ browser }) => {
  commit("(UserGlobals at: #TidewaterAcceptanceModel) add: 'milk'; add: 'eggs'");
  const [one, two] = await openTwo(browser);

  await one.getByRole('searchbox').pressSequentially('mi');

  await expect(one.getByRole('listitem')).toHaveText(['milk']);
  await expect(one.getByRole('searchbox')).toHaveValue('mi');
  await expect(two.getByRole('listitem')).toHaveText(['milk', 'eggs']);
});
