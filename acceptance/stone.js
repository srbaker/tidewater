import { execFileSync } from 'node:child_process';

const password = process.env.TIDEWATER_STONE_PASSWORD ?? 'swordfish';
const stone = process.env.TIDEWATER_STONE ?? 'gs64stone';

export function commit(smalltalk) {
  execFileSync(`${process.env.GEMSTONE}/bin/topaz`, ['-lq'], {
    input: `set user DataCurator pass ${password} gemstone ${stone}\nlogin\nrun\n${smalltalk}.\nSystem commitTransaction\n%\nlogout\nexit\n`,
  });
}
