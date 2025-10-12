# [PLANET NAME] Level Design - DESCENT

**Planet:** [Planet Name]  
**Difficulty:** [Tutorial/Beginner/Easy/Medium/Hard/Expert/Master]  
**Theme:** [Brief description of visual/geological theme]  
**Total Depth:** [XXXXm (XX rows × 64px per block)]  
**Core Location:** [XXXXm depth]  
**Planet Order:** [X of 8]  
**Unlock Requirements:** [Prerequisites - e.g., "Extract Mars core" or "Drill Level 4, Heat Resistance 2"]

---

## 🎨 Visual Design Philosophy

[Describe the overall visual aesthetic and how it differs from other planets. Explain the terrain style, color palette themes, and atmospheric effects that define this planet.]

**Key Visual Elements:**
- [Element 1 - e.g., "Icy crystalline structures"]
- [Element 2 - e.g., "Volcanic lava flows"]
- [Element 3 - e.g., "Bio-luminescent caves"]

**Terrain Style:**
- [Smooth/Rocky/Crystalline/Organic/etc.]
- [Special visual effects unique to this planet]

---

## 🌍 Geological Structure

[Planet Name] features **[X] distinct strata layers** that the player descends through. Each layer has unique terrain composition and embedded material deposits.

### Strata Overview

```
┌────────────────────────────────────────┐
│  STRATA 1: [NAME] (X-Xm)               │  [Brief description]
│    Materials: [Material list]          │
├────────────────────────────────────────┤
│  STRATA 2: [NAME] (X-Xm)               │  [Brief description]
│    Materials: [Material list]          │
├────────────────────────────────────────┤
│  STRATA 3: [NAME] (X-Xm)               │  [Brief description]
│    Materials: [Material list]          │
├────────────────────────────────────────┤
│  STRATA 4: [NAME] (X-Xm)               │  [Brief description]
│    Materials: [Material list]          │
└────────────────────────────────────────┘
```

---

## 🪨 Strata Definitions

### Strata 1: [Name] (X-Xm)

**Terrain Type:** [Sand/Stone/Rock/Ice/Crystal/etc.]  
**Visual Theme:** [Detailed description of appearance]  
**Mining Difficulty:** [Easy/Moderate/Hard/Very Hard]

**Technical Properties:**
- **Hardness:** [X.X] (baseline=1.0, max≈4.0)
- **Drill Speed Modifier:** [X.XX]x ([XX]% vs sand)
- **Minimum Drill Level:** [X] (slow), [X] (comfortable)
- **Base Drill Time:** 0.3 seconds × [hardness] / drillLevel
  - Drill Level 1: [X.XX] sec/block
  - Drill Level 3: [X.XX] sec/block
  - Drill Level 5: [X.XX] sec/block

**Colors:**
```
Surface:    #XXXXXX → #XXXXXX → #XXXXXX ([description])
Excavated:  #XXXXXX → #XXXXXX → #XXXXXX ([description])
Contrast:   ~XX% darker when mined
```

**Visual Details:**
- [Size] variations ([XX-XXpx]) at [XX-XX]% opacity
- [Flow pattern description] ([XX-XX]° angle)
- [Texture description] at [XX]% opacity
- [Overall appearance description]

**Material Deposits:**
- **[Material Name]** - [XX]% spawn rate per chunk
  - Deposit size: [XX-XX]px radius ([X-X] blocks)
  - Clustering: [Small/Medium/Large] clusters of [X-X] deposits
  - Visual: [Color and visual description]
  - Value: [XXX] Bocks/unit, Volume: [X.X]
  - Purpose: [Description of role in economy]

[Repeat for each material in this strata]

**Hazards:**
- **[Hazard Name]** - [XX]% spawn rate per chunk
  - Size: [X-X] blocks ([XX-XX]px)
  - Damage: [XX] HP [+ additional effects]
  - Visual: [Description]
  - Warning: [How player can detect before triggering]

[Repeat for each hazard type]

**Gameplay:**
- [Key gameplay characteristic 1]
- [Key gameplay characteristic 2]
- [Strategy/approach description]
- [Tutorial/learning element if applicable]
- Approximately [XX] rows ([XXX]px depth)

---

### Strata 2: [Name] (X-Xm)

[Repeat full strata structure above]

---

### Strata 3: [Name] (X-Xm)

[Repeat full strata structure above]

---

### Strata 4: [Name] (X-Xm)

[Repeat full strata structure above]

**Special Features:**
- **[Core Name/Type]** - Single occurrence at [XXXX]m depth
  - Location: [XX×XX] block open chamber ([XXX×XXX]px safe zone)
  - Visual: [Detailed description of core appearance]
  - Animation: [Description of visual effects]
  - Value: [XX,XXX] Bocks, Volume: [X.X]
  - Collection triggers prestige system
  - [Any special collection rules]

---

## 🚧 Obstacle Materials System

[Planet Name] features three types of **indestructible or special terrain** that create navigation challenges and strategic decisions.

### Bedrock (Completely Indestructible)

**Visual:** [Color scheme and appearance]  
**Properties:** Cannot drill, cannot bomb, must navigate around  
**Purpose:** Absolute barriers that force maze-like navigation

**Spawn Rates by Depth:**
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])

**Gameplay Impact:**
- [Impact description 1]
- [Impact description 2]
- [Strategic consideration]

---

### Hard Crystal (Bomb-Only)

**Visual:** [Color scheme and appearance with effects]  
**Properties:** Cannot drill, CAN bomb for [XXX] Bocks, can navigate around  
**Purpose:** Economic decision-making (bomb vs. navigate)

**Spawn Rates by Depth:**
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])

**Gameplay Impact:**
- [Impact description 1]
- [Impact description 2]
- [Economic consideration]

---

### Reinforced Rock (High Drill Level Required)

**Visual:** [Color scheme and appearance]  
**Properties:** Requires Drill Level [X]+ OR bomb for [XXX] Bocks  
**Purpose:** Progression gate and upgrade encouragement

**Spawn Rates by Depth:**
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])
- [X-X]m: [XX]% coverage ([description])

**Gameplay Impact:**
- [Impact description 1]
- [Impact description 2]
- [Progression consideration]

---

## 🗺️ Obstacle Distribution Strategy

**Placement Rules:**
1. [Rule 1 - e.g., "Never block all paths"]
2. [Rule 2 - e.g., "Cluster near valuable materials"]
3. [Rule 3 - e.g., "Create interesting cave systems"]
4. [Rule 4 - e.g., "Scale with depth"]
5. [Rule 5 - e.g., "Mix obstacle types"]

**Total Obstacle Coverage by Depth:**
- [Strata 1 name] ([X-X]m): [XX]% ([obstacle types present])
- [Strata 2 name] ([X-X]m): [XX]% ([obstacle types present])
- [Strata 3 name] ([X-X]m): [XX]% ([obstacle types present])
- [Strata 4 name] ([X-X]m): [XX]% ([obstacle types present])

---

## 📊 Material Distribution Summary

| Material | Depth Range | Frequency | Value | Volume | Visual |
|----------|-------------|-----------|-------|--------|--------|
| [Material 1] | [X-X]m | [XX→XX]% | [XXX] | [X.X] | [Description] |
| [Material 2] | [X-X]m | [XX→XX]% | [XXX] | [X.X] | [Description] |
| [Material 3] | [X-X]m | [XX→XX]% | [XXX] | [X.X] | [Description] |
| [Material 4] | [X-X]m | [XX]% | [XXX] | [X.X] | [Description] |
| [Material 5] | [X-X]m | [XX]% | [XXX] | [X.X] | [Description] |
| [Core Material] | [XXXX]m | 1 (unique) | [XX,XXX] | [X.X] | [Description] |

---

## 🎮 Progression Guidelines

### First Run ([X-X]m)
- [What players should focus on]
- [Learning objectives]
- [Expected earnings: ~XXX Bocks]
- [Typical outcome]
- [Recommended first upgrade]

### Runs 2-5 ([X-X]m)
- [Progression focus]
- [New mechanics introduced]
- [Expected earnings: ~X,XXX Bocks per run]
- [Upgrade recommendations]

### Runs 6-10 ([X-X]m)
- [Mid-game focus]
- [Key challenges]
- [Expected earnings: ~X,XXX Bocks per run]
- [Required upgrades to progress]

### Runs 10+ ([X-X]m)
- [End-game focus]
- [Core run preparation]
- [Expected earnings: ~XX,XXX+ Bocks per run]
- [Minimum requirements for core attempt]

---

## ⚙️ Drilling Mechanics Formula

### Core Formula
```
actualDrillTime = baseDrillTime × strataHardness / drillLevel

Where:
- baseDrillTime = 0.3 seconds per block (constant)
- strataHardness = [X.X] to [X.X] (varies by depth)
- drillLevel = 1 to 5 (player upgrade)
```

### Drill Time Table

| Strata | Hardness | Drill Lv1 | Drill Lv2 | Drill Lv3 | Drill Lv4 | Drill Lv5 |
|--------|----------|-----------|-----------|-----------|-----------|-----------|
| [Strata 1] | [X.X] | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s |
| [Strata 2] | [X.X] | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s |
| [Strata 3] | [X.X] | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s |
| [Strata 4] | [X.X] | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s | [X.XX]s |

### Visual/Audio Feedback by Speed

**Fast Drilling (< 0.15s):**
- [Animation description]
- [Sound effect description]
- [Particle effect description]
- [Player feedback]

**Normal Drilling (0.15-0.30s):**
- [Animation description]
- [Sound effect description]
- [Particle effect description]
- [Player feedback]

**Slow Drilling (0.30-0.60s):**
- [Animation description]
- [Sound effect description]
- [Particle effect description]
- [Player feedback]

**Very Slow Drilling (> 0.60s):**
- [Animation description]
- [Sound effect description]
- [Particle effect description]
- [Player feedback - warning indicator]

---

## 📦 Material Generation Rules

### Spawn System

Materials spawn in **chunks** (16×16 block regions, 1024×1024px). Each chunk independently rolls for material spawns based on depth.

### Clustering Algorithm

```
For each material type in current strata:
1. Roll spawn chance (e.g., [Material] = [XX]%)
2. If successful, determine cluster size:
   - Small: [X-X] deposits ([XX]% chance)
   - Medium: [X-X] deposits ([XX]% chance)
   - Large: [X-X] deposits ([XX]% chance)
3. Place first deposit at random valid location
4. Place remaining deposits adjacent (within [X-X] blocks)
5. Apply material-specific radius ([XX-XX]px)
```

### Material Deposit Sizes

| Material | Radius Range | Blocks Occupied | Visual Size |
|----------|--------------|-----------------|-------------|
| [Material 1] | [XX-XX]px | [X-X] blocks | [Size description] |
| [Material 2] | [XX-XX]px | [X-X] blocks | [Size description] |
| [Material 3] | [XX-XX]px | [X-X] blocks | [Size description] |
| [Material 4] | [XX-XX]px | [X-X] blocks | [Size description] |
| [Material 5] | [XX-XX]px | [X-X] blocks | [Size description] |

### Depth-Based Spawn Rates

Materials become more/less common as you descend:

| Material | [X-X]m | [X-X]m | [X-X]m | [X-X]m |
|----------|--------|--------|--------|--------|
| [Material 1] | [XX]% | [XX]% | [X]% | [X]% |
| [Material 2] | [X]% | [XX]% | [XX]% | [X]% |
| [Material 3] | [X]% | [X]% | [XX]% | [XX]% |
| [Material 4] | [X]% | [X]% | [X]% | [XX]% |
| [Material 5] | [X]% | [X]% | [X]% | [X]% |

---

## ⚠️ Hazard Escalation System

### Detailed Hazard Table

| Depth Range | [Hazard 1] | [Hazard 2] | [Hazard 3] | [Hazard 4] |
|-------------|------------|------------|------------|------------|
| **[X-X]m** | [X]% ([X] HP) | [X]% ([X] HP) | [X]% ([X] HP) | [X]% ([X] HP) |
| | [Size/details] | [Size/details] | [Size/details] | [Size/details] |
| **[X-X]m** | [XX]% ([XX] HP) | [X]% ([XX] HP) | [X]% ([X] HP) | [X]% |
| | [Size/details] | [Size/details] | [Size/details] | [Size/details] |
| **[X-X]m** | [XX]% ([XX] HP) | [XX]% ([XX] HP) | [XX]% ([XX] HP) | [X]% ([XX] HP) |
| | [Size/details] | [Size/details] | [Size/details] | [Size/details] |
| **[X-X]m** | [XX]% ([XX] HP) | [XX]% ([XX] HP) | [XX]% ([XX] HP) | [XX]% ([XX] HP) |
| | [Size/details] | [Size/details] | [Size/details] | [Size/details] |

### Hazard Mechanics Details

**[Hazard Type 1]:**
- Spawn rate: [Description]
- Trigger: [How it activates]
- Damage: [Amount and type]
- Visual warning: [What player sees]
- Audio warning: [What player hears]
- Effect: [Additional effects beyond damage]
- Avoidance: [How player can dodge/prevent]

[Repeat for each hazard type]

### Cumulative Danger Levels

| Depth | Combined Hazard % | Avg HP Lost Per Run | Risk Level |
|-------|-------------------|---------------------|------------|
| [X-X]m | [XX]% | [X-XX] HP | [Risk level] |
| [X-X]m | [XX]% | [XX-XX] HP | [Risk level] |
| [X-X]m | [XX]% | [XX-XX] HP | [Risk level] |
| [X-X]m | [XX]% | [XX-XXX] HP | [Risk level] |

*Note: Skilled players who observe warnings can reduce hazard damage by [XX-XX]%*

---

## 🌟 Planet-Specific Mechanics

[Describe any unique mechanics specific to this planet that don't exist elsewhere]

### [Mechanic 1 Name]

**Description:** [What this mechanic does]

**Implementation:**
- [Technical detail 1]
- [Technical detail 2]
- [How it affects gameplay]

**Balance Considerations:**
- [Pro/benefit]
- [Con/challenge]
- [How it interacts with upgrades]

[Repeat for each unique mechanic]

---

## ⏱️ Run Time Estimates

### Time to Drill Full Depth ([XXXX]m = [XX] rows)

Assumptions:
- Mix of all strata ([XX]% each)
- Average path (not straight down)
- Includes movement time between blocks

| Drill Level | Drilling Time | Movement Time | Total Run Time |
|-------------|---------------|---------------|----------------|
| Level 1 | ~[XXX] seconds | ~[XXX] seconds | ~[X] minutes |
| Level 2 | ~[XXX] seconds | ~[XX] seconds | ~[X.X] minutes |
| Level 3 | ~[XX] seconds | ~[XX] seconds | ~[X.X] minutes |
| Level 4 | ~[XX] seconds | ~[XX] seconds | ~[X] minutes |
| Level 5 | ~[XX] seconds | ~[XX] seconds | ~[X.X] minutes |

**Plus:**
- Material collection: +[XX-XX] seconds
- Hazard navigation: +[XX-XX] seconds
- Return to surface: +[XX-XX] seconds

**Total Expected Run Times:**
- **First runs (Drill Lv1)**: [X-X] minutes ([description])
- **Mid-game (Drill Lv3)**: [X-X] minutes ([description])
- **Optimized (Drill Lv5)**: [X-X] minutes ([description])

---

## 💎 Economy Balance & Progression

### Target Earnings Per Run

**Early Game (Runs 1-3):**
- Depth reached: [X-X]m ([strata description])
- Materials collected: [List primary materials]
- Gross earnings: [XXX-XXX] Bocks
- Fuel/repair costs: -[XX] to -[XXX] Bocks
- **Net earnings: [XXX-XXX] Bocks per run**
- Run time: [X-X] minutes

**Mid Game (Runs 4-8):**
- Depth reached: [X-X]m ([strata description])
- Materials collected: [List primary materials]
- Gross earnings: [X,XXX-X,XXX] Bocks
- Fuel/repair costs: -[XXX] to -[XXX] Bocks
- **Net earnings: [X,XXX-X,XXX] Bocks per run**
- Run time: [X-X] minutes

**Late Game (Runs 9-15):**
- Depth reached: [X-X]m ([strata description])
- Materials collected: [List primary materials]
- Gross earnings: [X,XXX-XX,XXX] Bocks
- Fuel/repair costs: -[XXX] to -[X,XXX] Bocks
- **Net earnings: [X,XXX-XX,XXX] Bocks per run**
- Run time: [X-X] minutes

**Core Runs (Runs 15+):**
- Depth reached: Full [XXXX]m ([all strata])
- Materials collected: [List all valuable materials] + [Core name]
- Gross earnings: [XX,XXX-XXX,XXX] Bocks (including [XX,XXX] from core)
- Fuel/repair costs: -[X,XXX] to -[X,XXX] Bocks
- **Net earnings: [XX,XXX-XXX,XXX] Bocks per run**
- Run time: [X-X] minutes (optimized)

### Value Multiplier vs Mars

**Base Multiplier:** [X]× Mars values  
**Explanation:** [Why this planet's materials are more/less valuable]

**Material Value Comparison:**
- [Material 1]: [XXX] Bocks (vs Mars: [XXX])
- [Material 2]: [XXX] Bocks (vs Mars: [XXX])
- [Material 3]: [XXX] Bocks (vs Mars: [XXX])

### Upgrade Cost Scaling

Costs appropriate for this planet's earning rate:

**Tier 1 Upgrades** (Unlocked at start, purchased runs 1-3):
- Fuel Tank Lv2: [XXX] Bocks ([X-X] runs)
- Cargo Capacity Lv2: [XXX] Bocks ([X-X] runs)
- Drill Strength Lv2: [XXX] Bocks ([X-X] runs)
- Hull Armor Lv2: [XXX] Bocks ([X-X] runs)
- [Planet-specific upgrade if any]: [XXX] Bocks

**Tier 2 Upgrades** (Purchased runs 4-8):
- Fuel Tank Lv3: [X,XXX] Bocks ([X] runs)
- Cargo Capacity Lv3: [X,XXX] Bocks ([X] runs)
- Drill Strength Lv3: [X,XXX] Bocks ([X-X] runs)
- Hull Armor Lv3: [X,XXX] Bocks ([X] runs)
- [Planet-specific upgrade if any]: [X,XXX] Bocks

**Tier 3 Upgrades** (Purchased runs 9-15):
- Fuel Tank Lv4: [X,XXX] Bocks ([X] runs)
- Cargo Capacity Lv4: [X,XXX] Bocks ([X] runs)
- Drill Strength Lv4: [X,XXX] Bocks ([X] runs)
- Hull Armor Lv4: [X,XXX] Bocks ([X] runs)
- [Planet-specific upgrade if any]: [X,XXX] Bocks

**Tier 4 Upgrades** (Purchased runs 15+, pre-core):
- Fuel Tank Lv5 (Max): [XX,XXX] Bocks ([X] runs)
- Cargo Capacity Lv5 (Max): [XX,XXX] Bocks ([X] runs)
- Drill Strength Lv5 (Max): [XX,XXX] Bocks ([X] runs)
- Hull Armor Lv5 (Max): [XX,XXX] Bocks ([X] runs)
- [Planet-specific upgrade if any]: [XX,XXX] Bocks

**Consumables:**
- Repair Kit ([XX] HP): [XXX] Bocks
- Fuel Cell ([XX] fuel): [XXX] Bocks
- Bomb (3×3 destroy): [XXX] Bocks
- Teleporter (instant surface): [XXX] Bocks

**Permanent Unlocks** (if introduced on this planet):
- [Unlock name]: [X,XXX] Bocks
- [Unlock name]: [X,XXX] Bocks

### Minimum Upgrade Requirements by Depth

**To Reach [X]m ([Strata X]):**
- Fuel Tank: Level [X] minimum ([XXX] fuel)
- Drill: Level [X] minimum (hardness [X.X])
- Hull: Level [X] minimum ([XXX] HP)
- Cargo: Level [X]+ recommended ([XX]+ slots)
- [Planet-specific requirement if any]

**To Reach [X]m ([Strata X]):**
- Fuel Tank: Level [X] minimum ([XXX] fuel)
- Drill: Level [X] minimum (hardness [X.X])
- Hull: Level [X] minimum ([XXX] HP)
- Cargo: Level [X]+ recommended ([XX]+ slots)
- [Planet-specific requirement if any]

**To Extract Core ([XXXX]m):**
- Fuel Tank: Level [X-X] ([XXX-XXX] fuel)
- Drill: Level [X] minimum (hardness [X.X])
- Hull: Level [X] minimum ([XXX]+ HP)
- Cargo: Level [X]+ ([XX]+ slots for materials + core)
- [Planet-specific requirement]
- Recommended: [Overall upgrade level recommendation]

### Prestige System Impact

**Soul Crystals Earned:**
- Formula: `totalLifetimeEarnings / 1000 = Soul Crystals`
- First [Planet] core run typically earns: [XX-XXX] Soul Crystals
- This is [X]× more than Mars due to [XX]× value multiplier

**Earning Efficiency:**
- With [XX] Soul Crystals from previous planets ([X]× bonus)
- Effective material values are [X]× base
- Target earnings become: [calculation]

---

## 🔧 Technical Implementation Guide

### Z-Index Layer System

```
Layer hierarchy (back to front):
1. Background ([description]) - z=0
2. [Planet-specific background elements] - z=1-2
3. Excavated terrain layer - z=4
4. Surface terrain layer - z=5
5. Material deposits:
   - Common ([materials]) - z=10
   - Uncommon ([materials]) - z=11
   - Rare ([materials]) - z=12
   - Special ([core]) - z=15
6. Hazard effects:
   - [Hazard 1] - z=16
   - [Hazard 2] - z=17
   - [Hazard 3] - z=18
7. [Planet-specific effects] - z=19
8. Player pod - z=20
9. UI elements:
   - HUD - z=30
   - Warnings - z=31
   - Menus/overlays - z=35
```

### Terrain Generation Algorithm

**Step 1: Generate Base Terrain**
```swift
For each row (0 to [XX]):
  1. Determine strata type based on depth (y-position)
     [Strata ranges: 0-X=Strata1, X-X=Strata2, etc.]
  2. Calculate strata-specific colors (surface + excavated)
  3. Generate Perlin noise for organic variation (scale: [X.XX])
  4. Apply [flow pattern description] ([XX-XX]° angle)
  5. Add [texture description] ([X-XX]% opacity)
  6. [Planet-specific generation step if any]
  7. Create SpriteNode for excavated layer (z=4)
  8. Create SpriteNode for surface layer (z=5)
  9. Set initial visibility: surface=visible, excavated=hidden
```

**Step 2: Embed Obstacle Materials**
```swift
For each 16×16 chunk:
  1. Roll for Bedrock (spawn % based on depth)
  2. Roll for Hard Crystal (spawn % based on depth)
  3. Roll for Reinforced Rock (spawn % based on depth)
  4. [Planet-specific obstacle if any]
  5. Place obstacles using clustering algorithm
  6. Ensure navigable paths remain (pathfinding check)
  7. Create obstacle SpriteNodes (z=5, same as surface)
```

**Step 3: Embed Mineable Materials**
```swift
For each 16×16 chunk:
  1. Determine valid materials for current depth
  2. For each material type:
     a. Roll spawn chance (e.g., [Material]=[XX]%)
     b. If successful, determine cluster size ([X-X] deposits)
     c. Place first deposit at random valid position
     d. Place remaining deposits adjacent ([X-X] blocks away)
     e. Create [shape] gradient sprite for each deposit
     f. Set radius ([XX-XX]px based on material)
     g. Apply glow effect ([description])
     h. Create SpriteNode (z=[XX-XX] based on rarity)
```

**Step 4: Embed Hazards**
```swift
For each 16×16 chunk:
  1. Roll for [hazard types based on depth]
  2. Mark [hazard mechanic] blocks (% based on depth)
  3. Store hazard data in metadata (not visible until triggered)
  4. Add subtle visual hints:
     - [Hazard 1]: [visual hint]
     - [Hazard 2]: [visual hint]
     - [Hazard 3]: [visual hint]
```

**Step 5: Planet-Specific Generation** (if applicable)
```swift
[Planet-specific generation steps]
[e.g., "Generate ice crystal formations", "Place bioluminescent plants"]
```

### Mining Mechanics Implementation

**Collision Detection:**
```swift
func onPlayerCollisionWithBlock(block: TerrainBlock) {
    // [Planet-specific collision check if needed]
    
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
    
    // [Planet-specific drill effect if any]
    
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
        
        // Spawn particles ([description of particles])
        spawnMiningParticles(block.position, block.strata.color)
    }
}
```

**Hazard System:**
```swift
func checkHazardsTrigger(block: TerrainBlock) {
    // [Hazard 1]
    if block.has[Hazard1] {
        dealDamage(block.hazardDamage)
        spawn[Hazard1]Effect(block.position, duration: [X.X])
        play[Hazard1]Sound()
    }
    
    // [Hazard 2]
    if block.is[Hazard2] && random() < block.[triggerChance] {
        trigger[Hazard2](block, [parameters])
        dealDamage(block.hazardDamage)
        [additional effects]
    }
    
    // [Hazard 3]
    if block.has[Hazard3] {
        dealDamage([XX])
        [hazard-specific effects]
    }
    
    // [Hazard 4]
    if block.depth > [XXX] && random() < [X.XX] {
        spawn[Hazard4]([parameters])
    }
}
```

**Planet-Specific Mechanics Implementation:**
[Code structure for unique planet mechanics]

### Collision Physics

**Player Pod:**
```swift
physicsBody.categoryBitMask = 0x1 << 0 // Player
physicsBody.collisionBitMask = 0x1 << 1 // Terrain
physicsBody.contactTestBitMask = 0x1 << 1 | 0x1 << 2 // Terrain + Materials
[Planet-specific physics adjustments if any]
```

**Terrain Blocks:**
```swift
// Surface layer (before mining)
physicsBody.categoryBitMask = 0x1 << 1
physicsBody.isDynamic = false
[Planet-specific properties]

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
- Only render chunks within [X] rows of player (±[XXX]px)
- Unload chunks when player moves >[X] rows away
- Cache chunk data for fast reload
- [Planet-specific optimization if needed]

**Sprite Pooling:**
- Reuse particle sprites ([list effect types])
- Pool common material sprites
- Maximum [XXX] active sprites at once
- [Planet-specific pooling needs]

**Collision Optimization:**
- Use spatial hash grid for collision detection
- Only check collisions within player radius ([XXX]px)
- Disable collision for fully mined blocks
- [Planet-specific optimization]

---

## ✅ Comprehensive Implementation Checklist

### Core Terrain System
- [ ] Implement [X]-strata depth system ([depth ranges])
- [ ] Create dual-layer terrain (surface + excavated) for each strata
- [ ] Generate smooth gradient colors using defined color schemes
- [ ] Apply Perlin noise variation (scale [X.XX], [XX-XX]% opacity)
- [ ] Add [flow pattern description] ([XX-XX]° angles)
- [ ] Implement [texture description] ([X-XX]% opacity)
- [ ] Set correct z-index layers (excavated=4, surface=5)
- [ ] Test color contrast between surface and excavated ([XX-XX]% darker)
- [ ] [Planet-specific terrain feature]

### Drilling Mechanics
- [ ] Implement base drill time formula: `0.3 × hardness / drillLevel`
- [ ] Create hardness values for each strata ([X.X, X.X, X.X, X.X])
- [ ] Build drill level upgrade system (Levels 1-5)
- [ ] Add drilling animations scaled to drill time
- [ ] Implement surface layer removal (fade out [X.XX]s)
- [ ] Reveal excavated layer after drilling
- [ ] Update collision masks after mining
- [ ] Add visual feedback ([particle description])
- [ ] Add audio feedback ([sound description])
- [ ] Test drill times match specification table
- [ ] [Planet-specific drilling mechanic if any]

### Material Generation System
- [ ] Implement chunk-based generation (16×16 blocks)
- [ ] Create spawn chance system per material per strata
- [ ] Build clustering algorithm ([X-X] deposits per cluster)
- [ ] Set material radii ([XX-XX]px based on material type)
- [ ] Apply gradient rendering for deposits
- [ ] Add glow effects (intensity based on rarity)
- [ ] Implement depth-based material transitions
- [ ] Set correct z-index (common=[XX], uncommon=[XX], rare=[XX])
- [ ] Test spawn rates match specification ([Material]=[XX]%, etc.)
- [ ] [Planet-specific material if any]

### Obstacle Materials System
- [ ] Implement Bedrock (indestructible, no drill/bomb)
- [ ] Implement Hard Crystal (bomb-only, [XXX] Bocks)
- [ ] Implement Reinforced Rock (Drill Lv[X]+ or bomb)
- [ ] Set depth-based spawn rates ([XX-XX]% Bedrock, [X-X]% Crystal, [X-X]% Reinforced)
- [ ] Create clustering patterns for obstacles
- [ ] Ensure navigable paths always exist (pathfinding validation)
- [ ] Add visual distinction ([color descriptions])
- [ ] Test obstacle density at each depth range
- [ ] [Planet-specific obstacle if any]

### Hazard System
- [ ] Implement [Hazard 1] ([X-XX]% spawn, [X-XX] HP damage)
- [ ] Implement [Hazard 2] ([X-XX]% blocks, [mechanic])
- [ ] Implement [Hazard 3] ([X-X]% chance, [description])
- [ ] Implement [Hazard 4] ([X]% spawn, [XX] HP + [effect])
- [ ] Add visual warnings ([description for each])
- [ ] Add audio warnings ([description for each])
- [ ] Create hazard effects ([visual effects list])
- [ ] Implement damage-over-time system (if applicable)
- [ ] Test hazard escalation by depth
- [ ] Balance hazard difficulty (should be dodgeable with skill)
- [ ] [Planet-specific hazard if any]

### Planet-Specific Mechanics
- [ ] Implement [Unique Mechanic 1]
- [ ] Implement [Unique Mechanic 2]
- [ ] Test interaction with core systems
- [ ] Balance mechanic difficulty
- [ ] Add tutorial/hints for new mechanic
- [ ] [Additional planet-specific items]

### Material Collection
- [ ] Implement cargo volume system (starts at [XX] units)
- [ ] Create material pickup collision detection
- [ ] Add materials to cargo inventory
- [ ] Update cargo UI (show fill percentage)
- [ ] Implement overweight mechanics (can't collect if full)
- [ ] Add material value calculation with planet multiplier
- [ ] Test volume system with all material types

### [Core Name] Core
- [ ] Create [XX×XX] block safe chamber at [XXXX]m depth
- [ ] Implement [visual description of core]
- [ ] Add [animation description]
- [ ] Make chamber hazard-free (safe zone)
- [ ] Implement core collection trigger
- [ ] [Special collection mechanics if any]
- [ ] Force return to surface journey
- [ ] Trigger prestige screen on surface arrival

### Upgrade System
- [ ] Create upgrade shop interface (if first time on this planet)
- [ ] Implement 5 upgrade levels for each stat
- [ ] Set upgrade costs for this planet's economy
- [ ] Build Fuel Tank upgrade ([XXX→XXX] fuel)
- [ ] Build Drill Strength upgrade (1→5, affects drill time)
- [ ] Build Cargo Capacity upgrade ([XX→XX] units)
- [ ] Build Hull Armor upgrade ([XX→XXX] HP)
- [ ] [Planet-specific upgrade if introduced]
- [ ] Add upgrade requirements checking
- [ ] Save upgrade state between runs
- [ ] Test upgrade costs balance with earnings

### Prestige System
- [ ] Calculate total lifetime earnings tracker
- [ ] Implement Soul Crystal formula (earnings / 1000)
- [ ] Create prestige confirmation screen
- [ ] Reset Bocks to 0 on prestige
- [ ] Reset all upgrades to Level 1
- [ ] Keep Soul Crystals (permanent)
- [ ] Apply mineral value multiplier (10% per crystal)
- [ ] Test prestige doesn't lose Soul Crystals
- [ ] Display Soul Crystal count earned from this planet

### Economy & Balance
- [ ] Set material base values ([Material]=[XXX], etc.)
- [ ] Apply planet value multiplier ([X]× Mars)
- [ ] Implement selling system at surface
- [ ] Calculate run earnings (materials sold + core value)
- [ ] Subtract fuel/repair costs
- [ ] Test earning progression ([XXX→X,XXX→XX,XXX] Bocks per run)
- [ ] Balance upgrade costs to match earning rate
- [ ] Test runs-to-upgrade ratios ([X-X] runs per upgrade tier)

### UI/HUD Elements
- [ ] Update depth meter (shows current depth / [XXXX]m)
- [ ] Ensure fuel gauge works at current scale
- [ ] Ensure HP gauge works at current scale
- [ ] Update cargo meter for new volume range
- [ ] Add currency display (Bocks + Soul Crystals)
- [ ] Add warning indicators (low fuel, low HP, full cargo)
- [ ] Update minimap/scanner for new planet
- [ ] [Planet-specific UI element if needed]
- [ ] Test UI visibility and readability

### Performance & Polish
- [ ] Implement chunk loading (±[X] rows of player)
- [ ] Implement chunk unloading (>[X] rows away)
- [ ] Add sprite pooling ([effect list])
- [ ] Optimize collision detection (spatial hash grid)
- [ ] Add screen shake effects ([when applicable])
- [ ] Add particle systems ([list unique particles])
- [ ] Implement sound effects ([list unique sounds])
- [ ] Update background music (planet theme)
- [ ] Test frame rate (target 60 FPS)
- [ ] Test on target devices (iPhone, iPad)
- [ ] [Planet-specific polish items]

### Testing & Validation
- [ ] Test full depth run (0-[XXXX]m)
- [ ] Validate drill times for all hardness levels
- [ ] Verify material spawn rates match specification
- [ ] Confirm hazard frequency and damage values
- [ ] Test economy balance (earnings vs costs)
- [ ] Verify prestige system works correctly
- [ ] Test with all upgrade combinations
- [ ] Ensure no soft-locks (always navigable path)
- [ ] Test edge cases (full cargo, zero fuel, zero HP)
- [ ] Performance test with max entities on screen
- [ ] Test planet-specific mechanics thoroughly
- [ ] Validate progression from previous planet feels natural
- [ ] Test Soul Crystal multiplier effects

---

## 📝 Design Notes

**Planet Personality:** [Describe the "feel" of this planet - is it fast and frantic? Slow and methodical? Strategic and puzzle-like?]

**Difficulty Curve:** [How does this planet's difficulty compare to Mars and other planets?]

**Learning Curve:** [What new skills/concepts does the player need to master?]

**Replayability:** [What makes players want to come back to this planet?]

**Unique Selling Point:** [What makes this planet memorable and distinct from others?]

---

**Document Status:** [Draft/In Progress/Ready for Implementation]  
**Last Updated:** [Date]  
**Version:** [X.X]  
**Designed By:** [Name/Team]