---
tags: [descent, decisions]
updated: 2026-06-21
---

# Decisions

A running log of the foundational design and platform decisions for DESCENT, with one-line rationale each. Newest concerns at the bottom. Most of these are settled; see [[Game Design]] for how they fit together and [[Roadmap]] for status.

## D1 — Game name: DESCENT
The name and tagline _"How deep will you go?"_ frame the whole game around vertical risk/reward.

## D2 — Inspiration: Motherload + Egg Inc
Borrow Motherload's mining feel and Egg Inc's prestige progression — proven loops, fresh combination.

## D3 — Platform: iOS, Swift + SpriteKit
2D sprite game with built-in physics; SpriteKit ships with iOS and suits chunk-based terrain on mobile. See [[Architecture]].

## D4 — Core loop: Drill → Collect → Upgrade → Prestige
A single tight loop that scales from a 2-minute session to a 15-minute core run keeps "one more run" pull at every tier. See [[Game Design#The Core Loop]].

## D5 — 8 planets with 100× value scaling
Mars (1×) → Enceladus (100×); same minerals worth more on harder planets creates natural grind-to-unlock progression. See [[Game Design#The 8 Planets (100× value scaling)]].

## D6 — Resource escalation: real → exotic → alien
Five tiers from familiar elements (Iron, Gold) to fictional exotics (Pyronium) to alien matter (Stellarium) deliver discovery and sci-fi escalation as you go deeper. See [[Materials and Economy]].

## D7 — Dual currency: Bocks (temporary) + Soul Crystals (permanent)
Separating run-cash from permanent progression lets prestige wipe upgrades without erasing player investment. (Premium Golden Gems added as a third, optional currency.) See [[Game Design#Currencies]].

## D8 — Prestige model: core extraction grants Soul Crystals
Extracting a planet's core resets Bocks + Common Upgrades but grants Soul Crystals at `√(Total Career Earnings / 1000)`, each worth +10% to all mineral values forever. Always-progressing payoff; even failed runs build toward it. See [[Game Design#The Prestige System]].

## D9 — Volume-based cargo with auto-drop
Each mineral occupies space by size/density (50-unit start), forcing "drop coal for diamonds?" decisions; auto-drop optimizes the haul. See [[Cargo System]].

## D10 — Planets regenerate between runs (seeded procedural)
Terrain respawns on surface return so players can't strip-mine or memorize mineral positions — each run tests skill, not memory. Core chamber stays fixed at max depth. See [[Game Design#Planet reset behavior]] and [[Terrain and Strata]].

## D11 — Direct touch-and-drag controls, automatic drilling
Hold to move the pod toward your finger; terrain auto-drills on contact. One-handed, no occlusion, no separate drill button — easy to learn, hard to master. See [[Design System]].

## D12 — Consumables reset on prestige (design change)
Originally kept across prestige; changed so consumable counts reset with Common Upgrades, keeping prestige a clean planet-state wipe. (Implemented this way.) See [[Roadmap#🌟 Phase 3 — Prestige Hook (90%, just completed)]].

## D13 — Mining Bomb implemented as 3×3 (vs 5×5 spec)
Implementation clears a 3×3 area; design docs spec 5×5. Open: reconcile to one value. Tracked in [[Roadmap]].

> [!warning] **OPEN — D14: Return-to-surface mechanic is contradictory.** CLAUDE.md states there is NO automatic "return to surface" button (players must use the Emergency Teleporter consumable), while [[Fuel System]] specs an emergency auto-return at 0 fuel with a 50% cargo penalty — and the current build ships BOTH a teleporter button and a surface-UI "return" option. Decide whether returning should be easy (button) or gated (teleporter only), then align FUEL_SYSTEM, the emergency-return work, and the UI. See [[Roadmap#Implementation differences from design]].
