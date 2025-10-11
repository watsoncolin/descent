# Mars Level Design - Complete Strata System

## Core Depth & Vertical Structure

**Total Depth to Core**: 500 meters  
**Tile Size**: 24 pixels (≈1 meter per tile)  
**Total Tiles Deep**: 500 tiles  
**World Width**: 16 tiles (384 pixels)

### Terrain Block Types

**Drillable Terrain:**

- Normal rock/soil (varies by layer)
- Mineral veins (drillable and collectible)
- Breakable with any drill level (speed varies by hardness)

**Unbreakable Obstacles:**

1. **Bedrock** (Completely Indestructible)

   - Dark gray/black appearance (#1a1a1a)
   - Cannot be drilled (any level)
   - Cannot be exploded (bombs don't work)
   - Forces navigation around obstacles
   - Creates maze-like sections

2. **Hard Crystal Formations** (Bomb-only)

   - Iridescent purple/blue (#8B00FF)
   - Cannot be drilled (any level)
   - CAN be destroyed with bombs ($400 each)
   - Often guards valuable minerals
   - Strategic choice: bomb through or navigate around

3. **Reinforced Rock** (High drill requirement)
   - Metallic gray with silver streaks (#4a4a4a)
   - Requires Drill Level 4+ to break
   - CAN be destroyed with bombs
   - Acts as soft progression gate
   - Only appears in deep layers (300m+)

### Obstacle Coverage by Layer

Deeper layers have progressively more obstacles, forcing strategic navigation:

| Layer | Depth | Bedrock | Hard Crystal | Reinforced Rock |
|---

## Obstacle Generation System

### Bedrock Formation Algorithm

**Step 1: Seed Placement**

```
For each layer:
  bedrockSeeds = floor(layerArea × bedrockCoverage)

  For each seed:
    - Place at random valid position
    - Skip if overlaps existing bedrock
```

**Step 2: Formation Growth**

```
For each seed:
  formationSize = random based on layer depth
  - Layer 2: 3x3 to 5x5
  - Layer 4: 8x10 to 10x12
  - Layer 8: 15x20 to 20x25

  Grow formation:
    - Start from seed position
    - Expand in organic blob shape
    - Stop at formation size limit
    - Don't cross layer boundaries
```

**Step 3: Path Validation**

```
After all bedrock placed:
  Run pathfinding from top to bottom

  If no valid path exists:
    - Remove small bedrock chunks
    - Ensure minimum 3-tile-wide passages exist
    - Guarantee at least 2 distinct paths through layer
```

### Hard Crystal Placement

```
For each layer with crystals:
  crystalCount = floor(layerArea × crystalCoverage)

  For each crystal:
    - Place near valuable mineral veins (50% chance)
    - Place near bedrock edges (30% chance)
    - Place randomly (20% chance)
    - Formation size: 3x3 to 5x5
    - Creates risk/reward: valuable minerals behind crystals
```

### Reinforced Rock Placement

```
Only in layers 6-8 (300m+):
  reinforcedCount = floor(layerArea × reinforcedCoverage)

  For each reinforced section:
    - Block passages to valuable areas
    - Create "gates" requiring Drill Level 4+
    - Formation size: 4x4 to 6x6
    - Acts as soft progression check
```

### Obstacle Interaction Rules

1. **Bedrock + Hard Crystal**: Can touch, creates complex barriers
2. **Bedrock + Reinforced Rock**: Can touch, layered defenses
3. **Hard Crystal + Minerals**: Often adjacent (intentional)
4. **Path Guarantee**: Always at least one 3-tile-wide path exists
5. **No Complete Blocks**: Never seal off entire sections permanently

---

## Bomb Mechanics

### Bomb Item

**Cost**: $400 (bought at surface)  
**Effect**: Destroys 5x5 tile area  
**Destroys**:

- All normal terrain
- Hard Crystal formations
- Reinforced Rock
- Mineral veins (careful!)

**Does NOT destroy**:

- Bedrock (indestructible)

**Explosion Pattern:**

```
Before bomb:          After bomb:
████████████████      ████████████████
████CCCC████████      ████░░░░████████
████CCCC████████  →   ████░░░░████████  C = Hard Crystal
████CCCC████████      ████░░░░████████  ░ = Destroyed (empty)
██████CCCC██████      ██████░░░░██████  █ = Remains
████████████████      ████████████████

5x5 area cleared (25 tiles)
```

### Bomb Economics

**When bombs are worth it:**

1. **Trapped valuable minerals**

   - Diamond vein behind hard crystal
   - Value: $8,000 (10 diamonds)
   - Bomb cost: $400
   - Net profit: $7,600 ✅

2. **Time/fuel savings**

   - Navigate around: 60 tiles drilling = 60 fuel + 30 seconds
   - Bomb shortcut: $400 + instant
   - If fuel scarce or time matters: Worth it ✅

3. **Emergency escape**

   - Low fuel, trapped by cave-in
   - Bomb creates direct path to surface
   - Saves cargo worth $5,000
   - Bomb = $400 insurance ✅

4. **Core access**
   - Hard crystal wall blocks core entrance
   - Must bomb through (no choice)
   - Necessary expense ✅

**When bombs aren't worth it:**

- Plenty of fuel, easy navigation exists
- Low-value area (iron/coal only)
- Early game with limited credits

### Strategic Bomb Usage

**Recommended carry by game stage:**

- **Early (Runs 1-5)**: 0 bombs (too expensive, not needed)
- **Mid (Runs 6-15)**: 1-2 bombs (insurance + shortcuts)
- **Late (Runs 16+)**: 2-3 bombs (strategic tool for efficiency)

-------|-------|---------|--------------|-----------------|
| 1 | 0-30m | 0% | 0% | 0% |
| 2 | 30-80m | 3% | 0% | 0% |
| 3 | 80-150m | 8% | 2% | 0% |
| 4 | 150-220m | 10% | 3% | 0% |
| 5 | 220-300m | 12% | 4% | 0% |
| 6 | 300-380m | 15% | 5% | 3% |
| 7 | 380-450m | 18% | 8% | 5% |
| 8 | 450-490m | 20% | 6% | 8% |
| 9 | 490-500m | 0% | Walls only | 0% |

---

## Strata Layers (9 Distinct Zones)

### Layer 1: Surface Regolith (0-30m)

**Characteristics:**

- Loose, dusty Martian soil
- Easiest to drill
- Tutorial zone

**Hardness**: 1.0 (baseline, drills instantly)  
**Color**: Light rust red (#C1440E)  
**Drill Speed Modifier**: 1.0x (full speed)

**Resources Found:**

- **Carbon (Coal)**: 10% vein seed rate
  - Value: $10, Size: 5 units
  - Vein size: 1-2 tiles (clustered)
  - Expected coverage: ~15-20% of layer
- **Iron**: 6% vein seed rate
  - Value: $25, Size: 3 units
  - Vein size: 2-3 tiles (clustered)
  - Expected coverage: ~10-15% of layer

**Special Features:**

- No hazards
- Clear visibility
- Tutorial prompts appear here
- **No obstacles** - straight vertical drilling possible (learning phase)

---

### Layer 2: Iron-Rich Sediment (30-80m)

**Characteristics:**

- Compacted soil with iron oxide
- Starting to get harder

**Hardness**: 1.3  
**Color**: Medium rust red (#A0380C)  
**Drill Speed Modifier**: 0.77x (takes 30% longer)

**Resources Found:**

- **Iron**: 12.5% vein seed rate (common)
  - Vein size: 3-5 tiles (larger veins)
  - Expected coverage: ~20-25% of layer
- **Copper**: 7.5% vein seed rate
  - Value: $30, Size: 3 units
  - Vein size: 2-3 tiles
  - Expected coverage: ~10-12% of layer
- **Silicon**: 5% vein seed rate
  - Value: $50, Size: 2 units
  - Vein size: 1-2 tiles (small deposits)
  - Expected coverage: ~5-7% of layer

**Special Features:**

- First **small gas pockets** appear (5% chance per chunk)
  - 1-2 tiles, 5 HP damage when drilled
- **First obstacles introduced**: Bedrock patches (3% coverage)
  - Small 3x3 formations
  - Teaches navigation around obstacles
  - Easy to avoid

---

### Layer 3: Basalt Shield (80-150m)

**Characteristics:**

- Volcanic rock layer
- Significantly harder
- Requires Drill Level 2 for efficient mining

**Hardness**: 2.0  
**Color**: Dark brown-red (#6B2C0A)  
**Drill Speed Modifier**: 0.5x (twice as slow)  
**Minimum Drill Level**: 1 (can drill, but slow), 2 (normal speed)

**Resources Found:**

- **Iron**: 15% spawn rate (still common)
- **Copper**: 17.5% spawn rate (more abundant here)
- **Silver**: 7.5% spawn rate
  - Value: $75, Size: 2 units
  - 2-4 tile veins
- **Aluminum**: 5% spawn rate
  - Value: $60, Size: 2 units

**Special Features:**

- **Unstable rock formations**: 10% of tiles
  - When drilled, adjacent tiles can collapse (10 HP damage)
- Gas pockets increase to 8% chance
- **Obstacles increase**:
  - Bedrock: 8% coverage (5x5 to 8x8 formations)
  - Hard Crystal: 2% coverage (introduces bomb-breakable obstacles)
  - Forces branching paths and navigation choices

---

### Layer 4: Fractured Crust (150-220m)

**Characteristics:**

- Cracked, unstable geology
- Mix of hard and soft patches
- More hazardous

**Hardness**: 2.2  
**Color**: Dark red-brown (#5A1F08)  
**Drill Speed Modifier**: 0.45x

**Resources Found:**

- **Silver**: 15% spawn rate (common here)
- **Gold**: 7.5% spawn rate (first appearance!)
  - Value: $150, Size: 2 units
  - 2-4 tile veins with golden color
- **Copper**: 12.5% spawn rate
- **Aluminum**: 5% spawn rate

**Special Features:**

- **Cave-ins**: 15% chance when drilling
  - Rocks fall from above (10 HP per rock)
- **Large gas pockets**: 12% chance
  - 3-5 tile pockets, 10 HP damage
- **Cracks**: Visual cracks appear, hinting at instability
- **Maze sections begin**:
  - Bedrock: 10% coverage (8x10 formations)
  - Hard Crystal: 3% coverage (often blocking valuable minerals)
  - Multiple valid paths through layer
  - Bombs become useful for shortcuts

---

### Layer 5: Ancient Lava Tubes (220-300m)

**Characteristics:**

- Old volcanic channels
- Very hard basalt walls
- Open pockets (caves)

**Hardness**: 2.5  
**Color**: Very dark brown-black (#3D1506)  
**Drill Speed Modifier**: 0.4x  
**Minimum Drill Level**: 2 (recommended), 3 (efficient)

**Resources Found:**

- **Gold**: 12.5% spawn rate (more common)
- **Silver**: 10% spawn rate
- **Platinum**: 4% spawn rate (first appearance!)
  - Value: $250, Size: 2 units
  - 2-3 tile veins, bright silver color
- **Neodymium**: 2.5% spawn rate
  - Value: $300, Size: 1.5 units
  - Rare purple-silver crystals

**Special Features:**

- **Empty cave pockets**: 20% chance
  - 5x5 open spaces (no drilling needed, save fuel)
  - But gravity pulls you down fast
- **Lava remnants**: Decorative orange cracks (no damage on Mars)
- Gas pockets: 10% chance, now 15 HP damage
- **Complex navigation required**:
  - Bedrock: 12% coverage (large 10x15 formations)
  - Hard Crystal: 4% coverage (guarding platinum and gems)
  - Winding corridors form naturally
  - Strategic bomb usage encouraged

---

### Layer 6: Dense Mantle Rock (300-380m)

**Characteristics:**

- Extremely hard compressed rock
- High pressure zone
- Requires Drill Level 3+

**Hardness**: 3.0  
**Color**: Near-black (#2A0F04)  
**Drill Speed Modifier**: 0.33x (three times slower)  
**Minimum Drill Level**: 3 (required for reasonable progress)

**Resources Found:**

- **Gold**: 17.5% spawn rate (abundant)
- **Platinum**: 10% spawn rate
- **Titanium**: 6% spawn rate
  - Value: $200, Size: 1.5 units
  - Dark gray metallic veins
- **Ruby**: 2.5% spawn rate (first gem!)
  - Value: $500, Size: 0.5 units
  - Small red crystals, 1-2 tiles
- **Neodymium**: 4% spawn rate

**Special Features:**

- **High pressure**: Movement slightly slower (fuel efficiency -10%)
- **Dense rock formations**: Some 3x3 unbreakable zones (navigate around)
- Very rare cave-ins: 8% chance, but 20 HP damage
- **Heavy obstacles**:
  - Bedrock: 15% coverage (massive 15x20 formations)
  - Hard Crystal: 5% coverage
  - Reinforced Rock: 3% coverage (Drill Level 3+ required, or bomb)
  - Must plan efficient routes
  - Bombs highly valuable here

---

### Layer 7: Crystalline Zone (380-450m)

**Characteristics:**

- Gem-bearing formation
- Glittering walls
- Very hard but rewarding

**Hardness**: 3.2  
**Color**: Dark with sparkling particles (#1F0A03 with glints)  
**Drill Speed Modifier**: 0.31x

**Resources Found:**

- **Platinum**: 15% spawn rate
- **Ruby**: 6% spawn rate
- **Emerald**: 4% spawn rate
  - Value: $600, Size: 0.5 units
  - Green crystals
- **Diamond**: 2.5% spawn rate
  - Value: $800, Size: 0.5 units
  - Brilliant white crystals, 1-2 tiles
- **Titanium**: 7.5% spawn rate
- **Gold**: 10% spawn rate (still present)

**Special Features:**

- **Crystal reflections**: Gems sparkle/glow, easier to spot
- **Brittle formations**: 20% chance drilling causes chain reaction
  - Adjacent tiles crack (visual warning, then break after 1 second)
- Minimal hazards (no gas, no cave-ins) - reward for reaching deep
- **Highest obstacle density**:
  - Bedrock: 18% coverage (very dense)
  - Hard Crystal: 8% coverage (ironic - crystal zone has crystal obstacles)
  - Reinforced Rock: 5% coverage (Drill Level 4+ needed)
  - Valuable gems often behind obstacles
  - Risk/reward: bomb through or navigate carefully?

---

### Layer 8: Pre-Core Mantle (450-490m)

**Characteristics:**

- Hottest zone on Mars
- Final challenge before core
- Extremely dense

**Hardness**: 3.5  
**Color**: Deep black with red veins (#150502)  
**Drill Speed Modifier**: 0.29x  
**Minimum Drill Level**: 4 (recommended for reasonable speed)

**Resources Found:**

- **Platinum**: 20% spawn rate (very common)
- **Diamond**: 5% spawn rate
- **Emerald**: 5% spawn rate
- **Ruby**: 7.5% spawn rate
- **Rhodium**: 1.5% spawn rate (rare!)
  - Value: $900, Size: 1 units
  - Ultra-reflective silver metal
- **Titanium**: 6% spawn rate

**Special Features:**

- **Heat signatures**: Visual red glow effect (no damage on Mars, but foreshadows other planets)
- **Magnetic interference**: HUD flickers occasionally (cosmetic)
- **Dense pockets**: Some tiles take 2x longer to drill even with max drill
- **Final obstacle challenge**:
  - Bedrock: 20% coverage (extremely dense)
  - Hard Crystal: 6% coverage
  - Reinforced Rock: 8% coverage (Drill Level 4+ or bomb required)
  - Most complex navigation in the game
  - Multiple bombs recommended for efficient progression

---

### Layer 9: Core Chamber (490-500m)

**Characteristics:**

- The goal
- Open chamber with the core
- No drilling needed once you reach it

**Hardness**: N/A (open space once accessed)  
**Color**: Glowing orange-red core in center

**Core Access:**

- Must drill through final wall at 490m
- Opens into 10x10 tile chamber
- **Dark Matter Crystal** in center (guaranteed)
  - Value: $10,000, Size: 0.1 units
  - Triggers prestige option when collected

**Special Features:**

- **The Core**: Glowing sphere, pulsing animation
- Extracting it triggers prestige screen
- Safe zone - no hazards, can rest here
- **Core access challenge**:
  - Hard Crystal walls form entry passage
  - Must bomb through OR find narrow natural passage
  - Final test before core extraction

---

## Resource Distribution Formula

### Vein Generation System

**All minerals in DESCENT use vein-based generation for realistic, clustered deposits.**

**Step 1: Place Vein Seeds**

```
veinSeeds = floor(totalTilesInLayer × seedRate)

For each seed:
  - Random position in layer
  - Skip if position already occupied
  - Mark as vein origin
```

**Step 2: Grow Veins from Seeds**

```
For each seed:
  veinSize = random(minSize, maxSize)
  currentPos = seedPosition

  For each tile in vein:
    place mineral at currentPos
    adjacentPositions = get valid adjacent tiles (cardinal + diagonal)
    if adjacentPositions is not empty:
      currentPos = random choice from adjacentPositions
    else:
      break (vein cannot grow further)
```

**Vein Growth Rules:**

- Veins grow to adjacent tiles (8 directions: N, S, E, W, NE, NW, SE, SW)
- Cannot overwrite existing minerals (veins don't overlap)
- Cannot grow into occupied spaces
- Growth is organic and follows natural clustering patterns

### Layer-Specific Vein Parameters

Each layer has different vein parameters for each mineral type:

**Example (Layer 1 - Surface Regolith):**

```
Coal:
  - seedRate: 20%
  - veinSize: [1, 2] tiles
  - Expected coverage: ~30-40%

Iron:
  - seedRate: 12%
  - veinSize: [2, 3] tiles
  - Expected coverage: ~20-30%
```

### Depth Bonus Modifier

```
adjustedSeedRate = baseSeedRate × (1 + depthBonus)

Where:
- baseSeedRate = listed seed rate for that layer
- depthBonus = (currentDepth / 500) × 0.2
  - Adds up to 20% more vein seeds at maximum depth
  - Makes deeper zones more mineral-rich
```

### Coverage Calculation

```
expectedCoverage = seedRate × averageVeinSize

Example:
- Coal: 20% seeds × 1.5 avg vein size = ~30% coverage
- Iron: 12% seeds × 2.5 avg vein size = ~30% coverage
```

**Note:** Actual coverage varies per generation due to:

- Random vein placement
- Vein growth blocking (can't grow through other veins)
- Edge cases (veins near layer boundaries)

This creates natural variation - some runs have more minerals, some have less.

### Hardness Impact on Drill Speed

```
actualDrillTime = baseDrillTime × strataHardness / drillLevel

Where:
- baseDrillTime = 0.3 seconds per tile
- strataHardness = 1.0 to 3.5
- drillLevel = 1 to 5

Example:
- Layer 6 (hardness 3.0) with Drill Level 2:
  0.3 × 3.0 / 2.0 = 0.45 seconds per tile

- Layer 1 (hardness 1.0) with Drill Level 1:
  0.3 × 1.0 / 1.0 = 0.3 seconds per tile (fast!)

- Layer 8 (hardness 3.5) with Drill Level 5:
  0.3 × 3.5 / 5.0 = 0.21 seconds per tile (efficient!)
```

### Drill Speed Table by Layer

**Layer 1 (Surface Regolith, Hardness 1.0):**

| Drill Level | Seconds/Tile | 100 Tiles |
| ----------- | ------------ | --------- |
| 1 (start)   | 0.30 sec     | 30 sec    |
| 2           | 0.15 sec     | 15 sec    |
| 3           | 0.10 sec     | 10 sec    |
| 5 (max)     | 0.06 sec     | 6 sec     |

**Layer 6 (Dense Mantle, Hardness 3.0):**

| Drill Level | Seconds/Tile | 100 Tiles |
| ----------- | ------------ | --------- |
| 1           | 0.90 sec     | 90 sec    |
| 2           | 0.45 sec     | 45 sec    |
| 3           | 0.30 sec     | 30 sec    |
| 5 (max)     | 0.18 sec     | 18 sec    |

**Layer 8 (Pre-Core Mantle, Hardness 3.5):**

| Drill Level | Seconds/Tile | 100 Tiles |
| ----------- | ------------ | --------- |
| 1           | 1.05 sec     | 105 sec   |
| 2           | 0.525 sec    | 52.5 sec  |
| 3           | 0.35 sec     | 35 sec    |
| 5 (max)     | 0.21 sec     | 21 sec    |

---

## Progression Gates

**Depth 80m**: Basalt layer strongly encourages Drill Level 2 + first obstacles appear  
**Depth 150m**: Maze sections begin, bombs become useful  
**Depth 220m**: Lava tubes show need for better fuel capacity + complex navigation  
**Depth 300m**: Dense mantle REQUIRES Drill Level 3 or progress is painfully slow + Reinforced Rock appears  
**Depth 380m**: Crystalline zone has highest obstacle density, strategic bomb usage essential  
**Depth 450m**: Pre-core zone benefits heavily from Drill Level 4+ + multiple bombs recommended  
**Depth 490m**: Core entrance may require bomb to access

**Estimated Run Time by Drill Level:**

- Level 1 only: ~10-12 minutes to core (very tedious in deep layers, difficult navigation)
- Level 2: ~6-7 minutes (obstacles still challenging)
- Level 3: ~4-5 minutes (comfortable pace, can handle most obstacles)
- Level 4+: ~3-4 minutes (efficient, optimized, obstacles manageable)

---

## Hazard Escalation

| Depth Range | Gas Pockets | Cave-ins | Damage |
| ----------- | ----------- | -------- | ------ |
| 0-80m       | 5%          | 0%       | 5 HP   |
| 80-150m     | 8%          | 10%      | 10 HP  |
| 150-220m    | 12%         | 15%      | 10 HP  |
| 220-300m    | 10%         | 5%       | 15 HP  |
| 300-450m    | 5%          | 8%       | 20 HP  |
| 450-500m    | 0%          | 0%       | 0 HP   |

**Design Note**: Hazards peak in mid-depths, then decrease in deep zones to reward reaching those areas with gems instead of constant danger.

---

## Visual Progression

**Color Gradient**:

- Light rust (#C1440E) at surface
- Gradually darkens to near-black (#150502) at pre-core
- Core chamber has orange glow (#FF4500)

**Particle Effects**:

- Surface: Light dust particles
- Mid-depths: Rock chips when drilling
- Deep: Sparkling crystal shards
- Core: Glowing energy particles

**Lighting**:

- Surface: Full brightness
- Each 50m deeper: -5% ambient light
- By 400m: Only pod's light illuminates surroundings
- Core chamber: Self-illuminated

---

## Economy Balance (Mars 1x Multiplier)

**Expected earnings per run by depth reached:**

- 100m: ~$500 (fuel upgrade)
- 200m: ~$1,500 (cargo or drill upgrade)
- 300m: ~$3,000 (hull or speed upgrade)
- 400m: ~$6,000 (multiple upgrades)
- Core (500m): ~$12,000 + Dark Matter ($10,000) = $22,000 total

**Prestige at core**: ~50 Soul Crystals (50% permanent bonus)

This ensures players need 3-5 runs to afford mid-tier upgrades, and 10-15 runs to max out Mars before prestiging.

---

## Planet Reset Behavior

**Between Runs:**

- All terrain regenerates when returning to surface
- Resource positions redistribute using the same spawn formulas
- Same spawn rates and vein sizes, but different random positions
- Hazards (gas pockets, cave-ins) respawn in new locations
- Core chamber always remains at 490-500m depth in center

**What Persists:**

- Your pod upgrades (fuel capacity, drill level, hull, etc.)
- Your Credits and Golden Gems
- Your Soul Crystal bonus
- Planet unlock status

**Procedural Generation:**

- Mars uses seeded random generation
- Maintains consistent "Mars feel" (red terrain, iron-rich, etc.)
- But prevents memorizing exact mineral positions
- Layer rules always apply (gold only below 150m, gems below 380m, etc.)

**Why This Matters:**

- Each run is a fresh challenge
- Can't "strip mine" and deplete the planet
- Upgrade value comes from speed/efficiency, not memory
- Keeps gameplay varied and replayable
- Economy stays balanced across all runs

---

## Summary

This Mars level design provides:

- **9 distinct strata layers** with unique characteristics
- **Clear progression gates** that encourage upgrades
- **Balanced hazard escalation** (peaks mid-game, rewards deep exploration)
- **Economic progression** requiring 10-15 runs to master
- **Visual and gameplay variety** throughout the descent
- **Formulaic resource distribution** for consistent but varied gameplay
