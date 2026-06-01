// Generate hand-made Open Graph cards (1200×630 PNG) in skipr's risograph-zine
// aesthetic — cream paper, riso inks (orange = the sealed box, blue = you own
// it), a rubber stamp, offset-print ghost, and the hero "hand-off" specimen.
// Run: node scripts/make-og.mjs   (sharp rasterizes the SVG templates)
import sharp from 'sharp';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const outDir = resolve(here, '../public/og');

// Zine palette (matches the landing's oklch tokens, hand-tuned to sRGB).
const PAPER = '#f1ead9';
const PAPER2 = '#e8dec6';
const INK = '#332a20';
const INK2 = '#5d513f';
const INK3 = '#7a6e58';
const ORANGE = '#cf4f27'; // vivid riso — fills & decoration
const ORANGE_INK = '#b1431f'; // deeper — small orange text (AA)
const BLUE = '#3a5fb0';
const ORANGE_TINT = '#efd9c9';
const BLUE_TINT = '#d9e0f0';

// Prefer the brand faces; fall back to a solid grotesque/serif/mono if the
// machine running this script doesn't have them registered with fontconfig.
const DISP =
  "'Bricolage Grotesque Variable','Bricolage Grotesque','Arial Black','Helvetica Neue',Arial,sans-serif";
const READ = "'Newsreader Variable','Newsreader',Georgia,'Times New Roman',serif";
const MONO = "'IBM Plex Mono','SFMono-Regular',Menlo,Consolas,monospace";

// ---- the hand-off specimen: sealed crate → keys → your folder ----
function specimen(x, y, s = 1) {
  return `<g transform="translate(${x},${y}) scale(${s})">
    <!-- offset-print shadow + plate -->
    <rect x="8" y="8" width="404" height="300" fill="${INK}"/>
    <rect x="0" y="0" width="404" height="300" fill="${PAPER2}" stroke="${INK}" stroke-width="2.5"/>
    <rect x="22" y="-11" width="216" height="22" fill="${PAPER}"/>
    <text x="30" y="5" font-family="${MONO}" font-size="13" letter-spacing="1.5" fill="${INK3}">FIG.1 — THE HAND-OFF</text>

    <!-- sealed crate (orange) -->
    <g transform="translate(40,70)">
      <rect width="96" height="120" fill="${ORANGE_TINT}" stroke="${ORANGE}" stroke-width="3"/>
      <line x1="-6" y1="14" x2="102" y2="92" stroke="${ORANGE}" stroke-width="9" opacity="0.55"/>
      <line x1="-6" y1="106" x2="102" y2="28" stroke="${ORANGE}" stroke-width="9" opacity="0.55"/>
      <g transform="translate(34,40)">
        <rect x="0" y="14" width="28" height="20" rx="3" fill="${ORANGE}"/>
        <path d="M5 14 v-5 a9 9 0 0 1 18 0 v5" fill="none" stroke="${ORANGE}" stroke-width="5"/>
      </g>
      <text x="48" y="150" text-anchor="middle" font-family="${MONO}" font-size="12" letter-spacing="2" fill="${ORANGE_INK}">SEALED</text>
    </g>

    <!-- keys / hand-off -->
    <g transform="translate(168,120)">
      <circle cx="9" cy="9" r="9" fill="none" stroke="${INK}" stroke-width="3.5"/>
      <path d="M18 9 H64 M56 9 V20 M64 9 V22" fill="none" stroke="${INK}" stroke-width="3.5" stroke-linecap="round"/>
      <text x="32" y="44" text-anchor="middle" font-family="${MONO}" font-size="11" letter-spacing="2" fill="${INK3}">THE KEYS</text>
    </g>

    <!-- your folder (blue) -->
    <g transform="translate(266,70)">
      <rect width="96" height="120" fill="${BLUE_TINT}" stroke="${BLUE}" stroke-width="3"/>
      <rect x="-1" y="-9" width="50" height="14" rx="2" fill="${BLUE}"/>
      <rect x="14" y="58" width="68" height="7" rx="3" fill="${BLUE}" opacity="0.5"/>
      <rect x="14" y="74" width="54" height="7" rx="3" fill="${BLUE}" opacity="0.5"/>
      <rect x="14" y="90" width="62" height="7" rx="3" fill="${BLUE}" opacity="0.5"/>
      <text x="48" y="150" text-anchor="middle" font-family="${MONO}" font-size="12" letter-spacing="1.5" fill="${BLUE}">OWNER: YOU</text>
    </g>
  </g>`;
}

function card({ stamp, lines, sub }) {
  // lines: [{ text, ghost? }]; an italic <i>…</i> span renders in the serif.
  const titleY = 232;
  const lh = 82;
  const renderLine = (ln, i) => {
    const y = titleY + i * lh;
    const html = ln.text
      .replace(/\[\[(.+?)\]\]/g, `<tspan fill="${ORANGE}">$1</tspan>`) // [[orange]]
      .replace(
        /\{\{(.+?)\}\}/g,
        `<tspan font-family="${READ}" font-style="italic" font-weight="500">$1</tspan>`,
      ); // {{italic serif}}
    const ghost = ln.ghost
      ? `<text x="73" y="${y + 4}" font-family="${DISP}" font-size="62" font-weight="800" letter-spacing="-2" fill="${ORANGE}" opacity="0.16">${ln.text.replace(/\[\[|\]\]|\{\{|\}\}/g, '')}</text>`
      : '';
    return `${ghost}<text x="70" y="${y}" font-family="${DISP}" font-size="62" font-weight="800" letter-spacing="-2" fill="${INK}">${html}</text>`;
  };

  return `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <rect width="1200" height="630" fill="${PAPER}"/>

  <!-- framed plate with offset shadow -->
  <rect x="36" y="36" width="1132" height="562" fill="${INK}"/>
  <rect x="28" y="28" width="1132" height="562" fill="${PAPER}" stroke="${INK}" stroke-width="2.5"/>

  <!-- deckline -->
  <line x1="28" y1="92" x2="1160" y2="92" stroke="${INK}" stroke-width="1.5" opacity="0.5"/>
  <text x="70" y="74" font-family="${MONO}" font-size="15" letter-spacing="2" fill="${INK2}">EST. 2026 · INDEPENDENT SOFTWARE · A FIELD GUIDE FOR FOUNDERS</text>

  <!-- rubber stamp -->
  <g transform="rotate(-3.5 70 150)">
    <rect x="70" y="132" width="${18 + stamp.length * 11}" height="34" rx="5" fill="none" stroke="${ORANGE}" stroke-width="2.5"/>
    <circle cx="88" cy="149" r="4.5" fill="${ORANGE}"/>
    <text x="102" y="154" font-family="${MONO}" font-size="14" font-weight="600" letter-spacing="2" fill="${ORANGE_INK}">${stamp}</text>
  </g>

  <!-- title -->
  ${lines.map(renderLine).join('\n  ')}

  <!-- sub -->
  <text x="72" y="510" font-family="${READ}" font-size="27" fill="${INK2}">${sub}</text>

  <!-- footer meta -->
  <text x="70" y="560" font-family="${MONO}" font-size="17" letter-spacing="1" fill="${INK3}">skipr<tspan fill="${ORANGE}">.</tspan>dev · not affiliated with Anthropic</text>

  <!-- brand mark, top-right of the plate -->
  <text x="1132" y="74" text-anchor="end" font-family="${DISP}" font-size="30" font-weight="800" letter-spacing="-1.5" fill="${INK}">skipr<tspan fill="${ORANGE}">.</tspan></text>

  ${specimen(724, 288, 0.9)}
</svg>`;
}

const cards = {
  'default.png': card({
    stamp: 'COMING SOON',
    lines: [
      { text: 'Build [[real]] software', ghost: true },
      { text: 'with AI —' },
      { text: 'and {{actually}} own it.' },
    ],
    sub: 'Your code, your GitHub, your deploy. Not a black box.',
  }),
  'from-no-code.png': card({
    stamp: 'FIELD NOTES',
    lines: [
      { text: 'From [[no-code]]', ghost: true },
      { text: 'to software' },
      { text: 'you {{own}}.' },
    ],
    sub: 'Graduate from rented apps to code you own.',
  }),
};

await mkdir(outDir, { recursive: true });
for (const [name, svg] of Object.entries(cards)) {
  await sharp(Buffer.from(svg)).png().toFile(resolve(outDir, name));
  console.log('wrote', name);
}
