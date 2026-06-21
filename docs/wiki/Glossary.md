---
tags: [descent, reference]
updated: 2026-06-21
---
# Glossary

Quick definitions for DESCENT terms. See [[Game Design]] for how they fit together.

- **Pod** — the player's drilling vessel. Moves by thrust toward the touch point; descends to mine. See [[Hull and Damage]], [[Fuel System]].
- **Bocks / Credits** — the temporary, per-run-ish soft currency spent on upgrades and consumables. Design docs call it **Bocks**; the current build's HUD labels it **Credits**. See [[Decisions]] for the naming note and [[Materials and Economy]].
- **Soul Crystals** — the permanent prestige currency. Earned on [[#Prestige]]; grants stacking earning bonuses that persist across resets. Formula: `sqrt(totalEarnings / 1000)`.
- **Prestige** — collect the Dark Matter at a planet's core, return to surface, and reset planet-specific progress in exchange for [[#Prestige|Soul Crystals]] and higher material values on the next descent.
- **Strata** — horizontal rock layers defined by depth, each with a **hardness** that scales drill time and fuel cost. See [[Terrain and Strata]].
- **Hardness** — per-stratum difficulty multiplier (Mars: 1.0 / 1.5 / 2.5 / 3.5). Drives drill duration and fuel-per-block.
- **Vein** — a procedurally generated, depth-gated cluster of a material deposited through the terrain. Spawned by seeded RNG. See [[Materials and Economy]].
- **Chunk** — a vertical slice of terrain streamed in/out as the pod descends, to bound memory. See [[Architecture]].
- **Block / `metersPerBlock`** — one grid cell is 64px = **12.5m** (`TerrainBlock.metersPerBlock`). The grid-rows-vs-meters distinction is a notorious bug source — see [[Code Review]].
- **Obstacle blocks** — `bedrock` (indestructible), `reinforcedRock` (needs Drill Level 4+), `hardCrystal` (needs a bomb). See [[Terrain and Strata]].
- **Dark Matter** — the alien-tier material at a planet's [[#Core chamber]]; collecting it unlocks [[#Prestige]].
- **Core chamber** — the walled cavity at the bottom of a planet holding the Dark Matter crystal.
- **Cargo (volume-based)** — hold capacity measured in volume, not count; an **auto-drop** routine jettisons lowest-value material when full. See [[Cargo System]].
- **Supply Drop** — mid-run ordering of consumables/fuel delivered into the shaft, with per-order capacity limits. See [[Supply Drops]].
- **Dampeners** — hull upgrade that raises the impact threshold before damage is taken. See [[Hull and Damage]].
- **Consumables** — Repair Kit, Fuel Cell, Bomb, Teleporter, Shield. See [[Fuel System]], [[Hull and Damage]].
- **Material tiers** — real elements → exotic materials → alien materials, with ~100× value scaling across the 8 planets. See [[Materials and Economy]].
