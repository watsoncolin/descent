---
tags: [descent, gameplay, resource]
updated: 2026-06-21
---

# Fuel System

Fuel is DESCENT's core resource-management mechanic. It depletes during thrust and drilling, forcing players to trade exploration depth against safe return capability. Running out doesn't kill you — it triggers an automatic [emergency return](#emergency-return-0-fuel) with a cargo penalty. See [[Game Design]] for how this fits the overall loop, and [[Hull and Damage]] for the other failure axis.

> [!note]
> **Movement and drilling fuel are implemented** (rebalanced 2026-06-21) — tuning lives in `K.Fuel` (`Constants.swift`); tank tiers are in `PlanetState`. The warning system and the auto-emergency-return below are **design targets** (not yet implemented). See [[Code Review]] for status.

---

## Consumption model

Fuel drains from three activities: **thrust**, **drilling**, and (indirectly) **environmental zones**. Idle drift under gravity alone costs nothing.

### 1. Movement (active thrust)

```
fuelPerSecond = baseFuelConsumption × thrustIntensity × zoneModifier

Where:
- baseFuelConsumption = 1.5 fuel/second (baseline)
- thrustIntensity = 0.0 to 1.0 (based on distance from finger to pod)
- zoneModifier = environmental effects (see below)
```

Thrust intensity scales with how far the finger is from the pod:

```
thrustIntensity = min(1.0, distanceToFinger / maxThrustDistance)

Where:
- distanceToFinger = pixels between touch point and pod center
- maxThrustDistance = 150 pixels (full thrust beyond this)
```

| Finger distance | Thrust | Rate |
| --- | --- | --- |
| 150+ px (max) | 1.0 | 1.5 fuel/sec |
| 75 px (half) | 0.5 | 0.75 fuel/sec |
| 30 px (gentle) | 0.2 | 0.3 fuel/sec |
| Not touching (gravity only) | 0.0 | 0 fuel/sec |

> [!note]
> Gentle, precise movements sip fuel; aggressive thrust drains it. This is the lever behind the [Free-Fall strategy](#free-fall).

### 2. Drilling

The whole block's fuel is charged **once, up front** when drilling starts — predictable, and
replacing an earlier per-frame drain that scaled *quadratically* with hardness.

```
fuelPerBlock = baseDrillCost × strataHardness / drillLevel

Where:
- baseDrillCost = K.Fuel.baseDrillCost = 1.5 fuel per block
- strataHardness = 1.0 to 3.5 (varies by strata layer)
- drillLevel = 1 to 5 (player upgrade)
```

| Strata | Hardness | Drill Lv1 | Drill Lv3 | Drill Lv5 |
| --- | --- | --- | --- | --- |
| Surface Regolith | 1.0 | 1.5 fuel | 0.5 fuel | 0.3 fuel |
| Basalt Shield | 2.0 | 3.0 fuel | 1.0 fuel | 0.6 fuel |
| Dense Mantle | 3.0 | 4.5 fuel | 1.5 fuel | 0.9 fuel |
| Pre-Core Mantle | 3.5 | 5.25 fuel | 1.75 fuel | 1.05 fuel |

Drill upgrades make blocks both faster *and* cheaper — essential for deep dives. See [[Terrain and Strata]] for the full hardness model.

### 3. Environmental zone modifiers

`zoneModifier` multiplies thrust (and movement) consumption per zone. Planet-specific detail lives in [[Mars]] and sibling planet pages.

| Zone | Modifier | Notes |
| --- | --- | --- |
| High Pressure (Mars 300m+, deep zones) | 1.1 | +10% consumption |
| Corrosive Gas (Venus) | 2.0 | Doubles consumption; yellow-green clouds; "CORROSIVE ATMOSPHERE" warning |
| Low Gravity (Luna, whole planet) | 0.7 | −30% consumption; easier movement |
| Atmospheric Pressure (Venus surface, Titan) | 1.2 – 1.5 | +20–50% at surface, decreases with depth |

---

## Fuel capacity tiers

| Level | Fuel | Cost | Approx. depth (round trip) |
| --- | --- | --- | --- |
| 1 | 100 | $0 (start) | ~100–150m |
| 2 | 250 | $500 | ~250–300m |
| 3 | 500 | $1,200 | ~500–600m |
| 4 | 1000 | $2,500 | ~1000–1100m |
| 5 | 2000 | $5,000 | ~2000–2100m (can reach Mars core) |
| 6 | 4000 | $10,000 (max) | ~4000–4100m (comfortable core runs) |

Costs and depth tradeoffs tie into [[Materials and Economy]].

---

## Warning system

Four staged warnings fire at fixed percentages of max fuel:

| Stage | Trigger | Behavior |
| --- | --- | --- |
| 1 — Low Fuel | 25% remaining | Gauge yellow; soft beep every 5s; "LOW FUEL"; begin return |
| 2 — Critical | 10% remaining | Gauge red + flashing; continuous alarm (mutable); "CRITICAL FUEL - RETURN NOW"; screen edges pulse yellow |
| 3 — Emergency | 5% remaining | Rapid red flash; urgent alarm; "FUEL DEPLETED - EMERGENCY RETURN"; large center warning; drop non-essential cargo |
| 4 — Depleted | 0% remaining | Automatic emergency return begins (below) |

---

## Emergency return (0 fuel)

> [!warning] Not yet implemented
> The designed auto-ascent below is a **target**. Current behavior: hitting 0 fuel ends the
> run immediately (game over) and keeps **50% of cargo value**. Building the auto-return is a
> tracked follow-up in [[Code Review]].

Hitting 0 fuel does **not** kill you — an automated ascent recovers the pod, minus cargo.

1. **Thrust disabled** — no manual movement, no drilling; gravity still pulls down.
2. **Emergency return activates** — pod floats upward on reserve power at ~5 m/sec, fully automated and uncontrollable.
3. **Return duration** — ~20s from 100m, ~60s from 300m, ~100s (1.5 min) from 500m. Player waits.
4. **Cargo penalty** — lose **50% of collected minerals by volume** (randomly removed). With the **Cargo Insurance Epic Upgrade**, only **25%** is lost.
5. **Hull impact risk** — colliding with terrain at high speed during ascent can still deal damage; reaching 0 hull means death (see [[Hull and Damage]]).
6. **Surface arrival** — pod lands at the surface station; run ends, proceed to sell minerals; fuel refills for next run.

UI/audio: "EMERGENCY RETURN IN PROGRESS", time-to-surface countdown, cargo-loss indicator, calm voice ("Emergency systems engaged. Returning to surface."), blue emergency lights.

---

## Restoration

**Between runs:** fuel auto-refills to max for free. With **Auto-Refuel Epic Upgrade**, it's instant and silent; otherwise click "Refuel" on the surface screen.

**During a run — Fuel Cell:**
- Cost: $200 (bought at surface)
- Restores 100 fuel instantly; tap fuel cell button on HUD
- Can carry multiple; strategic backup for deep dives

Mid-run restocks can also arrive via [[Supply Drops]] (Fuel Cell at $400 / 2x price, max 3 per order).

---

## Management strategies

### Conservative
Never run out. Return at 50% fuel; keep 50–60% for the trip back; treat fuel cells as insurance. Best early game, expensive runs, low drill level.

### Calculated
Optimize mathematically and return exactly at the buffer:

```
returnThreshold = currentDepth × 2 × (movementCost + drillingCost) × 1.3

Where:
- movementCost ≈ 1.5 fuel per 10 meters (movement time × 1.5 fuel/sec)
- drillingCost varies by strata hardness (1.0-3.5 fuel per tile avg)
- 1.3 = 30% safety buffer
```

Best mid-game with stable upgrades.

### Aggressive
Push to 15–20% fuel before returning; accept emergency return as viable; carry 2–3 fuel cells; drop low-value cargo to cut return cost. Risk: 50% cargo loss, possible death. Best late game with max capacity + Cargo Insurance.

### Free-Fall
Minimize fuel via gravity: no thrust on descent, drill straight down, save fuel for the climb. Reaches extreme depths on low capacity but demands good dampeners ([[Hull and Damage#Impact damage]], Level 3 = no fall damage). Example: 100-fuel pod, ~0–10 fuel descending, 40 drilling, 50 reserved — can reach 200m+.

---

## Efficiency tips

1. **Upgrade Engine Speed early** — less time moving = less fuel per distance.
2. **Upgrade Drill Strength** — lower drilling cost in hard rock.
3. **Use gravity** — don't fight it down; gentle corrections only; save thrust for ascent.
4. **Plan your path** — drill straight down, avoid zigzag, target mineral clusters.
5. **Avoid corrosive zones** — 2x cost on Venus is punishing.
6. **Carry fuel cells** — 2–3 cells = 200–300 extra fuel ($400–600), a temporary capacity boost.
7. **Know your limits** — each tier has a natural max depth; two safe runs beat one failed run.

---

## Economics

A 200m Mars run costs ~100 fuel (~30 down, ~40 drilling, ~30 up). Pushing to 300m costs ~150 but yields more valuable minerals (gold, platinum) — weigh the extra value against a potential 50% loss.

**Fuel Cell math:** $200 buys 100 fuel ≈ 67 seconds of thrust (or ~100 tiles of drilling at avg 1.0 fuel/tile). If a $200 cell prevents an emergency return on a ~$3,000 run, it saves ~$1,500 in cargo — a net ~$1,300 gain. Buy cells for high-value or depth-pushing runs. Full pricing context: [[Materials and Economy]].

---

## Advanced / future ideas

- **Micro Fusion Reactor (Epic Upgrade?)** — regen 0.5 fuel/sec while stationary; 50,000 Golden Gems.
- **Fuel cell trading** — sell back unneeded cells at 50% value ($200 → $100).
- **Fuel Efficiency stat** — e.g. "Fuel Efficiency: 85%", leaderboard potential.

See also: [[Cargo System]] · [[Supply Drops]] · [[Game Design]]
