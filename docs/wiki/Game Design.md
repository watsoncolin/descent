---
tags: [descent, design, progression]
updated: 2026-06-21
---

# Game Design

DESCENT is a Motherload-inspired mining game with Egg Inc-style prestige: you pilot a drilling pod through 8 planets, extract their cores, and convert career earnings into permanent multipliers. **Tagline: _"How deep will you go?"_**

- **Genre**: Mining Action / Incremental Progression
- **Platform**: iOS
- **Engine**: Swift + SpriteKit

This is the hub page. See [[Fuel System]], [[Hull and Damage]], [[Cargo System]], [[Supply Drops]], [[Terrain and Strata]], [[Materials and Economy]], [[Mars]], and [[Design System]] for system detail, and [[Roadmap]] for implementation status.

## Vision

A dual-currency prestige loop where each planet offers progressively more valuable materials but demands better upgrades and skill to conquer. Resources escalate from familiar real-world elements to exotic and alien materials, giving a sense of discovery and sci-fi escalation as you go deeper and harder. Inspiration: **Motherload** (mining feel) + **Egg Inc** (prestige progression).

## The Core Loop

**Drill → Collect → Upgrade → Prestige.**

A **run** is a single mining expedition. It can contain multiple trips (descend, return, bank, descend again) before you choose to end it.

1. **Launch** — Select a planet. Pod launches from the surface station with full fuel, full hull, empty cargo, at current upgrade levels.
2. **Descent** — Drill downward through [[Terrain and Strata|strata]], collect minerals to fill [[Cargo System|cargo]], manage [[Fuel System|fuel]], survive hazards. Constant risk/reward: go deeper for better minerals, or return now?
3. **Return decision**:
   - **Return early** — keep collected minerals, sell for Bocks, no prestige, immediately run again. Safe, lower reward.
   - **Reach core** — extract the planet's core, earn guaranteed Dark Matter, trigger the prestige option. Higher risk, maximum reward.
4. **Surface** — Sell minerals for Bocks, buy Common Upgrades, spend Golden Gems on Epic Upgrades, view run stats. **Planet regenerates** — terrain respawns fresh.
5. **Next run** — run again (fresh terrain, your upgrades persist), [[#The Prestige System|prestige]] (if core extracted), switch planets, or quit.

### Multiple trips per run

On returning to surface mid-run you choose:

- **Bank & Continue** — sell minerals (Bocks banked, safe), cargo empties, pod auto-refuels and auto-repairs to max, descend again. Repeat as fuel/skill allows.
- **End Run** — sell, bank, proceed to the upgrade shop and run statistics.

High fuel capacity enables **3-5 trips per run**, each deeper for better minerals.

### Planet reset behavior

Terrain regenerates every time you return to surface. Resource positions redistribute (same spawn rates/formulas, new locations), hazards respawn, but the **core chamber stays at maximum depth**. Your upgrades and stats persist; the planet itself resets. Planets use seeded random generation — Mars always feels like Mars, but exact mineral positions vary each run. This prevents strip-mining and memorization, keeping each run a test of skill, not memory.

> [!note] Lore: "The planet's crust regenerates between expeditions due to the corporation's quantum mining technology... a sustainable approach that prevents permanent planetary damage."

### Run length

- Quick surface run: 2-3 min
- Mid-depth run (~300m): 5-7 min
- Core run: 8-15 min depending on upgrades and skill
- Failed run: variable

Mobile-friendly: works for one quick run or a long multi-run session. Can pause mid-run and resume.

### Failure states

| Cause | Consequence |
|---|---|
| **Out of fuel** | Pod auto-returns to surface (emergency thrust); lose 50% of cargo (cargo insurance reduces this); hull stays at current HP. See [[Fuel System]]. |
| **Hull destroyed (0 HP)** | Pod explodes, emergency eject; lose all cargo (unless Ejection Pod active); respawn at surface. See [[Hull and Damage]]. |
| **Manual abandon** | "Abandon Run" from pause menu; lose all cargo; counts as failed run. |

## Resource Tiers

Five tiers escalate from real elements to alien matter. Full per-material values, volumes, depths and lore live in [[Materials and Economy]].

1. **Tier 1 — Common Elements** (Mars, Luna): real, familiar — Carbon, Iron, Copper, Silicon, Aluminum.
2. **Tier 2 — Precious Real Elements** (Luna, Io): Silver, Gold, Platinum, Titanium.
3. **Tier 3 — Rare Earth & Gems** (Io, Europa, Titan): Neodymium, Palladium, Ruby, Emerald, Diamond, Rhodium.
4. **Tier 4 — Exotic Fictional** (Venus, Mercury): Pyronium, Cryonite, Voltium, Gravitite, Neutronium.
5. **Tier 5 — Alien/Endgame** (Mercury, Enceladus): Xenite, Chronite, Quantum Foam, Dark Matter, Stellarium.

## The 8 Planets (100× value scaling)

Same minerals exist on every planet but are worth **more** on harder planets via a base multiplier. Iron on Mars = $25; Iron on Venus = $625 (25×). Diamond on Mars = $800; on Venus = $20,000. This drives natural progression: grind early planets to unlock later ones.

| # | Planet | Base value | Requirement | Core depth |
|---|---|---|---|---|
| 1 | Mars (tutorial) | 1× | None | 500m |
| 2 | Luna | 2× | None | 400m |
| 3 | Io | 5× | Heat Resistance L1 | 600m |
| 4 | Europa | 8× | Cold Resistance L1 | 700m |
| 5 | Titan | 15× | Cold Resistance L2 | 800m |
| 6 | Venus | 25× | Heat Resistance L2 | 900m |
| 7 | Mercury | 50× | Heat Resistance L3 | 1000m |
| 8 | Enceladus | 100× | Cold Resistance L3 | 1200m |

Progression arc: **1-2** learn mechanics, build Soul Crystals → **3-4** unlock resistances, meet hazards, discover exotics → **5-6** master advanced hazards, rare exotics appear → **7-8** endgame, perfect execution, alien materials. See [[Mars]] for the fully designed first planet; per-planet hazards and terrain composition are detailed there and in [[Terrain and Strata]].

## Currencies

Three currencies separate temporary, permanent, and premium progression.

1. **Bocks (Cash)** — _temporary_. Earned selling minerals at the surface. Buys Common Upgrades (planet-specific). **Resets on prestige.** Primary moment-to-moment currency.
2. **Soul Crystals** — _permanent_. Earned on prestige (core extraction). Each gives **+10% to ALL mineral values** permanently, compounding across all runs and planets. Never lost. Formula: `Soul Crystals = √(Total Career Earnings / 1000)`.
3. **Golden Gems** — _premium_. Buy Epic Upgrades (permanent unlocks). Earned via fly-by drones (shoot them down), rare Golden Nuggets while mining, daily login bonuses, ads (optional), challenges, and IAP (optional).

## The Prestige System

Extracting a planet's core lets you prestige.

- **You lose**: all Bocks, all Common Upgrades, current planet progress.
- **You keep**: Soul Crystals, Epic Upgrades, Golden Gems, planet unlocks.
- **You gain**: Soul Crystals based on total earnings, access to the next planet tier (if requirements met).

### Earnings Bonus (EB)

Your total multiplicative effect from Soul Crystals, applied to ALL mineral values on ALL planets permanently:

- 5 Soul Crystals = 50% bonus (1.5× multiplier)
- 20 Soul Crystals = 200% bonus (3× multiplier)
- 100 Soul Crystals = 1000% bonus (11× multiplier)

## Upgrades

**Common Upgrades** (Bocks, reset on prestige): Fuel Tank, Drill Strength, Cargo Capacity, Hull Armor, Engine Speed, Impact Dampeners — plus single-use consumables. **Epic Upgrades** (Golden Gems, never reset): earnings multipliers, quality-of-life, planet-unlock resistance gates, discounts. Full level tables and caps are tracked in [[Roadmap]]; persisted upgrade state lives in the [[Data Model]].

## Controls (iOS)

Direct touch-and-drag: hold anywhere to move the pod toward your finger (farther = faster); it auto-drills terrain it touches; release to let gravity take over. No separate drill button. Item buttons (Bomb, Teleporter, Repair Kit, Fuel Cell, Shield) sit at the bottom. One-handed, no occlusion (finger never blocks the pod), easy to learn, hard to master. Full feedback and accessibility detail in [[Design System]].

## Why this design works

1. **Always progressing** — even failed runs build toward Soul Crystals.
2. **Fresh challenges** — each planet feels new despite shared mechanics.
3. **"One more run"** — always near the next milestone.
4. **Strategic depth** — when to prestige? which planet? which upgrades?
5. **Long-term goals** — Epic Upgrades take 50-100 runs.
6. **Skill + persistence** — good players progress faster; everyone can max out.
7. **Clear milestones** — each Soul Crystal threshold feels significant.
8. **Variety** — 8 unique planets with different challenges.

## Build paths

- **Speed Runner** — max engine + dampeners early; fast, risky free-falling runs.
- **Tank** — max hull + drill; survive anything, push deeper.
- **Efficiency** — balanced fuel + cargo; maximize profit per run.
- **Explorer** — scanner + resistances early; reach rare planets sooner, focus on Golden Gems.

## Technical foundation

SpriteKit 2D, SpriteKit physics for gravity/collisions, seeded procedural terrain generation, UserDefaults + FileManager save system, optional ads/IAP for Golden Gems, chunk-based terrain loading for performance on older devices. Architecture detail in [[Architecture]] and [[Data Model]].
