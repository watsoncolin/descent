# Mars Level Design - Complete Strata System

## Core Depth & Vertical Structure

**Total Depth to Core**: 500 meters  
**Tile Size**: 32 pixels (≈1 meter per tile)  
**Total Tiles Deep**: 500 tiles

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

- **Carbon (Coal)**: 20% vein seed rate
  - Value: $10, Size: 5 units
  - Vein size: 1-2 tiles (clustered)
  - Expected coverage: ~30-40% of layer
- **Iron**: 12% vein seed rate
  - Value: $25, Size: 3 units
  - Vein size: 2-3 tiles (clustered)
  - Expected coverage: ~20-30% of layer

**Special Features:**

- No hazards
- Clear visibility
- Tutorial prompts appear here

---

### Layer 2: Iron-Rich Sediment (30-80m)

**Characteristics:**

- Compacted soil with iron oxide
- Starting to get harder

**Hardness**: 1.3  
**Color**: Medium rust red (#A0380C)  
**Drill Speed Modifier**: 0.77x (takes 30% longer)

**Resources Found:**

- **Iron**: 25% vein seed rate (common)
  - Vein size: 3-5 tiles (larger veins)
  - Expected coverage: ~40-50% of layer
- **Copper**: 15% vein seed rate
  - Value: $30, Size: 3 units
  - Vein size: 2-3 tiles
  - Expected coverage: ~20-25% of layer
- **Silicon**: 10% vein seed rate
  - Value: $50, Size: 2 units
  - Vein size: 1-2 tiles (small deposits)
  - Expected coverage: ~10-15% of layer

**Special Features:**

- First **small gas pockets** appear (5% chance per chunk)
  - 1-2 tiles, 5 HP damage when drilled

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

- **Iron**: 30% spawn rate (still common)
- **Copper**: 35% spawn rate (more abundant here)
- **Silver**: 15% spawn rate
  - Value: $75, Size: 2 units
  - 2-4 tile veins
- **Aluminum**: 10% spawn rate
  - Value: $60, Size: 2 units

**Special Features:**

- **Unstable rock formations**: 10% of tiles
  - When drilled, adjacent tiles can collapse (10 HP damage)
- Gas pockets increase to 8% chance

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

- **Silver**: 30% spawn rate (common here)
- **Gold**: 15% spawn rate (first appearance!)
  - Value: $150, Size: 2 units
  - 2-4 tile veins with golden color
- **Copper**: 25% spawn rate
- **Aluminum**: 10% spawn rate

**Special Features:**

- **Cave-ins**: 15% chance when drilling
  - Rocks fall from above (10 HP per rock)
- **Large gas pockets**: 12% chance
  - 3-5 tile pockets, 10 HP damage
- **Cracks**: Visual cracks appear, hinting at instability

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

- **Gold**: 25% spawn rate (more common)
- **Silver**: 20% spawn rate
- **Platinum**: 8% spawn rate (first appearance!)
  - Value: $250, Size: 2 units
  - 2-3 tile veins, bright silver color
- **Neodymium**: 5% spawn rate
  - Value: $300, Size: 1.5 units
  - Rare purple-silver crystals

**Special Features:**

- **Empty cave pockets**: 20% chance
  - 5x5 open spaces (no drilling needed, save fuel)
  - But gravity pulls you down fast
- **Lava remnants**: Decorative orange cracks (no damage on Mars)
- Gas pockets: 10% chance, now 15 HP damage

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

- **Gold**: 35% spawn rate (abundant)
- **Platinum**: 20% spawn rate
- **Titanium**: 12% spawn rate
  - Value: $200, Size: 1.5 units
  - Dark gray metallic veins
- **Ruby**: 5% spawn rate (first gem!)
  - Value: $500, Size: 0.5 units
  - Small red crystals, 1-2 tiles
- **Neodymium**: 8% spawn rate

**Special Features:**

- **High pressure**: Movement slightly slower (fuel efficiency -10%)
- **Dense rock formations**: Some 3x3 unbreakable zones (navigate around)
- Very rare cave-ins: 8% chance, but 20 HP damage

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

- **Platinum**: 30% spawn rate
- **Ruby**: 12% spawn rate
- **Emerald**: 8% spawn rate
  - Value: $600, Size: 0.5 units
  - Green crystals
- **Diamond**: 5% spawn rate
  - Value: $800, Size: 0.5 units
  - Brilliant white crystals, 1-2 tiles
- **Titanium**: 15% spawn rate
- **Gold**: 20% spawn rate (still present)

**Special Features:**

- **Crystal reflections**: Gems sparkle/glow, easier to spot
- **Brittle formations**: 20% chance drilling causes chain reaction
  - Adjacent tiles crack (visual warning, then break after 1 second)
- Minimal hazards (no gas, no cave-ins) - reward for reaching deep

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

- **Platinum**: 40% spawn rate (very common)
- **Diamond**: 10% spawn rate
- **Emerald**: 10% spawn rate
- **Ruby**: 15% spawn rate
- **Rhodium**: 3% spawn rate (rare!)
  - Value: $900, Size: 1 units
  - Ultra-reflective silver metal
- **Titanium**: 12% spawn rate

**Special Features:**

- **Heat signatures**: Visual red glow effect (no damage on Mars, but foreshadows other planets)
- **Magnetic interference**: HUD flickers occasionally (cosmetic)
- **Dense pockets**: Some tiles take 2x longer to drill even with max drill

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
ActualDrillTime = BaseDrillTime × StrataHardness / DrillLevel

Where:
- BaseDrillTime = 0.5 seconds
- StrataHardness = 1.0 to 3.5
- DrillLevel = 1 to 5

Example:
- Layer 6 (hardness 3.0) with Drill Level 2:
  0.5 × 3.0 / 2.0 = 0.75 seconds per tile
```

---

## Progression Gates

**Depth 80m**: Basalt layer strongly encourages Drill Level 2  
**Depth 220m**: Lava tubes show need for better fuel capacity  
**Depth 300m**: Dense mantle REQUIRES Drill Level 3 or progress is painfully slow  
**Depth 450m**: Pre-core zone benefits heavily from Drill Level 4+

**Estimated Run Time by Drill Level:**

- Level 1 only: ~15 minutes to core (tedious in deep layers)
- Level 2: ~10 minutes
- Level 3: ~7 minutes
- Level 4+: ~5 minutes

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
