#!/usr/bin/env node
// DESCENT — UI concept generator
// ------------------------------------------------------------------
// Generates concept art for the game's screens across a spread of models
// and art directions, so we can evaluate styles (incl. Ideogram) before
// committing to a UI look. Pure Node 20 (native fetch) — zero npm deps.
//
// The Runware key is read from an adjacent repo's .env so it never gets
// copied into this repo. Order of precedence:
//   1. process.env.RUNWARE_API_KEY
//   2. ./.env (this repo, gitignored)
//   3. ../pourcraft-api/.env  (the adjacent repo that already has a key)
//
// Usage:
//   node tools/gen-ui-concepts.mjs                     # full matrix
//   node tools/gen-ui-concepts.mjs --dry-run           # print the plan, no API calls
//   node tools/gen-ui-concepts.mjs --screens=mining-hud,surface-shop
//   node tools/gen-ui-concepts.mjs --styles=ideogram-ui,flux-painterly
//   node tools/gen-ui-concepts.mjs --n=2               # 2 variations per cell
//   node tools/gen-ui-concepts.mjs --list              # list screens & styles
//
// Output: tools/concepts/<style>/<screen>-<i>.webp
//         tools/concepts/index.html   (contact sheet, grouped by screen)
//         tools/concepts/manifest.json
// ------------------------------------------------------------------

import { randomUUID } from 'crypto';
import { writeFileSync, mkdirSync, existsSync, readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, resolve, join } from 'path';
import { buildBoard } from './build-board.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(__dirname, '..');
const OUT = join(__dirname, 'concepts');

// ---- key loading ----------------------------------------------------
function parseEnv(path) {
  if (!existsSync(path)) return {};
  const out = {};
  for (const line of readFileSync(path, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/i);
    if (m) out[m[1]] = m[2].replace(/^["']|["']$/g, '');
  }
  return out;
}
function loadKey() {
  if (process.env.RUNWARE_API_KEY) return process.env.RUNWARE_API_KEY;
  for (const p of [join(REPO, '.env'), resolve(REPO, '../pourcraft-api/.env')]) {
    const env = parseEnv(p);
    if (env.RUNWARE_API_KEY) return env.RUNWARE_API_KEY;
  }
  throw new Error(
    'RUNWARE_API_KEY not found. Set it in the env, in ./.env, or in ../pourcraft-api/.env',
  );
}

// ---- shared art direction ------------------------------------------
// Grounded in docs/wiki/Design System.md — modern sci-fi, atmospheric glows,
// deep-space palette, Mars rust terrain, crystal/credit accents.
const WORLD =
  'DESCENT is a sci-fi mining game: a single-pilot drilling pod burrows deep ' +
  'through a planet extracting minerals. Mood: modern sci-fi, atmospheric ' +
  'glows, smooth gradients, layered transparency, soft top-left lighting. ' +
  'Core palette: deep space dark #0a0e27 and #1a1f3a backgrounds, bright ' +
  'cyan-blue UI accents #4db8ff / #6dd5ff, rust-red Mars terrain #c44228 / ' +
  '#e85d3a, golden thruster #ffdd57, intense cyan crystal glow for rare ore. ' +
  'Dual currency: Credits (cyan) and Soul Crystals (purple prestige gem).';

const NEG =
  'low quality, blurry, jpeg artifacts, watermark, signature, distorted text, ' +
  'gibberish text, extra fingers, cluttered, washed out';

// ---- the screens ----------------------------------------------------
// Each is described as a *mobile game UI mockup* so the models compose a
// real screen layout, not just an illustration.
const SCREENS = {
  'title-menu': {
    label: 'Title / Main Menu',
    prompt:
      'Title screen for the mobile game DESCENT. A lone industrial drilling ' +
      'pod silhouetted against a cross-section of a planet, geological strata ' +
      'glowing with embedded minerals descending into darkness below. Large ' +
      'bold game logo "DESCENT" at top, a glowing "PLAY" button, small ' +
      'settings and shop icons. Portrait phone screen, cinematic depth.',
  },
  'planet-select': {
    label: 'Planet Select',
    prompt:
      'Planet selection screen for a mobile mining game. A row of orbiting ' +
      'planets shown as glowing spheres — a rust-red Mars-like world in focus, ' +
      'a grey cratered moon and a bright crystalline world dimmed/locked behind ' +
      'it. Each planet card shows a name and a difficulty/depth stat. Dark space ' +
      'background with stars. Portrait phone UI.',
  },
  // Accurate gameplay layout (matches the real prototype): a 2D SIDE-VIEW
  // cross-section like Motherload — surface base up top, a single narrow
  // vertical dig shaft (dug vs undug dirt), coal/ore clusters in a loose grid,
  // SUPPLY button + status bars + tool row.
  'gameplay': {
    label: 'Gameplay (side-view cross-section)',
    prompt:
      '2D side-view cross-section gameplay screen for a mobile mining game in ' +
      'the style of Motherload — a vertical slice of the underground seen from ' +
      'the side, shallow depth (~80m). A thin strip of warm planet surface with ' +
      'a tiny base/shop and a sky band sits at the very top; below it the ground ' +
      'is mostly flat, evenly-colored sandy tan dirt (warm tan #c4a57b). A small ' +
      'rounded mining pod is near the center with a drill nose pointed straight ' +
      'down, wrapped in a warm orange drilling glow with a spray of tan dirt ' +
      'particles. It has dug straight down from the surface, leaving a single ' +
      'narrow vertical tunnel directly above it: the dug tunnel is a darker ' +
      'hollow cleared channel (excavated sand, ~30% darker #8c7545), the ' +
      'surrounding undug dirt is lighter and solid. Embedded across the undug ' +
      'dirt in a loose even grid are many small mineral deposits — almost all ' +
      'are clusters of dull black coal nuggets (lumpy, slightly glossy), with ' +
      'just a few silver-grey metallic iron veins mixed in. No bright crystals, ' +
      'no gold at this shallow depth. HUD overlay drawn flat on top: top-left a ' +
      'rounded square blue SUPPLY button with a cardboard supply-crate icon (to ' +
      'call a supply drop); top-right a white depth readout "81m", a short ' +
      'horizontal green HULL bar and a horizontal FUEL bar reading "15/50" with ' +
      'a small "$30" credit value; along the bottom edge a row of five round ' +
      'tool buttons with small number badges — repair wrench, red fuel can, ' +
      'black bomb, purple teleporter swirl, cyan shield. Clean readable mobile ' +
      'game UI, simple and uncluttered.',
  },
  'mining-hud': {
    label: 'In-Game Mining HUD (side view, legacy)',
    prompt:
      'In-game heads-up display for a mobile mining game, mid-drill. Centered: ' +
      'a small drilling pod boring through continuous red-rust rock strata with ' +
      'embedded glowing cyan crystal and gold ore deposits, dust particles and ' +
      'a thruster flame. HUD overlays: a vertical FUEL gauge and HULL health bar ' +
      'on the left, a CARGO fill meter and DEPTH readout (e.g. "1240m") on the ' +
      'right, a row of round consumable buttons along the bottom. Clean glowing ' +
      'sci-fi HUD, portrait phone screen.',
  },
  'surface-shop': {
    label: 'Surface Shop / Upgrades',
    prompt:
      'Upgrade shop screen for a mobile mining game, set at the planet surface ' +
      'with the parked drilling pod and a rust-red horizon. Tabbed UI with a ' +
      'scrolling list of upgrade cards — Fuel Tank, Drill Power, Cargo Bay, ' +
      'Hull Armor, Engine Speed — each card with an icon, level pips, and a ' +
      'credit cost button. Cyan credit balance at top. Clean mobile game UI, ' +
      'portrait phone screen.',
  },
  'prestige-dialog': {
    label: 'Prestige / Soul Crystals',
    prompt:
      'Prestige reward dialog for a mobile mining game. A glowing purple Soul ' +
      'Crystal floating at center radiating light, a large number of crystals ' +
      'earned shown beneath, and a permanent-bonus multiplier callout. ' +
      'Confirm and cancel buttons. Mystical, premium, high-value mood over a ' +
      'dark space-blue background. Portrait phone screen.',
  },
  'supply-drop': {
    label: 'Supply Drop Menu',
    prompt:
      'Supply drop ordering menu for a mobile mining game, opened mid-run deep ' +
      'underground. A grid of orderable items — repair kit, fuel cell, bomb, ' +
      'teleporter, shield — each with an icon, quantity stepper and credit ' +
      'cost, plus a capacity bar showing how full the drop pod is. Glowing ' +
      'sci-fi panel over dark dug-out rock. Portrait phone screen.',
  },
};

// ---- the styles (variety axis) -------------------------------------
// Each style bundles a MODEL plus an art-direction modifier so we get a real
// spread of looks — and can directly compare Ideogram against the others.
// Model identifiers are Runware AIR strings; tweak/extend as the account allows.
// NOTE on Runware AIR ids (verified live via the modelSearch API):
//   Ideogram 3.0 = ideogram:4@1   ·   Ideogram 4.0 = ideogram:4@0
//   FLUX.2 [klein 9B] = runware:400@2 (steps OK)  ·  FLUX.2 [pro] = bfl:5@1
//   Recraft V4 = recraft:v4@0  ·  Seedream 4.5 = bytedance:seedream@4.5
// `steps` is only accepted by the FLUX models — keep it out of the others.
const STYLES = {
  'ideogram-ui': {
    label: 'Ideogram 3.0 — crisp UI mockup',
    model: 'ideogram:4@1',
    note: 'Best-in-class text rendering — use to evaluate real readable HUD labels & numbers.',
    modifier:
      'polished production mobile game UI mockup, crisp clean interface, ' +
      'flat design with subtle gradients, sharp legible labels and numbers, ' +
      'UI kit quality, high contrast, organized layout',
    params: {},
  },
  'ideogram4-ui': {
    label: 'Ideogram 4.0 — crisp UI mockup',
    model: 'ideogram:4@0',
    note: 'Newer Ideogram; compare against 3.0 for layout & typography.',
    modifier:
      'polished production mobile game UI mockup, crisp clean interface, ' +
      'flat design with subtle gradients, sharp legible labels and numbers, ' +
      'UI kit quality, high contrast, organized layout',
    params: {},
    noNeg: true,
    size: { width: 1664, height: 2496 }, // Ideogram 4.0 only allows a fixed dim list
  },
  'flux-painterly': {
    label: 'FLUX.2 — atmospheric concept art',
    model: 'runware:400@2',
    note: 'Known-good on this account (pourcraft default). Painterly/cinematic.',
    modifier:
      'atmospheric painterly sci-fi concept art, cinematic volumetric ' +
      'lighting, rich depth and glow, AAA mobile game key art, detailed',
    params: { steps: 30 },
  },
  'recraft-vector': {
    label: 'Recraft V4 — flat design system',
    model: 'recraft:v4@0',
    note: 'Strong at clean vector/flat design & UI kits. Swap to recraft:v4-pro@0 if enabled.',
    modifier:
      'clean flat vector design, crisp geometric shapes, modern mobile app ' +
      'UI design system, minimal, bold icons, consistent components',
    params: {},
    noNeg: true,
    size: { width: 832, height: 1344 }, // nearest portrait in Recraft's allowed dim list
  },
  'seedream-cinematic': {
    label: 'Seedream 4.5 — high-detail render',
    model: 'bytedance:seedream@4.5',
    note: 'High-detail cinematic render; another model to compare.',
    modifier:
      'highly detailed cinematic 3D render, dramatic lighting, glossy ' +
      'sci-fi surfaces, premium mobile game presentation',
    params: {},
    noNeg: true,
    size: { width: 1664, height: 2496 }, // Seedream needs >=3.7M total pixels
  },
  'retro-motherload': {
    label: 'Ideogram — retro Motherload homage',
    model: 'ideogram:4@1',
    note: 'Chunky 16-bit homage to Motherload (the inspiration). The picked direction.',
    modifier:
      'retro 16-bit pixel art arcade game UI, chunky pixels, bold limited ' +
      'palette, homage to the classic game Motherload, nostalgic',
    params: {},
  },

  // --- pixel-art exploration (the chosen direction; sub-variants to pick from) ---
  'pixel-snes': {
    label: 'Pixel — detailed 16-bit SNES',
    model: 'ideogram:4@1',
    note: 'Richer 16-bit: dithering, earthy palette, polished sprite work.',
    modifier:
      'detailed 16-bit SNES-era pixel art game screen, careful dithering and ' +
      'shading, rich earthy rust palette with cyan crystal accents, layered ' +
      'rock strata, crisp readable pixel UI bars and icons, clean pixel grid',
    params: {},
  },
  'pixel-modern': {
    label: 'Pixel — modern indie (SteamWorld/Dome Keeper)',
    model: 'ideogram:4@1',
    note: 'Polished neo-retro indie pixel art, atmospheric lighting.',
    modifier:
      'modern indie pixel art in the style of SteamWorld Dig and Dome Keeper, ' +
      'clean crisp pixels, atmospheric underground lighting and glow, polished ' +
      'detailed sprites, cohesive pixel UI with gauges and a consumable toolbar',
    params: {},
  },
  'pixel-8bit': {
    label: 'Pixel — chunky 8-bit',
    model: 'ideogram:4@1',
    note: 'Low-res bold 8-bit, blocky, NES-limited palette.',
    modifier:
      'low-resolution 8-bit pixel art, big chunky blocky pixels, bold limited ' +
      'NES-style palette, simple flat shading, retro arcade mining game UI',
    params: {},
  },
  'pixel-flux': {
    label: 'Pixel — modern indie via FLUX.2',
    model: 'runware:400@2',
    note: 'Same modern-pixel brief on Flux, to compare against Ideogram.',
    modifier:
      'modern indie pixel art mining game screen, crisp clean pixels, ' +
      'atmospheric underground glow, layered rust rock strata with cyan crystal ' +
      'and gold ore deposits, pixel UI gauges and consumable toolbar, Motherload-inspired',
    params: { steps: 30 },
  },

  // --- soft / rounded direction (the opposite of pixel: smooth & friendly) ---
  'soft-rounded': {
    label: 'Soft rounded — smooth gradient UI',
    model: 'runware:400@2',
    note: 'Rounded, friendly, smooth — soft 3D clay-like forms, rounded panels, gentle gradients.',
    modifier:
      'soft modern mobile game UI, smooth rounded shapes, rounded-rectangle ' +
      'panels with gentle gradients and soft drop shadows, glossy rounded ' +
      'icons, soft 3D clay-like forms, friendly polished casual game art, ' +
      'smooth anti-aliased curves, cohesive and clean, no hard edges, no pixels',
    params: { steps: 30 },
  },
};

// A spread that exercises Ideogram (text), Flux (painterly), Recraft (vector)
// and a retro outlier — one of each model family for a fair style comparison.
const DEFAULT_STYLES = ['ideogram-ui', 'flux-painterly', 'recraft-vector', 'retro-motherload'];

// ---- CLI ------------------------------------------------------------
const argv = process.argv.slice(2);
const flag = (name) => {
  const a = argv.find((x) => x.startsWith(`--${name}=`));
  return a ? a.split('=').slice(1).join('=') : undefined;
};
const has = (name) => argv.includes(`--${name}`);

if (has('list')) {
  console.log('\nSCREENS:');
  for (const [k, v] of Object.entries(SCREENS)) console.log(`  ${k.padEnd(16)} ${v.label}`);
  console.log('\nSTYLES:');
  for (const [k, v] of Object.entries(STYLES))
    console.log(`  ${k.padEnd(20)} ${v.label}\n${' '.repeat(22)}${v.model} — ${v.note}`);
  console.log(`\nDefault styles: ${DEFAULT_STYLES.join(', ')}`);
  process.exit(0);
}

const pick = (csv, all) =>
  csv ? csv.split(',').map((s) => s.trim()).filter((s) => all.includes(s)) : null;

const screens = pick(flag('screens'), Object.keys(SCREENS)) ?? Object.keys(SCREENS);
const styles = pick(flag('styles'), Object.keys(STYLES)) ?? DEFAULT_STYLES;
const N = Math.max(1, parseInt(flag('n') ?? '1', 10));
const START = Math.max(1, parseInt(flag('start') ?? '1', 10)); // variant offset, so refines don't clobber picks
const WIDTH = parseInt(flag('width') ?? '832', 10);   // portrait, model-friendly 2:3-ish
const HEIGHT = parseInt(flag('height') ?? '1216', 10);
const CONCURRENCY = parseInt(flag('concurrency') ?? '4', 10);
const dryRun = has('dry-run');

// build the job matrix
const jobs = [];
for (const screen of screens)
  for (const style of styles)
    for (let i = START; i < START + N; i++)
      jobs.push({ screen, style, i, name: `${screen}-${i}` });

console.log(`\nDESCENT UI concepts`);
console.log(`  screens : ${screens.join(', ')}`);
console.log(`  styles  : ${styles.join(', ')}`);
console.log(`  size    : ${WIDTH}x${HEIGHT}  variations/cell: ${N}`);
console.log(`  jobs    : ${jobs.length}  (concurrency ${CONCURRENCY})`);

if (dryRun) {
  console.log('\n[dry-run] plan:');
  for (const j of jobs)
    console.log(`  ${j.style.padEnd(20)} ${j.name.padEnd(20)} -> ${STYLES[j.style].model}`);
  process.exit(0);
}

const KEY = loadKey();
for (const style of styles) mkdirSync(join(OUT, style), { recursive: true });

// ---- generation -----------------------------------------------------
async function gen(job) {
  const s = STYLES[job.style];
  const sc = SCREENS[job.screen];
  const prompt = `${sc.prompt}\n\nStyle: ${s.modifier}.\n\nContext: ${WORLD}`;
  const body = [
    {
      taskType: 'imageInference',
      taskUUID: randomUUID(),
      positivePrompt: prompt,
      ...(s.noNeg ? {} : { negativePrompt: NEG }),
      model: s.model,
      width: s.size?.width ?? WIDTH,
      height: s.size?.height ?? HEIGHT,
      numberResults: 1,
      outputType: 'URL',
      outputFormat: 'WEBP',
      ...s.params,
    },
  ];
  const res = await fetch('https://api.runware.ai/v1', {
    method: 'POST',
    headers: { Authorization: `Bearer ${KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${text.slice(0, 300)}`);
  const data = JSON.parse(text);
  if (data.errors?.length) throw new Error(JSON.stringify(data.errors[0]).slice(0, 300));
  const r = data.data?.[0];
  if (!r?.imageURL) throw new Error(`no image: ${text.slice(0, 200)}`);
  const dl = await fetch(r.imageURL);
  const bytes = Buffer.from(await dl.arrayBuffer());
  const rel = join(job.style, `${job.name}.webp`);
  writeFileSync(join(OUT, rel), bytes);
  return { ...job, model: s.model, file: rel, prompt, bytes: bytes.length };
}

// simple concurrency-limited runner
async function run() {
  const results = [];
  let idx = 0;
  async function worker() {
    while (idx < jobs.length) {
      const job = jobs[idx++];
      const tag = `${job.style}/${job.name}`;
      try {
        const r = await gen(job);
        console.log(`  ✓ ${tag}  (${(r.bytes / 1024).toFixed(0)} KB)`);
        results.push(r);
      } catch (e) {
        console.error(`  ✗ ${tag}  [${STYLES[job.style].model}]  ${e.message}`);
        results.push({ ...job, model: STYLES[job.style].model, error: e.message });
      }
    }
  }
  console.log('');
  await Promise.all(Array.from({ length: CONCURRENCY }, worker));
  return results;
}

const results = await run();

// ---- outputs: manifest + contact sheet ------------------------------
writeFileSync(join(OUT, 'manifest.json'), JSON.stringify({ screens, styles, results }, null, 2));

// Rebuild the board from everything on disk (not just this run) so the index
// always reflects the full set of concepts. Shared with tools/build-board.mjs.
const ok = results.filter((r) => r.file);
buildBoard({ outDir: OUT, only: has('all') ? null : (screens.length === 1 ? screens[0] : null) });

const fails = results.filter((r) => r.error);
console.log(`\nDone. ${ok.length}/${results.length} generated.`);
if (fails.length) {
  const badModels = [...new Set(fails.map((f) => f.model))];
  console.log(`Failures on models: ${badModels.join(', ')} — likely not enabled on the account; edit STYLES to swap.`);
}
console.log(`\nOpen the board:  open ${join(OUT, 'index.html')}`);
