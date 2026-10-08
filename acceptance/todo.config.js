import { defineConfig } from '@playwright/test';

export default defineConfig({
  testMatch: 'todo.spec.js',
  workers: 1,
  use: { baseURL: 'http://localhost:8889' },
  webServer: {
    command: '../bin/acceptance-server todo 8889',
    url: 'http://localhost:8889/',
  },
});
