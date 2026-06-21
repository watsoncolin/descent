---
tags: [descent, gameplay, combat]
updated: 2026-06-21
---

# Hull and Damage

Hull (HP) is the pod's structural integrity and DESCENT's skill check. Unlike [[Fuel System|fuel]], which depletes predictably, hull loss comes from hazards, impacts, and risky choices. At 0 HP the pod explodes and the run ends (with potential cargo loss) — unless an Ejection Pod saves it. Mastery is about *avoiding* damage. See [[Game Design]] for the loop and [[Terrain and Strata]] / [[Mars]] for where hazards live.

> [!note]
> **Impact damage is implemented** (see [[#Impact damage]]) — tuning in `K.Damage`. Hull tiers are in `PlanetState`. Hazard values and resistance multipliers below are **design targets** (hazards not yet implemented). See [[Code Review]] for status.

---

## Hull capacity tiers

| Level | HP | Cost | Survivability |
| --- | --- | --- | --- |
| 1 | 50 | $0 (start) | 2–3 hazard hits, very fragile |
| 2 | 75 | $600 | 4–5 hits, early-game adequate |
| 3 | 100 | $1,400 | 6–8 hits, mid-game comfortable |
| 4 | 150 | $3,000 | 10–12 hits, can take risks |
| 5 | 200 | $6,500 (max) | 15+ hits, very tanky |

---

## Damage sources

### Impact damage

**Implemented model (rebalanced 2026-06-21).** Damage is driven by the **closing speed into
the surface you hit** — the pod's pre-impact velocity projected onto the contact normal — not
raw collision impulse. A head-on landing hurts; grazing/scraping a wall (velocity parallel to
it) deals ~0, even while falling fast.

```
impactDamage = max(0, (impactSpeed − threshold) × multiplier)

impactSpeed = |preImpactVelocity · contactNormal|   (px/sec into the surface)
multiplier  = K.Damage.multiplier = 0.3
```

Velocity is **clamped to a terminal `K.Damage.maxFallSpeed = 350 px/sec` every frame**, so the
worst-case impact is bounded. Pre-impact velocity is captured in `PlayerPod.update()` because
the physics solver has usually cancelled it by the time the contact fires (this was why
head-on landings briefly read as 0 damage).

The threshold rises with the **Impact Dampener** upgrade (`K.Damage.threshold`):

| Dampener Level | Threshold | Effect |
| --- | --- | --- |
| 0 | 200 px/sec | Routine descents safe; only real drops hurt |
| 1 | 275 px/sec | Handles fast falls |
| 2 | 330 px/sec | Near-immune (terminal is 350) |
| 3 | ∞ px/sec | No fall damage ever |

Worked examples (Lv0 dampeners, terminal = 350):

- ≤200 px/sec: `0 HP` → normal mining/descent never hurts
- 300 px/sec: `(300−200)×0.3 = 30 HP`
- 350 (terminal faceplant): `(350−200)×0.3 = 45 HP` → survivable once on a 50 HP hull

**Feedback on a hit:** screen shake (scaled to damage), a floating `-X` at the pod, a brief
red screen flash, an HUD hull-bar pulse, and a haptic thump (device only). Safe zone: no
impact damage within `K.Damage.safeZoneDepth = 150 px` of the surface; `K.Damage.cooldown =
0.4s` between impact events.

> [!note]
> All impact tuning lives in `K.Damage` (`Constants.swift`) — change feel in one place.
> Level 3 dampeners enable the [[Fuel System#Free-Fall|free-fall fuel strategy]] with no hull cost.

### Hazard damage

**Gas pockets** (instant burst when drilled):

```
Small gas pocket (1-2 tiles):    5 HP
Medium gas pocket (3-5 tiles):  10 HP
Large gas pocket (6-10 tiles):  15 HP
Toxic gas (Venus):              20 HP
```
Subtle discolored/shimmering terrain; the Scanner upgrade reveals them.

**Cave-ins** (per falling rock that hits the pod):

```
Each rock: 10 HP (Mars, Luna)
Each rock: 15 HP (Io, Europa)
Each rock: 20 HP (Venus, Mercury, Enceladus)
```

Trigger probability by zone: Unstable Rock 10–15% per tile drilled · Fractured Crust 15% · Dense Mantle 8% (higher damage) · Pre-Core Mantle 5% (safer deep). A single cave-in drops 2–4 rocks — average ~20 HP (2×10), bad case 60 HP (4×15). Warning: cracks above, rumble 0.5s before, screen shake. Drill slowly in cracked zones, move out fast.

**Lava / heat** (continuous per second of contact):

```
Mars lava (decorative):           0 HP/sec (safe, visual only)
Io lava rivers:                  20 HP/sec
Io volcanic vents (burst):       25 HP (instant)
Venus lava pools:                30 HP/sec
Venus ambient heat (no resist):  15 HP/sec (everywhere below surface!)
```

**Ice / cold** (continuous per second of contact):

```
Europa ice spikes (collision):   20 HP (instant)
Europa freezing water:           15 HP/sec
Titan methane lakes:             25 HP/sec
Enceladus extreme cold:          20 HP/sec (ambient below 200m)
Enceladus cryogenic jets:        50 HP (instant burst)
```

**Heat/Cold Resistance** reduces both lava and cold damage identically:

```
No resistance:      Full damage
Level 1 resistance: 50% damage (rounds up)
Level 2 resistance: 25% damage
Level 3 resistance: Immune (0 damage)
```
Example — Venus ambient heat: 15 HP/sec unprotected kills a 200 HP hull in 13 seconds; Level 2 resistance drops it to 15×0.25 = 3.75 → 4 HP/sec ≈ 50 seconds. On extreme planets, resistance is **mandatory**, not optional.

**Environmental (ambient, continuous while in zone):**

```
Io sulfur gas clouds:            10 HP/sec
Venus sulfuric acid rain:        10 HP/sec (constant at surface)
Venus corrosive gas zones:       15 HP/sec
Mercury solar radiation:         20 HP/sec (surface only, decreases with depth)
Titan hydrocarbon rain:           5 HP/sec (periodic weather event)
```

**Special hazards (instant burst, planet-specific):**

```
Io volcanic vent eruption:       25 HP
Mercury meteor impact:           60 HP
Enceladus ice quake:             70 HP
Enceladus alien guardian attack: 80 HP
```
Io vents glow orange ~1s before firing and can chain. Mercury meteors hit the top 100m only — a growing ground shadow gives ~2s to dodge. Enceladus ice quakes shift terrain (rumble + shake warning) and can crush. Alien Guardians are rare core-depth hostiles that melee on contact; outrun them.

### Radioactive cargo

```
damagePerSecond = radioactiveCrystalsInCargo × 1 HP/sec

- 1 crystal:  1 HP/sec
- 5 crystals: 5 HP/sec
- 10 crystals: 10 HP/sec (200 HP = 20 sec to death!)
```

Radioactive Crystals are worth $400 each but bleed hull the entire time you carry them. Grab them near the surface, use a teleporter to return instantly, or tank it with high hull. Indicated by Geiger clicks, a green HUD symbol, and a green-tinted hull bar. Auto-drop ([[Cargo System]]) treats them by value only, so they may be kept over Coal/Iron.

---

## Warning system

| Stage | Trigger | Behavior |
| --- | --- | --- |
| 1 — Moderate | 50% hull | Gauge yellow; cracks on sprite; soft beep per hit; "HULL DAMAGED"; spark particles |
| 2 — Heavy | 25% hull | Gauge red + pulsing; large cracks/dents; louder beep; "CRITICAL HULL DAMAGE"; red edge pulse; smoke |
| 3 — Critical | 10% hull | Rapid red flash; near-destroyed sprite; urgent alarm; "HULL FAILURE IMMINENT"; center warning; smoke/sparks/fire; repair or return now |
| 4 — Destroyed | 0% hull | Explosion sequence (below) |

---

## Hull destruction (0 HP)

1. **Explosion** — dramatic effect, violent screen shake, flash, sound, debris.
2. **Ejection Pod check** — if the **Ejection Pod Epic Upgrade** is owned and unused this run: ejection fires automatically, pod warps to surface (blue teleport), **all cargo kept**, hull restored to **25 HP**, fuel unchanged, run continues. Consumed (one use per run); "EJECTION POD ACTIVATED". Otherwise → death.
3. **Death** — run ends, fade to black, death stats screen.
4. **Cargo loss** — with **Cargo Insurance**: keep **50% of cargo value** as Credits ("Cargo Insurance recovered $X,XXX"). Without: **lose 100%** ("All cargo lost").
5. **Statistics** — death count, location (planet, depth), cause, planet death counter all increment.
6. **Respawn** — return to surface; pod fully repaired, fuel refilled, cargo empty; start a new run.

> [!note]
> **No permadeath.** You keep Soul Crystals, Epic Upgrades, Golden Gems, and prior Credits — only the current run's cargo is at stake.

---

## Restoration

**Between runs:** hull auto-repairs to max for free. With **Auto-Repair Epic Upgrade**, instant and silent; otherwise click "Repair".

**During a run — Repair Kit:**
- Cost: $150 (bought at surface)
- Restores 50 HP instantly (cannot exceed max); tap on HUD
- Example: 20 HP + kit = 70 HP. Carry multiple (3 kits = 150 HP for $450).

Mid-run restocks also via [[Supply Drops]] (Repair Kit $300 / 2x, max 3 per order).

---

## Management strategies

- **Tank** — max hull (200 HP) + 3–5 repair kits, skip dampeners, face-tank hazards. Forgiving but expensive. Best for new players and hazard-heavy planets (Io, Venus).
- **Avoidance** — hull Lv2–3, prioritize Impact Dampeners Lv3, dodge everything, use Scanner. Efficient and skill-rewarding but one mistake can be fatal. Best on predictable planets (Mars, Luna).
- **Balanced** — hull Lv3–4 (100–150 HP), Dampeners Lv2, 1–2 repair kits. Versatile default for most players.
- **Glass Cannon** — hull Lv1–2, max Ejection Pod + Cargo Insurance, spend Credits on fuel/cargo/drill instead. Play perfectly or die. Expert/challenge runs only.

---

## Efficiency tips

1. **Impact Dampeners are crucial** — Lv3 = no fall damage ever; best hull-preservation upgrade.
2. **Visual hazard awareness** — gas shimmer, cave-in cracks, visible lava/water.
3. **Scanner upgrade** — sees gas pockets and minerals through terrain; 3,000 Golden Gems.
4. **Slow down in dangerous zones** — Fractured Crust, lava, unknown areas.
5. **Shield item** — 10s invincibility for $600; push hazard gauntlets or survive radioactive cargo.
6. **Know your hull budget** — e.g. crossing lava at 20 HP/sec for 3s needs 60 HP; with 50 HP you'd die — reroute or repair.
7. **Resistance > Hull** — no amount of hull saves you on Venus without Heat Resistance (15 HP/sec = dead in 13s; Lv2 = ~50s).

---

## Economics

Cost to max hull:

```
Level 1→2: $600
Level 2→3: $1,400
Level 3→4: $3,000
Level 4→5: $6,500
Total: $11,500
```

A $150 repair kit that saves a ~$3,000 run nets ~$2,850 in protected cargo; used unnecessarily it wastes $150. Carry 1–2 on valuable runs. Pricing context: [[Materials and Economy]].

---

## Advanced / future ideas

- **Ejection Pod cooldown** — e.g. one use per 3 runs, or Golden Gem recharge.
- **Nano-Repair Systems (Epic Upgrade?)** — regen 1 HP/sec after 5s without damage; 50,000 Golden Gems.
- **Damage-type resistances** — separate Impact / Explosive / Environmental resistance upgrades for build depth.

See also: [[Fuel System]] · [[Cargo System]] · [[Supply Drops]] · [[Game Design]]
