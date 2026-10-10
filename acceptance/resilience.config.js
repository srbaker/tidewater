import { defineConfig } from '@playwright/test';

export default defineConfig({
  testMatch: 'resilience.spec.js',
  workers: 1,
  timeout: 60000,
});
