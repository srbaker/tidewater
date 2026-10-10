import { test, expect } from '@playwright/test';
import http from 'node:http';
import { fileURLToPath } from 'node:url';

const path = (file) => fileURLToPath(new URL(file, import.meta.url));

// A fake server that holds event streams open, like Tidewater does.
function eventServer() {
  const streams = [];
  let delay = 0;
  let page = '';
  const server = http.createServer(async (request, response) => {
    if (request.url === '/') {
      response.writeHead(200, { 'Content-Type': 'text/html' });
      return response.end(page);
    }
    if (delay) await new Promise((resolve) => setTimeout(resolve, delay));
    response.writeHead(200, { 'Content-Type': 'text/event-stream' });
    response.write('retry: 100\n\n');
    streams.push(response);
  });
  return new Promise((resolve) => server.listen(0, () => resolve({
    url: `http://127.0.0.1:${server.address().port}`,
    serve: (html) => { page = html; },
    connections: () => streams.length,
    send: (html) => streams.at(-1).write(`data: ${html}\n\n`),
    drop: () => streams.at(-1).destroy(),
    delayNextConnections: (ms) => { delay = ms; },
    close: () => { streams.forEach((stream) => stream.destroy()); server.close(); },
  })));
}

let events;
test.beforeEach(async () => { events = await eventServer(); });
test.afterEach(() => events.close());

async function open(page, { view = '<p>0</p><button tw-click="increment">+</button>', first } = {}) {
  events.serve(`<div tw-view="p1">${view}</div>`);
  await page.goto(`${events.url}/`);
  await page.addScriptTag({ path: path('morphdom.js') });
  await page.addScriptTag({ path: path('tidewater.js') });
  await expect.poll(() => events.connections()).toBe(1);
  if (first) events.send(first);
}

test('clicking an action posts it to its view and morphs the response into the view', async ({ page }) => {
  await page.route(`${events.url}/p1/increment`, (route) =>
    route.fulfill({ body: '<p>1</p><button tw-click="increment">+</button>' }));
  await open(page);
  const button = await page.getByRole('button').elementHandle();

  const posted = page.waitForRequest((request) => request.method() === 'POST');
  await button.click();

  expect((await posted).url()).toBe(`${events.url}/p1/increment`);
  await expect(page.locator('p')).toHaveText('1');
  expect(await button.evaluate((element) => element.isConnected)).toBe(true);
});

test('submitting a form posts its fields to its action', async ({ page }) => {
  await page.route(`${events.url}/p1/add`, (route) =>
    route.fulfill({ body: '<ul><li>milk</li></ul><form tw-submit="add"><input name="item"><button>Add</button></form>' }));
  await open(page, { view: '<ul></ul><form tw-submit="add"><input name="item"><button>Add</button></form>' });
  await page.getByRole('textbox').fill('milk');

  const posted = page.waitForRequest((request) => request.method() === 'POST');
  await page.getByRole('button').click();

  expect((await posted).url()).toBe(`${events.url}/p1/add`);
  expect((await posted).postData()).toBe('item=milk');
  expect((await posted).headers()['content-type']).toBe('application/x-www-form-urlencoded');
  await expect(page.getByRole('listitem')).toHaveText(['milk']);
  expect(page.url()).toBe(`${events.url}/`);
});

test('an action inside a child view posts to the child and morphs only the child', async ({ page }) => {
  await page.route(`${events.url}/p1-1/increment`, (route) =>
    route.fulfill({ body: '<p>1</p><button tw-click="increment">+</button>' }));
  await open(page, { view: '<p>outer</p><div tw-view="p1-1"><p>0</p><button tw-click="increment">+</button></div>' });

  const posted = page.waitForRequest((request) => request.method() === 'POST');
  await page.getByRole('button').click();

  expect((await posted).url()).toBe(`${events.url}/p1-1/increment`);
  await expect(page.locator('[tw-view="p1-1"] p')).toHaveText('1');
  await expect(page.locator('[tw-view="p1"] > p')).toHaveText('outer');
});

test('typing in an input posts its value once typing pauses', async ({ page }) => {
  const posts = [];
  await page.route(`${events.url}/p1/filter`, (route) => {
    posts.push(route.request().postData());
    route.fulfill({ body: '<input type="search" name="filter" tw-input="filter" tw-debounce="100"><ul><li>milk</li></ul>' });
  });
  await open(page, { view: '<input type="search" name="filter" tw-input="filter" tw-debounce="100"><ul><li>milk</li><li>eggs</li></ul>' });

  await page.getByRole('searchbox').pressSequentially('milk', { delay: 20 });
  await expect(page.getByRole('listitem')).toHaveText(['milk']);
  await page.waitForTimeout(200);

  expect(posts).toEqual(['filter=milk']);
});

test('morphing leaves the element being typed in alone', async ({ page }) => {
  await page.route(`${events.url}/p1/filter`, (route) =>
    route.fulfill({ body: '<input type="search" name="filter" tw-input="filter" value=""><ul><li>milk</li></ul>' }));
  await open(page, { view: '<input type="search" name="filter" tw-input="filter"><ul><li>milk</li><li>eggs</li></ul>' });

  await page.getByRole('searchbox').pressSequentially('mi');

  await expect(page.getByRole('listitem')).toHaveText(['milk']);
  await expect(page.getByRole('searchbox')).toHaveValue('mi');
});

test('marks the view connected once its first event arrives', async ({ page }) => {
  await open(page, { first: '<p>0</p><button tw-click="increment">+</button>' });

  await expect(page.locator('[tw-view][tw-connected]')).toBeAttached();
});

test('does not mark the view connected while its stream sends nothing', async ({ page }) => {
  await open(page);
  await page.waitForTimeout(300);

  await expect(page.locator('[tw-view][tw-connected]')).toHaveCount(0);
});

test('morphs pushed events into the view', async ({ page }) => {
  await open(page, { first: '<p>5</p><button tw-click="increment">+</button>' });

  await expect(page.locator('p')).toHaveText('5');
});

test('a hook is mounted on elements that are already on the page', async ({ page }) => {
  await open(page, { view: '<input tw-hook="mark">' });

  await page.evaluate(() => tidewater.hook('mark', { mounted: (element) => { element.value = 'mounted'; } }));

  await expect(page.getByRole('textbox')).toHaveValue('mounted');
});

test('a hook is mounted on elements a morph adds, and told when a morph updates them', async ({ page }) => {
  await page.route(`${events.url}/p1/add`, (route) =>
    route.fulfill({ body: '<p tw-hook="mark" class="new">one</p><button tw-click="change">+</button>' }));
  await page.route(`${events.url}/p1/change`, (route) =>
    route.fulfill({ body: '<p tw-hook="mark" class="changed">one</p><button tw-click="change">+</button>' }));
  await open(page, { view: '<button tw-click="add">+</button>' });
  await page.evaluate(() => tidewater.hook('mark', {
    mounted: (element) => { element.dataset.mounted = 'yes'; },
    updated: (element) => { element.dataset.updated = 'yes'; },
  }));

  await page.getByRole('button').click();
  await expect(page.locator('p[data-mounted="yes"]')).toHaveCount(1);
  await page.getByRole('button').click();

  await expect(page.locator('p.changed[data-updated="yes"]')).toHaveCount(1);
});

test('shows the view reconnecting while its stream is down, and connected once it is back', async ({ page }) => {
  await open(page, { first: '<p>0</p>' });
  await expect(page.locator('[tw-view][tw-connected]')).toBeAttached();

  events.delayNextConnections(1000);
  events.drop();

  await expect(page.locator('[tw-view][tw-reconnecting]:not([tw-connected])')).toBeAttached();
  await expect.poll(() => events.connections()).toBe(2);
  events.send('<p>1</p>');
  await expect(page.locator('[tw-view][tw-connected]:not([tw-reconnecting])')).toBeAttached();
  await expect(page.locator('p')).toHaveText('1');
});

test('reloads the page when its view is gone', async ({ page }) => {
  let visits = 0;
  await page.route('http://tidewater.test/', (route) => {
    visits += 1;
    route.fulfill({ contentType: 'text/html', body: '<div tw-view="p1"><p>0</p></div>' });
  });
  await page.route('http://tidewater.test/events/p1', (route) =>
    route.fulfill({ contentType: 'text/event-stream', body: 'event: gone\ndata: \n\n' }));
  await page.goto('http://tidewater.test/');
  await page.addScriptTag({ path: path('morphdom.js') });
  await page.addScriptTag({ path: path('tidewater.js') });

  await expect.poll(() => visits).toBe(2);
});

test('queues actions that fail while disconnected, and sends them once connected', async ({ page }) => {
  let attempts = 0;
  await page.route(`${events.url}/p1/increment`, (route) => {
    attempts += 1;
    if (attempts === 1) return route.abort();
    return route.fulfill({ body: '<p>1</p><button tw-click="increment">+</button>' });
  });
  await open(page, { first: '<p>0</p><button tw-click="increment">+</button>' });
  await expect(page.locator('[tw-view][tw-connected]')).toBeAttached();
  events.drop();

  await page.getByRole('button').click();
  await expect.poll(() => attempts).toBe(1);
  await expect.poll(() => events.connections()).toBe(2);
  events.send('<p>0</p><button tw-click="increment">+</button>');

  await expect.poll(() => attempts).toBe(2);
  await expect(page.locator('p')).toHaveText('1');
});
