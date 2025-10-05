# DESCENT - Cargo System

## Overview

Cargo is your pod's storage for collected minerals. It's measured in volume units, not item slots. Different minerals take up different amounts of space based on their size/density. When cargo is full, the system automatically drops the lowest value minerals to make room for better finds.

---

## Cargo Capacity

### Base Capacity by Upgrade Level

```
Level 1: 50 units   - $0 (starting)
Level 2: 75 units   - $400
Level 3: 100 units  - $900
Level 4: 150 units  - $2,000
Level 5: 200 units  - $4,500
Level 6: 250 units  - $9,000 (max)
```

### Example Capacity Usage

**With 50 units capacity:**
- 10 Coal (5 units each) = 50 units (full)
- OR 16 Iron (3 units each) = 48 units
- OR 100 Diamonds (0.5 units each) = 50 units
- OR Mix: 5 Coal (25u) + 5 Iron (15u) + 20 Diamonds (10u) = 50 units

---

## Mineral Sizes Reference

### Tier 1: Common Elements (Bulky)
- Carbon (Coal): 5 units
- Iron: 3 units
- Copper: 3 units
- Silicon: 2 units
- Aluminum: 2 units

### Tier 2: Precious Metals (Dense)
- Silver: 2 units
- Gold: 2 units
- Platinum: 2 units
- Titanium: 1.5 units

### Tier 3: Rare Earth & Gems (Small)
- Neodymium: 1.5 units
- Palladium: 1 unit
- Ruby: 0.5 units
- Emerald: 0.5 units
- Diamond: 0.5 units
- Rhodium: 1 unit

### Tier 4: Exotic Materials (Compact)
- Pyronium: 1 unit
- Cryonite: 1 unit
- Voltium: 0.8 units
- Gravitite: 0.5 units
- Neutronium: 0.3 units

### Tier 5: Alien Materials (Ultra-compact)
- Xenite: 0.5 units
- Chronite: 0.4 units
- Quantum Foam: 0.3 units
- Dark Matter: 0.1 units
- Stellarium: 0.05 units

---

## Auto-Drop System

### How It Works

**When collecting a new mineral:**

1. **Check if space is available**
   ```
   if (currentCargo + mineralSize <= maxCargo):
       collect mineral normally
       return
   ```

2. **If cargo is full, calculate space needed**
   ```
   spaceNeeded = (currentCargo + mineralSize) - maxCargo
   ```

3. **Sort current cargo by value per unit (lowest first)**
   ```
   For each mineral in cargo:
       valuePerUnit = (totalValue / totalSize)
   
   Sort ascending (lowest value per unit first)
   ```

4. **Drop lowest value minerals until space is freed**
   ```
   freedSpace = 0
   droppedItems = []
   
   while (freedSpace < spaceNeeded):
       lowestValueItem = cargo.first()
       freedSpace += lowestValueItem.size
       currentCargo -= lowestValueItem.size
       droppedItems.push(lowestValueItem)
       cargo.remove(lowestValueItem)
   ```

5. **Collect the new mineral**
   ```
   cargo.add(newMineral)
   currentCargo += mineralSize
   ```

6. **Show notification**
   ```
   "Dropped [items] for [new mineral]"
   ```

---

## Value Per Unit Calculation

**Formula:**
```
valuePerUnit = totalValue / totalSize

Examples:
- Coal: $10 / 5 units = $2 per unit
- Iron: $25 / 3 units = $8.33 per unit
- Gold: $150 / 2 units = $75 per unit
- Diamond: $800 / 0.5 units = $1,600 per unit
```

**This ensures:**
- Diamonds always kept over coal (even though diamonds are "smaller")
- Auto-drop prioritizes total value density
- Most efficient use of cargo space

---

## Auto-Drop Examples

### Example 1: Basic Replacement

**Current Cargo (50/50):**
- 10 Coal @ $10 each, 5 units = $100 total (50 units used)

**Collect: 1 Gold @ $150, 2 units**

**Auto-Drop Logic:**
```
Space needed: 2 units
Coal value per unit: $10 / 5 = $2/unit
Drop 1 Coal (frees 5 units)

Result:
- Dropped 1 Coal
- Collected 1 Gold
- New cargo: 9 Coal + 1 Gold = 47/50 units, $240 value
```

---

### Example 2: Multiple Items Dropped

**Current Cargo (50/50):**
- 5 Coal @ $10 each, 5 units = $50 total (25 units)
- 5 Iron @ $25 each, 3 units = $125 total (15 units)
- 5 Copper @ $30 each, 3 units = $150 total (15 units)

**Collect: 10 Diamonds @ $800 each, 0.5 units = $8,000 total (5 units needed)**

**Auto-Drop Logic:**
```
Space needed: 5 units

Sorted by value per unit:
1. Coal: $2/unit
2. Iron: $8.33/unit
3. Copper: $10/unit

Drop 1 Coal (frees 5 units)

Result:
- Dropped 1 Coal
- Collected 10 Diamonds
- New cargo: 4 Coal + 5 Iron + 5 Copper + 10 Diamonds = 50/50 units, $8,525 value
```

---

### Example 3: Won't Collect Worse Items

**Current Cargo (50/50):**
- 25 Diamonds @ $800 each = $20,000 total (12.5 units)
- 15 Gold @ $150 each = $2,250 total (30 units)
- Remaining space: filled with platinum

**Try to collect: Coal @ $10, 5 units**

**Auto-Drop Logic:**
```
Coal value per unit: $2/unit
Lowest current value per unit: Gold at $75/unit

Coal is worse than everything in cargo!

Result: Don't collect coal, show message: "Coal ignored (low value)"
```

---

### Example 4: Planet Multiplier Effect

**On Venus (25x multiplier) with 1000% Soul Crystal bonus (11x total = 275x):**

**Current Cargo (200/200):**
- 20 Coal @ $10 base × 275 = $2,750 each (100 units)
- 30 Iron @ $25 base × 275 = $6,875 each (90 units)

**Collect: 1 Pyronium @ $1,500 base × 275 = $412,500, 1 unit**

**Auto-Drop Logic:**
```
Pyronium value per unit: $412,500/unit
Coal value per unit: $2,750 / 5 = $550/unit

Drop 1 Coal (frees 5 units)

Result:
- Dropped 1 Coal ($2,750 lost)
- Collected 1 Pyronium ($412,500 gained)
- Net gain: $409,750 (obvious choice!)
```

---

## Visual Feedback

### When Auto-Drop Occurs

**On-Screen Notification:**
```
┌─────────────────────────┐
│  CARGO AUTO-MANAGED     │
│                         │
│  Dropped: 2 Coal        │
│  Collected: 1 Gold      │
└─────────────────────────┘

Appears for 2 seconds, fades out
```

**Dropped Mineral Visual:**
- Small sprite of dropped mineral appears behind pod
- Fades and falls away (not collectible)
- Quick animation (0.5 seconds)
- Shows what was dropped

**Cargo Bar Update:**
- Real-time bar fill animation
- Smooth transition as items drop/add
- Color codes:
  - Green: < 80% full
  - Yellow: 80-95% full
  - Red: 95-100% full

**Sound Effects:**
- Soft "whoosh" when dropping items
- Satisfying "clink" when collecting
- Different pitch for different mineral tiers

---

## Edge Cases

### Case 1: Need to drop multiple types

**Scenario:**
- Cargo full of mixed low-value items
- Collect large high-value item (e.g., Stellarium at 0.05 units but need to free 10 units of junk)

**Behavior:**
```
Keep dropping lowest value items until enough space

Example:
- Drop 2 Coal (10 units freed)
- Still need space, drop 1 Iron (3 units)
- Etc.

Show: "Dropped Coal x2, Iron x1 for Stellarium"
```

---

### Case 2: Exact tie in value per unit

**Scenario:**
- Two minerals have identical value per unit
- Need to drop one

**Behavior:**
```
Use secondary sort criteria:
1. Value per unit (primary)
2. Total value (secondary - drop smaller total value first)
3. Collection order (tertiary - drop oldest first)

This ensures consistent, predictable behavior
```

---

### Case 3: Cargo full, find worse mineral

**Scenario:**
- Cargo full of Diamonds
- Drill through Coal

**Behavior:**
```
Coal value per unit < Diamond value per unit
Don't collect coal
Don't show notification (would spam)
Coal is destroyed/drilled as normal, just not collected

Optional: Flash cargo icon yellow to indicate "ignored mineral"
```

---

### Case 4: Radioactive materials

**Scenario:**
- Radioactive Crystal: $400, 1 unit = $400/unit
- This is decent value per unit!
- But damages 1 HP/sec

**Behavior:**
```
Auto-drop treats it like any other mineral (by value only)
Might keep it over Coal/Iron
Player must decide: Accept damage or manually drop later

Future hybrid mode: Can mark radioactive as "never auto-collect"
```

---

## Cargo UI Display

### Main HUD (During Run)

```
┌──────────────────────────┐
│ CARGO: 45/50 units       │
│ [████████████░░] 90%     │
│ VALUE: $3,250            │
└──────────────────────────┘
```

**Color coding:**
- Green bar: < 80%
- Yellow bar: 80-95%
- Red bar: 95-100%
- Flashing red: 100% (auto-dropping likely)

---

### Detailed Cargo View (Optional, tap to expand)

```
┌─────────────────────────────┐
│   CARGO DETAILS (45/50)     │
├─────────────────────────────┤
│ Diamond x10    | $8,000     │
│ Gold x3        | $450       │
│ Iron x5        | $125       │
│ Coal x2        | $20        │
├─────────────────────────────┤
│ Total: $8,595               │
└─────────────────────────────┘

Sorted by value (highest first)
Shows what player is carrying
Can tap item to see stats
```

---

## Tutorial / First Time Experience

**First time cargo fills (usually Run 2-3):**

```
╔════════════════════════════╗
║     CARGO FULL!            ║
╠════════════════════════════╣
║ Your cargo is full!        ║
║                            ║
║ I automatically dropped    ║
║ 2 Coal to collect 1 Gold   ║
║                            ║
║ Lower value minerals are   ║
║ automatically dropped for  ║
║ higher value finds.        ║
║                            ║
║ TIP: Upgrade CARGO         ║
║ CAPACITY to carry more!    ║
╚════════════════════════════╝
       [GOT IT]
```

Shows once, never again (saved in player profile)

---

## Statistics Tracking

**Track for player stats:**
- Total minerals auto-dropped (count)
- Total value auto-dropped ($)
- Most valuable single auto-drop
- Most common auto-dropped mineral type

**Display in stats screen:**
```
Auto-Drop Statistics:
- Items Dropped: 1,247
- Value Dropped: $45,320
- Most Dropped: Coal (823 times)
```

Shows player the system is working and saving them better stuff

---

## Performance Considerations

### Optimization Tips

**Don't recalculate every frame:**
```
Only calculate value per unit when:
1. Collecting new mineral
2. Cargo composition changes

Cache results between calculations
```

**Batch drops:**
```
If need to drop multiple of same type, drop all at once
Don't animate each individual drop
Show single notification: "Dropped Coal x5"
```

**Limit notifications:**
```
If auto-dropping constantly (cargo always full):
- Show notification every 5th drop
- Or combine: "Auto-dropped 15 items" after run
Prevents notification spam
```

---

## Future Enhancements (Hybrid Mode)

When implementing hybrid mode later, add:

**Manual Cargo Management:**
- Cargo Manager screen
- Tap items to drop manually
- Lock items to prevent auto-drop
- Sort/filter options

**Settings:**
- Toggle auto-drop on/off
- Set auto-drop threshold (drop at 90% vs 100%)
- Notification preferences

**Advanced Features:**
- Mark mineral types as "never collect"
- Auto-sell common materials at surface
- Cargo loadout presets

---

## Implementation Checklist

- [ ] Cargo data structure (array of minerals with value, size, type)
- [ ] Current cargo tracking (units used / max units)
- [ ] Value per unit calculation function
- [ ] Auto-drop algorithm (sort and remove lowest value)
- [ ] Collection logic (check space, drop if needed, collect)
- [ ] Visual notification system
- [ ] Cargo UI display (bar + value)
- [ ] Sound effects (drop, collect)
- [ ] Tutorial message (first cargo full)
- [ ] Statistics tracking
- [ ] Edge case handling (ties, worse minerals, etc.)
- [ ] Testing with different scenarios

---

## Summary

The auto-drop cargo system:
- **Automatically optimizes** mineral collection
- **Prioritizes value density** ($ per unit)
- **Provides clear feedback** when dropping items
- **Simplifies gameplay** for mobile experience
- **Encourages cargo upgrades** (more space = less dropping)
- **Future-proof** for hybrid manual mode later

Players can focus on exploring and mining, not micromanaging inventory!