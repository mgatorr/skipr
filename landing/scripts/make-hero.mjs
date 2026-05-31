// Generate the README hero banner (PNG) — skipr's guided build-and-own flow in
// the dark terminal aesthetic. Run: node scripts/make-hero.mjs
import sharp from 'sharp';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const outDir = resolve(here, '../../assets');

const W = 1280;
const H = 460;

const panelX = 700;
const panelY = 70;
const panelW = 508;
const panelH = 320;

// single-quote font names: these go inside double-quoted XML attributes
const sans = "Inter, 'Helvetica Neue', Arial, sans-serif";
const mono = "'JetBrains Mono', 'SF Mono', Menlo, monospace";

const steps = [
  ['Claude Code ready', '— no terminal'],
  ['spec written from your idea', ''],
  ['building', '— your files, your machine'],
  ['pushed to your GitHub', ''],
  ['deployed — Vercel + Supabase', ''],
];

const linesY = panelY + 78;
const lineGap = 38;
const stepLines = steps
  .map((s, i) => {
    const y = linesY + i * lineGap;
    const muted = s[1] ? `<tspan fill="#50615b">  ${s[1]}</tspan>` : '';
    return `<text x="${panelX + 28}" y="${y}" font-family="${mono}" font-size="16" fill="#d6e2dd"><tspan fill="#3ddc84">✓</tspan>  ${s[0]}${muted}</text>`;
  })
  .join('\n    ');

const finalY = linesY + steps.length * lineGap + 16;

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0a0e0d"/>
      <stop offset="1" stop-color="#070b0a"/>
    </linearGradient>
    <radialGradient id="glow" cx="0.8" cy="0.12" r="0.75">
      <stop offset="0" stop-color="#3ddc84" stop-opacity="0.16"/>
      <stop offset="1" stop-color="#3ddc84" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="title" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#ffffff"/>
      <stop offset="1" stop-color="#b8f5d4"/>
    </linearGradient>
  </defs>

  <rect width="${W}" height="${H}" fill="url(#bg)"/>
  <rect width="${W}" height="${H}" fill="url(#glow)"/>
  <rect x="0.5" y="0.5" width="${W - 1}" height="${H - 1}" rx="18" fill="none" stroke="#16221e" stroke-width="1"/>

  <!-- LEFT: brand + value prop -->
  <g>
    <rect x="68" y="92" width="320" height="30" rx="15" fill="none" stroke="#1c2a26"/>
    <circle cx="88" cy="107" r="3.5" fill="#3ddc84"/>
    <text x="102" y="112" font-family="${mono}" font-size="12.5" letter-spacing="1.4" fill="#7d8f88">FOR FOUNDERS WHO SHIP FOR REAL</text>

    <text x="66" y="210" font-family="${sans}" font-size="92" font-weight="800" fill="url(#title)" letter-spacing="-2">skipr</text>

    <text x="70" y="258" font-family="${sans}" font-size="26" font-weight="600" fill="#d6e2dd">Build real software with AI —</text>
    <text x="70" y="292" font-family="${sans}" font-size="26" font-weight="600" fill="#3ddc84">and actually own it.</text>

    <text x="70" y="328" font-family="${mono}" font-size="15" fill="#7d8f88">From idea to a deployed app you control. No black box.</text>

    <g font-family="${mono}" font-size="13" fill="#7d8f88">
      <rect x="70" y="352" width="116" height="28" rx="6" fill="#0f1614" stroke="#1c2a26"/>
      <text x="84" y="370">your code</text>
      <rect x="196" y="352" width="128" height="28" rx="6" fill="#0f1614" stroke="#1c2a26"/>
      <text x="210" y="370">your GitHub</text>
      <rect x="334" y="352" width="128" height="28" rx="6" fill="#0f1614" stroke="#1c2a26"/>
      <text x="348" y="370">your deploy</text>
    </g>
  </g>

  <!-- RIGHT: guided-flow terminal -->
  <g>
    <rect x="${panelX}" y="${panelY}" width="${panelW}" height="${panelH}" rx="12" fill="#0d1412" stroke="#1c2a26"/>
    <rect x="${panelX}" y="${panelY}" width="${panelW}" height="40" rx="12" fill="#0a100e"/>
    <rect x="${panelX}" y="${panelY + 28}" width="${panelW}" height="12" fill="#0a100e"/>
    <circle cx="${panelX + 22}" cy="${panelY + 20}" r="4.5" fill="#1c2a26"/>
    <circle cx="${panelX + 38}" cy="${panelY + 20}" r="4.5" fill="#1c2a26"/>
    <circle cx="${panelX + 54}" cy="${panelY + 20}" r="4.5" fill="#1c2a26"/>
    <text x="${panelX + 76}" y="${panelY + 25}" font-family="${mono}" font-size="14" fill="#50615b">skipr — guided</text>

    <text x="${panelX + 28}" y="${linesY - 34}" font-family="${mono}" font-size="16" fill="#7d8f88">$ skipr new my-app</text>
    ${stepLines}

    <line x1="${panelX + 24}" y1="${finalY - 24}" x2="${panelX + panelW - 24}" y2="${finalY - 24}" stroke="#16221e"/>
    <text x="${panelX + 28}" y="${finalY}" font-family="${mono}" font-size="16" fill="#d6e2dd">your app is live — <tspan fill="#3ddc84" font-weight="700">and it's yours.</tspan></text>
  </g>
</svg>`;

await mkdir(outDir, { recursive: true });
await sharp(Buffer.from(svg)).png().toFile(resolve(outDir, 'skipr-hero.png'));
console.log('wrote assets/skipr-hero.png');
