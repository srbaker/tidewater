import { defineConfig } from '@playwright/test';

export default defineConfig({
  testMatch: 'cluster.spec.js',
  workers: 1,
  use: { baseURL: 'http://localhost:8889' },
  webServer: [
    { command: '../bin/acceptance-server todo 8901 w1', url: 'http://localhost:8901/' },
    { command: '../bin/acceptance-server todo 8902 w2', url: 'http://localhost:8902/' },
    { command: 'node ../front/front.js 8889 w1=http://localhost:8901 w2=http://localhost:8902', url: 'http://localhost:8889/' },
  ],
});
