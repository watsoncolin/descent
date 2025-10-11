# DESCENT - Missing Features Checklist

**Last Updated**: 2025-10-11
**Current Phase**: Phase 1 → Phase 3 transition
**Implementation Status**: ~70% Phase 1, prestige system just added

This document tracks all features from the design documents that are not yet implemented or implemented differently than designed.

---

## ✅ Currently Implemented

### Core Systems (Complete)
1. **Basic Movement** - Touch controls, thrust, gravity
2. **Drilling System** - Variable speed based on strata hardness
3. **Fuel System** - Consumption during thrust and drilling (1.5 fuel/sec base)
4. **Hull System** - Impact damage with dampeners (impulse-based)
5. **Terrain Generation** - Vein-based procedural generation with deterministic seeding
6. **Material System** - 15 materials with values and Soul Crystal bonuses
7. **Cargo System** - Volume-based with auto-drop optimization (fully matches CARGO_SYSTEM.md)
8. **Upgrade System** - ALL 6 Common Upgrades:
   - Fuel Tank (6 levels, max 500 fuel)
   - Drill Strength (5 levels)
   - Cargo Capacity (6 levels, max 250 units)
   - Hull Armor (5 levels, max 200 HP)
   - Engine Speed (5 levels, max 200%) ✅ IMPLEMENTED
   - Impact Dampeners (3 levels)
9. **Consumable System** - All 5 types fully functional:
   - Repair Kits (restore 50 HP)
   - Fuel Cells (restore 100 fuel)
   - Mining Bombs (clear 3×3 area) ✅ IMPLEMENTED
   - Emergency Teleporter (instant return to surface) ✅ IMPLEMENTED
   - Shield Generator (10s invincibility) ✅ IMPLEMENTED
10. **Consumable UI** - 5 buttons at bottom with counts ✅ IMPLEMENTED
11. **Supply Drop System** - Complete with capacity system (5-20 items) ✅ NEWLY IMPLEMENTED
12. **Supply Drop UI** - Menu with quantity selectors, capacity bar, per-item limits ✅ NEWLY IMPLEMENTED
13. **Surface Shop** - Buy upgrades and consumables with tabs
14. **HUD** - Fuel, hull, depth, cargo (with value), credits display
15. **Game Over System** - Fuel depletion and hull destruction handlers
16. **Save System** - Profile persistence with SaveManager
17. **Mars Planet** - Full level design with 8 strata layers, vein generation
18. **Sell Dialog** - Post-run cargo sale screen
19. **Reset Progress** - Testing button to reset all upgrades/credits
20. **Prestige System** - Core extraction, Soul Crystals, planet reset ✅ NEWLY IMPLEMENTED
21. **PrestigeDialog** - UI showing what's lost/kept/gained ✅ NEWLY IMPLEMENTED
22. **Core Chamber** - Spawns at 490m with Dark Matter crystal ✅ NEWLY IMPLEMENTED
23. **Soul Crystal Earnings Bonus** - Applies to all material values ✅ NEWLY IMPLEMENTED
24. **Pod Showcase** - 3D visualization of pod with button access ✅ IMPLEMENTED
25. **Launch Screen** - Custom design with PNG assets ✅ NEWLY IMPLEMENTED

---

## 🚧 Phase 1 - Core Proof (Critical Missing Features)

**Goal**: "Is mining fun?" - Need polish and feedback systems

### HIGH PRIORITY - Breaks Core Experience

#### 1. Fuel Warning System ❌ MISSING
**Status**: No warnings implemented at all
**Design**: FUEL_SYSTEM.md specifies 3 warning stages
**Impact**: Players run out of fuel with no warning (frustrating!)

**Needs:**
- [ ] **Low Fuel Warning (25% remaining)**
  - [ ] Fuel bar turns yellow
  - [ ] HUD message: "LOW FUEL"
  - [ ] Soft beep every 5 seconds
- [ ] **Critical Fuel Warning (10% remaining)**
  - [ ] Fuel bar turns red and flashes
  - [ ] HUD message: "CRITICAL FUEL - RETURN NOW"
  - [ ] Screen edges pulse yellow
  - [ ] Continuous warning alarm
- [ ] **Emergency Fuel Warning (5% remaining)**
  - [ ] Fuel bar flashing red rapidly
  - [ ] Large center screen warning
  - [ ] Urgent alarm sound

#### 2. Emergency Return System ❌ COMPLETELY MISSING
**Status**: Not implemented - fuel depletion = instant game over
**Design**: FUEL_SYSTEM.md requires auto-ascent with 50% cargo penalty
**Impact**: Breaks core risk/reward balance - too punishing

**Needs:**
- [ ] Trigger when fuel reaches 0
- [ ] Auto-ascent at 5 m/sec (slow upward float)
- [ ] "Emergency Return in Progress" UI overlay
- [ ] Countdown timer showing ETA to surface
- [ ] Apply 50% cargo penalty (drop half minerals)
- [ ] Show cargo loss indicator
- [ ] Can still take hull damage during ascent
- [ ] Disable player control during return

**CRITICAL**: This changes fail state from "lose everything" to "lose 50% cargo but survive"

#### 3. Hull Warning System ❌ PARTIALLY MISSING
**Status**: No visual warnings, no color changes
**Design**: Need progressive warnings at 75%, 50%, 25%
**Impact**: Players die unexpectedly

**Needs:**
- [ ] Hull warning stages (75%, 50%, 25%)
- [ ] Screen flash red when damaged ⚠️ PARTIALLY IMPLEMENTED (basic)
- [ ] Hull bar color changes (green → yellow → red)
- [ ] Warning sounds for damage
- [ ] Visual damage effects on pod sprite

### MEDIUM PRIORITY - Polish & Feel

#### 4. Visual & Audio Polish ❌ COMPLETELY MISSING
**Status**: No particles, no screen shake, no haptics, no sound
**Impact**: Game feels flat and unresponsive

**Visual Effects Needed:**
- [ ] Particle effects
  - [ ] Thrust particles (behind pod)
  - [ ] Drilling particles (blocks breaking)
  - [ ] Material collection sparkles
  - [ ] Explosion effects (hull destroyed)
  - [ ] Supply drop rocket trail ✅ (system exists, needs particles)
- [ ] Screen shake
  - [ ] Impact collisions
  - [ ] Cave-ins
  - [ ] Explosions
  - [ ] Supply drop landing

**Haptic Feedback Needed:**
- [ ] Light haptic for soft terrain
- [ ] Medium haptic for normal blocks
- [ ] Strong haptic for valuable materials
- [ ] Impact haptic for damage
- [ ] Consumable activation haptic

**Audio Needed:**
- [ ] Drilling sounds (vary by hardness)
- [ ] Material collection sounds
- [ ] Warning beeps/alarms
- [ ] Explosion sound
- [ ] Thrust/engine sound
- [ ] Supply drop sounds (countdown, rocket, impact)

#### 5. Material Collection Feedback ❌ MISSING
**Status**: No feedback when collecting materials
**Design**: Different feedback based on material rarity
**Impact**: Collecting rare materials feels unrewarding

**Needs:**
- [ ] Small popup showing material name + value
- [ ] Rare gem: Screen flash + dramatic sound
- [ ] Exotic material: Full-screen flash + lore snippet
- [ ] First discovery bonus notification

#### 6. Run Summary Screen ❌ MISSING
**Status**: Just shows sell dialog with list
**Design**: Need comprehensive post-run statistics
**Impact**: Players don't see their accomplishments

**Needs:**
- [ ] Show after returning to surface
- [ ] Display depth reached
- [ ] Display total cargo value
- [ ] Display best finds (most valuable materials)
- [ ] Display new records (personal bests)
- [ ] "Continue" button to surface shop

### LOW PRIORITY - Can Ship Without

#### 7. Hazards ❌ COMPLETELY MISSING
**Status**: No hazards implemented at all
**Design**: Gas pockets and cave-ins planned for Phase 1
**Impact**: Gameplay lacks variety and danger

**Needs:**
- [ ] **Gas Pockets**
  - [ ] Spawn in terrain (5% chance in layers 1-3)
  - [ ] Visual: Slightly discolored blocks with shimmer
  - [ ] Damage: 5-15 HP when drilled (based on size)
  - [ ] Particle explosion effect
- [ ] **Cave-ins**
  - [ ] Trigger probability (8-15% based on layer)
  - [ ] Visual warning: Cracks appear above
  - [ ] Falling rock physics (2-4 rocks)
  - [ ] Damage: 10 HP per rock
  - [ ] Screen shake effect

#### 8. Tutorial System ❌ MISSING
**Status**: No tutorial at all
**Impact**: New players confused

**Needs:**
- [ ] First run tutorial (movement controls)
- [ ] Fuel management tutorial
- [ ] Hull damage tutorial
- [ ] Cargo system tutorial
- [ ] Upgrade system tutorial
- [ ] "Skip Tutorial" option

#### 9. Statistics Tracking Display ❌ PARTIALLY MISSING
**Status**: Data tracked but not displayed
**Impact**: Players can't see their progress

**Needs:**
- [ ] Best depth reached (per planet)
- [ ] Best haul value (per run)
- [ ] Total minerals collected
- [ ] Total runs completed
- [ ] Death count by cause
- [ ] Display on surface UI or stats screen

---

## 🔄 Phase 2 - Upgrade Loop (Future)

**Goal**: "Is progression satisfying?"

### Not Yet Implemented

- [ ] **Expanded Material Set**
  - Currently: 15 materials implemented
  - Missing: Full Tier 4-5 exotic materials for other planets

- [ ] **More Hazards**
  - [ ] Lava zones (decorative on Mars)
  - [ ] Unstable rock zones
  - [ ] Visual hazard indicators

- [ ] **UI Improvements**
  - [ ] Smart upgrade recommendations (based on death cause)
  - [ ] Better visual feedback for purchases
  - [ ] Animated transitions
  - [ ] Better HUD layout

---

## 🌟 Phase 3 - Prestige Hook (JUST COMPLETED!)

**Goal**: "Does prestige feel rewarding?"

### ✅ IMPLEMENTED (Oct 11, 2025)

- [x] **Soul Crystal System**
  - [x] Soul Crystals currency (stored in GameProfile)
  - [x] Formula: `√(Total Career Earnings / 1000)`
  - [x] +10% mineral value bonus per crystal (12% with amplifier)
  - [x] Soul crystals tracked and saved

- [x] **Core Extraction Mechanic**
  - [x] Core chamber at max depth (490m for Mars)
  - [x] Dark Matter guaranteed drop at core center
  - [x] Core extraction flag set when collected
  - [x] Trigger prestige option on surface return

- [x] **Prestige Screen**
  - [x] Shows before/after comparison
  - [x] Soul Crystals gained calculation
  - [x] Permanent bonus preview
  - [x] "Prestige" vs "Continue Without Prestige" buttons
  - [ ] Epic celebration animation (basic, could be enhanced)
  - [ ] Particle effects and count-up (not implemented)

- [x] **Reset Logic**
  - [x] Clear all Credits
  - [x] Reset all Common Upgrades to Level 1
  - [x] Keep Soul Crystals
  - [x] Keep Epic Upgrades
  - [x] Keep consumable counts (design changed - consumables reset)
  - [x] Apply soul crystal bonuses
  - [x] Regenerate planet terrain

### Still Missing

- [ ] Display soul crystal count on HUD (currently only in surface UI)
- [ ] Enhanced prestige celebration animation
- [ ] Particle effects during prestige
- [ ] Count-up animations for soul crystals

---

## 🎨 Phase 4 - Polish (Not Started)

**Goal**: "Does it feel good?"

### All Missing

- [ ] **Enhanced Visual Effects**
  - [ ] Better particle systems
  - [ ] Dynamic lighting (pod headlight)
  - [ ] Material glows for exotic resources
  - [ ] Smoother animations
  - [ ] Polish UI transitions

- [ ] **Complete Audio**
  - [ ] Background music (menu, surface, mining)
  - [ ] Complete sound effect library
  - [ ] Volume controls in settings
  - [ ] Audio mixing

- [ ] **Settings Menu**
  - [ ] Volume controls (music, SFX, haptics)
  - [ ] Graphics quality options
  - [ ] Control sensitivity
  - [ ] Colorblind modes
  - [ ] Reset save data

- [ ] **Main Menu**
  - [ ] Title screen
  - [ ] Continue/New Game
  - [ ] Settings access
  - [ ] Material compendium access
  - [ ] Credits

---

## 🪐 Phase 5 - Second Planet (Not Started)

**Goal**: "Does variety work?"

### All Missing

- [ ] **Luna Planet**
  - [ ] luna.json level config
  - [ ] 2× value multiplier
  - [ ] Low gravity modifier (0.7× fuel consumption)
  - [ ] Unique visual identity (gray, moon dust)
  - [ ] Titanium deposits
  - [ ] Vacuum pockets hazard

- [ ] **Planet Selection Screen**
  - [ ] Globe view UI
  - [ ] Planet cards showing stats/requirements
  - [ ] Select/Launch buttons
  - [ ] Planet unlock logic

- [ ] **Golden Gems System**
  - [ ] Golden Gems currency
  - [ ] Display on HUD/surface UI
  - [ ] Earn from milestones/achievements
  - [ ] IAP integration (future)

- [ ] **Epic Upgrades**
  - [ ] Epic upgrades shop UI
  - [ ] Auto-Refuel
  - [ ] Advanced Scanner
  - [ ] Heat Resistance Level 1
  - [ ] Mineral Value Boost (formula exists, UI missing)
  - [ ] Soul Crystal Amplifier (formula exists, UI missing)
  - [ ] Purchase confirmation dialogs

---

## ⚠️ Implementation Differences from Design

### Things Implemented Differently

1. **Supply Drop System** ✅ CORRECT
   - **Design**: Capacity system with 5-20 items per drop, per-item limits
   - **Implementation**: Fully matches SUPPLY_DROP_SYSTEM.md
   - **Status**: ✅ Correct as implemented

2. **Prestige System** ✅ CORRECT
   - **Design**: Core extraction → prestige option → reset
   - **Implementation**: Matches design, just completed
   - **Status**: ✅ Correct as implemented

3. **Return to Surface Mechanic** ⚠️ INCONSISTENT
   - **Design (CLAUDE.md)**: "NO automatic 'return to surface' button. Players must use Emergency Teleporter (consumable item) to return"
   - **Design (FUEL_SYSTEM.md)**: Emergency return at 0 fuel with cargo penalty
   - **Implementation**: Has teleporter button AND surface UI "return" option
   - **Issue**: Conflicts with stated design philosophy
   - **Recommendation**: Need to clarify - should there be an easy "return" or only teleporter consumable?

4. **Engine Speed Upgrade** ✅ IMPLEMENTED
   - **Design**: Listed in MISSING_FEATURES.md as missing
   - **Implementation**: Fully implemented in game
   - **Status**: ✅ Was incorrectly listed as missing

5. **Consumables** ✅ IMPLEMENTED
   - **Design**: All 5 consumable types
   - **Implementation**: All 5 fully functional with UI buttons
   - **Status**: ✅ Was incorrectly listed as high priority missing

---

## 📊 Implementation Status by Phase

**Phase 1 Progress**: ~70% complete
- ✅ Core movement and drilling
- ✅ Fuel and hull systems (missing warnings/emergency return)
- ✅ ALL upgrades including Engine Speed
- ✅ ALL consumables with UI
- ✅ Supply drop system complete
- ❌ Warning systems (critical gap)
- ❌ Emergency return (critical gap)
- ❌ Hazards
- ❌ Polish (particles, sound, haptics)

**Phase 2 Progress**: 0% complete
- Not started

**Phase 3 Progress**: 90% complete ✅
- ✅ Soul Crystal system
- ✅ Core extraction
- ✅ Prestige mechanic
- ✅ Reset logic
- ❌ Enhanced animations/celebration

**Phase 4 Progress**: 0% complete
- Not started

**Phase 5 Progress**: 0% complete
- Not started

---

## 🎯 Next Priority Actions

### Critical for Playable MVP (Do First)

1. **Fuel Warning System** - Players need to know when fuel is low
2. **Emergency Return System** - Changes fail state from total loss to 50% penalty
3. **Hull Visual Warnings** - Players need damage feedback
4. **Basic Visual/Audio Polish** - Particles for drilling, sounds for warnings

### Important for Feel (Do Second)

5. **Material Collection Feedback** - Make collecting valuable
6. **Run Summary Screen** - Show accomplishments
7. **Basic Hazards** - Add variety to gameplay

### Polish for Launch (Do Later)

8. **Tutorial System** - Help new players
9. **Statistics Display** - Show progress
10. **Enhanced Prestige Animation** - Celebrate achievements

---

## 🗓️ Development Timeline

- **Phase 1** (Core Proof): 70% complete
  - ✅ Core systems done
  - ❌ Warnings/feedback needed (2-3 days)
  - ❌ Polish pass needed (3-5 days)

- **Phase 2** (Upgrade Loop): Not started (1-2 weeks)

- **Phase 3** (Prestige): 90% complete ✅
  - Just completed main implementation
  - Minor polish needed

- **Phase 4** (Polish): Not started (1 week)

- **Phase 5** (Second Planet): Not started (1-2 weeks)

---

## 📝 Notes

**Current State**:
- Strong foundation with all core systems working
- Prestige system just completed successfully
- Supply drop system fully functional
- **Critical Gap**: Missing warning/feedback systems that make failure feel fair
- **Critical Gap**: Missing emergency return system (breaks design intent)
- Need polish pass for feel (particles, sound, haptics)

**Biggest Risks**:
1. No fuel warnings = players frustrated by sudden failure
2. No emergency return = 100% cargo loss too punishing vs design (50% penalty)
3. No audio/haptics = game feels flat
4. No hazards = gameplay repetitive

**Positive Progress**:
- Supply drop system adds strategic depth ✅
- Prestige system creates long-term hook ✅
- All consumables working creates interesting decisions ✅
- Cargo auto-drop working smoothly ✅

**Recommendation**: Focus on warning systems and emergency return before adding more features. These are breaking core game feel right now.
