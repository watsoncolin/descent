# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DESCENT** is an iOS mining game inspired by Motherload with Egg Inc-style progression mechanics. Built using **Swift + SpriteKit**.

### Core Concept
- Drill through planets extracting minerals
- Dual-currency system: Credits (temporary) and Soul Crystals (permanent prestige currency)
- Prestige system resets planet-specific upgrades but grants permanent earning bonuses
- Volume-based cargo with auto-drop optimization

---

## Design Documentation

**All game design specifics live in dedicated design documents:**

### Core Design
- **DESIGN.md** - Complete game design, mechanics, progression
- **MISSING_FEATURES.md** - Implementation status and task tracking
- **DATA_MODEL.md** - Data structures and persistence layers

### System-Specific Design
- **FUEL_SYSTEM.md** - Fuel consumption, warnings, emergency return
- **CARGO_SYSTEM.md** - Volume-based cargo, auto-drop algorithm
- **HULL_SYSTEM.md** - Damage system, impact physics
- **SUPPLY_DROP_SYSTEM.md** - Mid-run item ordering with capacity limits
- **OBSTACLE_MATERIALS_GUIDE.md** - Terrain types and materials

### Level Design
- **level_design/mars_level_design.md** - Mars planet configuration
- **level_design/mars.json** - Mars strata and vein generation data

**When implementing features, always consult the relevant design document first.**

---

## Technical Stack

### Engine & Platform
- **Platform**: iOS (SpriteKit)
- **Language**: Swift 5+
- **Physics**: SpriteKit physics engine for gravity, collisions, movement
- **Rendering**: 2D sprite-based with planned particle effects

### Architecture Patterns
- **ECS-lite**: Entities (PlayerPod, TerrainBlock) with Systems (DamageSystem, ConsumableSystem, TerrainManager)
- **Data Layer**: GameProfile (permanent) → PlanetState (per-planet) → CurrentRun (per-run)
- **State Management**: GameState singleton manages current game phase and state
- **Delegate Pattern**: Systems communicate via delegates (e.g., ConsumableSystemDelegate)

---

## Current Development Status

**Phase**: Phase 1 → Phase 3 transition (~70% complete)

### ✅ Implemented
- Core movement, drilling, fuel, hull, cargo systems
- All 6 Common Upgrades (Fuel Tank, Drill, Cargo, Hull, Engine Speed, Dampeners)
- All 5 consumables (Repair Kit, Fuel Cell, Bomb, Teleporter, Shield)
- Supply drop system with capacity (5-20 items per order)
- Prestige system with Soul Crystal bonuses
- Terrain generation with vein-based procedural spawning
- Save/load system with persistence

### ❌ Missing (High Priority)
- Fuel/hull warning systems (25%, 10%, 5% thresholds)
- Emergency return system (auto-ascent at 0 fuel with cargo penalty)
- Visual/audio polish (particles, screen shake, haptics, sound)
- Hazards (gas pockets, cave-ins)
- Tutorial system

**See MISSING_FEATURES.md for complete status.**

---

## Key Code Locations

### Core Game Loop
- `DESCENT/Scenes/GameScene/GameScene.swift` - Main game scene, orchestrates all systems
- `DESCENT/Models/GameState.swift` - Central game state manager
- `DESCENT/Entities/PlayerPod.swift` - Player pod entity with physics

### Systems
- `DESCENT/Systems/TerrainManager.swift` - Procedural terrain generation, chunk loading
- `DESCENT/Systems/DamageSystem.swift` - Hull damage calculations
- `DESCENT/Systems/ConsumableSystem.swift` - Consumable activation logic
- `DESCENT/Systems/SupplyDropSystem.swift` - Mid-run supply ordering
- `DESCENT/Systems/InputManager.swift` - Touch input handling

### UI Components
- `DESCENT/Scenes/GameScene/HUD.swift` - In-game HUD (fuel, hull, cargo, depth)
- `DESCENT/Scenes/GameScene/SurfaceUI.swift` - Surface shop with upgrade tabs
- `DESCENT/Scenes/GameScene/PrestigeDialog.swift` - Prestige decision UI
- `DESCENT/Scenes/GameScene/SupplyDropUI.swift` - Supply ordering menu
- `DESCENT/Scenes/GameScene/ConsumableUI.swift` - Bottom consumable buttons

### Data Models
- `DESCENT/Models/GameProfile.swift` - Permanent progression (never resets)
- `DESCENT/Models/PlanetState.swift` - Per-planet progression (resets on prestige)
- `DESCENT/Models/CurrentRun.swift` - Current run state (resets each run)
- `DESCENT/Models/Material.swift` - Material definitions and values
- `DESCENT/Models/Planet.swift` - Planet configuration and strata

### Entity Components
- `DESCENT/Entities/TerrainBlock.swift` - Individual terrain blocks with materials
- `DESCENT/Entities/PlayerPod.swift` - Player entity with physics body

---

## Implementation Patterns

### When Adding New Features

1. **Check design docs first** - DESIGN.md or system-specific .md files
2. **Update MISSING_FEATURES.md** - Mark features as implemented
3. **Follow existing patterns**:
   - Systems for gameplay logic
   - Delegates for communication
   - Codable for persistence
4. **Test with existing save system** - Ensure data persists correctly

### Touch Controls Implementation

Touch controls follow this pattern:
- `touchesBegan` in GameScene handles all touches
- Delegate to appropriate UI element (HUD, SurfaceUI, dialogs)
- Movement uses vector from touch to pod position
- Distance from pod determines thrust intensity

### Terrain Generation

TerrainManager uses chunk-based loading:
- Generates terrain in 50-tile wide chunks
- Loads/unloads chunks based on player Y position
- Uses seeded RNG for deterministic generation
- Veins spawn based on depth ranges from planet config

### State Persistence

Three-tier persistence model:
```swift
GameProfile (Level 1) - Never resets
  └─ PlanetState (Level 2) - Resets on prestige
      └─ CurrentRun (Level 3) - Resets each run
```

Save on:
- Phase transitions (surface ↔ mining)
- Significant events (prestige, purchases)
- App backgrounding

### Prestige Flow

Prestige sequence:
1. Collect Dark Matter at core (490m depth on Mars)
2. Return to surface with `coreExtracted = true` flag
3. Show PrestigeDialog with Soul Crystal calculation
4. On prestige: sell cargo → calculate Soul Crystals → reset planet → regenerate terrain
5. New terrain has increased material values (Soul Crystal multiplier)

---

## Common Tasks

### Adding a New Upgrade

1. Add to `CommonUpgrades` struct in PlanetState.swift
2. Add cost/level data to upgrade methods
3. Add UI in SurfaceUI.swift (upgrade tab)
4. Update purchase handler in GameScene.swift
5. Apply effect in relevant system (e.g., PlayerPod for speed)

### Adding a New Consumable

1. Add enum case to `ConsumableType` in ConsumableSystem.swift
2. Add count property to GameState/PlanetState
3. Add activation logic in ConsumableSystem
4. Add button to ConsumableUI.swift
5. Add purchase option in SurfaceUI.swift (consumables tab)
6. Handle visual effects via delegate in GameScene

### Adding a New Material

1. Add enum case to `MaterialType` in Material.swift
2. Add base value, volume, hardness
3. Add to planet vein configuration (mars.json)
4. Add color definition in TerrainBlock.swift
5. Test spawning at appropriate depth range

### Adding Visual/Audio Effects

1. **Particles**: Create SKEmitterNode, add to scene at event location
2. **Screen shake**: Use SKAction.move on camera with quick return
3. **Haptics**: UIImpactFeedbackGenerator with .light/.medium/.heavy
4. **Sound**: AVAudioPlayer or SKAction.playSoundFileNamed

---

## Performance Considerations

### Memory Management
- Chunk-based terrain loading keeps memory bounded
- Remove off-screen terrain blocks to free memory
- Use weak references for delegates to prevent retain cycles

### Optimization
- Batch terrain generation (generate multiple blocks per frame)
- Cache frequently accessed data (planet config, material definitions)
- Use SKTexture atlas for sprite rendering efficiency

### iOS Best Practices
- Support older devices (optimize for iPhone 8+)
- Use size classes for different screen sizes
- Handle app backgrounding (save state, pause game)
- Test on actual devices, not just simulator

---

## Testing Checklist

When implementing features, test:
- [ ] Works with existing save data (backwards compatible)
- [ ] Persists correctly through app restart
- [ ] Handles edge cases (0 fuel, full cargo, etc.)
- [ ] Touch targets are appropriately sized (44pt minimum)
- [ ] No memory leaks (use Instruments)
- [ ] Performs well on older devices

---

## Notes for Claude Code

- **Always read design docs before implementing** - Don't guess at mechanics
- **Update MISSING_FEATURES.md** when completing items
- **Follow existing code patterns** - Consistency is key
- **Test save/load** after data model changes
- **Consider performance** - This runs on mobile devices
- **Ask if design is unclear** - Better to clarify than implement wrong

**Current Focus**: Implementing warning systems (fuel/hull) and emergency return system. See MISSING_FEATURES.md Priority 1 items.
