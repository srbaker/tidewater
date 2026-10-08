import { execFileSync } from 'node:child_process';

const password = process.env.TIDEWATER_STONE_PASSWORD ?? 'swordfish';
const stone = process.env.TIDEWATER_STONE ?? 'gs64stone';

export function commit(smalltalk) {
  const output = execFileSync(`${process.env.GEMSTONE}/bin/topaz`, ['-lq'], {
    encoding: 'utf8',
    input: `set user DataCurator pass ${password} gemstone ${stone}\nlogin\nrun\n${smalltalk}.\nSystem commitTransaction ifTrue: ['COMMITTED'] ifFalse: ['NOT COMMITTED']\n%\nlogout\nexit\n`,
  });
  if (!output.includes("'COMMITTED'")) throw new Error(`commit failed:\n${output}`);
}
