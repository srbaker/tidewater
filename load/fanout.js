// How long does one commit take to reach every open page?
// Usage: node load/fanout.js [base URL] [page counts...] — against a counter app, alone or behind front/front.js.

const [base = 'http://127.0.0.1:8889', ...sizes] = process.argv.slice(2);
const rounds = 10;

async function openPage(onCount) {
  const html = await (await fetch(`${base}/`)).text();
  const id = html.match(/tw-view="([^"]+)"/)[1];
  const response = await fetch(`${base}/events/${id}`);
  const reader = response.body.pipeThrough(new TextDecoderStream()).getReader();
  (async () => {
    for (;;) {
      const { value, done } = await reader.read();
      if (done) return;
      for (const match of value.matchAll(/<p>(\d+)<\/p>/g)) onCount(Number(match[1]));
    }
  })().catch(() => {});
  return { id, reader };
}

const percentile = (sorted, p) => sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * p))];
const ms = (n) => `${n.toFixed(1)}ms`;

async function measure(size) {
  const seen = new Array(size).fill(-1);
  const opened = Date.now();
  const pages = [];
  for (let i = 0; i < size; i++) pages.push(await openPage((count) => { seen[i] = Math.max(seen[i], count); }));
  const openTime = Date.now() - opened;
  while (seen.some((count) => count < 0)) await new Promise((resolve) => setTimeout(resolve, 10));

  const latencies = [];
  for (let round = 0; round < rounds; round++) {
    const target = Math.max(...seen) + 1;
    const start = performance.now();
    await fetch(`${base}/${pages[0].id}/increment`, { method: 'POST' });
    while (seen.some((count) => count < target)) {
      if (performance.now() - start > 30000) throw new Error(`only ${seen.filter((count) => count >= target).length}/${size} pages updated after 30s`);
      await new Promise((resolve) => setTimeout(resolve, 2));
    }
    latencies.push(performance.now() - start);
  }
  await Promise.all(pages.map(({ reader }) => reader.cancel()));

  latencies.sort((a, b) => a - b);
  console.log(`${String(size).padStart(6)} pages: opened in ${openTime}ms; commit → every page p50 ${ms(percentile(latencies, 0.5))}, p95 ${ms(percentile(latencies, 0.95))}, max ${ms(latencies.at(-1))}`);
}

for (const size of (sizes.length ? sizes : ['10', '100', '1000']).map(Number)) {
  try {
    await measure(size);
  } catch (error) {
    console.log(`${String(size).padStart(6)} pages: FAILED — ${error.message}${error.cause ? ` (${error.cause.code ?? ''})` : ''}`);
  }
}
