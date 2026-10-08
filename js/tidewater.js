const root = () => document.querySelector('[tw-view]');
const morph = (view, html) => morphdom(view, `<div>${html}</div>`, { childrenOnly: true });

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

const events = new EventSource(`/events/${root().getAttribute('tw-view')}`);
events.onmessage = (event) => {
  morph(root(), event.data);
  root().setAttribute('tw-connected', '');
};
