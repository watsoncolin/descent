# DESCENT - Supply Drop System

## Overview

The Supply Drop system allows players to order consumable items while underground during a run. This prevents being stuck without essential items (especially bombs when blocked by obstacles) but costs double the normal price and requires a risky 30-second wait.

---

## Core Mechanic

### How It Works

**Access:**

- "Emergency Supply" button always visible in HUD (bottom corner)
- Tap to open Supply Drop menu
- Available anytime during run while underground

**Capacity System:**

- **Default capacity**: 5 items per drop
- Can order any combination up to capacity limit
- Upgradeable through Epic Upgrades (up to 20 items)
- Per-item limits prevent loading up on single item type

**Ordering Process:**

```
1. Player opens Supply Drop menu
2. Selects items and quantities (up to capacity limit)
3. Pays 2x normal price for all items immediately (deducted from Credits)
4. 30-second countdown begins
5. Player MUST remain stationary
6. Supply pod drops from top of screen at 0 seconds
7. All items automatically added to inventory
```

**Restrictions:**

- Only consumables available (no upgrades)
- Must have sufficient Credits to pay
- Cannot exceed capacity limit (5-20 items depending on upgrade)
- Cannot exceed per-item limits (see below)
- Cannot order while moving (menu grays out)
- Moving during countdown cancels delivery (no refund!)
- Only one delivery at a time (can't stack orders)

---

## Pricing & Capacity

### Item Pricing

All items cost **2x normal surface price:**

| Item                 | Surface Price | Supply Drop Price | Max Per Order |
| -------------------- | ------------- | ----------------- | ------------- |
| Repair Kit           | $150          | $300              | 3             |
| Fuel Cell            | $200          | $400              | 3             |
| Mining Bomb          | $400          | $800              | 3             |
| Shield Generator     | $600          | $1,200            | 2             |
| Emergency Teleporter | $800          | $1,600            | 2             |

**Why 2x pricing:**

- Expensive enough to discourage spam
- Makes pre-planning valuable
- Rewards good preparation
- Emergency option when needed
- Doesn't break economy

**Per-Item Limits:**

- Common items (bombs, fuel, repair): Max 3 per order
- Expensive items (shields, teleporters): Max 2 per order
- Prevents loading up on single item type
- Encourages balanced orders

### Supply Pod Capacity System

**Total items per drop:**

| Level       | Capacity | Golden Gems Cost | Cumulative Cost |
| ----------- | -------- | ---------------- | --------------- |
| 1 (Default) | 5 items  | 0                | 0               |
| 2           | 8 items  | 3,000            | 3,000           |
| 3           | 12 items | 6,000            | 9,000           |
| 4           | 15 items | 12,000           | 21,000          |
| 5 (Max)     | 20 items | 25,000           | 46,000          |

**Capacity Rules:**

- Total items ordered cannot exceed capacity
- Per-item limits still apply within capacity
- Example: 5 capacity = can't order 5 bombs (max 3 bombs per order)
- Example: 20 capacity = can order 3 bombs + 3 fuel + 3 repair + 2 shields + 2 teleporters = 13 items

**Upgrade Value:**

- Level 1 (5 items): Emergency only, must choose carefully
- Level 3 (12 items): Comfortable restocks, covers most needs
- Level 5 (20 items): Full restock possible, late-game luxury

---

## Delivery Mechanics

### The 30-Second Wait

**Countdown Timer:**

```
┌─────────────────────────────┐
│  📦 SUPPLY DROP INCOMING    │
│                             │
│      ⏱️  23 seconds         │
│                             │
│   ⚠️  REMAIN STATIONARY     │
│                             │
│  Moving will cancel order!  │
└─────────────────────────────┘

Updates every second
Flashes warning if player starts moving
```

**Stationary Requirement:**

- Pod velocity must be < 5 pixels/sec
- Small drifting okay (floating in place)
- Any thrust = cancellation warning
- Move > 2 tiles = order cancelled

**Cancellation:**

```
If player moves too much:
┌─────────────────────────────┐
│  ⚠️  DELIVERY CANCELLED     │
│                             │
│  Supply drop aborted.       │
│  Credits NOT refunded.      │
│                             │
│  Remain still for delivery! │
└─────────────────────────────┘

No refund (paid for delivery attempt)
Can order again immediately
```

### Supply Pod Arrival

**Visual Sequence:**

```
At countdown 5 seconds:
- Warning beep
- Visual indicator appears at top of screen
- Arrow pointing down

At countdown 0:
- Supply pod sprite falls from top
- Small rocket trail
- Lands next to player pod (within 1 tile)
- Small impact effect (dust particles)
- Items automatically collected
- Confirmation message appears

Total animation: ~2 seconds
```

**Audio:**

- Countdown beeps at 10, 5, 3, 2, 1
- Rocket descent sound
- Impact thud
- Satisfying "restock complete" chime

---

## Strategic Depth

### When to Use Supply Drops

**Good Use Cases:**

**1. Blocked by Hard Crystal (No Bombs)**

```
Scenario: 250m deep, hit crystal wall, out of bombs
Capacity: 5 items (default)

Options:
A) Return to surface, end run, restart from 0m
B) Order 2 bombs for $1,600, wait 30 sec, continue

If cargo value > $3,000: Supply drop worth it
Can still order 3 more items if needed (fuel, repair)
```

**2. Low Fuel, Deep Dive**

```
Scenario: 400m deep, 30 fuel left, want to reach core
Capacity: 12 items (upgraded)

Options:
A) Return now (safe but miss core)
B) Order 3 fuel cells + 2 repair kits = 5 items, $2,100

If core extraction worth $10,000+: Worth the risk
Still have 7 capacity left for bombs if needed
```

**3. Complete Emergency Restock**

```
Scenario: 300m deep, low on everything
Capacity: 20 items (max upgrade)

Can order:
- 3 bombs ($2,400)
- 3 fuel cells ($1,200)
- 3 repair kits ($900)
- 2 shields ($2,400)
- 2 teleporters ($3,200)
= 13 items, $10,100

Full restock in one delivery
Still under 20 capacity
Late-game luxury
```

**4. Strategic Capacity Management**

```
Scenario: Need bombs and fuel urgently
Capacity: 5 items (default)

Smart order:
- 3 bombs (max per item) = 3 items
- 2 fuel cells = 2 items
Total: 5 items = $3,200

Uses full capacity efficiently
Prioritizes critical items
Can't fit repairs but that's the tradeoff
```

**3. Critical Hull, Valuable Cargo**

```
Scenario: 15 HP left, carrying $8,000 cargo
Options:
A) Risk return trip (might die, lose cargo)
B) Order repair kit for $300, heal, safe return

Almost always worth it to protect cargo
```

**4. Emergency Escape Path**

```
Scenario: Trapped by cave-in, need bomb to escape
Options:
A) Die, lose cargo
B) Order bomb for $800, blast way out

If cargo worth > $800: Clear choice
```

**Bad Use Cases:**

**1. Early Game, Low Value Run**

```
Carrying $500 cargo
Order $400 fuel cell
Net profit: $100 (not worth it)
Better: Just return and start fresh run
```

**2. Near Surface**

```
At 50m depth
Order $800 bomb for shortcut
Better: Just navigate around, save money
```

**3. Poor Planning**

```
Constantly running out of items
Paying 2x every run
Should: Buy more at surface, plan better
```

---

## Risk/Reward Balance

### The 30-Second Vulnerability

**During the wait, player is exposed to:**

**Hazards:**

- Gas pockets can still damage
- Cave-ins can hit stationary pod
- Environmental damage continues (lava, acid, etc.)
- Can't dodge incoming threats

**Hull Damage Risk:**

```
Waiting in sulfur gas zone (10 HP/sec):
30 seconds × 10 HP/sec = 300 HP damage!
If hull < 300: Will die during wait
Must find safe zone first
```

**Fuel Consumption:**

```
If in environmental hazard zone:
Must thrust against pressure
Fuel depletes during wait
Might run out before delivery arrives
```

**Strategic Positioning:**

- Find safe alcove before ordering
- Clear area of hazards
- Ensure stable position (not falling)
- Plan escape route if things go wrong

---

## UI Design

### Emergency Supply Button

**Location:** Bottom-right corner of HUD (always visible)

```
┌─────────┐
│   📦    │  Idle state: White icon
│ SUPPLY  │
└─────────┘

┌─────────┐
│   📦    │  Active delivery: Pulsing orange
│  23s    │  Shows countdown
└─────────┘
```

### Supply Drop Menu

```
╔═══════════════════════════════╗
║    EMERGENCY SUPPLY DROP      ║
╠═══════════════════════════════╣
║ CAPACITY: 4/5 items           ║ ← Shows used/total
║ [████████░░] 80%              ║    Visual capacity bar
╠═══════════════════════════════╣
║                               ║
║ Mining Bomb          $800 ea  ║
║ [−] 2 [+] (max 3)  = $1,600   ║ ← Quantity selector + limit
║                               ║
║ Fuel Cell            $400 ea  ║
║ [−] 1 [+] (max 3)  = $400     ║
║                               ║
║ Repair Kit           $300 ea  ║
║ [−] 1 [+] (max 3)  = $300     ║
║                               ║
║ Shield Generator   $1,200 ea  ║
║ [−] 0 [+] (max 2)  = $0       ║ ← Grayed out (at capacity)
║                               ║
║ Teleporter         $1,600 ea  ║
║ [−] 0 [+] (max 2)  = $0       ║ ← Grayed out (at capacity)
║                               ║
╠═══════════════════════════════╣
║ TOTAL: $2,300 (2x prices)     ║
║ Your Credits: $4,520          ║
║                               ║
║ 📦 All items in ONE delivery  ║
║ ⏱️  Takes 30 seconds          ║
║ ⚠️  Must remain stationary    ║
║                               ║
║ [ORDER $2,300] [CLEAR] [CLOSE]║
╚═══════════════════════════════╝
```

**Visual Feedback:**

- Items you can't afford: Grayed out
- At capacity: + buttons disabled, items grayed
- Per-item max reached: Shows "(max X)" and disables +
- Capacity bar fills as items added
- Real-time total calculation
- Warning if trying to add when full: "Supply pod capacity full"

### Delivery In Progress Overlay

```
Overlay on screen (semi-transparent):

        ↓ ↓ ↓
    SUPPLY DROP INCOMING
         ⏱️  18s

    ⚠️  STAY STILL
   Movement cancels order

Lower left shows pod velocity:
█ STATIONARY ✓  (green if good)
█ MOVING ⚠️      (red if moving)
```

---

## Tutorial Integration

### First Supply Drop (Teaches Mechanic)

**Trigger:** First time player opens supply drop menu

```
╔════════════════════════════════╗
║   EMERGENCY SUPPLY DROPS       ║
╠════════════════════════════════╣
║ Order supplies mid-run for     ║
║ 2x the normal price.           ║
║                                ║
║ Supply Pod Capacity: 5 items   ║
║                                ║
║ You can order multiple items   ║
║ in one delivery, but can't     ║
║ exceed your pod's capacity.    ║
║                                ║
║ ⚠️  Takes 30 seconds           ║
║ ⚠️  Must stay still            ║
║                                ║
║ 💎 Upgrade capacity with       ║
║    Golden Gems (Epic Upgrades) ║
╚════════════════════════════════╝
        [GOT IT]
```

Shows once, never again (saved in profile)

### When Hitting Capacity Limit

**First time player tries to add item at capacity:**

```
╔════════════════════════════════╗
║   SUPPLY POD FULL              ║
╠════════════════════════════════╣
║ Your supply pod can only carry ║
║ 5 items per delivery.          ║
║                                ║
║ Remove items or adjust         ║
║ quantities to stay under the   ║
║ capacity limit.                ║
║                                ║
║ 💡 TIP: Upgrade Supply Pod     ║
║    Capacity in Epic Upgrades   ║
║    for larger deliveries!      ║
╚════════════════════════════════╝
        [OK]
```

### When Hitting Per-Item Limit

**When trying to exceed per-item maximum:**

```
╔════════════════════════════════╗
║   ITEM LIMIT REACHED           ║
╠════════════════════════════════╣
║ Maximum 3 Mining Bombs per     ║
║ supply drop order.             ║
║                                ║
║ This limit prevents ordering   ║
║ too many of one item type.     ║
╚════════════════════════════════╝
        [OK]
```

---

## Economic Balance

### Supply Drop Economics

**Example Scenario: Bomb Shortage**

```
Situation:
- 250m deep
- Hit hard crystal wall
- Out of bombs
- Carrying $6,000 cargo

Options:

A) Return to surface:
   - End run
   - Sell cargo: $6,000
   - Must restart from 0m
   - Total time: 5 min to get back to 250m

B) Order bomb supply drop:
   - Cost: $800
   - Wait: 30 seconds
   - Continue immediately
   - Total time: 30 seconds

Analysis:
- Supply drop costs $800
- Saves 5 minutes of time
- Can continue deeper (potentially more valuable minerals)
- If die during wait: Lose cargo + $800 (worst case)
- If succeed: Net $5,200 cargo + continue run (best case)

Decision: Usually worth it if cargo > $1,500
```

### Prevents Griefing Yourself

**Problem Supply Drops Solve:**

```
Without supply drops:
1. Hit crystal at 300m, no bombs
2. Return, end run
3. Start new run, drill to 300m again (8 min)
4. Hit ANOTHER crystal, no bombs
5. Repeat infinitely (frustrating!)

With supply drops:
1. Hit crystal at 300m, no bombs
2. Order bomb for $800
3. Wait 30 sec
4. Continue (problem solved)
```

### Pricing Prevents Abuse

**Why 2x price works:**

```
If supply drops were same price as surface:
- No incentive to plan ahead
- Just buy everything mid-run
- Trivializes preparation

At 2x price:
- Expensive enough to avoid spam
- Cheap enough for emergencies
- Rewards planning (buy at surface)
- But available when needed
```

---

## Edge Cases

### Case 1: Order Multiple Items at Once

**Rule:** Multiple items in one order, one delivery

```
Player at 300m, needs multiple things:
- Select 2 bombs
- Select 1 fuel cell
- Select 1 repair kit
Total: 4 items, under 5 capacity ✓
Pay: $3,000 total
Wait: 30 seconds (one delivery)
Receive: All 4 items at once

This is the intended use!
```

### Case 2: Hitting Capacity Limit

```
Player with 5 capacity tries to order:
- 3 bombs (fills 3 slots)
- 2 fuel cells (fills 2 slots)
- Try to add repair kit...

Result: "Supply pod capacity full (5/5)"
+ button disabled for all items
Must remove something to add repair kit

Solution: Remove 1 fuel cell, add 1 repair kit
```

### Case 3: Hitting Per-Item Limit

```
Player tries to order 4 bombs:
- Adds bomb 1 ✓
- Adds bomb 2 ✓
- Adds bomb 3 ✓
- Tries bomb 4...

Result: "Maximum 3 Mining Bombs per order"
+ button disabled for bombs
Counter shows "3 (max 3)"

Can still add other item types up to capacity
```

### Case 4: Low Capacity vs High Needs

```
Early game player (5 capacity) needs:
- 2 bombs (to progress)
- 2 fuel cells (running low)
- 2 repair kits (damaged)
Total: 6 items needed

Problem: Capacity is only 5

Must choose:
Option A: 2 bombs + 2 fuel + 1 repair (prioritize progression)
Option B: 2 bombs + 3 repair (prioritize survival)
Option C: 1 bomb + 2 fuel + 2 repair (balanced, risky on bombs)

This is strategic depth in action!
Incentivizes upgrading capacity
```

### Case 5: Upgraded Capacity Advantage

```
Late game player (20 capacity) in same situation:
- 3 bombs (max)
- 3 fuel cells (max)
- 3 repair kits (max)
- 2 shields (max)
Total: 11 items, $6,300

Under 20 capacity ✓
Could add 2 teleporters if wanted
Essentially a full restock
This is the upgrade payoff!
```

### Case 2: Die During Wait

```
If hull reaches 0 during 30-second wait:
- Order is cancelled
- Credits already spent (no refund)
- Normal death consequences apply
- Lose cargo (unless Ejection Pod)

Lesson: Find safe spot before ordering!
```

### Case 3: Run Out of Credits Mid-Run

```
If Credits drop below supply drop cost:
- Items gray out in menu
- "Insufficient Credits" message
- Must return to surface to sell cargo
- Or use teleporter (if have one)

This is fine - prevents infinite resources
```

### Case 4: Surface During Wait

```
If player returns to surface during countdown:
- Delivery still arrives
- Items added to inventory at surface
- No penalty
- Unusual edge case but handled
```

### Case 5: Moving Slightly (Drift)

```
Tolerance: < 5 pixels/sec velocity
If drifting slowly (gravity, momentum):
- Warning appears: "Minimal movement detected"
- If velocity stays < 5 px/sec: OK
- If exceeds 5 px/sec for > 1 sec: Cancelled

Allows natural floating, prevents active movement
```

---

## Statistics Tracking

**Track for player stats:**

- Total supply drops ordered
- Total Credits spent on supply drops
- Most ordered item
- Times delivery cancelled (moved)
- Times saved by supply drop

**Display in stats:**

```
Supply Drop Statistics:
- Drops Ordered: 47
- Credits Spent: $28,400
- Most Ordered: Mining Bombs (23)
- Deliveries Cancelled: 3
```

Shows how often player relies on emergency supplies

---

## Implementation Checklist

- [ ] Supply Drop button UI (always visible)
- [ ] Supply Drop menu with capacity bar
- [ ] Quantity selectors (+/- buttons) for each item
- [ ] Capacity tracking and visual feedback
- [ ] Per-item limit enforcement
- [ ] Real-time total calculation
- [ ] Order confirmation popup
- [ ] 30-second countdown timer
- [ ] Stationary check (velocity monitoring)
- [ ] Cancellation on movement
- [ ] Supply pod fall animation (all items at once)
- [ ] Item delivery and inventory add (multiple items)
- [ ] Audio (countdown beeps, rocket, impact)
- [ ] Tutorial messages (capacity system, per-item limits)
- [ ] Epic upgrade: Supply Pod Capacity (5 levels)
- [ ] Capacity bar color progression (visual upgrade feedback)
- [ ] Statistics tracking (total orders, items per order avg)
- [ ] Edge case handling (death, at capacity, per-item limits)
- [ ] Testing all capacity scenarios

---

## Future Enhancements

### Possible V2 Features:

**1. Express Delivery**

- Pay 3x price for 10-second delivery
- Ultra-premium emergency option
- Doesn't change capacity limit

**2. Capacity Efficiency Bonus**

- Fill supply pod to 100% capacity: Get 5% discount
- Encourages using full capacity
- Example: 5/5 items = 5% off total

**3. Supply Drop Cooldown Reduction**

- Epic Upgrade: Reduce wait time
  - Level 1: 30 seconds (default)
  - Level 2: 25 seconds (5,000 gems)
  - Level 3: 20 seconds (10,000 gems)
- Makes supply drops less risky

**4. Per-Item Limit Increases**

- Epic Upgrade: Increase max per item
  - Default: 3 bombs max
  - Level 2: 5 bombs max (15,000 gems)
- Works with capacity upgrades for ultimate flexibility

---

## Summary

The Supply Drop system:

- **Solves stuck situations** (out of bombs, blocked path)
- **Adds strategic decisions** (expensive convenience vs planning ahead)
- **Maintains balance** (2x price + 30s vulnerable wait)
- **Prevents frustration** (never truly stuck)
- **Rewards skill** (good players plan, avoid needing drops)
- **Emergency safety net** (always an option when needed)

Players who prepare well rarely need supply drops. Players who get stuck have an expensive but reliable escape option. Perfect balance!
