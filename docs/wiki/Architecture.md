---
tags: [descent, architecture, engine]
updated: 2026-06-21
---

# Architecture

DESCENT is a **Swift + SpriteKit** iOS game built on an **ECS-lite** pattern: lightweight entities driven by focused systems, coordinated through a `GameState` singleton and wired together with delegates. The whole thing runs through SpriteKit's physics engine for gravity, collision, and movement, with 2D sprite rendering and planned particle effects.

## Engine & Platform

- **Platform:** iOS (SpriteKit)
- **Language:** Swift 5+
- **Physics:** SpriteKit physics engine — gravity, collisions, movement
- **Rendering:** 2D sprite-based, with planned particle effects (see [[Drill Animation and VFX]])

## Architecture Patterns

- **ECS-lite** — Entities (`PlayerPod`, `TerrainBlock`) act on by Systems (`DamageSystem`, `ConsumableSystem`, `TerrainManager`). Entities hold state and physics bodies; systems hold logic.
- **Data Layer** — three-tier persistence: `GameProfile` (permanent) → `PlanetState` (per-planet) → `CurrentRun` (per-run). Full detail in [[Data Model]].
- **State Management** — `GameState` singleton owns the current game phase and run state.
- **Delegate Pattern** — systems communicate via delegates (e.g. `ConsumableSystemDelegate`) rather than reaching into each other. Use **weak** delegate references to avoid retain cycles.

> [!warning]
> `GameScene` is a ~1591-line god-object that orchestrates every system, owns drilling state, handles all touch input, and renders core-collection effects. This and other structural issues (no `Theme` constant, mixed responsibilities) are tracked in [[Code Review]].

## System Roster

| System | File | Responsibility |
|--------|------|----------------|
| TerrainManager | `Systems/TerrainManager.swift` | Procedural terrain generation, chunk loading — see [[Terrain and Strata]] |
| DamageSystem | `Systems/DamageSystem.swift` | Hull damage calculations — see [[Hull and Damage]] |
| ConsumableSystem | `Systems/ConsumableSystem.swift` | Consumable activation logic — feeds [[Fuel System]] and others |
| SupplyDropSystem | `Systems/SupplyDropSystem.swift` | Mid-run supply ordering — see [[Supply Drops]] |
| InputManager | `Systems/InputManager.swift` | Touch input handling |

The cargo flow (volume-based collection, auto-drop) is detailed in [[Cargo System]].

### How systems talk

Gameplay logic lives in systems; communication flows through delegates. For example, `ConsumableSystem` activates an effect and notifies `GameScene` via `ConsumableSystemDelegate`, which then triggers the corresponding visual effect. The `GameState` singleton is the shared source of truth for phase (surface vs. mining) and current counts.

## Terrain Generation

`TerrainManager` uses **chunk-based loading**:

- Generates terrain in **50-tile-wide chunks**
- Loads/unloads chunks based on player Y position to keep memory bounded
- Uses **seeded RNG** for deterministic generation
- Veins spawn based on depth ranges from the planet config

Off-screen blocks are removed to free memory. See [[Terrain and Strata]] and [[Materials and Economy]] for strata bands and vein data.

## Touch Controls

Input follows a consistent path:

1. `touchesBegan` in `GameScene` captures all touches.
2. The touch is delegated to the appropriate UI element (HUD, SurfaceUI, dialogs).
3. Movement uses a **vector from the touch point to the pod position**.
4. **Distance from the pod determines thrust intensity.**

## State Persistence

Three-tier model (full schema in [[Data Model]]):

```swift
GameProfile (Level 1) - Never resets
  └─ PlanetState (Level 2) - Resets on prestige
      └─ CurrentRun (Level 3) - Resets each run
```

All models are `Codable` for JSON serialization. Save triggers:

- Phase transitions (surface ↔ mining)
- Significant events (prestige, purchases)
- App backgrounding

### Prestige flow

1. Collect Dark Matter at the core (2500m depth on [[Mars]], out of 2560m total).
2. Return to surface with `coreExtracted = true`.
3. Show `PrestigeDialog` with the Soul Crystal calculation.
4. On prestige: sell cargo → calculate Soul Crystals → reset planet → regenerate terrain.
5. New terrain carries increased material values (Soul Crystal multiplier).

## Code Map

### Core game loop

- `DESCENT/Scenes/GameScene/GameScene.swift` — main scene, orchestrates all systems *(the god-object; see [[Code Review]])*
- `DESCENT/Models/GameState.swift` — central game state manager (singleton)
- `DESCENT/Entities/PlayerPod.swift` — player pod entity with physics body

### Systems

- `DESCENT/Systems/TerrainManager.swift`
- `DESCENT/Systems/DamageSystem.swift`
- `DESCENT/Systems/ConsumableSystem.swift`
- `DESCENT/Systems/SupplyDropSystem.swift`
- `DESCENT/Systems/InputManager.swift`

### UI components

- `DESCENT/Scenes/GameScene/HUD.swift` — fuel, hull, cargo, depth
- `DESCENT/Scenes/GameScene/SurfaceUI.swift` — surface shop with upgrade tabs
- `DESCENT/Scenes/GameScene/PrestigeDialog.swift` — prestige decision UI
- `DESCENT/Scenes/GameScene/SupplyDropUI.swift` — supply ordering menu
- `DESCENT/Scenes/GameScene/ConsumableUI.swift` — bottom consumable buttons

### Data models

- `DESCENT/Models/GameProfile.swift` — permanent progression (never resets)
- `DESCENT/Models/PlanetState.swift` — per-planet progression (resets on prestige)
- `DESCENT/Models/CurrentRun.swift` — current run state (resets each run)
- `DESCENT/Models/Material.swift` — material definitions and values
- `DESCENT/Models/Planet.swift` — planet configuration and strata

### Entity components

- `DESCENT/Entities/TerrainBlock.swift` — individual terrain blocks with materials
- `DESCENT/Entities/PlayerPod.swift` — player entity with physics body

## Performance Notes

- **Memory:** chunk-based terrain keeps memory bounded; remove off-screen blocks; weak delegate refs.
- **Optimization:** batch terrain generation (multiple blocks per frame), cache planet config and material definitions, use `SKTextureAtlas` for sprites.
- **iOS:** optimize for iPhone 8+, support size classes, handle backgrounding (save + pause), test on device. Touch targets ≥ 44pt.

## Related

[[Data Model]] · [[Terrain and Strata]] · [[Fuel System]] · [[Hull and Damage]] · [[Cargo System]] · [[Supply Drops]] · [[Drill Animation and VFX]] · [[Code Review]]
