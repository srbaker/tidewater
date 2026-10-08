import { test, expect } from '@playwright/test';
import { fileURLToPath } from 'node:url';

const path = (file) => fileURLToPath(new URL(file, import.meta.url));

test('clicking an action posts it and morphs the response into the view', async ({ page }) => {
  await page.route('http://tidewater.test/', (route) =>
    route.fulfill({ contentType: 'text/html', body: '<div tw-view><p>0</p><button tw-click="increment">+</button></div>' }));
  await page.route('http://tidewater.test/increment', (route) =>
    route.fulfill({ body: '<p>1</p><button tw-click="increment">+</button>' }));
  await page.goto('http://tidewater.test/');
  await page.addScriptTag({ path: path('morphdom.js') });
  await page.addScriptTag({ path: path('tidewater.js') });
  const button = await page.getByRole('button').elementHandle();

  const posted = page.waitForRequest((request) => request.method() === 'POST');
  await button.click();

  expect((await posted).url()).toBe('http://tidewater.test/increment');
  await expect(page.locator('p')).toHaveText('1');
  expect(await button.evaluate((element) => element.isConnected)).toBe(true);
});
