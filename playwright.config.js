import { defineConfig } from '@playwright/test';

export default defineConfig({
  testMatch: ['js/**/*.spec.js', 'front/**/*.spec.js'],
});
