---
tags: [descent, terrain]
updated: 2026-06-21
---

# Terrain and Strata

Every planet is a vertical stack of **strata** — horizontal bands of terrain with their own hardness, palette, materials, hazards, and obstacle mix. Terrain is generated procedurally from a seeded RNG into a grid of 64px blocks, then carved away by drilling. This page is the model; [[Mars]] is the worked example and [[Level Design Guide]] is the authoring schema.

## The grid and chunk model

- **Block size:** 64px per tile (`tileSize` in the planet JSON).
- **Scale:** 1 block (64px) = **12.5 meters** of depth (5.12px per meter).
- **Chunks:** terrain generates in regions and loads/unloads around the player. Material spawns roll per **16×16-block chunk** (1024×1024px). [[Architecture]]'s `TerrainManager` generates in 50-tile-wide chunks, loads/unloads by player Y, and caches chunk data for reload.
- **Dual-layer blocks:** each block has a **surface layer** (visible before mining, z=5) and an **excavated layer** (darker, compacted, revealed after mining, z=4). Mining fades the surface out (0.15s) and exposes the excavated layer beneath.

> [!warning] Meters vs grid-rows is a recurring bug source
> Depth is expressed in **meters** in design copy but the runtime works in **grid rows** (1 row = 64px = 12.5m). The Mars docs even disagree with themselves: the strata table in `mars_level_design.md` still uses an old 0–500m / "64px = 12.5m → 40 rows" scale, while the header and `Resources/mars.json` use the current 0–2620m scale (205 rows, core at row 200). Treat `mars.json` as authoritative for boundaries and always confirm whether a number is meters or rows before using it. See [[Code Review]] and [[Mars]].

## Deterministic seeding

Terrain uses a **seeded RNG** so a given seed reproduces the same layout — veins, obstacles, and hazards included. This keeps generation reproducible across runs and devices and lets pathfinding validation run against a known map. Per-block strata is chosen by depth (y-position); Perlin noise (scale 0.05) adds organic surface variation.

## Strata properties

Each strata defines:

| Property | Meaning |
| --- | --- |
| `hardness` | Drill-resistance multiplier (1.0 baseline → 3.5 max on Mars) |
| `drillSpeedModifier` | Effective speed vs. sand (1.0 = full speed) |
| `minimumDrillLevel` | Drill level for comfortable mining |
| `surfaceColors` / `excavatedColors` | Gradient palettes before/after mining |
| `contrast` | How much darker the excavated layer is (~0.35–0.45) |
| `resources` | Mineable veins (see [[Materials and Economy]]) |
| `hazards` | Gas pockets, unstable rock, cave-ins, lava |
| `obstacles` | Bedrock / hard crystal / reinforced rock |

**Drilling formula** (see [[Drill Animation and VFX]] for feedback tiers):

```
actualDrillTime = 0.3s × strataHardness / drillLevel
```

## Vein-based procedural generation

Materials spawn as **veins/clusters**, not single tiles. Per chunk, per valid material:

1. Roll the per-strata spawn chance (`seedRate`, e.g. coal 0.6).
2. On success, pick a cluster size (Small 1–2 @ 40%, Medium 2–4 @ 40%, Large 3–6 @ 20%; runtime JSON uses `clusterSizeMin/Max` and `veinSizeMin/Max`).
3. Place the first deposit at a random valid tile.
4. Place the rest adjacent (within 2–3 blocks, `clusterRadiusMin/Max`).
5. Apply the material's deposit radius (10–22px).

Obstacles are embedded the same way, with a **pathfinding check** guaranteeing at least one navigable route survives (minimum 3-tile-wide passages, ≥2 distinct paths per layer).

## Obstacle block types

Three non-mineable block types create navigation and economic friction. Pulled from [[#Obstacle interaction matrix]] below; full lore/visuals in `OBSTACLE_MATERIALS_GUIDE.md`.

### Bedrock — completely indestructible

- Very dark gray/black (#1a1a1a), rough cracked texture, no glow, thick borders.
- **Cannot be drilled at any level. Cannot be bombed.** Must navigate around.
- Drill makes a dull "clunk"; pod bounces off; brief "INDESTRUCTIBLE" indicator.
- Forms maze-like blobs, often guarding valuable veins. Coverage scales with depth (3% → 20% on Mars).
- Formation sizes scale with depth: shallow 3×3–5×5, medium 8×10–12×15, deep 15×20–20×25 (runtime `mars.json` uses smaller per-block formations, e.g. 1×1, 1×2 shallow, up to 4×4 / 5×3 in the core).

### Reinforced Rock — drill Level 4+ (or bomb)

- Dark gray with metallic silver streaks (#4a4a4a), industrial/engineered look, metallic sheen.
- **Requires Drill Level 4+** to break (runtime: Lv4 in Deep Rock, **Lv5** in Mars Core). Lower levels bounce ("DRILL LEVEL 4 REQUIRED"). Takes ~2× longer than normal rock even when drillable.
- **Can also be destroyed with a bomb** ($800). Acts as a soft progression gate that encourages drill upgrades.
- Only appears in deep layers (300m+). Coverage 3–8%. Moderate formations (4×4–6×6).

### Hard Crystal — bomb-only

- Iridescent purple-blue (#8B00FF) with a pulsing glow (0.5s cycle), faceted, translucent, lit from within.
- **Cannot be drilled at any level. CAN be destroyed with a bomb** ($800; $400 at surface). Explosion clears a 5×5 area.
- High-pitched "ting" + sparks when drilled (no damage). Shatters into purple shards when bombed.
- Creates "pay to pass" decisions; frequently guards diamonds/platinum and walls off core entrances. Coverage 2–8%, peaking in the deep "crystal zone."

### Obstacle interaction matrix

| Material | Drill Lv1 | Drill Lv3 | Drill Lv5 | Bomb | Navigate |
|----------|-----------|-----------|-----------|------|----------|
| Bedrock | ✗ No | ✗ No | ✗ No | ✗ No | ✓ Must |
| Hard Crystal | ✗ No | ✗ No | ✗ No | ✓ Yes | ✓ Can |
| Reinforced Rock | ✗ No | ✗ No | ✓ Yes (slow) | ✓ Yes | ✓ Can |
| Normal Rock | ✓ Slow | ✓ Fast | ✓ Very Fast | ✓ Yes | ✓ Can |

| Material | Color | Drill? | Bomb? | Navigate? | Depth | Coverage |
|----------|-------|--------|-------|-----------|-------|----------|
| Bedrock | Black | ✗ | ✗ | ✓ Required | All | 3–20% |
| Hard Crystal | Purple | ✗ | ✓ $800 | ✓ Possible | 80m+ | 2–8% |
| Reinforced Rock | Gray-Silver | ✓ Lv4+ | ✓ $800 | ✓ Possible | 300m+ | 3–8% |

### Obstacle placement rules

1. **Never block all paths** — pathfinding validation guarantees a route.
2. **Cluster near value** — ~50–60% of hard crystal spawns guard high-value veins; 30% sit on bedrock edges (compound barriers); ~20% random.
3. **Form cave systems**, not scattered noise.
4. **Scale with depth** — total obstacle coverage climbs from ~3% at the surface to ~36% in the core zone.
5. **Mix types** in deep zones for varied challenge.

## Design intent

Obstacles exist to defeat boring straight-down drilling and path memorization: bedrock is pure navigation, reinforced rock gates progression (buy a [[Hull and Damage|better]] drill or burn bombs), and hard crystal forces economic choices. Together they reward spatial planning and resource management.

## Related

[[Materials and Economy]] · [[Mars]] · [[Level Design Guide]] · [[Architecture]] · [[Data Model]] · [[Drill Animation and VFX]] · [[Code Review]]
