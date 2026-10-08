document.addEventListener('click', async (event) => {
  const action = event.target.closest('[tw-click]')?.getAttribute('tw-click');
  if (!action) return;
  const response = await fetch(`/${action}`, { method: 'POST' });
  morphdom(document.querySelector('[tw-view]'), `<div tw-view>${await response.text()}</div>`);
});
