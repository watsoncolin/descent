#!/usr/bin/env node
// DESCENT — concept board builder
// ------------------------------------------------------------------
// Scans tools/concepts/<style>/<screen>-<n>.webp and writes a side-by-side
// comparison board. Reflects everything on disk (unlike the per-run index the
// generator writes). Run it any time after generating images.
//
// Usage:
//   node tools/build-board.mjs                 # focus: gameplay (mining-hud) only
//   node tools/build-board.mjs --screen=surface-shop
//   node tools/build-board.mjs --all           # every screen, grouped
//   node tools/build-board.mjs --out=gameplay.html
//
// Also exports buildBoard() so the generator can reuse it.
// ------------------------------------------------------------------

import { readdirSync, existsSync, writeFileSync, statSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const CONCEPTS = join(__dirname, 'concepts');

// Pretty labels (fallback to a title-cased folder/slug name when unknown).
const STYLE_LABELS = {
  'ideogram-ui': 'Ideogram 3.0 — crisp UI',
  'ideogram4-ui': 'Ideogram 4.0 — crisp UI',
  'flux-painterly': 'FLUX.2 — painterly',
  'recraft-vector': 'Recraft V4 — flat vector',
  'seedream-cinematic': 'Seedream 4.5 — cinematic',
  'retro-motherload': 'Pixel — Motherload homage',
  'pixel-snes': 'Pixel — 16-bit SNES',
  'pixel-modern': 'Pixel — modern indie',
  'pixel-8bit': 'Pixel — chunky 8-bit',
  'pixel-flux': 'Pixel — via FLUX.2',
  'soft-rounded': 'Soft rounded — smooth UI',
};
const SCREEN_LABELS = {
  'gameplay': 'Gameplay (side-view cross-section) — the real layout',
  'title-menu': 'Title / Main Menu',
  'planet-select': 'Planet Select',
  'mining-hud': 'In-Game Mining HUD (side view, legacy)',
  'surface-shop': 'Surface Shop / Upgrades',
  'prestige-dialog': 'Prestige / Soul Crystals',
  'supply-drop': 'Supply Drop Menu',
};
// Show the two front-runner directions first; everything else after, alpha.
const STYLE_ORDER = [
  'pixel-8bit', 'pixel-snes', 'pixel-modern', 'retro-motherload', 'pixel-flux',
  'soft-rounded',
  'ideogram-ui', 'ideogram4-ui', 'flux-painterly', 'recraft-vector', 'seedream-cinematic',
];

const titleCase = (s) => s.replace(/[-_]/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
const styleLabel = (s) => STYLE_LABELS[s] ?? titleCase(s);
const screenLabel = (s) => SCREEN_LABELS[s] ?? titleCase(s);
const esc = (s) => String(s).replace(/[&<>"]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));

// Scan disk -> { [screen]: [ {style, variant, file} ] }
function scan(outDir) {
  const byScreen = {};
  if (!existsSync(outDir)) return byScreen;
  for (const style of readdirSync(outDir)) {
    const dir = join(outDir, style);
    if (!statSync(dir).isDirectory()) continue;
    for (const f of readdirSync(dir)) {
      const m = f.match(/^(.*)-(\d+)\.webp$/);
      if (!m) continue;
      const [, screen, variant] = m;
      (byScreen[screen] ??= []).push({ style, variant: +variant, file: `${style}/${f}` });
    }
  }
  return byScreen;
}

const styleRank = (s) => {
  const i = STYLE_ORDER.indexOf(s);
  return i === -1 ? STYLE_ORDER.length : i;
};

export function buildBoard({ outDir = CONCEPTS, only = null, out = 'index.html' } = {}) {
  const byScreen = scan(outDir);
  let screens = Object.keys(byScreen);
  if (only) screens = screens.filter((s) => s === only);
  // order screens: gameplay first, then by SCREEN_LABELS order, then alpha
  const screenOrder = Object.keys(SCREEN_LABELS);
  screens.sort((a, b) => (screenOrder.indexOf(a) + 1 || 99) - (screenOrder.indexOf(b) + 1 || 99));

  const total = screens.reduce((n, s) => n + byScreen[s].length, 0);
  let html = `<!doctype html><meta charset="utf8"><title>DESCENT — concept board</title>
<style>
 :root{--w:320px}
 *{box-sizing:border-box}
 body{background:#0a0e27;color:#cfe6ff;font:14px/1.4 -apple-system,Segoe UI,sans-serif;margin:0;padding:20px 24px 60px}
 header{position:sticky;top:0;background:linear-gradient(#0a0e27,#0a0e27ee 70%,#0a0e2700);padding:8px 0 14px;z-index:5;margin:-8px -24px 8px;padding-left:24px}
 h1{color:#6dd5ff;margin:0 0 4px;font-size:20px}
 .sub{color:#6a8aa8;font-size:13px}
 .ctl{margin-top:10px;display:flex;align-items:center;gap:10px;color:#9ef4ff;font-size:13px}
 .ctl input[type=range]{width:240px;accent-color:#4db8ff}
 h2{color:#e85d3a;margin:34px 0 12px;border-bottom:1px solid #1a3d5c;padding-bottom:6px;font-size:16px}
 .row{display:flex;gap:18px;flex-wrap:wrap;align-items:flex-start}
 .card{width:var(--w)}
 .card a{display:block}
 .card img{width:100%;border-radius:10px;display:block;border:1px solid #1a2540;background:#1a1f3a;transition:border-color .15s}
 .card img:hover{border-color:#4db8ff}
 .cap{margin:7px 2px 0}
 .cap .s{color:#9ef4ff;font-weight:600}
 .cap .m{color:#5a7a98;font-size:12px}
</style>
<header>
 <h1>DESCENT — concept board</h1>
 <div class="sub">${total} image${total === 1 ? '' : 's'} · ${screens.length === 1 ? screenLabel(screens[0]) : screens.length + ' screens'} · click an image to open full size</div>
 <div class="ctl"><label>size</label><input type="range" min="160" max="560" value="320"
   oninput="document.documentElement.style.setProperty('--w',this.value+'px')"></div>
</header>`;

  for (const screen of screens) {
    const items = byScreen[screen].sort(
      (a, b) => styleRank(a.style) - styleRank(b.style) || a.variant - b.variant,
    );
    html += `\n<h2>${esc(screenLabel(screen))} <span style="color:#5a7a98;font-weight:400">· ${items.length}</span></h2>\n<div class="row">`;
    for (const it of items) {
      html += `<figure class="card" style="margin:0"><a href="${esc(it.file)}" target="_blank" rel="noopener">` +
        `<img src="${esc(it.file)}" loading="lazy"></a>` +
        `<figcaption class="cap"><div class="s">${esc(styleLabel(it.style))}</div>` +
        `<div class="m">${esc(it.style)} · #${it.variant}</div></figcaption></figure>`;
    }
    html += `</div>`;
  }
  if (!screens.length) html += `<p style="color:#ff6b35">No images found in ${esc(outDir)}. Generate some first.</p>`;

  const outPath = join(outDir, out);
  writeFileSync(outPath, html);
  return { outPath, total, screens };
}

// CLI (only when run directly, not when imported)
if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  const flag = (n) => {
    const a = process.argv.slice(2).find((x) => x.startsWith(`--${n}=`));
    return a ? a.split('=').slice(1).join('=') : undefined;
  };
  const all = process.argv.includes('--all');
  const only = all ? null : (flag('screen') ?? 'gameplay'); // default focus: gameplay
  const out = flag('out') ?? 'index.html';
  const r = buildBoard({ only, out });
  console.log(`Board: ${r.outPath}`);
  console.log(`  ${r.total} image(s) across ${r.screens.length} screen(s): ${r.screens.join(', ') || '(none)'}`);
  console.log(`\nOpen it:  open ${r.outPath}`);
}
