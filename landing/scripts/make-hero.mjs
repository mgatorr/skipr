// Generate the README hero banner (PNG) — a premium "observability dashboard"
// look (inspired by Datadog/DRUIDS) in Sorrel's dark terminal palette.
// Run: node scripts/make-hero.mjs
import sharp from 'sharp';
import { mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const outDir = resolve(here, '../../assets');

const W = 1280;
const H = 460;

// data for the mini "context cost" panel
const rows = [
  { name: 'github', tools: 42, tok: 8310 },
  { name: 'playwright', tools: 31, tok: 6740 },
  { name: 'supabase', tools: 28, tok: 5120 },
  { name: 'filesystem', tools: 9, tok: 1180 },
];
const maxTok = Math.max(...rows.map((r) => r.tok));
const BAR_MAX = 168;

const panelX = 712;
const panelY = 84;
const panelW = 496;
const panelH = 308;
const rowsY = panelY + 84;
const rowGap = 40;
const barX = panelX + 150;

// single-quote font names: these go inside double-quoted XML attributes
const sans = "Inter, 'Helvetica Neue', Arial, sans-serif";
const mono = "'JetBrains Mono', 'SF Mono', Menlo, monospace";

const barRows = rows
  .map((r, i) => {
    const y = rowsY + i * rowGap;
    const w = Math.round((r.tok / maxTok) * BAR_MAX);
    const tok = r.tok.toLocaleString('en-US');
    return `
      <text x="${panelX + 28}" y="${y + 5}" font-family="${mono}" font-size="17" fill="#d6e2dd">${r.name}</text>
      <rect x="${barX}" y="${y - 11}" width="${BAR_MAX}" height="15" rx="7.5" fill="#0a1410"/>
      <rect x="${barX}" y="${y - 11}" width="${w}" height="15" rx="7.5" fill="url(#bar)"/>
      <text x="${panelX + panelW - 24}" y="${y + 5}" text-anchor="end" font-family="${mono}" font-size="16" fill="#3ddc84">${tok} tok</text>`;
  })
  .join('');

const totalY = rowsY + rows.length * rowGap + 26;

const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0a0e0d"/>
      <stop offset="1" stop-color="#070b0a"/>
    </linearGradient>
    <radialGradient id="glow" cx="0.82" cy="0.1" r="0.7">
      <stop offset="0" stop-color="#3ddc84" stop-opacity="0.16"/>
      <stop offset="1" stop-color="#3ddc84" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="bar" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#2a9c5e"/>
      <stop offset="1" stop-color="#3ddc84"/>
    </linearGradient>
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
    <rect x="70" y="92" width="280" height="30" rx="15" fill="none" stroke="#1c2a26"/>
    <circle cx="90" cy="107" r="3.5" fill="#3ddc84"/>
    <text x="104" y="112" font-family="${mono}" font-size="13" letter-spacing="1.5" fill="#7d8f88">OBSERVABILITY FOR CLAUDE CODE</text>

    <text x="68" y="214" font-family="${sans}" font-size="92" font-weight="800" fill="url(#title)" letter-spacing="-2">sorrel</text>

    <text x="72" y="262" font-family="${sans}" font-size="27" font-weight="600" fill="#d6e2dd">See what your MCP servers <tspan fill="#3ddc84">really cost</tspan>.</text>

    <text x="72" y="298" font-family="${mono}" font-size="16" fill="#7d8f88">A friendly control layer for piloting Claude Code.</text>

    <g font-family="${mono}" font-size="13" fill="#7d8f88">
      <rect x="72" y="328" width="116" height="28" rx="6" fill="#0f1614" stroke="#1c2a26"/>
      <text x="86" y="346">Go · Charm</text>
      <rect x="198" y="328" width="150" height="28" rx="6" fill="#0f1614" stroke="#1c2a26"/>
      <text x="212" y="346">Astro · Vercel</text>
      <rect x="358" y="328" width="150" height="28" rx="6" fill="#0f1614" stroke="#1c2a26"/>
      <text x="372" y="346">single binary</text>
    </g>
  </g>

  <!-- RIGHT: observability panel -->
  <g>
    <rect x="${panelX}" y="${panelY}" width="${panelW}" height="${panelH}" rx="12" fill="#0d1412" stroke="#1c2a26"/>
    <rect x="${panelX}" y="${panelY}" width="${panelW}" height="40" rx="12" fill="#0a100e"/>
    <rect x="${panelX}" y="${panelY + 28}" width="${panelW}" height="12" fill="#0a100e"/>
    <circle cx="${panelX + 22}" cy="${panelY + 20}" r="4.5" fill="#1c2a26"/>
    <circle cx="${panelX + 38}" cy="${panelY + 20}" r="4.5" fill="#1c2a26"/>
    <circle cx="${panelX + 54}" cy="${panelY + 20}" r="4.5" fill="#1c2a26"/>
    <text x="${panelX + 76}" y="${panelY + 25}" font-family="${mono}" font-size="14" fill="#50615b">sorrel analyze</text>

    ${barRows}

    <line x1="${panelX + 24}" y1="${totalY - 28}" x2="${panelX + panelW - 24}" y2="${totalY - 28}" stroke="#16221e"/>
    <text x="${panelX + 28}" y="${totalY}" font-family="${mono}" font-size="17" fill="#d6e2dd">total context</text>
    <rect x="${panelX + 250}" y="${totalY - 16}" width="70" height="22" rx="11" fill="#0a1410" stroke="#2a9c5e"/>
    <text x="${panelX + 285}" y="${totalY - 1}" text-anchor="middle" font-family="${mono}" font-size="13" fill="#3ddc84">~34%</text>
    <text x="${panelX + panelW - 24}" y="${totalY}" text-anchor="end" font-family="${mono}" font-size="19" font-weight="700" fill="#3ddc84">21,350 tok</text>
  </g>
</svg>`;

await mkdir(outDir, { recursive: true });
await sharp(Buffer.from(svg)).png().toFile(resolve(outDir, 'sorrel-hero.png'));
console.log('wrote assets/sorrel-hero.png');
