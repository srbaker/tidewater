// Do concurrent increments all land, and does every page end up showing them?
// Clicks over HTTP race with another session's commits, while every page's stream is open, so pushes abort mid-flight.
// Usage: node load/concurrent.js [base URL] [increment|slowIncrement] — against bin/acceptance-server counter.
// slowIncrement waits partway through, which is when a refresh in the same gem could discard it.
import { spawn } from 'node:child_process';
import { commit } from '../acceptance/stone.js';

const base = process.argv[2] ?? 'http://127.0.0.1:8889';
const action = process.argv[3] ?? 'increment';
const clients = 10;
const clicks = 20;
const external = 100;

function externalIncrements(count) {
  const password = process.env.TIDEWATER_STONE_PASSWORD ?? 'swordfish';
  const stone = process.env.TIDEWATER_STONE ?? 'gs64stone';
  const smalltalk = `| lost | lost := 0.
${count} timesRepeat: [[System abortTransaction. (UserGlobals at: #TidewaterAcceptanceModel) increment. System commitTransaction] whileFalse: [lost := lost + 1]].
'RETRIED ', lost printString`;
  return new Promise((resolve) => {
    const topaz = spawn(`${process.env.GEMSTONE}/bin/topaz`, ['-lq']);
    let output = '';
    topaz.stdout.on('data', (data) => { output += data; });
    topaz.on('close', () => resolve(output.match(/RETRIED (\d+)/)?.[1] ?? '?'));
    topaz.stdin.end(`set user DataCurator pass ${password} gemstone ${stone}\nlogin\nrun\n${smalltalk}\n%\nlogout\nexit\n`);
  });
}

const shown = [];
const statuses = {};

async function watch(index, id) {
  const response = await fetch(`${base}/events/${id}`);
  const reader = response.body.pipeThrough(new TextDecoderStream()).getReader();
  (async () => {
    for (;;) {
      const { value, done } = await reader.read();
      if (done) return;
      for (const match of value.matchAll(/<p>(\d+)<\/p>/g)) shown[index] = Number(match[1]);
    }
  })().catch(() => {});
  return reader;
}

async function client(index) {
  const html = await (await fetch(`${base}/`)).text();
  const id = html.match(/tw-view="([^"]+)"/)[1];
  const reader = await watch(index, id);
  for (let i = 0; i < clicks; i++) {
    const { status } = await fetch(`${base}/${id}/${action}`, { method: 'POST' });
    statuses[status] = (statuses[status] ?? 0) + 1;
  }
  return reader;
}

commit('(UserGlobals at: #TidewaterAcceptanceModel) reset');
const started = Date.now();
const [retried, ...readers] = await Promise.all([externalIncrements(external), ...Array.from({ length: clients }, (_, index) => client(index))]);
const final = await (await fetch(`${base}/`)).text();
const count = Number(final.match(/<p>(\d+)<\/p>/)[1]);
const expected = (statuses[200] ?? 0) + external;
console.log(`${clients} clients × ${clicks} ${action} clicks + ${external} external increments (external retried ${retried} conflicts) in ${Date.now() - started}ms`);
console.log(`clicks answered ${Object.entries(statuses).map(([status, n]) => `${status} ×${n}`).join(', ')}; a 409 gave up after conflicting ten times, and committed nothing`);
console.log(`count ${count}, expected ${expected} (accepted clicks + external): ${count === expected ? 'every increment landed' : `${expected - count} LOST`}`);
const settled = Date.now();
while (shown.some((each) => each !== count) && Date.now() - settled < 5000) await new Promise((resolve) => setTimeout(resolve, 50));
const behind = shown.filter((each) => each !== count).length;
console.log(behind ? `${behind} of ${clients} pages STILL BEHIND after 5s: ${shown.join(' ')}` : `every page shows ${count}`);
await Promise.all(readers.map((reader) => reader.cancel()));
