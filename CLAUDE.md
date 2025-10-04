# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DESCENT** is an iOS mining game inspired by Motherload with Egg Inc-style progression mechanics. Built using **Swift + SpriteKit**.

### Core Concept
- Drill through planets extracting minerals
- Dual-currency system: Credits (temporary) and Soul Crystals (permanent prestige currency)
- 8 planets with 100x value scaling from Mars to Enceladus
- Prestige system resets planet-specific upgrades but grants permanent earning bonuses

## Development Status

This is a **very early-stage project**. As of the last update:
- Basic prototype with keyboard controls exists
- Design decisions finalized (controls, art style, MVP scope)
- Ready to begin iOS implementation
- No Xcode project files present yet

## Design Decisions

### Visual Art Style
**Modern Pixel Art with HD Effects:**
- 24x24 pixel art for terrain blocks
- 48x48 pixel pod with 8-direction rotation
- Pixel art base for all materials
- Modern particle effects and shaders for exotic materials (Tier 4-5)
- HD particle systems: fire trails for Pyronium, ice crystals for Cryonite, lens flares for Stellarium
- Clean vector graphics for UI/menus
- Each planet has distinct color grading filter
- Dynamic lighting system (pod headlight, material glows)

### iOS Touch Controls
**Direct Touch & Drag Control:**
- Touch and hold anywhere on screen to move pod toward finger
- Distance from pod = movement speed
- Automatic drilling when pod contacts terrain while moving
- Release to stop (gravity takes over)
- 5 consumable item buttons at bottom (Bomb, Teleporter, Repair, Fuel, Shield)
- Top HUD bar: Fuel, Hull, Cargo, Depth, Credits
- Haptic feedback: Light (soft terrain) → Strong (valuable materials)
- Visual feedback: Thrust particles, terrain cracks, screen shake, damage flash
- One-handed play optimized

**Return to Surface Mechanic:**
- NO automatic "return to surface" button
- Players must use Emergency Teleporter (consumable item) to return
- Teleporters are purchased at surface shop with credits
- Core risk/reward: balance fuel usage vs cargo collection
- Running out of fuel = game over = lose all cargo
- Strategic decision: when to teleport back vs continue mining deeper

### MVP Scope
**Phased Development (8-10 weeks to soft launch):**

**Phase 1 (Week 1-2): Core Proof**
- Mars only, 5 materials (Coal, Iron, Copper, Silver, Gold)
- Touch controls + drilling mechanics
- Fuel + cargo systems, basic sell loop
- Milestone: "Is mining fun?"

**Phase 2 (Week 3-4): Upgrade Loop**
- 6 upgrade types (3-5 levels each)
- Hull/damage system, 3 hazards
- 10 total materials (add Platinum, Ruby, Emerald, Diamond, Titanium)
- Save system
- Milestone: "Is progression satisfying?"

**Phase 3 (Week 5): Prestige Hook**
- Soul Crystal system
- Core extraction mechanic
- Prestige reset logic
- Milestone: "Does prestige feel rewarding?"

**Phase 4 (Week 6): Polish**
- Particle effects, screen shake, haptics
- UI animations, sound effects
- Milestone: "Does it feel good?"

**Phase 5 (Week 7-8): Second Planet**
- Planet selection screen (globe view)
- Luna implementation (2x multiplier)
- Golden Gems basics, 2-3 Epic upgrades
- Milestone: "Does variety work?"

**Soft Launch MVP:**
- 3 planets (Mars, Luna, Io)
- 15 materials (Tier 1-2 + Pyronium teaser)
- Full Common Upgrades (6 types, 5 levels)
- 5 Epic Upgrades (Auto-Refuel, Scanner, Heat Resistance 1, Mineral Boost, Soul Amplifier)
- Tutorial system (first 3 runs)
- 15-20 hours of gameplay

## Game Architecture

### Planet System
- 8 planets with progressive difficulty: Mars (1x) → Luna (2x) → Io (5x) → Europa (8x) → Titan (15x) → Venus (25x) → Mercury (50x) → Enceladus (100x)
- Each planet has unique hazards, visual identity, and core depths (500m-1200m)
- Planets require resistance upgrades to unlock (Heat/Cold Resistance Levels 1-3)

### Resource Economy
Three tiers of materials:
1. **Tier 1-3**: Real elements (Carbon, Iron, Gold, Platinum, Diamonds, etc.)
2. **Tier 4**: Exotic fictional materials (Pyronium, Cryonite, Voltium, Gravitite, Neutronium)
3. **Tier 5**: Alien/endgame materials (Xenite, Chronite, Quantum Foam, Dark Matter, Stellarium)

Resource values scale with planet multiplier (e.g., Iron on Mars = $25, Iron on Venus = $625).

### Currency Systems
1. **Credits** (cash): Earned by selling minerals, resets on prestige, used for Common Upgrades
2. **Soul Crystals**: Earned on prestige based on career earnings, provide +10% mineral value bonus each, never reset
3. **Golden Gems**: Premium currency for Epic Upgrades (permanent unlocks)

### Upgrade Systems
**Common Upgrades** (reset on prestige):
- Fuel Tank (6 levels, max 500 fuel)
- Drill Strength (5 levels, gates terrain access)
- Cargo Capacity (6 levels, max 250 units)
- Hull Armor (5 levels, max 200 HP)
- Engine Speed (5 levels, max 200%)
- Impact Dampeners (3 levels)
- Consumables (Repair Kit, Fuel Cell, Mining Bomb, Emergency Teleporter, Shield Generator)

**Epic Upgrades** (permanent, bought with Golden Gems):
- Soul Crystal Amplifier, Mineral Value Boost
- Auto-Refuel, Auto-Repair, Advanced Scanner
- Heat/Cold Resistance gates for planet unlocking
- Discount upgrades for common purchases

### Core Mechanics
- **Movement**: Left/Right, Down (drilling), Up (thrusting), all consume fuel
- **Fuel Management**: Running out = game over, must balance depth vs return trip
- **Cargo System**: Volume-based (not weight), creates strategic "drop or keep" decisions
- **Prestige**: Extract planet core → lose Credits/upgrades → gain Soul Crystals → unlock next planets
- **Progression Formula**: `Soul Crystals = √(Total Career Earnings / 1000)`

## Technical Implementation (iOS/Swift)

### Engine Choice
- **SpriteKit**: 2D engine built into iOS, suitable for physics-based mining gameplay
- Use SpriteKit physics for gravity, collisions, and movement
- Procedural terrain generation algorithms needed for mineral placement

### Key Systems to Build
1. **Touch Controls**: Convert keyboard prototype to iOS touch/swipe controls
2. **Terrain Generation**: Chunk-based loading, depth-based mineral spawning
3. **Save System**: UserDefaults for simple data, FileManager for complex progression
4. **Planet-Specific Hazards**: Each planet needs unique environmental challenges
5. **UI Screens**:
   - Mining view (HUD with fuel, hull, cargo, depth)
   - Surface/upgrade shop
   - Planet selection (globe view)
   - Material compendium

### Performance Considerations
- Optimize for older iOS devices
- Chunk-based terrain loading to manage memory
- Efficient particle effects for exotic materials

## Resource Distribution by Depth
- **0-50m**: Coal, Iron, Copper
- **50-150m**: Silver, Gold appears
- **150-300m**: Gold common, Platinum, occasional gems
- **300-500m**: Gems common, Titanium
- **500m+**: Heavy gem concentration, exotic materials
- **Core zone**: Alien artifacts, Dark Matter

## Planet-Specific Features

Key differentiators for each planet:
- **Mars**: Tutorial, dust storms, unstable rock
- **Luna**: Low gravity, vacuum pockets, titanium deposits
- **Io**: Lava rivers, volcanic vents, sulfur gas, crumbling terrain
- **Europa**: Ice spikes, subglacial ocean, pressure cracks, alien life
- **Titan**: Methane lakes, nitrogen geysers, slippery physics, thick atmosphere
- **Venus**: Sulfuric acid rain, extreme heat, volcanic eruptions, corrosive gas
- **Mercury**: Solar radiation, magnetic storms, meteor impacts, day/night cycle
- **Enceladus**: Cryogenic jets, deep ocean layer, ice quakes, alien guardians

## Monetization Strategy
- Optional ads for Golden Gems
- IAP for gem packs
- No pay-to-win mechanics
- Golden Gems also earnable through gameplay (drones, golden nuggets, daily bonuses, challenges)

## UI/UX Design

### Key Screens
1. **Main Menu**: Title, Start/Continue, Settings, Compendium
2. **Planet Selection**: Rotatable globe, planet cards with stats/requirements/best runs
3. **Mining View**: Full-screen gameplay with top HUD (fuel, hull, cargo, depth) + bottom item buttons
4. **Surface/Shop**: Cargo summary, Credits balance, upgrade shop (Common/Epic tabs), Launch button
5. **Prestige Screen**: Core extraction celebration, Soul Crystal gain calculation, before/after comparison
6. **Pause Menu**: Resume, Return to Surface, Abandon Run, Settings

### UI Enhancements
- **Run Summary Screen**: Shows depth, cargo value, best finds, new records after each run
- **Material Collection Feedback**:
  - Common materials: Small popup + particles
  - Rare gems: Screen flash + dramatic sound
  - Exotic materials: Full-screen flash + lore snippet + first discovery bonus
- **Smart Upgrade Recommendations**: Game suggests upgrades based on how you died
- **Dynamic HUD Modes**: Standard, Minimal (auto-hide), Critical (warnings)
- **Contextual Tutorials**: Learn by doing, not reading walls of text
- **Enhanced Planet Cards**: Show your stats (deepest, best haul, prestiges), recommendations
- **Prestige Animation**: Epic sequence with particle effects, count-up animations, celebration

### Accessibility
- Colorblind modes (Protanopia, Deuteranopia, Tritanopia)
- Material labels option (text on sprites)
- Adjustable button sizes
- Haptic intensity control
- High contrast mode
- Reduced motion option

## Design Philosophy
- **Always Progressing**: Even failed runs contribute to Soul Crystals
- **Fresh Challenges**: 8 unique planets keep gameplay varied
- **"One More Run" Factor**: Clear milestones drive engagement
- **Strategic Depth**: When to prestige? Which planet? Which upgrades?
- **Skill + Persistence**: Good players progress faster, but everyone can max out eventually
