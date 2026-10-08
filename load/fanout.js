// How long does one commit take to reach every open page?
// Usage: node load/fanout.js [base URL] — against a server like bin/acceptance-server.

const base = process.argv[2] ?? 'http://localhost:8890';
const rounds = 20;

async function openStream(onCount) {
  const response = await fetch(`${base}/events`);
  const reader = response.body.pipeThrough(new TextDecoderStream()).getReader();
  (async () => {
    for (;;) {
      const { value, done } = await reader.read();
      if (done) return;
      for (const match of value.matchAll(/<p>(\d+)<\/p>/g)) onCount(Number(match[1]));
    }
  })().catch(() => {});
  return reader;
}

function percentile(sorted, p) {
  return sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * p))];
}

async function measure(size) {
  await fetch(`${base}/reset`, { method: 'POST' });
  const seen = new Array(size).fill(0);
  const opened = Date.now();
  const readers = [];
  for (let i = 0; i < size; i++) readers.push(await openStream((count) => { seen[i] = Math.max(seen[i], count); }));
  const openTime = Date.now() - opened;

  const latencies = [];
  for (let round = 1; round <= rounds; round++) {
    const start = performance.now();
    await fetch(`${base}/increment`, { method: 'POST' });
    while (seen.some((count) => count < round)) {
      if (performance.now() - start > 10000) throw new Error(`round ${round}: only ${seen.filter((c) => c >= round).length}/${size} streams updated after 10s`);
      await new Promise((resolve) => setTimeout(resolve, 1));
    }
    latencies.push(performance.now() - start);
  }
  await Promise.all(readers.map((reader) => reader.cancel()));

  latencies.sort((a, b) => a - b);
  const ms = (n) => `${n.toFixed(1)}ms`;
  console.log(`${String(size).padStart(4)} streams: opened in ${openTime}ms; commit → every page p50 ${ms(percentile(latencies, 0.5))}, p95 ${ms(percentile(latencies, 0.95))}, max ${ms(latencies.at(-1))}`);
}

for (const size of [10, 100, 500]) {
  try {
    await measure(size);
  } catch (error) {
    console.log(`${String(size).padStart(4)} streams: FAILED — ${error.message}${error.cause ? ` (${error.cause.code ?? ""} ${error.cause.message})` : ""}`);
  }
}
