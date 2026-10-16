// Methods shown in the docs come straight from the source, so they can't drift from it.
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

function* classFiles(directory) {
  for (const entry of readdirSync(directory, { withFileTypes: true })) {
    if (entry.name === 'node_modules' || entry.name.startsWith('.')) continue;
    const path = join(directory, entry.name);
    if (entry.isDirectory()) yield* classFiles(path);
    else if (entry.name.endsWith('.class.st')) yield path;
  }
}

function selectorOf(pattern) {
  const keywords = pattern.match(/\S+:/g);
  return keywords ? keywords.join('') : pattern.trim().split(/\s+/)[0];
}

export function methodSource(root, reference) {
  const [receiver, selector] = reference.split(/\s*>>\s*/);
  const className = receiver.split(' ')[0];
  for (const path of classFiles(root)) {
    if (!path.endsWith(`/${className}.class.st`)) continue;
    const lines = readFileSync(path, 'utf8').split('\n');
    const start = lines.findIndex((line) => {
      const header = line.match(/^(.+?) >> (.+) \[$/);
      return header && header[1] === receiver && selectorOf(header[2]) === selector;
    });
    if (start < 0) break;
    const end = lines.indexOf(']', start);
    return [lines[start].slice(0, -2), ...lines.slice(start + 1, end)].join('\n');
  }
  throw new Error(`No method ${reference}`);
}

export function expandMethods(tokens, root) {
  for (const token of tokens) {
    if (token.type !== 'fence' || token.info.trim() !== 'methods') continue;
    const references = token.content.split('\n').filter((line) => line.trim());
    token.info = 'smalltalk';
    token.content = `${references.map((each) => methodSource(root, each)).join('\n\n')}\n`;
  }
}
