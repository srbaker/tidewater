import { test, expect } from '@playwright/test';
import { fileURLToPath } from 'node:url';

const path = (file) => fileURLToPath(new URL(file, import.meta.url));

async function open(page, { view = '<p>0</p><button tw-click="increment">+</button>', events = '' } = {}) {
  await page.route('http://tidewater.test/', (route) =>
    route.fulfill({ contentType: 'text/html', body: `<div tw-view="p1">${view}</div>` }));
  await page.route('http://tidewater.test/events/p1', (route) =>
    route.fulfill({ contentType: 'text/event-stream', body: events }));
  await page.goto('http://tidewater.test/');
  await page.addScriptTag({ path: path('morphdom.js') });
  await page.addScriptTag({ path: path('tidewater.js') });
}

test('clicking an action posts it to its view and morphs the response into the view', async ({ page }) => {
  await page.route('http://tidewater.test/p1/increment', (route) =>
    route.fulfill({ body: '<p>1</p><button tw-click="increment">+</button>' }));
  await open(page);
  const button = await page.getByRole('button').elementHandle();

  const posted = page.waitForRequest((request) => request.method() === 'POST');
  await button.click();

  expect((await posted).url()).toBe('http://tidewater.test/p1/increment');
  await expect(page.locator('p')).toHaveText('1');
  expect(await button.evaluate((element) => element.isConnected)).toBe(true);
});

test('submitting a form posts its fields to its action', async ({ page }) => {
  await page.route('http://tidewater.test/p1/add', (route) =>
    route.fulfill({ body: '<ul><li>milk</li></ul><form tw-submit="add"><input name="item"><button>Add</button></form>' }));
  await open(page, { view: '<ul></ul><form tw-submit="add"><input name="item"><button>Add</button></form>' });
  await page.getByRole('textbox').fill('milk');

  const posted = page.waitForRequest((request) => request.method() === 'POST');
  await page.getByRole('button').click();

  expect((await posted).url()).toBe('http://tidewater.test/p1/add');
  expect((await posted).postData()).toBe('item=milk');
  expect((await posted).headers()['content-type']).toBe('application/x-www-form-urlencoded');
  await expect(page.getByRole('listitem')).toHaveText(['milk']);
  expect(page.url()).toBe('http://tidewater.test/');
});

test('marks the view connected once its event stream opens', async ({ page }) => {
  await open(page);

  await expect(page.locator('[tw-view][tw-connected]')).toBeAttached();
});

test('morphs pushed events into the view', async ({ page }) => {
  await open(page, { events: 'data: <p>5</p><button tw-click="increment">+</button>\n\n' });

  await expect(page.locator('p')).toHaveText('5');
});
