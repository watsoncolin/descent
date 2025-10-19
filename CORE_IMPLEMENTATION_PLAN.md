# Core System Implementation Plan

## Overview
Implement the complete core extraction system for Mars, including visual polish, gameplay mechanics, and prestige flow.

---

## Phase 1: ~~Fix Core Depth Configuration~~ ✅ VERIFIED CORRECT

### Status: NO ACTION NEEDED

Core depth is a **per-planet configuration** stored in each planet's JSON file:
- **Mars**: `coreDepth: 2500m` (out of `totalDepth: 2560m`)
- This is intentional and correct for the current design
- Each planet can have different depths based on difficulty

### What Was Updated
- ✅ Mars level design doc updated to reflect actual implementation (2560m total, 2500m core)
- ✅ Added note about per-planet configuration in design docs
- ✅ Verified core chamber generation works correctly at configured depth

### Files
- Updated: `level_design/mars_level_design.md`
- No code changes needed

---

## Phase 2: Core Chamber Visuals

### Current State
Core chamber is empty space (10×10 blocks) with no visual indicators

### Design Requirements
- Glowing ambient light in chamber
- Orange-red gradient background
- Particle effects (floating dust, energy wisps)
- Hazard-free zone indicator
- Different terrain texture/color for chamber walls

### Tasks
- [ ] Create `CoreChamber` SKNode class
- [ ] Add ambient orange-red glow sprite (subtle radial gradient)
- [ ] Add particle system for floating energy wisps
- [ ] Create chamber wall texture (darker, smoother than regular terrain)
- [ ] Position chamber visuals at `coreDepth` in `TerrainManager`
- [ ] Set zPosition correctly (behind terrain but above background)

### Files
- New: `DESCENT/Entities/CoreChamber.swift`
- Modify: `DESCENT/Systems/TerrainManager.swift`

---

## Phase 3: Dark Matter Crystal Enhanced Visuals ✅ COMPLETE

### Current State
✅ Dark Matter now uses custom PNG asset with pulsing animation and glow

### Design Requirements
- Pulsing animation (0.8-1.2 scale, 2 second cycle)
- Orange-red gradient with strong outer glow
- Larger size than normal materials (5x deposit size)
- Always visible (not hidden by terrain)

### Tasks
- [x] Add check in `MaterialDeposit.setupVisuals()` for `.darkMatter` type
- [x] Create custom Dark Matter visual using asset image
- [x] Large glowing sprite (5x normal material size)
- [x] Strong outer glow (7x size with blur radius 15)
- [x] Pulsing scale animation (0.8 → 1.2 → 0.8, 2s repeat forever)
- [x] Counter-pulsing glow animation for visual interest
- [x] Set high zPosition (15 for core, 14 for glow, above terrain)

### Files
- Modified: `DESCENT/Entities/MaterialDeposit.swift:60-94` (special Dark Matter handling)

---

## Phase 4: Teleporter Disable After Core Collection ✅ COMPLETE

### Current State
✅ Teleporter is now disabled after Dark Matter collection

### Design Requirement
Teleporter should be disabled once Dark Matter is collected (force surface return)

### Tasks
- [x] Check `coreExtracted` flag in `GameState.useTeleporter()`
- [x] Return false if core has been extracted
- [x] Show message when player tries to use disabled teleporter: "Teleporter disabled - Core extracted! Return to surface manually."

### Files
- Modified: `DESCENT/Models/GameState.swift:442-457` (added check)

---

## Phase 4.5: Bedrock Barrier at Core Bottom ✅ COMPLETE

### Design Requirement
Prevent pod from descending deeper than core chamber (user request)

### Implementation
- Bottom row of core chamber uses indestructible bedrock blocks
- Cannot be drilled through or destroyed by bombs
- Forces player to return to surface after core collection

### Tasks
- [x] Add bedrock block placement at `y >= totalDepth - 1` in core chamber
- [x] Set collision type to `.obstacle(.bedrock)` for indestructibility
- [x] Create physics bodies to prevent passage

### Files
- Modified: `DESCENT/Systems/TerrainManager.swift:148-157` (bedrock barrier in `generateChunk()`)

---

## Phase 5: Optional Force-Return Mechanic

### Design Consideration
"Force return to surface journey" after core collection

### Options
1. **Soft Force** (Recommended for Phase 1):
   - Disable teleporter (Phase 4)
   - Keep drilling enabled
   - Player must navigate back manually
   - More engaging gameplay

2. **Hard Force** (Optional for Phase 2):
   - Automatically start ascending
   - Remove player control temporarily
   - Auto-navigate to surface
   - More cinematic but less engaging

### Recommended: Implement Option 1 (Soft Force) First
Already covered by Phase 4 (teleporter disable)

---

## Phase 6: Core Collection Special Effects ✅ COMPLETE

### Tasks
- [x] Screen flash effect (orange-red pulse covering full screen)
- [x] Camera shake (stronger than normal - 15px amplitude, 0.6s duration)
- [x] Special particle burst (24 energy particles flying outward)
- [x] Large expanding burst at collection point (15x scale)
- [x] HUD notification: "CORE EXTRACTED!\nReturn to surface to prestige!"
- [ ] Add special sound effect on core collection (optional - no audio assets yet)

### Files
- Modified: `DESCENT/Scenes/GameScene/GameScene.swift:1438-1510` (added `createCoreCollectionEffect()`)
- Modified: `DESCENT/Scenes/GameScene/GameScene.swift:1065-1066` (call effect on Dark Matter collection)
- Modified: `DESCENT/Scenes/GameScene/HUD.swift:131-163` (added `showNotification()` method)

---

## Phase 7: Prestige Flow Polish

### Current State
Prestige dialog shows on surface return if core extracted (✅ working)

### Enhancements
- [ ] Add prestige preview calculation in dialog
- [ ] Show Soul Crystal gain calculation breakdown
- [ ] Add warning about what will be lost/kept
- [ ] Add animation when prestige button is pressed
- [ ] Add confirmation step ("Are you sure?")

### Files
- Modify: `DESCENT/Scenes/GameScene/PrestigeDialog.swift`

---

## Phase 8: Testing & Balance

### Test Cases
- [ ] Core spawns at correct depth (490m for Mars)
- [ ] Core chamber is hazard-free (no gas pockets, cave-ins)
- [ ] Dark Matter crystal is visible and collectable
- [ ] Collecting Dark Matter sets `coreExtracted` flag
- [ ] Teleporter disables after core collection
- [ ] Prestige dialog shows on surface return with core
- [ ] Regular sell dialog shows on surface return without core
- [ ] Dark Matter has correct value (10,000 Bocks)
- [ ] Dark Matter counts toward cargo space (0.1 units)
- [ ] Prestige correctly resets upgrades and Bocks
- [ ] Prestige correctly keeps Soul Crystals
- [ ] Soul Crystal multiplier applies to next run

---

## Priority Order

### High Priority (Implement First) ✅ ALL COMPLETE
1. ✅ Phase 1: Core Depth Configuration (VERIFIED CORRECT - no changes needed)
2. ✅ Phase 3: Dark Matter Enhanced Visuals (COMPLETE - pulsing animation + glow)
3. ✅ Phase 4: Teleporter Disable (COMPLETE - disabled after core collection)
4. ✅ Phase 6: Core Collection Effects (COMPLETE - screen flash, camera shake, particles, HUD notification)
5. ✅ **BONUS**: Bedrock Barrier (prevents descending below core chamber)

### Medium Priority (Remaining Polish)
6. ⬜ Phase 2: Core Chamber Visuals (ambient glow, particle effects)
7. ⬜ Phase 7: Prestige Flow Polish (calculation preview, confirmation)

### Low Priority (Optional)
8. ⬜ Phase 5: Hard Force-Return (optional alternative to soft force)
9. ⬜ Phase 8: Extended Testing (comprehensive test cases)

---

## Implementation Notes

### Mars Core Depth Calculation
```
Current Implementation: 2500m core depth, 2560m total depth
Meters per block: 12.5m
Block Y = 2500 / 12.5 = 200 blocks
Chamber: Blocks 200-205 (2500m-2560m range)
Center: Block 202.5 (~2531m)
Width: 9 blocks (terrain width)
Chamber size: 10 blocks wide × 5 blocks tall (centered horizontally)
```

### Dark Matter Specs
- **Value**: 10,000 Bocks (from mars.json)
- **Volume**: 0.1 units (barely takes cargo space)
- **Rarity**: Guaranteed one per core
- **Spawn**: Center of core chamber only

### Core Chamber Dimensions
- **Horizontal**: 10 blocks wide (5 blocks on each side of center)
- **Vertical**: Variable (from coreDepth to totalDepth per planet)
- **Mars**:
  - Width: Blocks X=0-9 (width=9, center=4)
  - Depth: Blocks Y=200-205 (2500m-2560m)
  - Chamber: X=0-9, Y=200-205 (full width, bottom 60m)

---

## Success Criteria

Core system is complete when:
- ✅ Core spawns at configured depth (2500m for Mars, per planet config)
- ✅ Dark Matter has unique pulsing visual (5x size, orange-red glow, 2s pulse cycle)
- ✅ Collecting Dark Matter triggers special effects (screen flash, camera shake, particles, HUD notification)
- ✅ Teleporter disables after collection (prints error message)
- ✅ Bedrock barrier prevents descending below core chamber
- ✅ Prestige dialog shows on surface return (already working)
- ⬜ Core chamber has ambient visuals (optional polish - Phase 2)
- ⬜ All test cases pass (Phase 8)

### High Priority Features: **COMPLETE** ✅
All critical core system features have been implemented and build successfully!
