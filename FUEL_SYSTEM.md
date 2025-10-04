# DESCENT - Fuel System

## Overview

Fuel is the primary resource management mechanic in DESCENT. It depletes during movement and drilling, forcing players to balance exploration depth against safe return capability. Running out of fuel doesn't kill you, but triggers an emergency return with cargo penalties.

---

## Fuel Consumption Rules

### 1. Movement Consumption (Active Thrust)

**Formula:**
```
fuelPerSecond = baseFuelConsumption × thrustIntensity × zoneModifier

Where:
- baseFuelConsumption = 0.5 fuel/second (baseline)
- thrustIntensity = 0.0 to 1.0 (based on distance from finger to pod)
- zoneModifier = environmental effects (see below)
```

**Thrust Intensity Calculation:**
```
thrustIntensity = min(1.0, distanceToFinger / maxThrustDistance)

Where:
- distanceToFinger = pixels between touch point and pod center
- maxThrustDistance = 150 pixels (full thrust beyond this)
```

**Examples:**
- Finger 150+ pixels away (max thrust): 0.5 fuel/sec
- Finger 75 pixels away (half thrust): 0.25 fuel/sec
- Finger 30 pixels away (gentle): 0.1 fuel/sec
- Not touching screen (gravity only): 0 fuel/sec

**Key Insight:** Gentle, precise movements consume less fuel. Aggressive thrust drains quickly.

---

### 2. Drilling Consumption

**Formula:**
```
fuelPerTile = baseDrillCost × strataHardness / drillLevel

Where:
- baseDrillCost = 0.2 fuel per tile
- strataHardness = 1.0 to 3.5 (varies by strata layer)
- drillLevel = 1 to 5 (player upgrade)
```

**Examples by Strata:**

| Strata | Hardness | Drill Lv1 | Drill Lv3 | Drill Lv5 |
|--------|----------|-----------|-----------|-----------|
| Surface Regolith | 1.0 | 0.20 fuel | 0.07 fuel | 0.04 fuel |
| Basalt Shield | 2.0 | 0.40 fuel | 0.13 fuel | 0.08 fuel |
| Dense Mantle | 3.0 | 0.60 fuel | 0.20 fuel | 0.12 fuel |
| Pre-Core Mantle | 3.5 | 0.70 fuel | 0.23 fuel | 0.14 fuel |

**Key Insight:** Drill upgrades dramatically reduce fuel consumption in hard rock. Essential for deep dives.

---

### 3. Environmental Zone Modifiers

**High Pressure Zones** (Mars 300m+, most planets deep zones)
```
zoneModifier = 1.1 (10% more fuel consumption)
```

**Corrosive Gas Zones** (Venus specific zones)
```
zoneModifier = 2.0 (doubles fuel consumption)
Visual: Yellow-green gas clouds
Warning: "CORROSIVE ATMOSPHERE" indicator
```

**Low Gravity Zones** (Luna entire planet)
```
zoneModifier = 0.7 (30% less fuel consumption)
Bonus: Easier movement, more fuel efficient
```

**Atmospheric Pressure** (Venus surface, Titan)
```
zoneModifier = 1.2 to 1.5 (20-50% more fuel at surface)
Decreases with depth as you go underground
```

---

## Fuel Capacity by Upgrade Level

**Base Stats:**
```
Level 1: 100 fuel  - $0 (starting)
Level 2: 150 fuel  - $500
Level 3: 200 fuel  - $1,200
Level 4: 300 fuel  - $2,500
Level 5: 400 fuel  - $5,000
Level 6: 500 fuel  - $10,000 (max)
```

**Estimated Travel Distance per Fuel Level:**
- Level 1 (100 fuel): ~200m depth (one-way with drilling)
- Level 2 (150 fuel): ~300m depth
- Level 3 (200 fuel): ~400m depth
- Level 4 (300 fuel): ~600m depth (can reach Mars core with return)
- Level 5 (400 fuel): ~800m depth
- Level 6 (500 fuel): ~1000m depth (needed for Mercury/Enceladus)

---

## Fuel Warning System

**Warning Stages:**

**Stage 1: Low Fuel (25% remaining)**
- Fuel gauge turns yellow
- Soft warning beep every 5 seconds
- HUD message: "LOW FUEL"
- Recommended action: Begin return

**Stage 2: Critical Fuel (10% remaining)**
- Fuel gauge turns red and flashes
- Continuous warning alarm (can be muted)
- HUD message: "CRITICAL FUEL - RETURN NOW"
- Screen edges pulse yellow
- Recommended action: Immediate return or use fuel cell

**Stage 3: Emergency (5% remaining)**
- Fuel gauge flashing red rapidly
- Urgent alarm sound
- HUD message: "FUEL DEPLETED - EMERGENCY RETURN"
- Large center screen warning
- Recommended action: Drop non-essential cargo, return immediately

**Stage 4: Depleted (0% remaining)**
- Emergency return sequence begins automatically
- See "Fuel Depletion" section below

---

## Fuel Depletion (0 Fuel)

**What Happens:**

1. **Thrust Disabled**
   - Cannot move pod manually
   - Gravity continues to pull downward
   - Cannot drill new terrain

2. **Emergency Return Activates**
   - Automatic system engages
   - Pod begins slow upward float using reserve power
   - Speed: ~5 meters/second (slow but steady)
   - Cannot be controlled - fully automated

3. **Return Duration**
   - Surface from 100m: ~20 seconds
   - Surface from 300m: ~60 seconds
   - Surface from 500m: ~100 seconds (1.5 minutes)
   - Player must wait helplessly

4. **Cargo Penalty**
   - Lose 50% of collected minerals (by volume)
   - Game randomly removes minerals to reduce cargo by half
   - If Cargo Insurance Epic Upgrade active: Only lose 25%
   - Remaining minerals are kept and can be sold

5. **Hull Impact Risk**
   - If pod hits terrain during emergency ascent at high speed
   - Can still take impact damage
   - If hull reaches 0 during return: Death (see Hull System doc)

6. **Surface Arrival**
   - Pod lands safely at surface station
   - Run ends, proceed to sell minerals screen
   - Fuel refills for next run

**Visual/Audio During Emergency Return:**
- HUD shows "EMERGENCY RETURN IN PROGRESS"
- Countdown shows estimated time to surface
- Cargo loss indicator shows what's being jettisoned
- Calm, automatic voice: "Emergency systems engaged. Returning to surface."
- Blue emergency lights on pod

---

## Fuel Restoration

**Between Runs:**
- Fuel automatically refills to max capacity for free
- If Auto-Refuel Epic Upgrade owned: Instant, no confirmation
- If not owned: Must click "Refuel" button on surface screen

**During Run (Consumables):**

**Fuel Cell Item:**
- Cost: $200 (bought at surface)
- Effect: Restores 100 fuel instantly
- Usage: Tap fuel cell button on HUD
- Strategic use: Emergency backup for deep dives
- Can carry multiple

---

## Fuel Management Strategies

### Conservative Strategy
**Goal:** Never run out, always safe

**Approach:**
- Keep 40-50% fuel for return trip
- Return when fuel hits 50%
- Use fuel cells as insurance, not primary fuel
- Slower progression but no risk

**Best For:**
- Early game when learning
- Expensive cargo runs
- Low drill level (drilling costs more fuel)

---

### Calculated Strategy  
**Goal:** Optimize fuel usage mathematically

**Approach:**
- Calculate fuel needed for return: depth × 2 × avg cost per meter
- Add 20% safety buffer
- Return exactly when buffer is reached
- Use fuel cells if miscalculated

**Formula:**
```
returnThreshold = currentDepth × 2 × (movementCost + drillingCost) × 1.2

Where:
- movementCost ≈ 0.5 fuel per 10 meters
- drillingCost varies by strata hardness
- 1.2 = 20% safety buffer
```

**Best For:**
- Mid-game with stable upgrades
- Players good at mental math
- Maximizing each run efficiency

---

### Aggressive Strategy
**Goal:** Maximum depth/minerals per run

**Approach:**
- Push to 10-15% fuel before returning
- Accept emergency return as viable option
- Carry 2-3 fuel cells for emergencies
- Drop low-value cargo if needed to reduce fuel cost

**Risk:**
- 50% cargo loss if emergency return triggers
- Potential death if hull also critical
- Stressful gameplay

**Best For:**
- Late game with max fuel capacity
- Players with Cargo Insurance Epic Upgrade
- Speed running, high-stakes runs

---

### Free-Fall Strategy
**Goal:** Minimize fuel use via gravity

**Approach:**
- Let gravity pull you down (no thrust)
- Only thrust to avoid hazards
- Drill straight down when possible
- Save fuel for return trip

**Pros:**
- Can reach extreme depths with low fuel capacity
- Very fuel efficient descent

**Cons:**
- High impact damage risk (need good dampeners)
- Less control, harder to target minerals
- Dangerous in hazard-heavy zones

**Best For:**
- Players with Impact Dampener Level 3
- Core rush attempts
- Low fuel, high hull builds

---

## Fuel Efficiency Tips

1. **Upgrade Engine Speed Early**
   - Higher speed = less time moving = less fuel per distance
   - One of best fuel efficiency upgrades

2. **Upgrade Drill Strength**
   - Lower drilling fuel cost in hard rock
   - Essential for deep zones

3. **Use Gravity Wisely**
   - Don't fight gravity going down
   - Gentle course corrections only
   - Save thrust for upward movement

4. **Plan Your Path**
   - Drill straight down when possible
   - Avoid zigzagging (wastes fuel)
   - Target mineral clusters to minimize drilling

5. **Avoid Corrosive Zones**
   - On Venus, navigate around yellow-green gas
   - Doubling fuel cost is punishing

6. **Carry Fuel Cells**
   - 2-3 fuel cells = 200-300 extra fuel
   - Costs $400-600 but enables deeper dives
   - Think of as "fuel capacity temporary upgrade"

7. **Know Your Limits**
   - Each upgrade tier has a natural max depth
   - Don't push beyond your fuel capacity
   - Better to make 2 safe runs than 1 failed run

---

## Fuel Economics

**Fuel vs Cargo Tradeoff:**

Example: Mars run with 200m depth goal
- Fuel spent going down: ~30 fuel
- Fuel spent drilling: ~40 fuel (varies by path)
- Fuel spent going up: ~30 fuel
- Total: ~100 fuel minimum

If you push to 300m:
- Total fuel needed: ~150 fuel
- But cargo contains more valuable minerals (gold, platinum)
- Risk/reward: Is the extra value worth potentially losing 50%?

**Fuel Cell Economics:**

Fuel cell cost: $200
Average cargo value at 300m: ~$3,000

If emergency return triggered:
- Lose 50% cargo = $1,500 lost
- Fuel cell would have prevented this
- Net: Spent $200 to save $1,500 = $1,300 gain

**Lesson:** Fuel cells are insurance. Buy them for high-value runs.

---

## Advanced Mechanics

### Fuel Regeneration (Future Feature?)
Consider adding Epic Upgrade: "Micro Fusion Reactor"
- Regenerates 0.5 fuel/second when stationary
- Can hover in safe zones to refuel slowly
- High cost (50,000 Golden Gems)
- Late-game quality of life

### Fuel Trading (Future Feature?)
Allow selling excess fuel cells back at 50% value
- Buy for $200, sell for $100
- Let players liquidate unneeded consumables

### Fuel Efficiency Stat
Track and display:
- "Fuel Efficiency: 85%" (how much of max depth you reached per fuel used)
- Encourages optimized play
- Leaderboard potential

---

## Testing Checklist

- [ ] Fuel depletes correctly during movement
- [ ] Fuel depletes correctly during drilling
- [ ] Environmental modifiers work (pressure, corrosive, low-gravity)
- [ ] Warning stages trigger at correct percentages
- [ ] Emergency return activates at 0 fuel
- [ ] 50% cargo loss applied correctly
- [ ] Cargo Insurance reduces loss to 25%
- [ ] Fuel cells restore 100 fuel instantly
- [ ] Auto-refuel works between runs
- [ ] Can die from impact during emergency return
- [ ] UI displays fuel accurately
- [ ] Warning sounds/visuals work

---

## Summary

Fuel is DESCENT's core resource management mechanic. It creates tension, forces planning, and provides natural depth gates. The emergency return system ensures failure isn't punishing (no permadeath), but cargo loss creates meaningful consequences. Master fuel management to maximize profits and reach the deepest zones.