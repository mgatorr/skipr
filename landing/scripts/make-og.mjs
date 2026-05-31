// Generate hand-made Open Graph cards (1200×630 PNG) in the skipr terminal aesthetic.
// Run: node scripts/make-og.mjs   (sharp rasterizes the SVG templates)
import sharp from 'sharp';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const outDir = resolve(here, '../public/og');

const BG = '#0a0e0d';
const FG = '#d6e2dd';
const MUTED = '#7d8f88';
const ACCENT = '#3ddc84';
const FONT = 'JetBrains Mono, SFMono-Regular, Menlo, monospace';

function card({ kicker, title, sub }) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <rect width="1200" height="630" fill="${BG}"/>
  <rect x="40" y="40" width="1120" height="550" rx="14" fill="none" stroke="#1c2a26" stroke-width="2"/>
  <g font-family="${FONT}">
    <text x="80" y="140" font-size="26" fill="${ACCENT}">▲ ${kicker}</text>
    <text x="78" y="300" font-size="60" font-weight="700" fill="${FG}">${title}</text>
    <text x="80" y="378" font-size="30" fill="${MUTED}">${sub}</text>
    <text x="80" y="560" font-size="24" fill="${MUTED}">skipr.dev · not affiliated with Anthropic</text>
  </g>
</svg>`;
}

const cards = {
  'default.png': card({
    kicker: 'skipr — coming soon',
    title: 'Build real software with AI',
    sub: 'and actually own it. Not a black box.',
  }),
  'from-no-code.png': card({
    kicker: 'skipr — article',
    title: 'From no-code to',
    sub: 'software you actually own.',
  }),
};

await mkdir(outDir, { recursive: true });
for (const [name, svg] of Object.entries(cards)) {
  await sharp(Buffer.from(svg)).png().toFile(resolve(outDir, name));
  console.log('wrote', name);
}
