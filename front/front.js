// Tidewater's front end: holds every browser's event stream, and spreads the work over worker gems.
// Usage: node front/front.js PORT NAME=URL [NAME=URL ...]
import http from 'node:http';
import { fileURLToPath } from 'node:url';

export function front({ port, workers }) {
  const streams = new Map();
  let turn = 0;

  const workerFor = (id) => workers.find((worker) => worker.name === id.split('.')[0]);

  function send(stream, html) {
    stream.response.write(`${html.split('\n').map((line) => `data: ${line}`).join('\n')}\n\n`);
  }

  function gone(stream) {
    stream.response.write('event: gone\ndata: \n\n');
  }

  function forget(worker) {
    for (const [id, entries] of streams) {
      if (workerFor(id) === worker) entries.forEach(gone);
    }
  }

  function deliver(id, html) {
    for (const stream of streams.get(id) ?? []) {
      stream.pushed = true;
      send(stream, html);
    }
  }

  function relay(worker) {
    http.get(`${worker.url}/relay`, (response) => {
      let buffer = '';
      response.setEncoding('utf8');
      response.on('data', (chunk) => {
        buffer += chunk;
        const events = buffer.split('\n\n');
        buffer = events.pop();
        for (const event of events) {
          const lines = event.split('\n');
          const id = lines.find((line) => line.startsWith('event: '))?.slice(7);
          const html = lines.filter((line) => line.startsWith('data: ')).map((line) => line.slice(6)).join('\n');
          if (id) deliver(id, html);
        }
      });
      response.on('end', () => {
        forget(worker);
        setTimeout(() => relay(worker), 1000);
      });
    }).on('error', () => setTimeout(() => relay(worker), 1000));
  }

  function forward(request, response, worker) {
    const headers = {};
    for (const name of ['content-type', 'content-length']) {
      if (request.headers[name]) headers[name] = request.headers[name];
    }
    const upstream = http.request(`${worker.url}${request.url}`, { method: request.method, headers }, (answer) => {
      response.writeHead(answer.statusCode, answer.headers);
      answer.pipe(response);
    });
    upstream.on('error', () => { response.writeHead(502); response.end(); });
    request.pipe(upstream);
  }

  function stream(request, response, id) {
    const worker = workerFor(id);
    if (!worker) { response.writeHead(404); return response.end(); }
    response.writeHead(200, { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache' });
    const entry = { response, pushed: false };
    streams.set(id, (streams.get(id) ?? new Set()).add(entry));
    request.on('close', () => streams.get(id)?.delete(entry));
    http.get(`${worker.url}/views/${id}`, (answer) => {
      let html = '';
      answer.setEncoding('utf8');
      answer.on('data', (chunk) => { html += chunk; });
      answer.on('end', () => {
        if (answer.statusCode === 404) return gone(entry);
        if (!entry.pushed) send(entry, html);
      });
    });
  }

  const server = http.createServer((request, response) => {
    const path = request.url;
    if (request.method === 'GET' && path.startsWith('/events/')) return stream(request, response, path.slice(8));
    if (request.method === 'GET' && path === '/') return forward(request, response, workers[turn++ % workers.length]);
    if (request.method === 'POST') {
      const worker = workerFor(path.slice(1));
      if (!worker) { response.writeHead(404); return response.end(); }
      return forward(request, response, worker);
    }
    return forward(request, response, workers[0]);
  });

  workers.forEach(relay);
  return new Promise((resolve) => server.listen(port, () => resolve(server)));
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [port, ...pairs] = process.argv.slice(2);
  const workers = pairs.map((pair) => {
    const [name, url] = pair.split('=');
    return { name, url };
  });
  front({ port: Number(port), workers });
}
