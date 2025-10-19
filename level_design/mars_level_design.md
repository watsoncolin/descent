# Mars Level Design - Complete Strata System

**Planet:** Mars
**Difficulty:** Tutorial/Beginner
**Theme:** Rust-colored Martian excavation
**Total Depth:** 2560m (configurable per planet in mars.json)
**Core Location:** 2500m depth (configurable per planet - see `coreDepth` in mars.json)
**Planet Order:** 1 of 8
**Unlock Requirements:** None (starting planet)

> **Note:** Core depth is a per-planet configuration stored in the planet's JSON file. Each planet can have different total depth and core placement based on difficulty and design.

---

## 🎨 Visual Design Philosophy

Mars uses **continuous flowing terrain** with embedded material deposits. Each strata has two visual states:

- **Surface Layer**: Lighter colors, visible before mining
- **Excavated Layer**: Darker, compacted version revealed after mining

All terrain uses smooth gradients with atmospheric glows rather than pixel art.

**Scale:** 64px block = 12.5 meters of terrain depth (5.12px per meter)

---

## 🌍 Geological Structure

Mars features **4 distinct strata layers** that the player descends through. Each layer has unique terrain composition and embedded material deposits.

### Strata Overview

```
┌────────────────────────────────────────┐
│  STRATA 1: SURFACE SAND (0-640m)       │  Light tan sediment
│    Blocks 0-51                          │
│    Materials: Coal (common)             │
├────────────────────────────────────────┤
│  STRATA 2: STONE LAYER (640-1280m)     │  Gray sedimentary rock
│    Blocks 51-102                        │
│    Materials: Iron, Coal                │
├────────────────────────────────────────┤
│  STRATA 3: DEEP ROCK (1280-1920m)      │  Dark metamorphic rock
│    Blocks 102-154                       │
│    Materials: Copper, Iron, Silicon     │
├────────────────────────────────────────┤
│  STRATA 4: MARS CORE (1920-2560m)      │  Ancient red planetary core
│    Blocks 154-205                       │
│    Materials: Gold, Silicon, Copper     │
│    Core Chamber at 2500m (Block 200)    │
└────────────────────────────────────────┘
```

---

## 🪨 Strata Definitions

### Strata 1: Surface Sand (0-125m, Blocks 1-10)

**Terrain Type:** Sand  
**Visual Theme:** Light Martian regolith, beachy sand dunes  
**Mining Difficulty:** Easy (baseline)

**Technical Properties:**

- **Hardness:** 1.0 (baseline)
- **Drill Speed Modifier:** 1.0x (full speed)
- **Minimum Drill Level:** 1 (any drill works)
- **Base Drill Time:** 0.3 seconds × 1.0 / drillLevel
  - Drill Level 1: 0.30 sec/block
  - Drill Level 3: 0.10 sec/block
  - Drill Level 5: 0.06 sec/block

**Colors:**

```
Surface:    #c4a57b → #b89a70 → #a89060 (light tan, warm)
Excavated:  #8c7545 → #7c6535 → #6c5525 (dark compacted sand)
Contrast:   ~35% darker when mined
```

**Visual Details:**

- Large elliptical variations (80-120px) at 10-15% opacity
- Diagonal flow pattern (15-30°)
- Horizontal organic texture lines at 8% opacity
- Subtle sand dune appearance

**Material Deposits:**

- **Coal** - 60% spawn rate per chunk
  - Deposit size: 10-18px radius (2-4 blocks)
  - Clustering: Small clusters of 1-3 deposits
  - Visual: Dark black ore (#1a1a1a) with subtle glow
  - Value: 10 Bocks/unit, Volume: 1.0
  - Purpose: Common early-game resource for fuel/credits

**Hazards:**

- None (safe tutorial zone)

**Gameplay:**

- Tutorial/starting area
- Easiest drilling resistance
- Learn basic mining mechanics
- Safe zone with no hazards
- Collect coal for initial fuel and credits
- Depth range: 0-125m (10 blocks)

---

### Strata 2: Stone Layer (125-250m, Blocks 11-20)

**Terrain Type:** Stone  
**Visual Theme:** Solid gray sedimentary rock, stratified layers  
**Mining Difficulty:** Moderate

**Technical Properties:**

- **Hardness:** 1.5
- **Drill Speed Modifier:** 0.67x (50% slower than sand)
- **Minimum Drill Level:** 1 (slow), 2 (comfortable)
- **Base Drill Time:** 0.3 seconds × 1.5 / drillLevel
  - Drill Level 1: 0.45 sec/block (noticeably slower)
  - Drill Level 2: 0.225 sec/block
  - Drill Level 3: 0.15 sec/block
  - Drill Level 5: 0.09 sec/block

**Colors:**

```
Surface:    #6a7a8a → #5a6a7a (medium gray)
Excavated:  #4a5a6a → #3a4a5a (dark bedrock)
Contrast:   ~40% darker when mined
```

**Visual Details:**

- Medium elliptical variations (60-90px) at 12-18% opacity
- Diagonal stratification (20-35°), more angular than sand
- Horizontal stratification lines at 10% opacity
- Solid stone appearance transitioning to ancient bedrock

**Material Deposits:**

- **Iron Ore** - 25% spawn rate per chunk

  - Deposit size: 12-18px radius (3-4 blocks)
  - Clustering: Medium veins of 2-4 deposits
  - Visual: Silvery metallic (#7a8a9a) with shine effect
  - Value: 25 Bocks/unit, Volume: 1.5
  - Purpose: Uncommon metallic resource

- **Coal** - 40% spawn rate per chunk
  - Still present but less common
  - Deposit size: 10-16px radius (2-3 blocks)
  - Transition zone between strata

**Hazards:**

- **Small Gas Pockets** - 5% spawn rate per chunk
  - Size: 1-2 blocks (64-128px)
  - Damage: 5 HP when drilled through
  - Visual: Yellowish-green gas cloud effect
  - Warning: Slight shimmer before drilling

**Gameplay:**

- Moderate drilling resistance (requires upgraded drill for efficiency)
- Introduction to valuable metals
- First upgrade tier unlocks here
- Strategic mining paths needed
- Minor gas pockets begin appearing
- Depth range: 125-250m (10 blocks)

---

### Strata 3: Deep Rock (250-375m, Blocks 21-30)

**Terrain Type:** Rock  
**Visual Theme:** Ancient dense metamorphic rock, dark formations  
**Mining Difficulty:** Hard

**Technical Properties:**

- **Hardness:** 2.5
- **Drill Speed Modifier:** 0.4x (2.5x slower than sand)
- **Minimum Drill Level:** 2 (very slow), 3 (acceptable), 4 (comfortable)
- **Base Drill Time:** 0.3 seconds × 2.5 / drillLevel
  - Drill Level 1: 0.75 sec/block (painfully slow)
  - Drill Level 2: 0.375 sec/block (still slow)
  - Drill Level 3: 0.25 sec/block
  - Drill Level 4: 0.1875 sec/block
  - Drill Level 5: 0.15 sec/block

**Colors:**

```
Surface:    #7a8090 → #6a7080 (gray-blue)
Excavated:  #5a6070 → #4a5060 (deep gray-blue)
Contrast:   ~35% darker when mined
```

**Visual Details:**

- Large irregular shapes (70-110px) at 15-20% opacity
- Mixed angular flow patterns (15-40°)
- Cracked texture patterns at 12% opacity
- Ancient metamorphic rock appearance

**Material Deposits:**

- **Copper Ore** - 20% spawn rate per chunk

  - Deposit size: 13-20px radius (3-5 blocks)
  - Clustering: Large veins of 3-6 deposits
  - Visual: Orange-brown metallic (#c4754e) with warm glow
  - Value: 30 Bocks/unit, Volume: 1.8
  - Purpose: Valuable metallic resource

- **Iron Ore** - 15% spawn rate per chunk
  - Still present but rarer
  - Deposit size: 14-20px radius (3-5 blocks)
  - Deeper veins, larger deposits

**Hazards:**

- **Gas Pockets** - 10% spawn rate per chunk

  - Size: 2-3 blocks (128-192px)
  - Damage: 10 HP when drilled through
  - Visual: Denser gas clouds with yellow-green glow

- **Unstable Rock Formations** - 8% of terrain blocks

  - When drilled, 30% chance to trigger collapse
  - Collapse affects 3-5 adjacent blocks
  - Damage: 15 HP when caught in collapse
  - Visual: Subtle cracks in rock texture
  - Warning: Slight rumble/shake before drilling

- **Minor Cave-ins** - 3% random event after drilling
  - Rocks fall from above (2-4 blocks)
  - Damage: 10 HP if hit
  - Can be dodged with movement

**Gameplay:**

- High drilling resistance (strongly encourages Drill Level 3+)
- Risk/reward balance increases significantly
- Gas pockets more frequent and dangerous
- Unstable formations create navigation challenges
- First cave-ins possible
- Depth range: 250-375m (10 blocks)

---

### Strata 4: Mars Core Zone (1920-2560m, Blocks 154-205)

**Terrain Type:** Mars Rock
**Visual Theme:** Ancient red planetary core, oxidized deep layers
**Mining Difficulty:** Very Hard (requires high-level upgrades)

**Technical Properties:**

- **Hardness:** 3.5 (maximum for Mars)
- **Drill Speed Modifier:** 0.29x (3.5x slower than sand)
- **Minimum Drill Level:** 3 (very slow), 4 (slow), 5 (acceptable)
- **Base Drill Time:** 0.3 seconds × 3.5 / drillLevel
  - Drill Level 1: 1.05 sec/block (nearly impossible)
  - Drill Level 2: 0.525 sec/block (too slow)
  - Drill Level 3: 0.35 sec/block (challenging)
  - Drill Level 4: 0.2625 sec/block
  - Drill Level 5: 0.21 sec/block (efficient)

**Colors:**

```
Surface:    #b85a40 → #a04a30 (rust red)
Excavated:  #8a3a20 → #6a2a10 (deep rust, almost black)
Contrast:   ~45% darker (approaching void darkness)
```

**Visual Details:**

- Large organic shapes (90-130px) at 12-18% opacity
- Wavy geological upheaval patterns
- Crater-like depressions and dust patterns at 10% opacity
- Oxidized Martian surface transitioning to ancient planetary core

**Material Deposits:**

- **Gold** - 8% spawn rate per chunk

  - Deposit size: 15-22px radius (4-6 blocks)
  - Clustering: Large rich veins of 4-8 deposits
  - Visual: Brilliant yellow metallic (#FFD700) with strong glow
  - Value: 100 Bocks/unit, Volume: 2.0
  - Purpose: Rare, high-value resource

- **Silicon** - 12% spawn rate per chunk

  - Deposit size: 12-18px radius (3-4 blocks)
  - Clustering: Medium crystalline clusters of 2-5 deposits
  - Visual: Gray crystalline (#9a9aaa) with subtle sparkle
  - Value: 50 Bocks/unit, Volume: 1.3

- **Copper Ore** - 10% spawn rate per chunk
  - Still present near core
  - Deposit size: 15-22px radius (4-6 blocks)
  - Valuable backup resource

**Special Features:**

- **Dark Matter Crystal (Core)** - Single occurrence at 490m depth (Block 39-40)
  - Location: 10×10 block open chamber (640×640px safe zone)
  - Glowing orange-red pulsing sphere in center
  - Visual: Animated pulsing glow (0.8-1.2 scale, 2 sec cycle)
  - Value: 10,000 Bocks, Volume: 0.1 (negligible weight)
  - Collection triggers prestige system
  - Must return to surface after collection (no teleporter bypass)

**Hazards:**

- **Large Gas Pockets** - 15% spawn rate per chunk

  - Size: 3-5 blocks (192-320px)
  - Damage: 15 HP when drilled through
  - Visual: Dense toxic clouds with bright yellow-green glow
  - Effect: Lingering damage field for 2 seconds

- **Major Cave-ins** - 12% of terrain blocks

  - When drilled, 50% chance to trigger collapse
  - Collapse affects 5-8 adjacent blocks in cascade
  - Damage: 20 HP when caught in collapse
  - Visual: Obvious cracks with rumbling animation
  - Warning: 0.5 second warning shake before collapse

- **Lava Pockets** - 5% spawn rate per chunk

  - Size: 2-4 blocks (128-256px)
  - Damage: 25 HP when drilled through
  - Visual: Glowing orange-red molten rock
  - Effect: Lingering heat damage (5 HP/sec for 3 seconds)
  - Warning: Bright glow visible before drilling

- **Random Falling Debris** - 8% chance per drilled block
  - Rocks fall from above (3-6 blocks)
  - Damage: 15 HP if hit
  - Can be dodged with quick movement
  - Visual: Shadow warning above player

**Gameplay:**

- Highest drilling resistance (requires Drill Level 4+ or patience)
- Maximum hazard frequency and severity
- High fuel consumption zone (extreme depth)
- Requires multiple upgrade tiers to survive
- Core extraction is victory condition for Mars
- High risk, high reward gameplay
- Depth range: 375-500m (10 blocks)
- Only accessible with significant upgrades (Hull 100+ HP, Fuel 300+, Drill 3+)

---

## 🚧 Obstacle Materials System

Mars features three types of **indestructible or special terrain** that create navigation challenges and strategic decisions. These are embedded within the flowing terrain alongside mineable materials.

### Bedrock (Completely Indestructible)

**Visual:** Black/dark gray (#1a1a1a → #0a0a0a), no glow  
**Properties:** Cannot drill, cannot bomb, must navigate around  
**Purpose:** Absolute barriers that force maze-like navigation

**Spawn Rates by Depth:**

- 0-125m: 3% coverage (sparse, easy navigation)
- 125-250m: 5% coverage (increasing complexity)
- 250-375m: 10% coverage (requires planning)
- 375-500m: 20% coverage (significant obstacles)

**Gameplay Impact:**

- Forces non-linear descent paths
- Creates natural chokepoints
- Prevents boring straight-down drilling
- Encourages spatial awareness
- No workarounds available

---

### Hard Crystal (Bomb-Only)

**Visual:** Purple-blue crystalline (#8a4a9a → #6a2a7a) with pulsing glow  
**Properties:** Cannot drill, CAN bomb for $800, can navigate around  
**Purpose:** Economic decision-making (bomb vs. navigate)

**Spawn Rates by Depth:**

- 0-125m: 0% (not present)
- 125-250m: 2% coverage (introduction)
- 250-375m: 5% coverage (common obstacles)
- 375-500m: 8% coverage (frequent barriers)

**Gameplay Impact:**

- Strategic choice: spend Bocks to bomb or take longer route
- Often guards valuable material deposits
- Risk/reward decision making
- Becomes more economical to bomb in deep zones with high-value materials
- Can create "pay walls" blocking optimal paths

---

### Reinforced Rock (High Drill Level Required)

**Visual:** Gray-silver metallic (#9a9aaa → #7a7a8a) with subtle shine  
**Properties:** Requires Drill Level 4+ OR bomb for $800  
**Purpose:** Progression gate and upgrade encouragement

**Spawn Rates by Depth:**

- 0-125m: 0% (not present)
- 125-250m: 0% (not present)
- 250-375m: 3% coverage (first appearance)
- 375-500m: 8% coverage (significant presence)

**Gameplay Impact:**

- Acts as soft gate: accessible with upgrades OR bombs
- Encourages drill upgrades for cost efficiency
- Without Drill Level 4+, must bomb (expensive) or navigate around
- Prevents early-game players from easily reaching deep zones
- Rewards investment in drill upgrades

---

## 🗺️ Obstacle Distribution Strategy

**Placement Rules:**

1. **Never block all paths** - Always maintain at least one navigable route
2. **Cluster near valuable materials** - 60% of Hard Crystal spawns near Gold/rare materials
3. **Create interesting shapes** - Obstacles form natural cave systems, not random scattered blocks
4. **Depth scaling** - Total obstacle coverage increases from 3% (surface) to 36% (core zone)
5. **Type mixing** - Deep zones contain all three obstacle types for varied challenges

**Total Obstacle Coverage by Depth:**

- Surface Sand (0-125m): 3% (Bedrock only)
- Stone Layer (125-250m): 7% (Bedrock + Hard Crystal intro)
- Deep Rock (250-375m): 18% (All three types)
- Mars Core (375-500m): 36% (Heavy obstacles, requires skilled navigation)

---

## 📊 Material Distribution Summary

| Material    | Depth Range | Frequency  | Value  | Volume | Visual           |
| ----------- | ----------- | ---------- | ------ | ------ | ---------------- |
| Coal        | 0-250m      | 60→40%     | 10     | 1.0    | Black with glow  |
| Iron        | 125-375m    | 25→15%     | 25     | 1.5    | Silver metallic  |
| Copper      | 250-500m    | 20→10%     | 30     | 1.8    | Orange-brown     |
| Silicon     | 375-500m    | 12%        | 50     | 1.3    | Gray crystal     |
| Gold        | 375-500m    | 8%         | 100    | 2.0    | Brilliant yellow |
| Dark Matter | 490m        | 1 (unique) | 10,000 | 0.1    | Orange-red pulse |

---

## 🎮 Progression Guidelines

### First Run (0-125m)

- Mine coal in Surface Sand
- Learn basic controls and fuel management
- Earn first ~500 Bocks
- Return to surface before fuel runs out
- Buy first upgrade (Fuel Tank or Cargo)

### Runs 2-5 (125-250m)

- Reach Stone Layer
- Mine iron ore for better earnings
- Gradually improve drill and fuel capacity
- Learn to manage gas pockets
- Earn ~2,000 Bocks per successful run

### Runs 6-10 (250-375m)

- Enter Deep Rock zone
- Mine copper for significant value
- Requires Drill Level 2+ and armor upgrades
- Deal with unstable formations
- Earn ~5,000 Bocks per run

### Runs 10+ (375-500m)

- Attempt Mars Core Zone
- Mine gold and silicon
- Requires maxed starter upgrades
- High risk, high reward runs
- Navigate extreme hazards
- Earn ~15,000+ Bocks per run
- Extract Dark Matter Crystal to trigger prestige

---

## ⚙️ Drilling Mechanics Formula

### Core Formula

```
actualDrillTime = baseDrillTime × strataHardness / drillLevel

Where:
- baseDrillTime = 0.3 seconds per block (constant)
- strataHardness = 1.0 to 3.5 (varies by depth)
- drillLevel = 1 to 5 (player upgrade)
```

### Drill Time Table

| Strata       | Hardness | Drill Lv1 | Drill Lv2 | Drill Lv3 | Drill Lv4 | Drill Lv5 |
| ------------ | -------- | --------- | --------- | --------- | --------- | --------- |
| Surface Sand | 1.0      | 0.30s     | 0.15s     | 0.10s     | 0.075s    | 0.06s     |
| Stone Layer  | 1.5      | 0.45s     | 0.225s    | 0.15s     | 0.1125s   | 0.09s     |
| Deep Rock    | 2.5      | 0.75s     | 0.375s    | 0.25s     | 0.1875s   | 0.15s     |
| Mars Core    | 3.5      | 1.05s     | 0.525s    | 0.35s     | 0.2625s   | 0.21s     |

### Visual/Audio Feedback by Speed

**Fast Drilling (< 0.15s):**

- Quick crack animation (3-5 frames)
- Sharp drill sound (high pitch)
- Dust particles fly outward quickly
- Satisfying "pop" sound effect

**Normal Drilling (0.15-0.30s):**

- Standard crack animation (5-8 frames)
- Medium drill sound
- Normal particle spray
- Solid "crunch" sound effect

**Slow Drilling (0.30-0.60s):**

- Extended grinding animation (8-12 frames)
- Deep grinding drill sound
- Sparks instead of dust
- Labored "grind" sound effect

**Very Slow Drilling (> 0.60s):**

- Long struggle animation (12+ frames)
- Painful grinding sound
- Heavy spark shower
- Screen shake effect
- "This is too hard!" visual indicator

---

## 📦 Material Generation Rules

### Spawn System

Materials spawn in **chunks** (16×16 block regions, 1024×1024px). Each chunk independently rolls for material spawns based on depth.

### Clustering Algorithm

```
For each material type in current strata:
1. Roll spawn chance (e.g., Coal = 60%)
2. If successful, determine cluster size:
   - Small: 1-2 deposits (40% chance)
   - Medium: 2-4 deposits (40% chance)
   - Large: 3-6 deposits (20% chance)
3. Place first deposit at random valid location
4. Place remaining deposits adjacent (within 2-3 blocks)
5. Apply material-specific radius (10-22px)
```

### Material Deposit Sizes

| Material | Radius Range | Blocks Occupied | Visual Size  |
| -------- | ------------ | --------------- | ------------ |
| Coal     | 10-18px      | 2-4 blocks      | Small-Medium |
| Iron     | 12-18px      | 3-4 blocks      | Medium       |
| Copper   | 13-20px      | 3-5 blocks      | Medium-Large |
| Silicon  | 12-18px      | 3-4 blocks      | Medium       |
| Gold     | 15-22px      | 4-6 blocks      | Large        |

### Depth-Based Spawn Rates

Materials become more/less common as you descend:

| Material | 0-125m | 125-250m | 250-375m | 375-500m |
| -------- | ------ | -------- | -------- | -------- |
| Coal     | 60%    | 40%      | 0%       | 0%       |
| Iron     | 0%     | 25%      | 15%      | 0%       |
| Copper   | 0%     | 0%       | 20%      | 10%      |
| Silicon  | 0%     | 0%       | 0%       | 12%      |
| Gold     | 0%     | 0%       | 0%       | 8%       |

---

## ⚠️ Hazard Escalation System

### Detailed Hazard Table

| Depth Range  | Gas Pockets | Unstable Rock        | Cave-ins         | Lava Pockets     |
| ------------ | ----------- | -------------------- | ---------------- | ---------------- |
| **0-125m**   | 0%          | 0%                   | 0%               | 0%               |
| **125-250m** | 5% (5 HP)   | 0%                   | 0%               | 0%               |
|              | 1-2 blocks  | -                    | -                | -                |
| **250-375m** | 10% (10 HP) | 8% (15 HP)           | 3% (10 HP)       | 0%               |
|              | 2-3 blocks  | Collapses 3-5 blocks | Falls 2-4 blocks | -                |
| **375-500m** | 15% (15 HP) | 12% (20 HP)          | 8% (15 HP)       | 5% (25 HP + DoT) |
|              | 3-5 blocks  | Collapses 5-8 blocks | Falls 3-6 blocks | 2-4 blocks       |

### Hazard Mechanics Details

**Gas Pockets:**

- Spawn rate: Percentage chance per chunk
- Trigger: Player drills into block containing gas
- Damage: Instant HP loss when triggered
- Visual warning: Slight shimmer/distortion in terrain
- Effect: Brief toxic cloud remains for 1-2 seconds
- Can be avoided by observing visual cues

**Unstable Rock Formations:**

- Spawn rate: Percentage of terrain blocks marked as unstable
- Trigger: 30-50% chance when drilling adjacent to unstable block
- Damage: HP loss if player in collapse radius
- Visual warning: Visible cracks in rock texture
- Audio warning: Rumbling sound 0.5 seconds before collapse
- Cascade effect: Can trigger adjacent unstable blocks (chain reaction)
- Can be partially avoided by drilling from edges

**Cave-ins (Falling Debris):**

- Spawn rate: Random chance after drilling any block in depth range
- Trigger: Drilling disturbs ceiling stability
- Damage: HP loss only if rocks hit player
- Visual warning: Shadow appears above player 0.3 seconds before
- Dodgeable: Player can move sideways to avoid
- Fall pattern: 2-6 rocks fall in cluster formation

**Lava Pockets:**

- Spawn rate: Percentage chance per chunk
- Trigger: Player drills into block containing lava
- Damage: 25 HP instant + 5 HP/sec for 3 seconds (total 40 HP)
- Visual warning: Bright orange-red glow through cracks
- Effect: Lingering heat zone remains for 3 seconds
- Highly dangerous - requires careful observation

### Cumulative Danger Levels

| Depth    | Combined Hazard % | Avg HP Lost Per Run | Risk Level |
| -------- | ----------------- | ------------------- | ---------- |
| 0-125m   | 0%                | 0 HP                | Safe       |
| 125-250m | 5%                | 5-10 HP             | Low        |
| 250-375m | 21%               | 25-40 HP            | Moderate   |
| 375-500m | 40%               | 60-100 HP           | High       |

_Note: Skilled players who observe warnings can reduce hazard damage by 50-70%_

---

## ⏱️ Run Time Estimates

### Time to Drill Full Depth (500m = 40 blocks)

Assumptions:

- Mix of all strata (25% each)
- Average path (not straight down)
- Includes movement time between blocks

| Drill Level | Drilling Time | Movement Time | Total Run Time |
| ----------- | ------------- | ------------- | -------------- |
| Level 1     | ~180 seconds  | ~120 seconds  | ~5 minutes     |
| Level 2     | ~110 seconds  | ~90 seconds   | ~3.3 minutes   |
| Level 3     | ~75 seconds   | ~75 seconds   | ~2.5 minutes   |
| Level 4     | ~60 seconds   | ~60 seconds   | ~2 minutes     |
| Level 5     | ~50 seconds   | ~50 seconds   | ~1.7 minutes   |

**Plus:**

- Material collection: +30-60 seconds
- Hazard navigation: +20-40 seconds
- Return to surface: +60-90 seconds

**Total Expected Run Times:**

- **First runs (Drill Lv1)**: 7-9 minutes (encourages upgrades)
- **Mid-game (Drill Lv3)**: 4-6 minutes (comfortable)
- **Optimized (Drill Lv5)**: 3-4 minutes (efficient grinding)

---

## 💎 Economy Balance & Progression

### Target Earnings Per Run

**Early Game (Runs 1-3):**

- Depth reached: 0-150m (Surface Sand + partial Stone Layer)
- Materials collected: Mostly Coal, some Iron
- Gross earnings: 300-600 Bocks
- Fuel/repair costs: -50 to -100 Bocks
- **Net earnings: 250-500 Bocks per run**
- Run time: 5-7 minutes

**Mid Game (Runs 4-8):**

- Depth reached: 150-300m (Stone Layer + partial Deep Rock)
- Materials collected: Iron, Copper, some Coal
- Gross earnings: 1,200-2,500 Bocks
- Fuel/repair costs: -200 to -400 Bocks
- **Net earnings: 1,000-2,100 Bocks per run**
- Run time: 4-6 minutes

**Late Game (Runs 9-15):**

- Depth reached: 300-450m (Deep Rock + partial Core)
- Materials collected: Copper, Silicon, some Gold
- Gross earnings: 4,000-8,000 Bocks
- Fuel/repair costs: -500 to -1,000 Bocks
- **Net earnings: 3,500-7,000 Bocks per run**
- Run time: 3-5 minutes

**Core Runs (Runs 15+):**

- Depth reached: Full 500m (all strata including Core)
- Materials collected: Gold, Silicon, Copper + Dark Matter Crystal
- Gross earnings: 15,000-25,000 Bocks (including 10,000 from core)
- Fuel/repair costs: -1,500 to -3,000 Bocks
- **Net earnings: 12,000-20,000 Bocks per run**
- Run time: 3-4 minutes (optimized)

### Upgrade Cost Scaling

Costs are balanced so players progress naturally through runs:

**Tier 1 Upgrades** (Unlocked at start, purchased runs 1-3):

- Fuel Tank Lv2: 500 Bocks (1-2 runs)
- Cargo Capacity Lv2: 600 Bocks (1-2 runs)
- Drill Strength Lv2: 800 Bocks (2-3 runs)
- Hull Armor Lv2: 700 Bocks (2-3 runs)

**Tier 2 Upgrades** (Purchased runs 4-8):

- Fuel Tank Lv3: 1,500 Bocks (2 runs)
- Cargo Capacity Lv3: 1,800 Bocks (2 runs)
- Drill Strength Lv3: 2,500 Bocks (2-3 runs)
- Hull Armor Lv3: 2,200 Bocks (2 runs)

**Tier 3 Upgrades** (Purchased runs 9-15):

- Fuel Tank Lv4: 4,000 Bocks (2 runs)
- Cargo Capacity Lv4: 5,000 Bocks (2 runs)
- Drill Strength Lv4: 7,000 Bocks (2 runs)
- Hull Armor Lv4: 6,000 Bocks (2 runs)

**Tier 4 Upgrades** (Purchased runs 15+, pre-core):

- Fuel Tank Lv5 (Max): 10,000 Bocks (2 runs)
- Cargo Capacity Lv5 (Max): 12,000 Bocks (2 runs)
- Drill Strength Lv5 (Max): 15,000 Bocks (2 runs)
- Hull Armor Lv5 (Max): 14,000 Bocks (2 runs)

**Consumables:**

- Repair Kit (50 HP): 200 Bocks
- Fuel Cell (50 fuel): 100 Bocks
- Bomb (3×3 destroy): 800 Bocks
- Teleporter (instant surface): 500 Bocks

**Permanent Unlocks:**

- Mineral Scanner: 2,000 Bocks
- Auto-Refuel: 1,500 Bocks
- Ejection Pod (survive death once): 3,000 Bocks

### Minimum Upgrade Requirements by Depth

**To Reach 250m (Deep Rock):**

- Fuel Tank: Level 3 minimum (200 fuel)
- Drill: Level 2 minimum (or very patient)
- Hull: Level 2 minimum (75 HP)
- Cargo: Level 2+ recommended (15+ slots)

**To Reach 375m (Mars Core Zone):**

- Fuel Tank: Level 4 minimum (300 fuel)
- Drill: Level 3 minimum (hardness 2.5)
- Hull: Level 3 minimum (100 HP)
- Cargo: Level 3+ recommended (20+ slots)

**To Extract Core (500m):**

- Fuel Tank: Level 4-5 (300-500 fuel)
- Drill: Level 4 minimum (hardness 3.5)
- Hull: Level 4 minimum (125+ HP)
- Cargo: Level 3+ (20+ slots for materials + core)
- Recommended: All level 4-5 for comfortable run

### Prestige System

**Soul Crystals Earned:**

- Formula: `totalLifetimeEarnings / 1000 = Soul Crystals`
- Example: 50,000 Bocks earned = 50 Soul Crystals
- First Mars core run typically earns: 40-60 Soul Crystals

**Soul Crystal Bonus:**

- Each crystal: +10% to all mineral values (multiplicative)
- 50 crystals = 5× mineral values (500% of base)
- Applies permanently across all planets
- Never resets, only grows

**What Resets on Prestige:**

- All Bocks (currency) → 0
- All upgrades → Level 1
- Planet progress → Restart from surface
- Consumables → None

**What Persists:**

- Soul Crystals (permanent earning multiplier)
- Unlocked planets (can replay any)
- Golden Gems (premium currency, not earned on Mars)
- Permanent unlocks (scanner, auto-refuel, etc.)

---

## 🔧 Technical Implementation Guide

### Z-Index Layer System

```
Layer hierarchy (back to front):
1. Background (parallax stars) - z=0
2. Far terrain (depth fade effect) - z=1-2
3. Excavated terrain layer - z=4
4. Surface terrain layer - z=5
5. Material deposits:
   - Common (Coal, Iron) - z=10
   - Uncommon (Copper, Silicon) - z=11
   - Rare (Gold) - z=12
   - Special (Dark Matter) - z=15
6. Hazard effects:
   - Gas clouds - z=16
   - Falling debris - z=17
   - Lava/fire effects - z=18
7. Player pod - z=20
8. UI elements:
   - HUD - z=30
   - Warnings - z=31
   - Menus/overlays - z=35
```

### Terrain Generation Algorithm

**Step 1: Generate Base Terrain**

```swift
For each row (0 to 40):
  1. Determine strata type based on depth (y-position)
     [0-10=Sand, 11-20=Stone, 21-30=Rock, 31-40=MarsCore]
  2. Calculate strata-specific colors (surface + excavated)
  3. Generate Perlin noise for organic variation (scale: 0.05)
  4. Apply diagonal flow pattern (15-40° angle)
  5. Add horizontal texture lines (8-12% opacity)
  6. Create SpriteNode for excavated layer (z=4)
  7. Create SpriteNode for surface layer (z=5)
  8. Set initial visibility: surface=visible, excavated=hidden
```

**Step 2: Embed Obstacle Materials**

```swift
For each 16×16 chunk:
  1. Roll for Bedrock (spawn % based on depth)
  2. Roll for Hard Crystal (spawn % based on depth)
  3. Roll for Reinforced Rock (spawn % based on depth)
  4. Place obstacles using clustering algorithm
  5. Ensure navigable paths remain (pathfinding check)
  6. Create obstacle SpriteNodes (z=5, same as surface)
```

**Step 3: Embed Mineable Materials**

```swift
For each 16×16 chunk:
  1. Determine valid materials for current depth
  2. For each material type:
     a. Roll spawn chance (e.g., Coal=60%)
     b. If successful, determine cluster size (1-6 deposits)
     c. Place first deposit at random valid position
     d. Place remaining deposits adjacent (2-3 blocks away)
     e. Create circular gradient sprite for each deposit
     f. Set radius (10-22px based on material)
     g. Apply glow effect (rare materials glow more)
     h. Create SpriteNode (z=10-12 based on rarity)
```

**Step 4: Embed Hazards**

```swift
For each 16×16 chunk:
  1. Roll for gas pockets (spawn % based on depth)
  2. Mark unstable rock blocks (% based on depth)
  3. Store hazard data in metadata (not visible until triggered)
  4. Add subtle visual hints:
     - Gas: shimmer effect in terrain
     - Unstable: crack texture overlay
     - Lava: orange glow through cracks
```

### Mining Mechanics Implementation

**Collision Detection:**

```swift
func onPlayerCollisionWithBlock(block: TerrainBlock) {
    // Check if material deposit present first
    if let material = block.materialDeposit {
        collectMaterial(material)
        removeMaterialSprite(material)
        checkIfBlockFullyMined(block)
    }

    // Check if obstacle
    if block.isObstacle {
        handleObstacle(block) // Bedrock, Hard Crystal, Reinforced Rock
        return
    }

    // Mine terrain
    mineTerrainBlock(block)
}
```

**Drill Animation:**

```swift
func mineTerrainBlock(block: TerrainBlock) {
    // Calculate drill time
    let drillTime = (0.3 * block.strata.hardness) / player.drillLevel

    // Show drilling animation
    showDrillAnimation(duration: drillTime)
    playDrillSound(block.strata.hardness)

    // After drill time elapses:
    Timer.after(drillTime) {
        // Remove surface layer with fade animation
        block.surfaceLayer.run(SKAction.fadeOut(duration: 0.15))

        // Reveal excavated layer
        block.excavatedLayer.isHidden = false

        // Update collision mask
        block.updatePhysicsBody()

        // Check for hazards
        checkHazardsTrigger(block)

        // Spawn particles
        spawnMiningParticles(block.position, block.strata.color)
    }
}
```

**Hazard System:**

```swift
func checkHazardsTrigger(block: TerrainBlock) {
    // Gas pocket
    if block.hasGasPocket {
        dealDamage(block.hazardDamage)
        spawnGasCloud(block.position, duration: 2.0)
        playGasSound()
    }

    // Unstable rock
    if block.isUnstable && random() < block.collapseChance {
        triggerCollapse(block, radius: block.collapseRadius)
        dealDamage(block.hazardDamage)
        shakeScreen()
    }

    // Lava pocket
    if block.hasLava {
        dealDamage(25)
        applyDamageOverTime(5, duration: 3.0)
        spawnLavaEffect(block.position)
    }

    // Random cave-in
    if block.depth > 250 && random() < 0.03 {
        spawnFallingDebris(above: player.position, count: 3-6)
    }
}
```

### Collision Physics

**Player Pod:**

```swift
physicsBody.categoryBitMask = 0x1 << 0 // Player
physicsBody.collisionBitMask = 0x1 << 1 // Terrain
physicsBody.contactTestBitMask = 0x1 << 1 | 0x1 << 2 // Terrain + Materials
```

**Terrain Blocks:**

```swift
// Surface layer (before mining)
physicsBody.categoryBitMask = 0x1 << 1
physicsBody.isDynamic = false

// Excavated layer (after mining)
physicsBody = nil // No collision
```

**Material Deposits:**

```swift
physicsBody.categoryBitMask = 0x1 << 2
physicsBody.isDynamic = false
physicsBody.contactTestBitMask = 0x1 << 0 // Player only
```

### Performance Optimization

**Chunk Loading:**

- Only render chunks within 3 rows of player (±192px)
- Unload chunks when player moves >5 rows away
- Cache chunk data for fast reload

**Sprite Pooling:**

- Reuse particle sprites (dust, sparks, gas clouds)
- Pool common material sprites
- Maximum 500 active sprites at once

**Collision Optimization:**

- Use spatial hash grid for collision detection
- Only check collisions within player radius (128px)
- Disable collision for fully mined blocks

---

## ✅ Comprehensive Implementation Checklist

### Core Terrain System

- [ ] Implement 4-strata depth system (0-125m, 125-250m, 250-375m, 375-500m)
- [ ] Create dual-layer terrain (surface + excavated) for each strata
- [ ] Generate smooth gradient colors using defined color schemes
- [ ] Apply Perlin noise variation (scale 0.05, 10-20% opacity)
- [ ] Add diagonal flow patterns (15-40° angles)
- [ ] Implement horizontal texture overlays (8-12% opacity)
- [ ] Set correct z-index layers (excavated=4, surface=5)
- [ ] Test color contrast between surface and excavated (35-45% darker)

### Drilling Mechanics

- [ ] Implement base drill time formula: `0.3 × hardness / drillLevel`
- [ ] Create hardness values for each strata (1.0, 1.5, 2.5, 3.5)
- [ ] Build drill level upgrade system (Levels 1-5)
- [ ] Add drilling animations scaled to drill time
- [ ] Implement surface layer removal (fade out 0.15s)
- [ ] Reveal excavated layer after drilling
- [ ] Update collision masks after mining
- [ ] Add visual feedback (particles, screen effects)
- [ ] Add audio feedback (varies by hardness)
- [ ] Test drill times match specification table

### Material Generation System

- [ ] Implement chunk-based generation (16×16 blocks)
- [ ] Create spawn chance system per material per strata
- [ ] Build clustering algorithm (1-6 deposits per cluster)
- [ ] Set material radii (10-22px based on material type)
- [ ] Apply gradient rendering for deposits
- [ ] Add glow effects (intensity based on rarity)
- [ ] Implement depth-based material transitions
- [ ] Set correct z-index (common=10, uncommon=11, rare=12)
- [ ] Test spawn rates match specification (Coal 60%, Iron 25%, etc.)

### Obstacle Materials System

- [ ] Implement Bedrock (indestructible, no drill/bomb)
- [ ] Implement Hard Crystal (bomb-only, 800 Bocks)
- [ ] Implement Reinforced Rock (Drill Lv4+ or bomb)
- [ ] Set depth-based spawn rates (3-20% Bedrock, 2-8% Crystal, 3-8% Reinforced)
- [ ] Create clustering patterns for obstacles
- [ ] Ensure navigable paths always exist (pathfinding validation)
- [ ] Add visual distinction (black, purple, gray-silver)
- [ ] Test obstacle density at each depth range

### Hazard System

- [ ] Implement Gas Pockets (5-15% spawn, 5-15 HP damage)
- [ ] Implement Unstable Rock (8-12% blocks, collapse mechanic)
- [ ] Implement Cave-ins (3-8% chance, falling debris)
- [ ] Implement Lava Pockets (5% spawn, 25 HP + DoT)
- [ ] Add visual warnings (shimmer, cracks, glow)
- [ ] Add audio warnings (rumble before collapse)
- [ ] Create hazard effects (gas clouds, sparks, fire)
- [ ] Implement damage-over-time system (lava)
- [ ] Test hazard escalation by depth
- [ ] Balance hazard difficulty (should be dodgeable)

### Material Collection

- [ ] Implement cargo volume system (starts at 10 units)
- [ ] Create material pickup collision detection
- [ ] Add materials to cargo inventory
- [ ] Update cargo UI (show fill percentage)
- [ ] Implement overweight mechanics (can't collect if full)
- [ ] Add material value calculation
- [ ] Test volume system with all material types

### Dark Matter Core

- [ ] Create 10×10 block safe chamber at 490m depth
- [ ] Implement glowing pulsing sphere (0.8-1.2 scale, 2s cycle)
- [ ] Add orange-red gradient with strong glow
- [ ] Make chamber hazard-free (safe zone)
- [ ] Implement core collection trigger
- [ ] Disable teleporter after core collection
- [ ] Force return to surface journey
- [ ] Trigger prestige screen on surface arrival

### Upgrade System

- [ ] Create upgrade shop interface
- [ ] Implement 5 upgrade levels for each stat
- [ ] Set upgrade costs (Tier 1: 500-800, Tier 2: 1500-2500, Tier 3: 4000-7000, Tier 4: 10000-15000)
- [ ] Build Fuel Tank upgrade (100→500 fuel)
- [ ] Build Drill Strength upgrade (1→5, affects drill time)
- [ ] Build Cargo Capacity upgrade (10→30 units)
- [ ] Build Hull Armor upgrade (50→150 HP)
- [ ] Add upgrade requirements checking (can't buy without funds)
- [ ] Save upgrade state between runs

### Prestige System

- [ ] Calculate total lifetime earnings tracker
- [ ] Implement Soul Crystal formula (earnings / 1000)
- [ ] Create prestige confirmation screen
- [ ] Reset Bocks to 0 on prestige
- [ ] Reset all upgrades to Level 1
- [ ] Keep Soul Crystals (permanent)
- [ ] Apply mineral value multiplier (10% per crystal)
- [ ] Test prestige doesn't lose Soul Crystals

### Economy & Balance

- [ ] Set material base values (Coal=10, Iron=25, Copper=30, Silicon=50, Gold=100)
- [ ] Implement selling system at surface
- [ ] Calculate run earnings (materials sold + core value)
- [ ] Subtract fuel/repair costs
- [ ] Test earning progression (250→1000→3500→12000 Bocks per run)
- [ ] Balance upgrade costs to match earning rate
- [ ] Test runs-to-upgrade ratios (1-3 runs per upgrade tier)

### UI/HUD Elements

- [ ] Create depth meter (shows current depth / 500m)
- [ ] Create fuel gauge (visual + numeric)
- [ ] Create HP gauge (visual + numeric)
- [ ] Create cargo meter (volume used / max volume)
- [ ] Add currency display (Bocks)
- [ ] Add warning indicators (low fuel, low HP, full cargo)
- [ ] Create minimap/scanner (if purchased)
- [ ] Test UI visibility and readability

### Performance & Polish

- [ ] Implement chunk loading (±3 rows of player)
- [ ] Implement chunk unloading (>5 rows away)
- [ ] Add sprite pooling (particles, effects)
- [ ] Optimize collision detection (spatial hash grid)
- [ ] Add screen shake effects (explosions, collapse)
- [ ] Add particle systems (dust, sparks, gas)
- [ ] Implement sound effects (drill, explosion, hazards, collection)
- [ ] Add background music
- [ ] Test frame rate (target 60 FPS)
- [ ] Test on target devices (iPhone, iPad)

### Testing & Validation

- [ ] Test full depth run (0-500m)
- [ ] Validate drill times for all hardness levels
- [ ] Verify material spawn rates match specification
- [ ] Confirm hazard frequency and damage values
- [ ] Test economy balance (earnings vs costs)
- [ ] Verify prestige system works correctly
- [ ] Test with all upgrade combinations
- [ ] Ensure no soft-locks (always navigable path)
- [ ] Test edge cases (full cargo, zero fuel, zero HP)
- [ ] Performance test with max entities on screen

---

**Document Status:** Complete specification ready for implementation  
**Last Updated:** October 12, 2025  
**Version:** 2.1 (Corrected scale: 500m depth, 64px = 12.5m)  
**Scale:** 1 block (64px) = 12.5 meters, 40 blocks = 500 meters total
