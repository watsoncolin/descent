# DESCENT - Hull System

## Overview

Hull (HP) represents your pod's structural integrity. Unlike fuel, which depletes predictably, hull damage comes from hazards, impacts, and environmental dangers. When hull reaches 0, the pod explodes and the run ends (with potential cargo loss). Hull management is about avoiding damage through skill and preparation.

---

## Hull Capacity by Upgrade Level

**Base Stats:**
```
Level 1: 50 HP   - $0 (starting)
Level 2: 75 HP   - $600
Level 3: 100 HP  - $1,400
Level 4: 150 HP  - $3,000
Level 5: 200 HP  - $6,500 (max)
```

**Survivability by Hull Level:**
- Level 1 (50 HP): 2-3 hazard hits, very fragile
- Level 2 (75 HP): 4-5 hazard hits, early game adequate
- Level 3 (100 HP): 6-8 hazard hits, mid-game comfortable
- Level 4 (150 HP): 10-12 hazard hits, can take risks
- Level 5 (200 HP): 15+ hazard hits, very tanky

---

## Damage Sources

### 1. Impact Damage (Collision/Falling)

**Formula:**
```
impactDamage = max(0, (impactSpeed - damageThreshold) × damageMultiplier)

Where:
- impactSpeed = velocity magnitude when hitting terrain (pixels/second)
- damageThreshold = speed at which damage begins (based on Impact Dampeners)
- damageMultiplier = 0.5 (scaling factor)
```

**Damage Thresholds by Impact Dampener Level:**
```
Level 0: 50 px/sec   - Very fragile, any fall hurts
Level 1: 100 px/sec  - Can handle moderate falls
Level 2: 200 px/sec  - Can handle fast falls
Level 3: ∞ px/sec    - No fall damage ever (terminal velocity safe)
```

**Example Calculations:**

**Scenario 1:** Hit wall at 150 px/sec with Level 0 dampeners
```
(150 - 50) × 0.5 = 50 HP damage
With 50 HP starting hull = instant death!
```

**Scenario 2:** Hit wall at 150 px/sec with Level 1 dampeners
```
(150 - 100) × 0.5 = 25 HP damage
Painful but survivable
```

**Scenario 3:** Hit wall at 250 px/sec with Level 2 dampeners
```
(250 - 200) × 0.5 = 25 HP damage
Still safe despite high speed
```

**Scenario 4:** Hit wall at any speed with Level 3 dampeners
```
0 HP damage always
Can free-fall from any height safely
```

**Key Insight:** Impact Dampeners are critical for aggressive free-fall playstyles. Level 3 is gamechanging.

---

### 2. Hazard Damage

#### Gas Pockets
**Instant burst damage when drilled**

```
Small gas pocket (1-2 tiles):    5 HP
Medium gas pocket (3-5 tiles):  10 HP
Large gas pocket (6-10 tiles):  15 HP
Toxic gas (Venus):              20 HP
```

**Visual Warning:** Gas pockets appear as slightly discolored terrain with subtle bubble/shimmer effect

**Avoidance:** Scanner upgrade shows gas pockets through terrain

---

#### Cave-ins
**Damage per falling rock that hits pod**

```
Each rock: 10 HP (Mars, Luna)
Each rock: 15 HP (Io, Europa)
Each rock: 20 HP (Venus, Mercury, Enceladus)
```

**Trigger Probability:**
- Unstable Rock zones: 10-15% chance per tile drilled
- Fractured Crust: 15% chance
- Dense Mantle: 8% chance but higher damage
- Pre-Core Mantle: 5% chance (safer deep)

**Multiple Rocks:** A single cave-in can drop 2-4 rocks
- Average cave-in: 2 rocks × 10 HP = 20 HP damage
- Bad cave-in: 4 rocks × 15 HP = 60 HP damage (can be devastating!)

**Visual Warning:** 
- Cracks appear in terrain above you
- Rumble sound effect (0.5 seconds before rocks fall)
- Screen shake intensifies

**Avoidance:** Drill slowly in cracked zones, move quickly after drilling

---

#### Lava/Heat Hazards
**Continuous damage per second of contact**

```
Mars lava (decorative):           0 HP/sec (safe, visual only)
Io lava rivers:                  20 HP/sec
Io volcanic vents (burst):       25 HP (instant)
Venus lava pools:                30 HP/sec
Venus ambient heat (no resist):  15 HP/sec (everywhere below surface!)
```

**Heat Resistance Effect:**
```
No resistance:     Full damage
Level 1 resistance: 50% damage (rounds up)
Level 2 resistance: 25% damage
Level 3 resistance: Immune (0 damage)
```

**Example:** Venus ambient heat without resistance
- 15 HP/sec × 60 seconds = 900 HP/minute
- Even max hull (200 HP) = dead in 13 seconds!
- With Level 2 Heat Resistance: 15 × 0.25 = 3.75 = 4 HP/sec = 50 seconds survival

**Key Insight:** Heat/Cold resistance isn't optional for extreme planets, it's mandatory.

---

#### Ice/Cold Hazards
**Continuous damage per second of contact**

```
Europa ice spikes (collision):   20 HP (instant)
Europa freezing water:           15 HP/sec
Titan methane lakes:             25 HP/sec
Enceladus extreme cold:          20 HP/sec (ambient below 200m)
Enceladus cryogenic jets:        50 HP (instant burst)
```

**Cold Resistance Effect:**
- Same as heat resistance (50% / 25% / Immune)

**Visual Warning:**
- Ice spikes are visible, bright blue-white
- Water has distinctive visual (blue-tinted)
- Methane is orange-brown liquid
- Cold zones have frost particle effects

---

#### Environmental (Ambient)
**Continuous damage while in zone**

```
Io sulfur gas clouds:            10 HP/sec
Venus sulfuric acid rain:        10 HP/sec (constant at surface)
Venus corrosive gas zones:       15 HP/sec
Mercury solar radiation:         20 HP/sec (surface only, decreases with depth)
Titan hydrocarbon rain:           5 HP/sec (periodic weather event)
```

**Zone Identification:**
- Visual particle effects (gas clouds, acid rain streaks)
- HUD warning: "HAZARDOUS ENVIRONMENT"
- Damage numbers appear continuously
- Screen edges pulse red

**Avoidance:** Navigate around visible zones, or accept damage as cost of passage

---

#### Special Hazards
**Instant burst damage, unique to specific planets**

```
Io volcanic vent eruption:       25 HP
Mercury meteor impact:           60 HP
Enceladus ice quake:             70 HP
Enceladus alien guardian attack: 80 HP
```

**Volcanic Vents (Io):**
- Random eruptions from floor
- 1 second warning: Orange glow appears
- Shoots upward, pushes pod and damages
- Can chain-trigger multiple vents

**Meteor Impacts (Mercury):**
- Only near surface (top 100m)
- Warning: Shadow appears on ground, grows larger
- 2 seconds to move out of impact zone
- Devastating damage if hit

**Ice Quakes (Enceladus):**
- Random terrain shifts
- Warning: Rumble sound, screen shake increases
- Crushing damage if caught between shifting terrain
- Can create or destroy paths

**Alien Guardians (Enceladus):**
- Rare hostile creatures near core
- Move toward pod when detected
- Melee attack if they touch pod
- Can be avoided by moving quickly

---

### 3. Radioactive Materials in Cargo

**Continuous damage while carrying**

```
damagePerSecond = radioactiveCrystalsInCargo × 1 HP/sec

Examples:
- Carrying 1 radioactive crystal:   1 HP/sec
- Carrying 5 radioactive crystals:  5 HP/sec
- Carrying 10 radioactive crystals: 10 HP/sec (200 HP = 20 sec to death!)
```

**Risk/Reward:**
- Radioactive Crystals worth $400 each (good value)
- But slowly kills you the entire time you carry them
- Must balance: Grab many and rush back, or skip entirely?

**Strategy:**
- Grab them only when near surface (short trip back)
- Or grab at core, use teleporter item to instant-return
- Or have high hull to tank the damage

**Visual Indicator:**
- Geiger counter clicking sound effect (faster = more crystals)
- Green radioactive symbol on HUD
- Hull bar drains with green tint

---

## Hull Damage Warning System

**Warning Stages:**

**Stage 1: Moderate Damage (50% hull remaining)**
- Hull gauge turns yellow
- Visible cracks appear on pod sprite
- Soft warning beep on each new damage
- HUD message: "HULL DAMAGED"
- Pod emits occasional spark particles

**Stage 2: Heavy Damage (25% hull remaining)**
- Hull gauge turns red and pulses
- Heavy damage visible: Large cracks, dents
- Warning beep on each damage (louder)
- HUD message: "CRITICAL HULL DAMAGE"
- Screen edges pulse red on damage
- Pod emits smoke particles continuously

**Stage 3: Critical (10% hull remaining)**
- Hull gauge flashing red rapidly
- Severe damage: Pod looks nearly destroyed
- Urgent alarm sound
- HUD message: "HULL FAILURE IMMINENT"
- Large center-screen warning
- Heavy smoke, sparks flying, fire effects
- Recommended action: Use repair kit or return immediately

**Stage 4: Destroyed (0% hull)**
- Pod explosion sequence begins
- See "Hull Destruction" section below

---

## Hull Destruction (0 HP)

**What Happens:**

1. **Explosion Animation**
   - Pod explodes in dramatic effect
   - Screen shakes violently
   - Flash of light
   - Explosion sound effect
   - Debris particles scatter

2. **Check for Ejection Pod**
   - If Ejection Pod Epic Upgrade owned AND unused this run:
     - **Ejection triggers automatically**
     - Pod warps to surface instantly (blue teleport effect)
     - All cargo is kept (nothing lost!)
     - Hull restored to 25 HP (quarter health)
     - Fuel remains at current level
     - Can continue playing the run
     - Ejection Pod consumed (one use per run)
     - HUD shows: "EJECTION POD ACTIVATED"
   - If no Ejection Pod available:
     - Proceed to death consequences (below)

3. **Death Consequences**
   - Run ends immediately
   - Screen fades to black
   - Death statistics screen appears

4. **Cargo Loss**
   - Check for Cargo Insurance Epic Upgrade:
     - **If owned:** Keep 50% of cargo value
       - Game calculates total value, gives you 50% as Credits
       - Message: "Cargo Insurance recovered $X,XXX"
     - **If not owned:** Lose 100% of cargo
       - All collected minerals are lost
       - No Credits earned from this run
       - Message: "All cargo lost"

5. **Statistics Update**
   - Death count increments
   - Death location recorded (planet, depth)
   - Cause of death recorded (for stats screen)
   - Planet death counter increments

6. **Respawn**
   - Return to surface/upgrade screen
   - Pod fully repaired (max hull)
   - Fuel refilled (max fuel)
   - Cargo empty
   - Can immediately start new run

**No Permadeath:** Death doesn't erase progression
- Keep all Soul Crystals
- Keep all Epic Upgrades
- Keep all Golden Gems
- Keep Credits earned from previous runs
- Only lose current run's cargo

---

## Hull Restoration

**Between Runs:**
- Hull automatically repairs to max for free
- If Auto-Repair Epic Upgrade owned: Instant, no confirmation
- If not owned: Must click "Repair" button on surface screen

**During Run (Consumables):**

**Repair Kit Item:**
- Cost: $150 (bought at surface)
- Effect: Restores 50 HP instantly
- Usage: Tap repair kit button on HUD
- Cannot exceed max hull
- Strategic use: Emergency healing when critical

**Example:**
- Max hull: 100 HP
- Current hull: 20 HP (critical!)
- Use repair kit: 20 + 50 = 70 HP (now safe)

**Can carry multiple repair kits:**
- 3 repair kits = 150 HP healing available
- Costs $450 but enables risky deep dives

---

## Hull Management Strategies

### Tank Strategy
**Goal:** Survive through pure HP

**Approach:**
- Max hull armor first (200 HP priority)
- Buy multiple repair kits (3-5)
- Ignore impact dampeners (use hull to absorb falls)
- Face-tank hazards if needed

**Pros:**
- Very forgiving of mistakes
- Can push through dangerous zones
- Good for learning

**Cons:**
- Expensive (hull upgrades are pricey)
- Repair kits cost money
- Doesn't address root cause (taking damage)

**Best For:**
- New players
- Hazard-heavy planets (Io, Venus)
- Players who take lots of damage

---

### Avoidance Strategy
**Goal:** Don't get hit at all

**Approach:**
- Keep hull at Level 2-3 (adequate, not maxed)
- Invest heavily in Impact Dampeners (Level 3 priority)
- Play carefully, avoid all hazards
- Use scanner to spot dangers

**Pros:**
- More efficient with upgrade spending
- Frees up Credits for other upgrades
- Rewards skill

**Cons:**
- One mistake can be fatal
- Stressful gameplay
- Not viable on hazard-dense planets

**Best For:**
- Skilled players
- Planets with predictable hazards (Mars, Luna)
- Speed runners

---

### Balanced Strategy
**Goal:** Medium hull + damage mitigation

**Approach:**
- Hull at Level 3-4 (100-150 HP)
- Impact Dampeners Level 2
- Carry 1-2 repair kits
- Play moderately carefully

**Pros:**
- Versatile, works everywhere
- Can survive mistakes
- Not too expensive

**Cons:**
- Not optimal at anything
- Still vulnerable to spike damage

**Best For:**
- Most players, most situations
- General progression
- Moderate risk/reward play

---

### Glass Cannon Strategy
**Goal:** Ignore hull entirely

**Approach:**
- Keep hull at Level 1-2 (bare minimum)
- Max Ejection Pod + Cargo Insurance
- Play perfectly or die
- Invest Credits in fuel/cargo/drill instead

**Pros:**
- Maximum other stats
- Ejection Pod = second chance
- Cargo Insurance means death isn't total loss

**Cons:**
- Very high risk
- Requires near-perfect play
- Ejection Pod only works once per run

**Best For:**
- Expert players
- Late game with Epic Upgrades
- Challenge runs

---

## Hull Efficiency Tips

1. **Impact Dampeners Are Crucial**
   - Level 3 = no fall damage ever
   - Enables free-fall playstyle
   - Saves massive hull over time
   - Best upgrade for hull preservation

2. **Visual Hazard Awareness**
   - Gas pockets have subtle shimmer
   - Cracks indicate cave-in zones
   - Lava/water are clearly visible
   - Learn to spot dangers early

3. **Scanner Upgrade**
   - Shows gas pockets through terrain
   - Shows mineral locations
   - Costs 3,000 Golden Gems but worth it
   - Prevents most surprise damage

4. **Slow Down in Dangerous Zones**
   - Fractured Crust: Drill carefully
   - Lava zones: Navigate slowly
   - Unknown areas: Scout before committing

5. **Use Shield Item**
   - Shield item = 10 seconds invincibility
   - Costs $600 but can save a run
   - Use when pushing through hazard gauntlet
   - Use when radioactive cargo is killing you

6. **Know Your Hull Budget**
   - Calculate: "Can I survive X damage?"
   - Example: 50 HP remaining, need to cross lava zone
     - Lava = 20 HP/sec, takes 3 seconds to cross
     - 20 × 3 = 60 HP needed
     - Will die! Must find alternate path or use repair kit

7. **Resistance > Hull**
   - On extreme planets, resistance is mandatory
   - No amount of hull saves you on Venus without Heat Resistance
   - 15 HP/sec ambient = 200 HP dead in 13 seconds
   - Level 2 Resistance = only 4 HP/sec = 50 seconds (doable!)

---

## Hull Economics

**Cost to Max Hull:**
```
Level 1→2: $600
Level 2→3: $1,400
Level 3→4: $3,000
Level 4→5: $6,500
Total: $11,500
```

**Repair Kit Economics:**

Repair kit cost: $150
Average run value: ~$3,000

If repair kit saves the run:
- Prevented cargo loss
- Net: Spent $150 to save $3,000 = $2,850 gain

If used unnecessarily:
- Wasted $150
- But safe is better than sorry

**Lesson:** Carry 1-2 repair kits on valuable runs. Insurance is worth it.

---

## Advanced Mechanics

### Ejection Pod Cooldown (Future Feature?)
Consider: Ejection Pod recharges after X runs
- Current: One use per run
- Alternative: One use per 3 runs (more strategic)
- Or: Permanent but costs Golden Gems to recharge

### Hull Regeneration (Future Feature?)
Epic Upgrade: "Nano-Repair Systems"
- Regenerates 1 HP/second when not taking damage for 5 seconds
- Slow but allows recovery during safe moments
- High cost (50,000 Golden Gems)
- Late-game quality of life

### Damage Type Resistances (Future Feature?)
Separate Epic Upgrades for:
- Impact Resistance (reduce fall damage %)
- Explosive Resistance (reduce burst damage %)
- Environmental Resistance (reduce DoT damage %)
- Adds strategic depth to builds

---

## Testing Checklist

- [ ] Hull depletes correctly from all damage sources
- [ ] Impact damage calculates correctly with dampener levels
- [ ] Gas pockets deal correct damage
- [ ] Cave-ins spawn rocks that damage pod
- [ ] Lava/heat hazards deal continuous damage
- [ ] Heat/cold resistance reduces damage correctly
- [ ] Radioactive cargo deals continuous damage
- [ ] Repair kits restore 50 HP instantly
- [ ] Ejection Pod activates at 0 HP if owned
- [ ] Cargo Insurance keeps 50% value on death
- [ ] Hull warning stages trigger at correct %
- [ ] Visual damage effects appear correctly
- [ ] Death sequence plays correctly
- [ ] Can respawn and start new run
- [ ] Statistics track deaths correctly

---

## Summary

Hull is DESCENT's health system and skill check. Unlike fuel (predictable), hull damage comes from player mistakes, hazards, and risky choices. Managing hull requires awareness, preparation, and strategic upgrade choices. Ejection Pod and Cargo Insurance provide safety nets, but mastering avoidance is the true goal.