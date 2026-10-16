import { defineConfig } from 'vitepress';
import { fileURLToPath } from 'node:url';
import { expandMethods } from './methods.js';

const root = fileURLToPath(new URL('../..', import.meta.url));

export default defineConfig({
  title: 'Tidewater',
  description: 'A live web framework for GemStone/S',
  base: '/tidewater/',
  cleanUrls: true,
  head: [['link', { rel: 'icon', href: '/tidewater/wave.svg' }]],
  markdown: {
    config: (md) => md.core.ruler.push('methods', (state) => expandMethods(state.tokens, root)),
  },
  themeConfig: {
    logo: '/wave.svg',
    nav: [
      { text: 'Guide', link: '/guide/getting-started' },
      { text: 'Reference', link: '/reference/html' },
    ],
    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'What is Tidewater?', link: '/guide/what-is-tidewater' },
          { text: 'Getting started', link: '/guide/getting-started' },
        ],
      },
      {
        text: 'Guide',
        items: [
          { text: 'Views', link: '/guide/views' },
          { text: 'Actions', link: '/guide/actions' },
          { text: 'State', link: '/guide/state' },
          { text: 'Composing views', link: '/guide/composing' },
          { text: 'Watching', link: '/guide/watching' },
          { text: 'In the browser', link: '/guide/browser' },
          { text: 'Testing', link: '/guide/testing' },
        ],
      },
      {
        text: 'Running it',
        items: [
          { text: 'Serving an app', link: '/running/serving' },
          { text: 'Scaling out', link: '/running/scaling' },
        ],
      },
      {
        text: 'How it works',
        items: [
          { text: 'Inside Tidewater', link: '/how-it-works' },
          { text: 'Notes from building it', link: '/notes' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'TwHtml', link: '/reference/html' },
          { text: 'TwView', link: '/reference/view' },
          { text: 'TwApp', link: '/reference/app' },
          { text: 'TwRoot and TwTestCase', link: '/reference/root-and-test-case' },
          { text: 'The client', link: '/reference/client' },
        ],
      },
    ],
    socialLinks: [{ icon: 'github', link: 'https://github.com/srbaker/tidewater' }],
    editLink: { pattern: 'https://github.com/srbaker/tidewater/edit/master/docs/:path' },
    search: { provider: 'local' },
    footer: { message: 'Released under the MIT License.' },
  },
});
