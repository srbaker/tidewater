import { test, expect } from '@playwright/test';
import http from 'node:http';
import { front } from './front.js';

function fakeWorker(name) {
  const worker = { name, posts: [], relay: null };
  worker.server = http.createServer((request, response) => {
    let body = '';
    request.on('data', (chunk) => { body += chunk; });
    request.on('end', () => {
      if (request.url === '/relay') {
        response.writeHead(200, { 'Content-Type': 'text/event-stream' });
        response.flushHeaders();
        worker.relay = response;
      } else if (request.url.startsWith('/views/')) {
        if (request.url.includes('nope')) { response.writeHead(404); return response.end(); }
        response.end(`<p>current ${request.url.slice(7)}</p>`);
      } else if (request.method === 'POST') {
        worker.posts.push({ url: request.url, body, type: request.headers['content-type'], length: request.headers['content-length'] });
        response.end(`<p>${name} ran ${request.url}</p>`);
      } else {
        response.end(`${name} served ${request.url}`);
      }
    });
  });
  return new Promise((resolve) => worker.server.listen(0, () => {
    worker.url = `http://127.0.0.1:${worker.server.address().port}`;
    resolve(worker);
  }));
}

async function cluster() {
  const workers = [await fakeWorker('w1'), await fakeWorker('w2')];
  const server = await front({ port: 0, workers: workers.map(({ name, url }) => ({ name, url })) });
  const base = `http://127.0.0.1:${server.address().port}`;
  await expect.poll(() => workers.every((worker) => worker.relay)).toBe(true);
  return { base, workers, close: () => { server.close(); workers.forEach((worker) => { worker.relay?.end(); worker.server.close(); }); } };
}

async function readEvents(response, count) {
  const reader = response.body.pipeThrough(new TextDecoderStream()).getReader();
  let text = '';
  while (text.split('\n\n').length <= count) text += (await reader.read()).value;
  reader.cancel();
  return text.split('\n\n').slice(0, count);
}

test('sends new visits to the workers in turn', async () => {
  const { base, close } = await cluster();
  const first = await (await fetch(`${base}/`)).text();
  const second = await (await fetch(`${base}/`)).text();
  close();

  expect([first, second]).toEqual(['w1 served /', 'w2 served /']);
});

test('sends an action to the worker that holds its view', async () => {
  const { base, workers, close } = await cluster();
  const response = await fetch(`${base}/w2.abc-1/add`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'item=milk',
  });
  const html = await response.text();
  close();

  expect(html).toBe('<p>w2 ran /w2.abc-1/add</p>');
  expect(workers[1].posts).toEqual([{ url: '/w2.abc-1/add', body: 'item=milk', type: 'application/x-www-form-urlencoded', length: '9' }]);
  expect(workers[0].posts).toEqual([]);
});

test('streams a view its current render, then only the pushes for it', async () => {
  const { base, workers, close } = await cluster();
  const stream = await fetch(`${base}/events/w1.abc`);
  const events = readEvents(stream, 2);
  await new Promise((resolve) => setTimeout(resolve, 100));
  workers[0].relay.write('event: w1.other\ndata: <p>not mine</p>\n\n');
  workers[0].relay.write('event: w1.abc\ndata: <ul>\ndata: <li>milk</li></ul>\n\n');

  expect(await events).toEqual(['data: <p>current w1.abc</p>', 'data: <ul>\ndata: <li>milk</li></ul>']);
  close();
});

test('serves scripts from a worker', async () => {
  const { base, close } = await cluster();
  const script = await (await fetch(`${base}/tidewater.js`)).text();
  close();

  expect(script).toBe('w1 served /tidewater.js');
});

test('tells a browser when the worker no longer has its view', async () => {
  const { base, close } = await cluster();
  const events = await readEvents(await fetch(`${base}/events/w1.nope`), 1);
  close();

  expect(events).toEqual(['event: gone\ndata: ']);
});

test('tells a worker\'s browsers their views are gone when its relay drops', async () => {
  const { base, workers, close } = await cluster();
  const stream = await fetch(`${base}/events/w1.abc`);
  const events = readEvents(stream, 2);
  await new Promise((resolve) => setTimeout(resolve, 100));
  workers[0].relay.end();

  expect(await events).toEqual(['data: <p>current w1.abc</p>', 'event: gone\ndata: ']);
  close();
});

test('asks the worker that holds a view for its history', async () => {
  const { base, close } = await cluster();
  const history = await (await fetch(`${base}/history/w2.abc`)).text();
  close();

  expect(history).toBe('w2 served /history/w2.abc');
});
