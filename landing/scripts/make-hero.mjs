// Generate the README hero banner (PNG) in skipr's risograph-zine aesthetic —
// cream paper, riso inks, rubber stamp, and the "hand-off" specimen.
// Run: node scripts/make-hero.mjs
import sharp from 'sharp';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const outDir = resolve(here, '../../assets');

const W = 1280;
const H = 460;

// Zine palette (matches the landing's oklch tokens, hand-tuned to sRGB).
const PAPER = '#f1ead9';
const PAPER2 = '#e8dec6';
const INK = '#332a20';
const INK2 = '#5d513f';
const INK3 = '#7a6e58';
const ORANGE = '#cf4f27';
const ORANGE_INK = '#b1431f';
const BLUE = '#3a5fb0';
const ORANGE_TINT = '#efd9c9';
const BLUE_TINT = '#d9e0f0';

const DISP =
  "'Bricolage Grotesque Variable','Bricolage Grotesque','Arial Black','Helvetica Neue',Arial,sans-serif";
const READ = "'Newsreader Variable','Newsreader',Georgia,'Times New Roman',serif";
const MONO = "'IBM Plex Mono','SFMono-Regular',Menlo,Consolas,monospace";

// ---- the hand-off specimen: sealed crate → keys → your folder ----
function specimen(x, y, s = 1) {
  return `<g transform="translate(${x},${y}) scale(${s})">
    <rect x="8" y="8" width="404" height="300" fill="${INK}"/>
    <rect x="0" y="0" width="404" height="300" fill="${PAPER2}" stroke="${INK}" stroke-width="2.5"/>
    <rect x="22" y="-11" width="216" height="22" fill="${PAPER}"/>
    <text x="30" y="5" font-family="${MONO}" font-size="13" letter-spacing="1.5" fill="${INK3}">FIG.1 — THE HAND-OFF</text>
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
    <g transform="translate(168,120)">
      <circle cx="9" cy="9" r="9" fill="none" stroke="${INK}" stroke-width="3.5"/>
      <path d="M18 9 H64 M56 9 V20 M64 9 V22" fill="none" stroke="${INK}" stroke-width="3.5" stroke-linecap="round"/>
      <text x="32" y="44" text-anchor="middle" font-family="${MONO}" font-size="11" letter-spacing="2" fill="${INK3}">THE KEYS</text>
    </g>
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

const chip = (x, label) =>
  `<g transform="translate(${x},346)"><rect width="${30 + label.length * 9.5}" height="32" rx="6" fill="${PAPER2}" stroke="${INK}" stroke-width="1.5"/><text x="15" y="21" font-family="${MONO}" font-size="13" fill="${INK2}">${label}</text></g>`;

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <rect width="${W}" height="${H}" fill="${PAPER}"/>

  <!-- framed plate with offset shadow -->
  <rect x="32" y="32" width="${W - 56}" height="${H - 56}" fill="${INK}"/>
  <rect x="24" y="24" width="${W - 56}" height="${H - 56}" fill="${PAPER}" stroke="${INK}" stroke-width="2.5"/>

  <!-- deckline -->
  <line x1="24" y1="84" x2="${W - 32}" y2="84" stroke="${INK}" stroke-width="1.5" opacity="0.5"/>
  <text x="64" y="67" font-family="${MONO}" font-size="14" letter-spacing="2" fill="${INK2}">EST. 2026 · INDEPENDENT SOFTWARE · A FIELD GUIDE FOR FOUNDERS</text>
  <text x="${W - 64}" y="68" text-anchor="end" font-family="${DISP}" font-size="26" font-weight="800" letter-spacing="-1.2" fill="${INK}">skipr<tspan fill="${ORANGE}">.</tspan></text>

  <!-- rubber stamp -->
  <g transform="rotate(-3.5 64 120)">
    <rect x="64" y="104" width="324" height="32" rx="5" fill="none" stroke="${ORANGE}" stroke-width="2.5"/>
    <circle cx="82" cy="120" r="4.5" fill="${ORANGE}"/>
    <text x="96" y="125" font-family="${MONO}" font-size="13" font-weight="600" letter-spacing="2" fill="${ORANGE_INK}">FOR FOUNDERS WHO SHIP FOR REAL</text>
  </g>

  <!-- giant wordmark -->
  <text x="60" y="248" font-family="${DISP}" font-size="120" font-weight="800" letter-spacing="-5" fill="${ORANGE}" opacity="0.16">skipr.</text>
  <text x="58" y="244" font-family="${DISP}" font-size="120" font-weight="800" letter-spacing="-5" fill="${INK}">skipr<tspan fill="${ORANGE}">.</tspan></text>

  <!-- tagline -->
  <text x="62" y="296" font-family="${DISP}" font-size="29" font-weight="700" letter-spacing="-0.8" fill="${INK}">Build <tspan fill="${ORANGE}">real</tspan> software with AI —</text>
  <text x="62" y="332" font-family="${DISP}" font-size="29" font-weight="700" letter-spacing="-0.8" fill="${INK}">and <tspan font-family="${READ}" font-style="italic" font-weight="500">actually</tspan> own it.</text>

  <!-- ownership chips -->
  ${chip(62, 'your code')}
  ${chip(62 + 145, 'your GitHub')}
  ${chip(62 + 145 + 162, 'your deploy')}

  <!-- footer meta -->
  <text x="62" y="412" font-family="${MONO}" font-size="15" letter-spacing="0.5" fill="${INK3}">skipr<tspan fill="${ORANGE}">.</tspan>dev · idea → spec → code → GitHub → deploy · not affiliated with Anthropic</text>

  ${specimen(854, 150, 0.82)}
</svg>`;

await mkdir(outDir, { recursive: true });
await sharp(Buffer.from(svg)).png().toFile(resolve(outDir, 'skipr-hero.png'));
console.log('wrote assets/skipr-hero.png');
