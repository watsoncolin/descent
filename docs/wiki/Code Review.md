---
tags: [descent, review, status]
updated: 2026-06-21
---
# Code Review

Living record of the 2026-06-21 multi-agent code review (engine, terrain/strata,
fuel & damage balance, aesthetics). Verdict: **good bones, held back by a few
systemic bugs and shipped-debug values that break the three hardest-won systems.**
The full source report is at `REVIEW.md` in the repo root.

## Root causes (cross-cutting)

### 1. Grid-rows-vs-meters unit confusion
Two vertical units exist — grid rows (64px / 12.5m) and depth in meters — and
`TerrainBlock.metersPerBlock` (12.5) is applied in some places, silently omitted in
others. The *correct* conversion often sits ~50 lines from the buggy one. Symptoms
spanned three separate reviews and the [[Terrain and Strata]] system:
- **Strata:** obstacles never spawned (`TerrainManager.swift:377` treated row index as meters).
- **Fuel:** deep drilling charged at surface-rock rates (`GameScene.swift:1037`). See [[Fuel System]].
- **Worldbuilding:** collision grid allocated ~12.5× too tall; strata boundaries fractionally misaligned.

### 2. Debug values shipped as production defaults
- **100 of every consumable** (`PlanetState.swift:147-151`) ≈ 10,000 free fuel + 5,000 free HP — short-circuited the [[Fuel System]] / [[Hull and Damage]] loop and the shop.
- `showsFPS`/`showsNodeCount` overlays on; a live destructive "reset progress" button; debug markers on the pod.

### 3. No single source of truth
Tuning constants scattered as inline literals; 249+ hardcoded colors with a [[Design System]]
palette that has no code-level theme; [[Terrain and Strata]] uses six parallel
string-keyed dicts. Code contradicts docs: fuel 1.0 vs documented 1.5; damage uses
physics *impulse* (spiky) vs documented *velocity*; emergency auto-return unimplemented;
obstacle materials indestructible despite being designed drillable.

## Quick-win batch — DONE (2026-06-21, build verified)

> [!success] Shipped
> All six compile clean and the app builds, installs, and launches on iOS 26.5.

- [x] Consumable defaults 100 → starter (1 fuel cell + 1 repair kit, rest 0) — `PlanetState.swift:147-151`
- [x] Drilling fuel reads depth in **meters** not grid rows — `GameScene.swift:1037`
- [x] Obstacles actually spawn (meters fix) — `TerrainManager.swift:377`
- [x] reinforcedRock/hardCrystal destroyable; only bedrock indestructible — `TerrainManager.swift:886`
- [x] Thrust fuel uses `clampedDeltaTime` (no hitch spikes) — `GameScene.swift:447`
- [x] Debug overlays + reset button gated behind `#if DEBUG`

## Deeper passes — TODO

> [!success] Fuel & damage — rebalanced 2026-06-21 (see [[Fuel System]], [[Hull and Damage]])
> Done:
> - Drilling fuel is now **linear**, charged once per block: `baseDrillCost(1.5) × hardness / drillLevel` (was quadratic per-frame).
> - Impact damage rebuilt on **closing speed into the surface** (pre-impact velocity · contact normal) — not impulse. Side-scrapes/ascending bumps no longer hurt; head-on landings do. Deleted the dead `sizeScaleFactor`.
> - Thresholds 200/275/330/∞ by dampener level, ×0.3; free-fall terminal velocity clamped to 350 px/s every frame.
> - Movement fuel raised to 1.5/s. Impact feedback added: screen shake, floating `-X`, red flash, hull-bar pulse, haptic.
> - Tuning centralized in `K.Fuel` / `K.Damage`.
>
> Remaining:
> - Emergency auto-return at 0 fuel still unimplemented (currently instant game-over, keeps 50% cargo).
> - Two contradictory consumable price tables (`Consumables.costs` vs `SupplyItem.surfacePrice`).
> - Optionally move tank/hull/threshold ladders into planet JSON.

> [!todo] Strata (see [[Terrain and Strata]])
> - ✅ **Done:** O(N²) surface-mask rebuild fixed — the mask now appends one cutout per drill in place (was the depth perf cliff *and* the bomb hitch).
> - Standardize on block-rows internally; convert to meters only at the JSON boundary.
> - Make `CollisionGrid` the single source of truth; retire the six string-keyed dicts; integer/`GridCoord` keys.
> - `seededRandom` can return `max+1` → OOB crash (`TerrainManager.swift:683`). Stratum > ~1600m → `fatalError` (Metal 8192px limit). Validate author data, never `fatalError`.

> [!todo] Aesthetics (see [[Design System]])
> - North star: the app icon (polished cozy sci-fi) — none of it survives into the game.
> - Replace the in-game pod hexagon (`PlayerPod.swift:149-219`) with a sprite of the icon pod.
> - Build a `Theme` palette enum; route all colors through it; background → navy `#0a0e27`.
> - Re-tint obstacles off `#8B00FF`. Restyle HUD with real `safeAreaInsets`. Add juice (shake, haptics, SFX — all absent).

> [!todo] Engine (see [[Architecture]])
> - Frame-rate-dependent camera/drill smoothing → differs on 120Hz ProMotion. Make delta-time-based.
> - Drilling/consumable state desync can strand the pod. `GameScene` is a 1591-line god-object.
> - No save-on-background. Latent force-unwraps; shield-cleanup race; magic-number physics bitmasks.

See also [[Roadmap]] for feature status.
