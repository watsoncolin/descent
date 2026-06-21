---
tags: [descent, authoring, level-design]
updated: 2026-06-21
---

# Level Design Guide

How to author a new planet. A planet is a JSON config plus a design doc that fills in the same schema for every layer: strata → veins → hazards → obstacles → core. Follow the [[Terrain and Strata]] model and copy [[Mars]] as the reference build; the source template is `level_design/level-design-template.md`.

> [!todo] Authoring checklist
> A new planet ships when it has: a `<planet>.json` config (boundaries, hardness, resources, hazards, obstacles, gates, economy), a worked design doc, and a verified full-depth run with no soft-locks. Use the section order below.

## 1. Planet header

Define the top-level identity and per-planet physics. These map to JSON fields (see [[Mars#Planet config (`Resources/mars.json`)]]):

- **Name, Difficulty** (Tutorial → Master), **Theme** (one-line visual/geological hook).
- **Total Depth** and **Core Location** — *in meters*. Remember 1 block (64px) = 12.5m. Pick a `coreDepth` slightly above `totalDepth`.
- **Planet Order** (1–8) and **Unlock Requirements** (e.g. "Heat Resistance Lv1").
- **`gravity`**, **`tileSize`** (64), and **`valueMultiplier`** (1× Mars baseline; harder planets earn more — [[Materials and Economy#Planet value multiplier]]).

> [!warning] Author in one unit
> Depth copy is in meters but the runtime grid is in rows (1 row = 12.5m). Mars already drifted into two incompatible scales — see [[Terrain and Strata#The grid and chunk model]] and [[Code Review]]. Pick meters, convert once, and keep the JSON authoritative.

## 2. Visual design philosophy

State the aesthetic and how it differs from other planets: terrain style (smooth/rocky/crystalline/organic), color-palette theme, atmospheric effects, and 2–3 signature visual elements. Each strata gets **surface** and **excavated** gradient palettes plus a `contrast` value (~0.35–0.45 darker when mined). See [[Design System]] and [[Drill Animation and VFX]].

## 3. Geological structure — strata

Most planets use **4 strata** of increasing hardness. For each, fill the schema:

**Technical properties**
- **`hardness`** — baseline 1.0, max ≈ 4.0. Drives drill time: `actualDrillTime = 0.3s × hardness / drillLevel`.
- **`drillSpeedModifier`** (relative to sand), **`minimumDrillLevel`** (slow vs. comfortable).
- **Drill-time samples** at Lv1/3/5 — sanity-check against the table.
- **Colors** (surface + excavated gradients, contrast %).
- **Visual details** — variation size/opacity, flow-pattern angle (15–40°), texture overlays (8–12% opacity).

**Per-strata content** (sections 4–6 below): material veins, hazards, obstacles.

Worked Mars strata + the full drill-time table: [[Mars#Strata boundaries and hardness]] and [[Terrain and Strata#Strata properties]].

## 4. Material veins

For each material in a strata define: **spawn rate per chunk** (`seedRate`), **deposit radius** (10–22px), **cluster size** (Small 1–2 / Medium 2–4 / Large 3–6, via `veinSize*` / `clusterSize*`), **value** (Bocks/unit), **volume** (cargo units), and **purpose** in the economy. Materials should phase in/out with depth so each layer feels distinct.

- Spawn system: materials roll per **16×16-block chunk**; clustering places a seed then adjacent deposits within 2–3 blocks. [[Terrain and Strata#Vein-based procedural generation]].
- Pull values from the shared catalog rather than inventing numbers: [[Materials and Economy]].
- Provide a **Material Distribution Summary** table (depth range, frequency, value, volume, visual) and a **depth-based spawn-rate** grid.

## 5. Hazards

Define a hazard table escalating by depth. Each hazard needs: **spawn rate**, **trigger**, **damage** (+ DoT/effects), **visual warning**, **audio warning**, **avoidance**. Canonical types — gas pockets, unstable rock (chain-collapse), cave-ins (falling debris), lava pockets (damage + DoT). Track **cumulative danger** (combined %, avg HP lost, risk level); skilled players observing warnings should be able to cut hazard damage 50–70%. Damage routing: [[Hull and Damage]]. Mars reference: [[Mars#Hazards by strata (`mars.json`)]].

## 6. Obstacle materials

Every planet carries the three obstacle types from [[Terrain and Strata#Obstacle block types]], re-skinned to theme (Mars sets the baseline; e.g. Europa = ice crystals, Venus = sulfur crystals + heat-resistant alloy). For each, set **spawn coverage by depth**:

- **Bedrock** — indestructible, navigate only. Coverage scales ~3% → 20%+.
- **Hard Crystal** — bomb-only ($800), economic gate. Coverage ~2–8%.
- **Reinforced Rock** — Drill Lv4+ (or Lv5 deep) / bomb, progression gate. Deep layers only (300m+), ~3–8%.

**Distribution rules:** never block all paths (pathfinding-validated), cluster obstacles near valuable veins, form cave systems not noise, scale coverage with depth (surface ~3% → core ~36%), and mix types deep. Give a **total obstacle coverage by depth** table.

## 7. Core + prestige

The deepest strata ends in a **safe open chamber** (hazard-free, ~10×10 blocks) holding one unique core material that triggers prestige on extraction — and force the return trip (no teleporter bypass). Specify chamber size/position, core visual + animation, value, and volume. Soul Crystal mechanics are shared: [[Materials and Economy#Soul Crystal bonus (prestige)]]. Mars example: [[Mars#Core chamber + Dark Matter prestige goal]].

## 8. Tuning sections to complete

Round out the doc with the same analysis Mars carries, so balance is verifiable:

- **Progression guidelines** — what to do / expected earnings across First / 2–5 / 6–10 / 10+ runs.
- **Progression gates** — depth → required drill level (JSON `progressionGates`).
- **Run-time estimates** — drilling + movement time per drill level.
- **Economy balance** — target net earnings per run, `expectedEarnings` by depth, upgrade cost scaling (Tiers 1–4), consumable prices, and minimum upgrade requirements by depth.
- **Planet-specific mechanics** — anything unique (heat/cold resistance, floating materials), with balance notes.

## 9. Technical + QA

The implementation guide and checklist port directly from the template: z-index layering, the four-step terrain generation (base terrain → obstacles → minerals → hazards), mining/collision code, and performance (chunk loading ±3 rows, sprite pooling ≤500, spatial-hash collision). Architecture context: [[Architecture]] and [[Data Model]].

> [!todo] Validation gate (must pass)
> Full-depth run completes; drill times match the table; spawn rates and hazard values match spec; economy earnings vs. costs balance; prestige works; **no soft-locks (a navigable path always exists)**; edge cases handled (full cargo, zero fuel, zero HP).

## Related

[[Terrain and Strata]] · [[Mars]] · [[Materials and Economy]] · [[Hull and Damage]] · [[Drill Animation and VFX]] · [[Design System]] · [[Architecture]] · [[Data Model]] · [[Code Review]]
