const root = () => document.querySelector('[tw-view]');
const hooks = {};

const call = (element, callback) => hooks[element.getAttribute('tw-hook')]?.[callback]?.(element);
const hooked = (node) => node.nodeType === Node.ELEMENT_NODE
  ? [node, ...node.querySelectorAll('[tw-hook]')].filter((element) => element.hasAttribute('tw-hook'))
  : [];

const morph = (view, html) => morphdom(view, `<div>${html}</div>`, {
  childrenOnly: true,
  onBeforeElUpdated: (element) => element !== document.activeElement,
  onNodeAdded: (node) => { hooked(node).forEach((element) => call(element, 'mounted')); return node; },
  onElUpdated: (element) => { if (element.hasAttribute('tw-hook')) call(element, 'updated'); },
});

let latest;
let traveling = false;

window.tidewater = {
  hook(name, callbacks) {
    hooks[name] = callbacks;
    document.querySelectorAll(`[tw-hook="${name}"]`).forEach((element) => call(element, 'mounted'));
  },

  async travel(steps) {
    const history = await (await fetch(`/history/${root().getAttribute('tw-view')}`)).json();
    traveling = true;
    root().setAttribute('tw-traveling', '');
    morph(root(), history[Math.max(0, history.length - 1 + steps)]);
  },

  present() {
    traveling = false;
    root().removeAttribute('tw-traveling');
    if (latest !== undefined) morph(root(), latest);
  },
};

const pending = [];

async function send(id, action, fields) {
  const view = document.querySelector(`[tw-view="${id}"]`);
  try {
    const response = await fetch(`/${id}/${action}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: fields,
    });
    morph(view, await response.text());
  } catch {
    pending.push(() => send(id, action, fields));
  }
}

const run = (element, action, fields = '') =>
  send(element.closest('[tw-view]').getAttribute('tw-view'), action, fields.toString());

document.addEventListener('click', (event) => {
  const element = event.target.closest('[tw-click]');
  if (element) run(element, element.getAttribute('tw-click'));
});

document.addEventListener('submit', (event) => {
  const form = event.target.closest('[tw-submit]');
  if (!form) return;
  event.preventDefault();
  run(form, form.getAttribute('tw-submit'), new URLSearchParams(new FormData(form)));
});

const pauses = new WeakMap();

document.addEventListener('input', (event) => {
  const input = event.target.closest('[tw-input]');
  if (!input) return;
  clearTimeout(pauses.get(input));
  pauses.set(input, setTimeout(
    () => run(input, input.getAttribute('tw-input'), new URLSearchParams({ [input.name]: input.value })),
    Number(input.getAttribute('tw-debounce') ?? 0)));
});

const events = new EventSource(`/events/${root().getAttribute('tw-view')}`);

events.onmessage = (event) => {
  latest = event.data;
  if (!traveling) morph(root(), latest);
  root().setAttribute('tw-connected', '');
  root().removeAttribute('tw-reconnecting');
  pending.splice(0).forEach((action) => action());
};

events.onerror = () => {
  root().setAttribute('tw-reconnecting', '');
  root().removeAttribute('tw-connected');
};

events.addEventListener('gone', () => location.reload());
