# DESCENT - Missing Features Checklist

**Last Updated**: 2025-10-04
**Current Phase**: Phase 1 (Core Proof)

This document tracks all features from the design documents that are not yet implemented.

---

## ✅ Currently Implemented

1. **Basic Movement** - Touch controls, thrust, gravity
2. **Drilling System** - Variable speed based on strata hardness
3. **Fuel System** - Consumption during thrust and drilling (1.5 fuel/sec base)
4. **Hull System** - Impact damage with dampeners (impulse-based)
5. **Terrain Generation** - Vein-based procedural generation with deterministic seeding
6. **Material System** - 15 materials with values
7. **Cargo System** - Volume-based with auto-drop optimization
8. **Upgrade System** - 6 Common Upgrades (Fuel Tank, Drill Strength, Cargo, Hull, Impact Dampeners - Engine Speed missing)
9. **Surface Shop** - Buy upgrades and consumables
10. **HUD** - Fuel, hull, depth, cargo (with value), credits display
11. **Game Over** - Fuel depletion and hull destruction handlers
12. **Save System** - Profile persistence with SaveManager
13. **Mars Planet** - Full level design with 8 strata layers, vein generation
14. **Sell Dialog** - Post-run cargo sale screen
15. **Reset Progress** - Testing button to reset all upgrades/credits

---

## 🚧 Phase 1 - Core Proof (Week 1-2)

**Goal**: "Is mining fun?"

### High Priority (Needed for MVP)

- [ ] **Consumable Items Activation**
  - [ ] UI buttons for consumables (bottom of screen, 5 buttons)
  - [ ] Fuel Cell usage (restore 100 fuel instantly)
  - [ ] Repair Kit usage (restore 50 HP instantly)
  - [ ] Emergency Teleporter usage (instant return to surface)
  - [ ] Shield usage (5 seconds invincibility)
  - [ ] Mining Bomb usage (clear 3×3 area)
  - [ ] Item count display on buttons
  - [ ] Visual feedback when used
  - [ ] Disable button when count = 0

- [ ] **Engine Speed Upgrade**
  - [ ] Add to CommonUpgrades struct (5 levels)
  - [ ] Add to SurfaceUI shop
  - [ ] Implement movement speed multiplier in PlayerPod
  - [ ] Cost: $110 base, 1.5× scaling
  - [ ] Levels: 100% / 120% / 140% / 160% / 180% / 200%

- [ ] **Fuel Warning System**
  - [ ] Low fuel warning (25% remaining)
    - [ ] Fuel bar turns yellow
    - [ ] HUD message: "LOW FUEL"
    - [ ] Soft beep every 5 seconds
  - [ ] Critical fuel warning (10% remaining)
    - [ ] Fuel bar turns red and flashes
    - [ ] HUD message: "CRITICAL FUEL - RETURN NOW"
    - [ ] Screen edges pulse yellow
    - [ ] Continuous warning alarm
  - [ ] Emergency fuel warning (5% remaining)
    - [ ] Fuel bar flashing red rapidly
    - [ ] Large center screen warning
    - [ ] Urgent alarm sound

- [ ] **Hull Warning System**
  - [ ] Hull warning stages (75%, 50%, 25%)
  - [ ] Screen flash red when damaged
  - [ ] Hull bar color changes (green → yellow → red)
  - [ ] Warning sounds for damage
  - [ ] Visual damage effects on pod sprite

- [ ] **Emergency Return System (Fuel Depletion)**
  - [ ] Trigger when fuel reaches 0
  - [ ] Auto-ascent at 5 m/sec (slow upward float)
  - [ ] "Emergency Return in Progress" UI overlay
  - [ ] Countdown timer showing ETA to surface
  - [ ] Apply 50% cargo penalty (drop half minerals)
  - [ ] Show cargo loss indicator
  - [ ] Can still take hull damage during ascent
  - [ ] Disable player control during return

### Medium Priority

- [ ] **Basic Hazards**
  - [ ] Gas Pockets
    - [ ] Spawn in terrain (5% chance in layers 1-3)
    - [ ] Visual: Slightly discolored blocks with shimmer
    - [ ] Damage: 5-15 HP when drilled (based on size)
    - [ ] Particle explosion effect
  - [ ] Cave-ins
    - [ ] Trigger probability (8-15% based on layer)
    - [ ] Visual warning: Cracks appear above
    - [ ] Falling rock physics (2-4 rocks)
    - [ ] Damage: 10 HP per rock
    - [ ] Screen shake effect

- [ ] **Visual & Audio Polish**
  - [ ] Particle effects
    - [ ] Thrust particles (behind pod)
    - [ ] Drilling particles (blocks breaking)
    - [ ] Material collection sparkles
    - [ ] Explosion effects (hull destroyed)
  - [ ] Screen shake
    - [ ] Impact collisions
    - [ ] Cave-ins
    - [ ] Explosions
  - [ ] Haptic feedback
    - [ ] Light haptic for soft terrain
    - [ ] Medium haptic for normal blocks
    - [ ] Strong haptic for valuable materials
    - [ ] Impact haptic for damage
  - [ ] Sound effects
    - [ ] Drilling sounds (vary by hardness)
    - [ ] Material collection sounds
    - [ ] Warning beeps/alarms
    - [ ] Explosion sound
    - [ ] Thrust/engine sound

- [ ] **Run Summary Screen**
  - [ ] Show after returning to surface
  - [ ] Display depth reached
  - [ ] Display total cargo value
  - [ ] Display best finds (most valuable materials)
  - [ ] Display new records (personal bests)
  - [ ] "Continue" button to surface shop

- [ ] **Material Collection Feedback**
  - [ ] Small popup showing material name + value
  - [ ] Rare gem: Screen flash + dramatic sound
  - [ ] Exotic material: Full-screen flash + lore snippet
  - [ ] First discovery bonus notification

### Low Priority (Polish)

- [ ] **Tutorial System**
  - [ ] First run tutorial (movement controls)
  - [ ] Fuel management tutorial
  - [ ] Hull damage tutorial
  - [ ] Cargo system tutorial
  - [ ] Upgrade system tutorial
  - [ ] "Skip Tutorial" option

- [ ] **Statistics Tracking**
  - [ ] Best depth reached (per planet)
  - [ ] Best haul value (per run)
  - [ ] Total minerals collected
  - [ ] Total runs completed
  - [ ] Death count by cause
  - [ ] Display on surface UI

---

## 🔄 Phase 2 - Upgrade Loop (Week 3-4)

**Goal**: "Is progression satisfying?"

### Features Needed

- [ ] **Expanded Material Set**
  - [ ] Add 5 more materials (Platinum, Ruby, Emerald, Diamond, Titanium)
  - [ ] Update mars.json with proper distributions
  - [ ] Add to Material.swift enum
  - [ ] Add color definitions

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

## 🌟 Phase 3 - Prestige Hook (Week 5)

**Goal**: "Does prestige feel rewarding?"

### Features Needed

- [ ] **Soul Crystal System**
  - [ ] Soul Crystals currency (stored in GameProfile)
  - [ ] Formula: `√(Total Career Earnings / 1000)`
  - [ ] +10% mineral value bonus per crystal
  - [ ] Display soul crystal count on HUD

- [ ] **Core Extraction Mechanic**
  - [ ] Core chamber at max depth (490m for Mars)
  - [ ] Visual: Glowing core object
  - [ ] Extraction animation
  - [ ] Dark Matter guaranteed drop
  - [ ] Trigger prestige option

- [ ] **Prestige Screen**
  - [ ] Show before/after comparison
  - [ ] Soul Crystals gained calculation
  - [ ] Permanent bonus preview
  - [ ] "Prestige" vs "Not Yet" buttons
  - [ ] Epic celebration animation
  - [ ] Particle effects and count-up

- [ ] **Reset Logic**
  - [ ] Clear all Credits
  - [ ] Reset all Common Upgrades to Level 1
  - [ ] Keep Soul Crystals
  - [ ] Keep Epic Upgrades
  - [ ] Keep consumable counts
  - [ ] Apply soul crystal bonuses
  - [ ] Regenerate planet terrain

---

## 🎨 Phase 4 - Polish (Week 6)

**Goal**: "Does it feel good?"

### Features Needed

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

## 🪐 Phase 5 - Second Planet (Week 7-8)

**Goal**: "Does variety work?"

### Features Needed

- [ ] **Luna Planet**
  - [ ] luna.json level config
  - [ ] 2× value multiplier
  - [ ] Low gravity modifier (0.7× fuel consumption)
  - [ ] Unique visual identity (gray, moon dust)
  - [ ] Titanium deposits
  - [ ] Vacuum pockets hazard

- [ ] **Planet Selection Screen**
  - [ ] Globe view UI
  - [ ] Planet cards showing:
    - [ ] Name and multiplier
    - [ ] Unlock requirements
    - [ ] Best depth/haul stats
    - [ ] Hazard warnings
  - [ ] Select/Launch buttons
  - [ ] Planet unlock logic

- [ ] **Golden Gems System**
  - [ ] Golden Gems currency
  - [ ] Display on HUD/surface UI
  - [ ] Earn from milestones/achievements
  - [ ] IAP integration (future)

- [ ] **First Epic Upgrades**
  - [ ] Auto-Refuel (no manual refuel needed)
  - [ ] Advanced Scanner (show gas pockets)
  - [ ] Heat Resistance Level 1 (50% heat damage reduction)
  - [ ] Epic upgrades shop UI
  - [ ] Purchase confirmation dialogs

---

## 🚀 Future Features (Post-MVP)

### Additional Planets

- [ ] Io (5× multiplier, volcanic hazards)
- [ ] Europa (8× multiplier, ice/water hazards)
- [ ] Titan (15× multiplier, methane lakes)
- [ ] Venus (25× multiplier, extreme heat)
- [ ] Mercury (50× multiplier, radiation/meteors)
- [ ] Enceladus (100× multiplier, alien guardians)

### Advanced Materials (Tier 4-5)

- [ ] Pyronium (Io exclusive, fire trails)
- [ ] Cryonite (Europa exclusive, ice crystals)
- [ ] Voltium (electric arcs)
- [ ] Gravitite (gravity distortion)
- [ ] Neutronium (ultra-dense)
- [ ] Xenite (alien crystal)
- [ ] Chronite (time effects)
- [ ] Quantum Foam (reality distortion)
- [ ] Dark Matter (core reward)
- [ ] Stellarium (ultimate endgame)

### Epic Upgrades (Complete Set)

- [ ] Auto-Repair (hull repairs slowly over time)
- [ ] Soul Crystal Amplifier (+25% soul crystals gained)
- [ ] Mineral Value Boost (+15% all mineral values)
- [ ] Cargo Insurance (fuel-out loss 50% → 25%)
- [ ] Heat Resistance Level 2 (75% reduction)
- [ ] Heat Resistance Level 3 (immune)
- [ ] Cold Resistance Level 1/2/3
- [ ] Ejection Pod (survive hull destruction with 25% cargo)
- [ ] Discount upgrades (10% off all Common Upgrades)

### Environmental Hazards (Complete)

- [ ] High pressure zones (1.1× fuel consumption)
- [ ] Corrosive gas zones (2.0× fuel consumption, visual clouds)
- [ ] Lava rivers (20-30 HP/sec continuous)
- [ ] Volcanic vents (25 HP burst)
- [ ] Ice spikes (20 HP collision)
- [ ] Freezing water (15 HP/sec)
- [ ] Sulfur gas clouds (10 HP/sec)
- [ ] Sulfuric acid rain (10 HP/sec)
- [ ] Solar radiation (20 HP/sec near surface)
- [ ] Meteor impacts (60 HP, 2 sec warning)
- [ ] Ice quakes (70 HP crushing)
- [ ] Alien guardians (80 HP melee)
- [ ] Radioactive cargo damage (1 HP/sec per crystal)

### UI/UX Enhancements

- [ ] Manual cargo management screen
- [ ] Material compendium (encyclopedia)
- [ ] Achievement system
- [ ] Leaderboards (depth, value, speed runs)
- [ ] Dynamic HUD modes (Standard/Minimal/Critical)
- [ ] Enhanced planet cards with recommendations
- [ ] Prestige celebration animation

### Accessibility

- [ ] Colorblind modes (Protanopia, Deuteranopia, Tritanopia)
- [ ] Material text labels on sprites
- [ ] Adjustable button sizes
- [ ] Haptic intensity control
- [ ] High contrast mode
- [ ] Reduced motion option

### Quality of Life

- [ ] iCloud save sync
- [ ] Multiple save slots
- [ ] Run history log
- [ ] Pause menu improvements
- [ ] Quick restart option
- [ ] Auto-save frequency settings

### Monetization (Future)

- [ ] IAP for Golden Gems
- [ ] Optional ads for gems (2× reward)
- [ ] Daily bonus system
- [ ] Challenge system (earn gems)
- [ ] Golden nuggets (find in terrain for gems)
- [ ] Drone system (earn gems over time)

---

## 📊 Implementation Status

**Phase 1 Progress**: ~60% complete
- ✅ Core movement and drilling
- ✅ Fuel and hull systems
- ✅ Basic upgrades and shop
- ❌ Consumables activation
- ❌ Warning systems
- ❌ Hazards
- ❌ Polish (particles, sound, haptics)

**Next Priority**:
1. Consumable items activation (biggest gameplay feature missing)
2. Fuel/hull warning systems (QoL)
3. Engine Speed upgrade (completes upgrade set)
4. Basic hazards (gas pockets, cave-ins)
5. Visual/audio polish (particles, screen shake, sound)

---

## 🗓️ Development Timeline

- **Week 1-2** (Phase 1): Core proof - "Is mining fun?"
- **Week 3-4** (Phase 2): Upgrade loop - "Is progression satisfying?"
- **Week 5** (Phase 3): Prestige hook - "Does prestige feel rewarding?"
- **Week 6** (Phase 4): Polish - "Does it feel good?"
- **Week 7-8** (Phase 5): Second planet - "Does variety work?"
- **Week 9-10**: Bug fixes, balance tuning, soft launch prep

---

## 📝 Notes

- Focus on **feel** before features - mining should be satisfying
- Consumables are critical for strategic gameplay
- Warning systems prevent frustration
- Visual/audio feedback makes progress tangible
- Prestige system provides long-term hook
- Each planet must feel unique and challenging

**Current Status**: Phase 1, building toward playable MVP with full core loop.
