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

window.tidewater = {
  hook(name, callbacks) {
    hooks[name] = callbacks;
    document.querySelectorAll(`[tw-hook="${name}"]`).forEach((element) => call(element, 'mounted'));
  },
};

async function run(element, action, fields = '') {
  const view = element.closest('[tw-view]');
  const response = await fetch(`/${view.getAttribute('tw-view')}/${action}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: fields.toString(),
  });
  morph(view, await response.text());
}

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
  morph(root(), event.data);
  root().setAttribute('tw-connected', '');
};
