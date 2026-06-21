---
tags: [descent, planet, mars]
updated: 2026-06-21
---

# Mars

Mars is planet **1 of 8** — the tutorial planet, always unlocked. A rust-colored excavation with four strata of escalating hardness, ending in an ancient planetary core that hides the Dark Matter prestige goal. It is the canonical worked example for the [[Terrain and Strata]] model and [[Level Design Guide]] schema.

![[descent-terrain-grid.svg]]

## Planet config (`Resources/mars.json`)

| Field | Value |
| --- | --- |
| `name` | Mars |
| `totalDepth` | **2620m** |
| `coreDepth` | **2560m** |
| `valueMultiplier` | 1.0 |
| `gravity` | 0.38 (38% of Earth) |
| `tileSize` | 64px |
| `difficulty` | Tutorial |
| `planetOrder` | 1 |
| `unlockRequirements` | None — always available |

Theme: *"Red desert planet with iron-rich soil, ancient geology, and increasing danger with depth."* Core depth, total depth, gravity, and value multiplier are all **per-planet** — every planet's JSON can set different physics and progression. See [[Materials and Economy#Planet value multiplier]].

> [!warning] Two depth scales are in play — use `mars.json`
> `mars.json` and the `mars_level_design.md` header agree: **2620m total, core at 2560m** (205 rows at 12.5m each, core chamber ≈ row 200). But the body of `mars_level_design.md` (strata definitions, distribution tables, the Dark Matter "490m" chamber) still uses an **old 0–500m / 40-row** scale that was never migrated. Where they conflict, **`mars.json` is authoritative.** This meters-vs-rows split is a known bug source — see [[Terrain and Strata#The grid and chunk model]] and [[Code Review]].

## Strata boundaries and hardness

Authoritative boundaries from `mars.json` (depths in meters):

| # | Strata | Depth (m) | Hardness | Drill Speed | Min Drill Lv | Surface palette |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Surface Sand | 0–640 | 1.0 | 1.0× | 1 | #c4a57b / #b89a70 / #a89060 |
| 2 | Stone Layer | 640–1280 | 1.5 | 0.67× | 2 | #6a7a8a / #5a6a7a / #4a5a6a |
| 3 | Deep Rock | 1280–1920 | 2.5 | 0.4× | 3 | #7a8090 / #6a7080 / #5a6070 |
| 4 | Mars Core Zone | 1920–2560 | 3.5 | 0.3× | 4 | #b85a40 / #a04a30 / #8a3a20 |

`mars_level_design.md`'s overview block maps these to rows: Strata 1 = blocks 0–51, Strata 2 = 51–102, Strata 3 = 102–154, Strata 4 = 154–205, with the **Core Chamber at 2500m (Block 200)**. Hardness 1.0/1.5/2.5/3.5 is consistent across both sources. Drill-time math is in [[Terrain and Strata#Strata properties]] and [[Drill Animation and VFX]].

> [!note] Legacy strata depths
> The detailed strata write-ups in `mars_level_design.md` are headed with old ranges (Surface Sand 0–125m, Stone 125–250m, Deep Rock 250–375m, Mars Core 375–500m). They describe the same four layers — just rescale to the table above when authoring.

## Veins / material spawns by depth

Per-strata `seedRate` (spawn chance per chunk) from `mars.json`. Full value/volume table in [[Materials and Economy#Mars runtime values (Resources/mars.json)]].

| Material | Surface Sand | Stone Layer | Deep Rock | Core Zone | Value | Volume |
| --- | --- | --- | --- | --- | --- | --- |
| Coal | 0.6 | 0.35 | — | — | 10 | 1.0 |
| Iron | 0.1 | 0.9 | 0.17 | — | 25 | 1.5 |
| Copper | — | — | 0.17 | 0.12 | 30 | 1.8 |
| Silicon | — | — | — | 0.12 | 50 | 1.3 |
| Gold | — | — | — | 0.08 | 100 | 2.0 |
| Dark Matter | — | — | — | 0.0001 | 10,000 | 0.1 |

Veins use `veinSizeMin/Max` and `clusterSizeMin/Max` (e.g. coal veins 3–8, clusters 8–12; gold veins 1–3, clusters 2–4 — rare and small). Generation rules: [[Terrain and Strata#Vein-based procedural generation]].

### Hazards by strata (`mars.json`)

| Strata | Gas Pocket | Unstable Rock | Cave-in | Lava Pocket |
| --- | --- | --- | --- | --- |
| Surface Sand | — | — | — | — |
| Stone Layer | 0.10 (8 HP) | 0.05 (10 HP) | — | — |
| Deep Rock | 0.12 (10 HP) | 0.08 (15 HP) | 0.05 (20 HP) | — |
| Core Zone | 0.15 (15 HP) | 0.12 (20 HP) | 0.08 (25 HP) | 0.05 (25 HP, 20% DoT over 3s) |

Hull/damage detail lives in [[Hull and Damage]].

### Obstacles by strata (`mars.json`)

| Strata | Bedrock | Hard Crystal (bomb) | Reinforced Rock |
| --- | --- | --- | --- |
| Surface Sand | 0.0 | — | — |
| Stone Layer | 0.08 | 0.03 | — |
| Deep Rock | 0.12 | 0.05 | 0.03 (Drill Lv4) |
| Core Zone | 0.20 | 0.08 | 0.08 (Drill Lv5) |

> [!note] Obstacle-coverage discrepancy
> The narrative in `mars_level_design.md` quotes bedrock 3%/5%/10%/20%, crystal 0/2/5/8%, reinforced 0/0/3/8% — close to but not identical with `mars.json` (above; e.g. bedrock surface 0% vs. 3%, stone 8% vs. 5%). Reinforced rock also requires **Drill Lv5** in the core zone per JSON, not just Lv4. Trust the JSON. Mechanics: [[Terrain and Strata#Obstacle block types]].

## Progression gates (`mars.json`)

| Depth (m) | Requirement |
| --- | --- |
| 640 | Drill Level 2+ recommended (Stone Layer) |
| 1280 | Drill Level 3+ required (Deep Rock) |
| 1920 | Drill Level 4+ required (Core Zone) |

Special features by strata: dust storms / surface rocks (Sand), rock striations / mineral veins (Stone), dense rock layers / pressure zones (Deep Rock), lava channels / core energy / alien artifacts (Core).

## Core chamber + Dark Matter prestige goal

At the bottom of the Core Zone sits a **safe open chamber** (10×10 blocks, 640×640px, hazard-free) holding a single **Dark Matter Crystal** — a glowing orange-red pulsing sphere (0.8–1.2 scale, 2s cycle).

- **Value:** 10,000 Bocks; **Volume:** 0.1 (negligible weight); `seedRate` 0.0001 (unique).
- Collecting it sets `coreExtracted` and **triggers the prestige system**.
- **No teleporter bypass** — you must drill back to the surface carrying it, then the [[Architecture|PrestigeDialog]] offers the Soul Crystal trade.

`mars.json` economy hints: `prestigeSoulCrystals: 15`, `runsToMaxOut: 20`. (Note the Soul Crystal *formula* conflicts across docs — see [[Materials and Economy#Soul Crystal bonus (prestige)]].) Expected earnings ramp from 500 Bocks at 100m to 40,000 at 2,500m ([[Materials and Economy#Mars economy targets]]).

## Related

[[Terrain and Strata]] · [[Materials and Economy]] · [[Level Design Guide]] · [[Hull and Damage]] · [[Drill Animation and VFX]] · [[Game Design]] · [[Code Review]]
