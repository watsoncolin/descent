---
tags: [descent, roadmap, status]
updated: 2026-06-21
---

# Roadmap

Implementation status as of the last source update (2025-10-11): **~70% of Phase 1**, with the prestige system just landed. Strong foundation — all core systems work — but the critical gaps are the **fuel/hull warning systems** and the **emergency return system**, which currently break core game feel.

See [[Game Design]] for the vision this implements.

> [!todo] Known bugs and regressions from the recent review live in [[Code Review]]. Read it before picking up new feature work — some "implemented" systems have issues.

## Status by phase

| Phase | Goal | Progress |
|---|---|---|
| Phase 1 — Core Proof | "Is mining fun?" | ~70% |
| Phase 2 — Upgrade Loop | "Is progression satisfying?" | 0% |
| Phase 3 — Prestige Hook | "Does prestige feel rewarding?" | 90% |
| Phase 4 — Polish | "Does it feel good?" | 0% |
| Phase 5 — Second Planet | "Does variety work?" | 0% |

## ✅ Currently implemented

**Core systems (complete):**

1. Basic movement — touch controls, thrust, gravity
2. Drilling — variable speed based on strata hardness (see [[Terrain and Strata]])
3. [[Fuel System]] — consumption during thrust and drilling (1.5 fuel/sec base)
4. [[Hull and Damage]] — impact damage with dampeners (impulse-based)
5. Terrain generation — vein-based procedural with deterministic seeding
6. Material system — 15 materials with values and Soul Crystal bonuses ([[Materials and Economy]])
7. [[Cargo System]] — volume-based with auto-drop optimization (fully matches design)
8. **All 6 Common Upgrades** — Fuel Tank (6 levels, max 500), Drill Strength (5 levels), Cargo Capacity (6 levels, max 250), Hull Armor (5 levels, max 200 HP), Engine Speed (5 levels, max 200%), Impact Dampeners (3 levels)
9. **All 5 consumables** — Repair Kit (50 HP), Fuel Cell (100 fuel), Mining Bomb (clears 3×3 area), Emergency Teleporter, Shield Generator (10s invincibility)
10. Consumable UI — 5 buttons at bottom with counts
11. [[Supply Drops|Supply drop system]] — capacity system (5-20 items)
12. Supply drop UI — quantity selectors, capacity bar, per-item limits
13. Surface shop — buy upgrades and consumables via tabs
14. HUD — fuel, hull, depth, cargo (with value), credits
15. Game over system — fuel depletion and hull destruction handlers
16. Save system — profile persistence via SaveManager (see [[Data Model]])
17. [[Mars]] — full level design, 8 strata layers, vein generation
18. Sell dialog — post-run cargo sale
19. Reset progress — testing button to reset all upgrades/credits
20. Prestige system — core extraction, Soul Crystals, planet reset
21. PrestigeDialog — UI showing lost/kept/gained
22. Core chamber — spawns at 490m with Dark Matter crystal
23. Soul Crystal earnings bonus — applies to all material values
24. Pod showcase — 3D pod visualization
25. Launch screen — custom design with PNG assets

> [!note] The Mining Bomb clears a **3×3** area as implemented, though [[Game Design]]/design docs spec a 5×5 area. Tracked as a design difference.

## 🚧 Phase 1 — Core Proof (critical missing)

### High priority — breaks core experience

**1. Fuel Warning System** ❌ — no warnings exist at all. [[Fuel System]] specifies 3 stages:

- **Low (25%)** — fuel bar yellow, "LOW FUEL" HUD message, soft beep every 5s
- **Critical (10%)** — bar red + flashing, "CRITICAL FUEL - RETURN NOW", screen edges pulse yellow, continuous alarm
- **Emergency (5%)** — bar flashing red rapidly, large center-screen warning, urgent alarm

**2. Emergency Return System** ❌ — completely missing; fuel depletion is currently instant game over. Required: trigger at 0 fuel, auto-ascent at 5 m/sec, "Emergency Return in Progress" overlay with ETA countdown, apply 50% cargo penalty with loss indicator, can still take hull damage, player control disabled. **Critical**: changes fail state from "lose everything" to "lose 50% cargo but survive."

**3. Hull Warning System** ❌ partial — no color changes, no staged warnings. Need stages at 75% / 50% / 25%, hull bar color (green → yellow → red), damage warning sounds, visual damage on pod sprite. Red screen flash is partially implemented. See [[Hull and Damage]].

### Medium priority — polish & feel

**4. Visual & Audio Polish** ❌ — no particles, screen shake, haptics, or sound.

- Particles: thrust, drilling, material-collection sparkles, hull-destroyed explosion, supply-drop rocket trail
- Screen shake: impacts, cave-ins, explosions, supply-drop landing
- Haptics: light (soft terrain), medium (normal blocks), strong (valuable materials), impact (damage), consumable activation
- Audio: drilling (varies by hardness), material collection, warning beeps/alarms, explosion, thrust/engine, supply-drop sounds

**5. Material Collection Feedback** ❌ — popup with name + value; rare gem screen flash + sound; exotic full-screen flash + lore snippet; first-discovery bonus notification.

**6. Run Summary Screen** ❌ — depth reached, total cargo value, best finds, new records, "Continue" to shop.

### Low priority — can ship without

**7. Hazards** ❌ — none implemented. Gas pockets (5% chance in layers 1-3, 5-15 HP, particle explosion) and cave-ins (8-15% by layer, crack warning, 2-4 falling rocks at 10 HP each, screen shake). See [[Terrain and Strata]].

**8. Tutorial System** ❌ — first-run movement, fuel, hull, cargo, upgrade tutorials; "Skip Tutorial" option.

**9. Statistics Tracking Display** ❌ partial — data is tracked but not shown. Best depth per planet, best haul per run, total minerals, total runs, death count by cause.

## 🔄 Phase 2 — Upgrade Loop (not started)

- **Expanded material set** — 15 materials today; missing full Tier 4-5 exotics for other planets
- **More hazards** — lava zones (decorative on Mars), unstable rock zones, visual hazard indicators
- **UI improvements** — smart upgrade recommendations (by death cause), better purchase feedback, animated transitions, better HUD layout

## 🌟 Phase 3 — Prestige Hook (90%, just completed)

**Done (Oct 11, 2025):** Soul Crystal system (`√(Total Career Earnings / 1000)`, +10%/crystal, 12% with amplifier); core extraction (chamber at 490m, guaranteed Dark Matter, extraction flag → prestige option); prestige screen (before/after, Soul Crystals gained, bonus preview, prestige vs continue); reset logic (clear Credits, reset Common Upgrades to L1, keep Soul Crystals + Epic Upgrades, consumables reset, apply bonuses, regenerate terrain).

**Still missing:** Soul Crystal count on HUD (currently only surface UI); enhanced prestige celebration animation; particle effects during prestige; count-up animations.

## 🎨 Phase 4 — Polish (not started)

Enhanced visual effects (better particles, dynamic pod-headlight lighting, exotic material glows, smoother animations, UI transitions); complete audio (background music for menu/surface/mining, full SFX library, volume controls, mixing); settings menu (volume, graphics quality, control sensitivity, colorblind modes, reset save); main menu (title, continue/new game, settings, [[Materials and Economy|compendium]], credits).

## 🪐 Phase 5 — Second Planet (not started)

- **Luna** — luna.json config, 2× multiplier, low gravity (0.7× fuel consumption), gray moon-dust identity, titanium deposits, vacuum-pocket hazard
- **Planet selection screen** — globe view, planet cards (stats/requirements), select/launch, unlock logic
- **Golden Gems system** — currency, HUD display, earn from milestones/achievements, IAP (future)
- **Epic Upgrades** — shop UI, Auto-Refuel, Advanced Scanner, Heat Resistance L1, Mineral Value Boost (formula exists, UI missing), Soul Crystal Amplifier (formula exists, UI missing), purchase confirmations

## Implementation differences from design

1. **Supply Drop System** ✅ correct — matches design (5-20 items, per-item limits)
2. **Prestige System** ✅ correct — matches design
3. **Return to Surface** ⚠️ inconsistent — CLAUDE.md says no automatic return button (teleporter consumable only); [[Fuel System]] specs emergency return at 0 fuel; implementation has both a teleporter button AND a surface UI "return" option. **Needs a design decision.** See [[Decisions]].
4. **Engine Speed Upgrade** ✅ — fully implemented (was wrongly listed as missing)
5. **Consumables** ✅ — all 5 functional with UI (was wrongly listed as high-priority missing)

## Next priority actions

**Critical for playable MVP:** (1) Fuel Warning System, (2) Emergency Return System, (3) Hull visual warnings, (4) basic visual/audio polish. **Important for feel:** (5) material collection feedback, (6) run summary, (7) basic hazards. **Polish for launch:** (8) tutorial, (9) statistics display, (10) enhanced prestige animation.

> [!warning] Biggest risks: no fuel warnings = frustrating sudden failure; no emergency return = 100% cargo loss is too punishing vs the designed 50% penalty; no audio/haptics = flat feel; no hazards = repetitive gameplay. **Recommendation: ship warning systems and emergency return before any new features.**
