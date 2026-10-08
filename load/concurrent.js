// Do concurrent increments all land? Clicks over HTTP race with another session's commits.
// Usage: node load/concurrent.js [base URL] — against bin/acceptance-server counter.
import { spawn } from 'node:child_process';
import { commit } from '../acceptance/stone.js';

const base = process.argv[2] ?? 'http://127.0.0.1:8889';
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

async function client() {
  const html = await (await fetch(`${base}/`)).text();
  const id = html.match(/tw-view="([^"]+)"/)[1];
  for (let i = 0; i < clicks; i++) await fetch(`${base}/${id}/increment`, { method: 'POST' });
}

commit('(UserGlobals at: #TidewaterAcceptanceModel) reset');
const started = Date.now();
const [retried] = await Promise.all([externalIncrements(external), ...Array.from({ length: clients }, client)]);
const final = await (await fetch(`${base}/`)).text();
const count = Number(final.match(/<p>(\d+)<\/p>/)[1]);
const expected = clients * clicks + external;
console.log(`${clients} clients × ${clicks} clicks + ${external} external increments (external retried ${retried} conflicts) in ${Date.now() - started}ms`);
console.log(`count ${count}, expected ${expected}: ${count === expected ? 'every increment landed' : `${expected - count} LOST`}`);
