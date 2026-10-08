import { test, expect } from '@playwright/test';
import { fileURLToPath } from 'node:url';

const path = (file) => fileURLToPath(new URL(file, import.meta.url));

async function open(page, { events = '' } = {}) {
  await page.route('http://tidewater.test/', (route) =>
    route.fulfill({ contentType: 'text/html', body: '<div tw-view><p>0</p><button tw-click="increment">+</button></div>' }));
  await page.route('http://tidewater.test/events', (route) =>
    route.fulfill({ contentType: 'text/event-stream', body: events }));
  await page.goto('http://tidewater.test/');
  await page.addScriptTag({ path: path('morphdom.js') });
  await page.addScriptTag({ path: path('tidewater.js') });
}

test('clicking an action posts it and morphs the response into the view', async ({ page }) => {
  await page.route('http://tidewater.test/increment', (route) =>
    route.fulfill({ body: '<p>1</p><button tw-click="increment">+</button>' }));
  await open(page);
  const button = await page.getByRole('button').elementHandle();

  const posted = page.waitForRequest((request) => request.method() === 'POST');
  await button.click();

  expect((await posted).url()).toBe('http://tidewater.test/increment');
  await expect(page.locator('p')).toHaveText('1');
  expect(await button.evaluate((element) => element.isConnected)).toBe(true);
});

test('marks the view connected once its event stream opens', async ({ page }) => {
  await open(page);

  await expect(page.locator('[tw-view][tw-connected]')).toBeAttached();
});

test('morphs pushed events into the view', async ({ page }) => {
  await open(page, { events: 'data: <p>5</p><button tw-click="increment">+</button>\n\n' });

  await expect(page.locator('p')).toHaveText('5');
});
