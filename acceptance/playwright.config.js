import { defineConfig } from '@playwright/test';

export default defineConfig({
  use: { baseURL: 'http://localhost:8889' },
  webServer: {
    command: '../bin/acceptance-server 8889',
    url: 'http://localhost:8889/',
  },
});
