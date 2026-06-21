---
tags: [descent, moc]
updated: 2026-06-21
---
# DESCENT — Wiki

Map of content for **DESCENT**: an iOS mining game — drill through planets, extract
minerals, upgrade, prestige. Inspired by Motherload + Egg Inc progression. Built in
Swift + SpriteKit. Repo: `descent`.

## Start here
- [[Game Design]] — the vision, core loop, and progression
- [[Roadmap]] — what's built, what's missing, by phase
- [[Code Review]] — current health, the quick-win fixes shipped, and the deeper-pass TODOs
- [[Glossary]] — terms in one place

## Gameplay systems
- [[Fuel System]] — consumption, tanks, refuel, emergency return
- [[Hull and Damage]] — impact model, dampeners, repair
- [[Cargo System]] — volume-based hold + auto-drop
- [[Supply Drops]] — mid-run item ordering

## World & content
- [[Terrain and Strata]] — strata, hardness, veins, obstacles
- [[Materials and Economy]] — the ~15 materials, values, sell loop
- [[Mars]] — the first planet, fully configured
- [[Level Design Guide]] — how to author a new planet

## Tech & visual
- [[Architecture]] — engine, systems, code map
- [[Data Model]] — three-tier persistence (Profile → Planet → Run)
- [[Design System]] — palette, typography, visual language
- [[Drill Animation and VFX]] — the consuming-drill animation + effects

## Reference
- [[Decisions]] — running decision log
- [[Glossary]]

## Status — June 2026
Resumed after an ~8-month pause. A four-part [[Code Review]] mapped the engine,
[[Terrain and Strata]], [[Fuel System]]/[[Hull and Damage]] balance, and [[Design System]]
aesthetics. A quick-win batch is shipped and building on iOS 26.5. **Next:** the deeper
passes — fuel/damage tuning first (now testable), then the strata unit-convention
refactor, then the aesthetic pass toward the app-icon art direction.
