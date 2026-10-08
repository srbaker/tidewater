import { execFileSync } from 'node:child_process';

const password = process.env.TIDEWATER_STONE_PASSWORD ?? 'swordfish';
const stone = process.env.TIDEWATER_STONE ?? 'gs64stone';
const topaz = () => `${process.env.GEMSTONE}/bin/topaz`;
const committed = (output) => /String\] COMMITTED\s*$/m.test(output);
const script = (smalltalk) => `set user DataCurator pass ${password} gemstone ${stone}\nlogin\nrun\n${smalltalk}\n%\nlogout\nexit\n`;

export function commit(smalltalk) {
  const output = execFileSync(topaz(), ['-lq'], {
    encoding: 'utf8',
    input: script(`${smalltalk}.\nSystem commitTransaction ifTrue: ['COMMITTED'] ifFalse: ['NOT COMMITTED']`),
  });
  if (!committed(output)) throw new Error(`commit failed:\n${output}`);
}
