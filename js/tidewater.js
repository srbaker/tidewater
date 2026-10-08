const view = () => document.querySelector('[tw-view]');
const id = view().getAttribute('tw-view');
const morph = (html) => morphdom(view(), `<div>${html}</div>`, { childrenOnly: true });

async function run(action, fields = '') {
  const response = await fetch(`/${id}/${action}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: fields.toString(),
  });
  morph(await response.text());
}

document.addEventListener('click', (event) => {
  const action = event.target.closest('[tw-click]')?.getAttribute('tw-click');
  if (action) run(action);
});

document.addEventListener('submit', (event) => {
  const form = event.target.closest('[tw-submit]');
  if (!form) return;
  event.preventDefault();
  run(form.getAttribute('tw-submit'), new URLSearchParams(new FormData(form)));
});

const events = new EventSource(`/events/${id}`);
events.onopen = () => view().setAttribute('tw-connected', '');
events.onmessage = (event) => morph(event.data);
