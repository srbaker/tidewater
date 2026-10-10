import { test, expect } from '@playwright/test';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { commit } from './stone.js';

const base = 'http://localhost:8890';

async function startServer() {
  const server = spawn(fileURLToPath(new URL('../bin/acceptance-server', import.meta.url)), ['counter', '8890'], { stdio: 'ignore' });
  await expect.poll(async () => (await fetch(`${base}/`).catch(() => null))?.ok ?? false, { timeout: 30000 }).toBe(true);
  return server;
}

function stop(server) {
  return new Promise((resolve) => {
    server.on('exit', resolve);
    server.kill();
  });
}

test('a page recovers on its own when its server restarts', async ({ page }) => {
  commit('(UserGlobals at: #TidewaterAcceptanceModel put: TwCounter new)');
  let server = await startServer();
  try {
    await page.goto(base);
    await page.getByRole('button', { name: '+' }).click();
    await expect(page.locator('p')).toHaveText('1');

    await stop(server);
    await expect(page.locator('[tw-view][tw-reconnecting]')).toBeAttached();

    server = await startServer();
    await expect(page.locator('[tw-view][tw-connected]')).toBeAttached({ timeout: 15000 });
    await expect(page.locator('p')).toHaveText('1');
    await page.getByRole('button', { name: '+' }).click();
    await expect(page.locator('p')).toHaveText('2');
  } finally {
    await stop(server);
  }
});
