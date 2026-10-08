const view = () => document.querySelector('[tw-view]');
const morph = (html) => morphdom(view(), `<div>${html}</div>`, { childrenOnly: true });

document.addEventListener('click', async (event) => {
  const action = event.target.closest('[tw-click]')?.getAttribute('tw-click');
  if (!action) return;
  const response = await fetch(`/${action}`, { method: 'POST' });
  morph(await response.text());
});

const events = new EventSource('/events');
events.onopen = () => view().setAttribute('tw-connected', '');
events.onmessage = (event) => morph(event.data);
