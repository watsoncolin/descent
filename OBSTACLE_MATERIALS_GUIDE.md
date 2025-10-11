# DESCENT - Obstacle Materials Guide

## Overview

Three types of indestructible/special materials appear throughout planets to create navigation challenges. Each has unique properties and requires different strategies to overcome.

---

## Material Types

### 1. Bedrock (Completely Indestructible)

**Appearance:**
- Very dark gray to black color (#1a1a1a)
- Rough, cracked texture
- Heavy, impenetrable look
- Thick black borders
- No glow or shimmer

**Properties:**
- **Cannot be drilled** - any drill level
- **Cannot be exploded** - bombs have no effect
- **Must navigate around** - no way through
- Forms maze-like obstacles
- Creates strategic routing challenges

**Sound/Visual Feedback:**
- Drill makes dull "clunk" sound when hitting
- No drilling particles appear
- Pod bounces off slightly on contact
- Visual indicator: "INDESTRUCTIBLE" appears briefly

**When/Where Found:**

**Mars:**
- Appears from Layer 2 (30m) onward
- Increases with depth (3% → 20% coverage)
- Small patches early (3x3 tiles)
- Massive formations deep (20x25 tiles)

**Other Planets:**
- All planets feature bedrock
- Coverage varies by planet difficulty
- Venus/Mercury/Enceladus: Very dense (25%+ in deep layers)
- Luna: Sparse (easier planet)

**Strategic Implications:**
- Forces branching paths
- Must plan routes in advance
- Creates maze-like sections in deep layers
- Often positioned to guard valuable mineral veins
- Can trap players if not careful (always leave escape route)

---

### 2. Hard Crystal Formations (Bomb-Only Breakable)

**Appearance:**
- Iridescent purple-blue color (#8B00FF with gradient)
- Crystalline, faceted surfaces
- Subtle pulsing glow animation (0.5 sec cycle)
- Translucent appearance
- Light emanates from within

**Properties:**
- **Cannot be drilled** - any drill level
- **CAN be destroyed with bombs** - $800 per bomb (supply drop)
- Explosion creates 5x5 clear area
- Strategic choice: bomb through or navigate around
- Often blocks access to valuable areas

**Sound/Visual Feedback:**
- High-pitched "ting" when drill hits
- Drill sparks off surface (no damage to crystal)
- Resonating hum sound (ambient near crystals)
- When bombed: Shatters with satisfying crystal break sound
- Particles: Purple crystal shards fly out

**When/Where Found:**

**Mars Distribution:**
```
Layer 1 (0-30m):     0% - None (tutorial)
Layer 2 (30-80m):    0% - Still learning
Layer 3 (80-150m):   2% - First introduction
Layer 4 (150-220m):  3% - Occasional blocks
Layer 5 (220-300m):  4% - More frequent
Layer 6 (300-380m):  5% - Strategic placement
Layer 7 (380-450m):  8% - Highest density (crystal zone!)
Layer 8 (450-490m):  6% - Core approach
Layer 9 (490-500m):  Walls only - Core entrance
```

**Strategic Placement:**
- Often positioned near valuable minerals (guards diamonds, platinum)
- Blocks shortcuts between areas
- Creates "pay to pass" decision points
- Core entrance typically has crystal walls (must bomb or find passage)

**Other Planets:**
- **Europa**: Ice crystals (blue-white, same mechanics)
- **Io**: Volcanic crystals (orange-red, heat glow)
- **Titan**: Hydrocarbon crystals (amber, translucent)
- **Enceladus**: Pure ice crystals (clear blue, very bright)

**Economic Decision:**
```
Bomb cost: $800 (supply drop)

Scenario A: Crystal blocks path to $5,000 diamond vein
Decision: BOMB (net gain $4,200)

Scenario B: Crystal blocks minor shortcut, alternate path exists
Decision: NAVIGATE (save $800)

Scenario C: Crystal blocks core entrance, no alternate route
Decision: MUST BOMB (required for completion)
```

---

### 3. Reinforced Rock (High Drill Requirement)

**Appearance:**
- Dark gray with metallic silver streaks (#4a4a4a)
- Industrial, man-made looking texture
- Metallic sheen/reflection
- Silver metallic edges
- Looks engineered, not natural

**Properties:**
- **Requires Drill Level 4+** to break through
- Lower drill levels bounce off (cannot drill)
- **CAN be destroyed with bombs** (alternative)
- Acts as soft progression gate
- Encourages drill upgrades

**Sound/Visual Feedback:**
- Metallic "clang" when hitting with insufficient drill
- "DRILL LEVEL 4 REQUIRED" message appears
- With Drill Level 4+: Normal drilling sound but slower
- Sparks fly when drilling (even with high level drill)
- Takes 2x longer to drill than normal rock

**When/Where Found:**

**Mars Distribution:**
```
Layer 1-5 (0-300m):  0% - Not present
Layer 6 (300-380m):  3% - First appearance
Layer 7 (380-450m):  5% - More common
Layer 8 (450-490m):  8% - Frequent gates
Layer 9 (490-500m):  0% - Core is open
```

**Only appears in deep layers (300m+) across all planets**

**Strategic Placement:**
- Guards access to deep valuable zones
- Creates progression checkpoints
- Blocks passages to platinum/gem areas
- Forces upgrade decision: drill or bomb?

**Other Planets:**
- **Venus**: Heat-resistant alloy (black with red veins)
- **Mercury**: Magnetic reinforced plates (silver with blue shimmer)
- **Enceladus**: Cryogenic-hardened ice (dark blue, very dense)

**Progression Gate:**
```
At 300m depth with Drill Level 2:
- Hit reinforced rock wall
- Cannot progress through
- Options:
  A) Bomb through ($800 per section)
  B) Navigate around (time/fuel cost)
  C) Return and upgrade to Drill Level 3+ ($4,500+)
  
Design: Encourages upgrading drill by this point
```

---

## Visual Comparison

### Side-by-Side Appearance

```
BEDROCK          HARD CRYSTAL       REINFORCED ROCK
████████         ◆◆◆◆◆◆◆◆          ▓▓▓▓▓▓▓▓
████████         ◆◆◆◆◆◆◆◆          ▓▓▓▓▓▓▓▓
Black/dark       Purple/blue        Gray/silver
No glow          Pulsing glow       Metallic sheen
Natural          Crystalline        Industrial
```

### Identification at a Glance

**Color Coding:**
- **Dark/Black** = Bedrock (avoid, can't break)
- **Purple/Blue glow** = Crystal (consider bombing)
- **Gray/Silver** = Reinforced (upgrade drill or bomb)

**Visual Hierarchy:**
- Bedrock: Darkest, most imposing
- Crystal: Brightest, most eye-catching
- Reinforced: Industrial, man-made

---

## Interaction Matrix

| Material | Drill Lv1 | Drill Lv3 | Drill Lv5 | Bomb | Navigate |
|----------|-----------|-----------|-----------|------|----------|
| Bedrock | ✗ No | ✗ No | ✗ No | ✗ No | ✓ Must |
| Hard Crystal | ✗ No | ✗ No | ✗ No | ✓ Yes | ✓ Can |
| Reinforced Rock | ✗ No | ✗ No | ✓ Yes (slow) | ✓ Yes | ✓ Can |
| Normal Rock | ✓ Slow | ✓ Fast | ✓ Very Fast | ✓ Yes | ✓ Can |

---

## Planet-Specific Variations

### Mars (Base Reference)
- **Bedrock**: Standard black
- **Hard Crystal**: Purple-blue
- **Reinforced Rock**: Gray-silver
- Baseline for comparison

### Luna (Low Obstacle Density)
- **Bedrock**: Gray moon rock (lighter than Mars)
- **Hard Crystal**: Rare, small formations
- **Reinforced Rock**: None (easier planet)
- Overall: Less obstacles, easier navigation

### Io (Volcanic Theme)
- **Bedrock**: Black volcanic basalt (same as Mars)
- **Hard Crystal**: Orange-red volcanic crystals (heat glow)
- **Reinforced Rock**: Heat-resistant alloy (dark red)
- Often near lava flows

### Europa (Ice Theme)
- **Bedrock**: Deep blue-black ice (frozen solid)
- **Hard Crystal**: Clear blue ice crystals (transparent)
- **Reinforced Rock**: Cryogenic-hardened ice (very dark blue)
- Crystalline aesthetic throughout

### Titan (Hydrocarbon Theme)
- **Bedrock**: Black hydrocarbon rock
- **Hard Crystal**: Amber/orange crystallized hydrocarbons
- **Reinforced Rock**: Organic composite material (brown-black)
- Oily, slippery aesthetic

### Venus (Extreme Heat)
- **Bedrock**: Charred black volcanic rock
- **Hard Crystal**: Yellow sulfur crystals (toxic appearance)
- **Reinforced Rock**: Heat-resistant alloy (black with red veins)
- Highest obstacle density

### Mercury (Metallic)
- **Bedrock**: Dark iron-nickel rock
- **Hard Crystal**: Rare, metallic crystals (silver-gold)
- **Reinforced Rock**: Magnetic plates (silver with blue shimmer)
- Metallic theme throughout

### Enceladus (Endgame)
- **Bedrock**: Ultra-dense frozen core material
- **Hard Crystal**: Brilliant clear ice crystals (most beautiful)
- **Reinforced Rock**: Alien-engineered barriers (hints at intelligence)
- Highest difficulty, densest formations

---

## Generation Rules

### Bedrock Formation

**Seed Placement:**
```
bedrockSeeds = floor(layerArea × coveragePercent)

For each seed:
  formationSize = based on depth:
    - Shallow (< 150m): 3x3 to 5x5
    - Medium (150-350m): 8x10 to 12x15
    - Deep (350m+): 15x20 to 20x25
```

**Growth Pattern:**
- Organic blob shapes (not perfect rectangles)
- Can touch/merge with other bedrock
- Never completely blocks all paths
- Minimum 3-tile-wide passages guaranteed

**Validation:**
- Pathfinding algorithm ensures route exists
- If no path: Remove small formations or create passages
- Always at least 2 distinct paths through layer

### Hard Crystal Placement

**Strategic Positioning:**
```
50% near valuable minerals (guards diamonds, platinum)
30% near bedrock edges (compound barriers)
20% random placement (unpredictable)
```

**Formation Sizes:**
- Small: 3x3 (easy to bomb through)
- Medium: 5x5 (standard)
- Large: 7x7 (expensive to clear, multiple bombs)

**Clustering:**
- Can appear in groups (2-3 formations together)
- Creates "crystal fields" in deep zones
- Forces multiple bomb usage or complex navigation

### Reinforced Rock Placement

**Gating Strategy:**
```
Appears only in deep layers (300m+)

Placement priorities:
1. Block passages to gem-rich areas
2. Create chokepoints in key routes
3. Guard access to core approaches
```

**Formation Sizes:**
- Moderate: 4x4 to 6x6 (not huge, but significant)
- Positioned to require decision (drill upgrade or bomb)

---

## Tutorial Integration

### First Bedrock Encounter

**Trigger:** First time drilling hits bedrock (Layer 2, ~30-50m)

```
╔════════════════════════════════╗
║   INDESTRUCTIBLE BEDROCK       ║
╠════════════════════════════════╣
║ You've hit BEDROCK!            ║
║                                ║
║ ⚫ Cannot be drilled            ║
║ ⚫ Cannot be bombed             ║
║                                ║
║ You must navigate around it.   ║
║                                ║
║ Look for alternate paths or    ║
║ drill around the obstacle.     ║
╚════════════════════════════════╝
        [GOT IT]
```

### First Hard Crystal Encounter

**Trigger:** First time hitting hard crystal (Layer 3, ~80-100m)

```
╔════════════════════════════════╗
║   HARD CRYSTAL FORMATION       ║
╠════════════════════════════════╣
║ Your drill can't break through ║
║ these crystalline structures!  ║
║                                ║
║ 💣 Use MINING BOMBS to destroy ║
║    (Costs $400 surface/$800    ║
║     via supply drop)           ║
║                                ║
║ OR navigate around for free.   ║
║                                ║
║ Crystals often guard valuable  ║
║ minerals - bombing may be      ║
║ worth the cost!                ║
╚════════════════════════════════╝
        [GOT IT]
```

### First Reinforced Rock Encounter

**Trigger:** First time hitting reinforced rock with low drill (Layer 6, ~300m)

```
╔════════════════════════════════╗
║   REINFORCED ROCK              ║
╠════════════════════════════════╣
║ This material is too hard for  ║
║ your current drill!            ║
║                                ║
║ 🔧 Upgrade to DRILL LEVEL 4+   ║
║    to break through            ║
║                                ║
║ 💣 Or use MINING BOMBS          ║
║                                ║
║ Reinforced rock appears in     ║
║ deep layers and guards         ║
║ valuable areas.                ║
╚════════════════════════════════╝
        [GOT IT]
```

---

## Player Strategies

### Early Game (Layers 1-3)

**Obstacles:** Minimal bedrock, no crystals yet

**Strategy:**
- Learn to navigate around bedrock
- Build muscle memory for pathfinding
- Obstacles are sparse and easy to avoid

### Mid Game (Layers 4-6)

**Obstacles:** Moderate bedrock, crystals appear, first reinforced rock

**Strategy:**
- Carry 1-2 bombs for emergencies
- Navigate when possible, bomb when valuable
- Start considering Drill Level 3+ upgrade
- Learn to identify which obstacles guard good minerals

### Late Game (Layers 7-9)

**Obstacles:** Dense bedrock, heavy crystals, common reinforced rock

**Strategy:**
- Carry 2-3 bombs minimum (or rely on supply drops)
- Drill Level 4+ essential for reinforced rock
- Complex maze navigation required
- Strategic bombing to create efficient routes
- Accept that some areas are inaccessible without bombs

---

## Summary Table

| Material | Color | Drill? | Bomb? | Navigate? | Depth | Coverage |
|----------|-------|--------|-------|-----------|-------|----------|
| Bedrock | Black | ✗ | ✗ | ✓ Required | All | 3-20% |
| Hard Crystal | Purple | ✗ | ✓ $800 | ✓ Possible | 80m+ | 2-8% |
| Reinforced Rock | Gray-Silver | ✓ Lv4+ | ✓ $800 | ✓ Possible | 300m+ | 3-8% |

---

## Design Philosophy

**Why Three Types:**
1. **Bedrock**: Absolute barriers, pure navigation challenge
2. **Hard Crystal**: Economic decisions, bomb vs navigate
3. **Reinforced Rock**: Progression gates, encourages upgrades

**Prevents:**
- Boring straight-down drilling
- Optimal path memorization
- Ignoring upgrade systems

**Encourages:**
- Spatial awareness and planning
- Resource management (bombs)
- Strategic upgrade choices
- Varied playstyles
