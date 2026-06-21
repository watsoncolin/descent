---
tags: [descent, economy]
updated: 2026-06-21
---

# Materials and Economy

Mining sells minerals for **Bocks** (Credits), the per-planet currency you spend on upgrades and consumables. Materials progress from familiar real-world elements to exotic fictional matter as planets get harder, and the same mineral is worth more on tougher planets (planet value multiplier). [[Cargo System]] limits *what* you can haul home; this page covers *what it's worth*. Veins and spawn rules live in [[Terrain and Strata]].

## The sell/economy loop

1. Drill down, fill cargo with the highest value-per-volume minerals (auto-drop ditches low-value cargo when full — see [[Cargo System]]).
2. Return to surface → **all minerals auto-sell for Bocks**, cargo empties, pod refuels.
3. Spend Bocks on Common Upgrades and consumables (see [[Game Design]]).
4. Extract the planet core → option to **prestige** for permanent Soul Crystal earning bonuses.

Each material's worth scales with **value** (Bocks/unit) and is constrained by **volume** (cargo units consumed). High value-per-volume = worth carrying.

## Mars runtime values (`Resources/mars.json`)

These are the authoritative six minerals the Mars build actually spawns. `size` is the cargo volume per unit.

| Material | Value (Bocks) | Volume (`size`) | `seedRate` by strata | Color |
| --- | --- | --- | --- | --- |
| Coal | 10 | 1.0 | Sand 0.6, Stone 0.35 | #333333 |
| Iron | 25 | 1.5 | Sand 0.1, Stone 0.9, Deep 0.17 | #808080 |
| Copper | 30 | 1.8 | Deep 0.17, Core 0.12 | #B87333 |
| Silicon | 50 | 1.3 | Core 0.12 | #708090 |
| Gold | 100 | 2.0 | Core 0.08 | #FFD700 |
| Dark Matter | 10,000 | 0.1 | Core 0.0001 (unique) | #0A0A1A |

> [!note] Value bookkeeping caveats
> The design narrative and runtime disagree in spots — preserve both, trust `mars.json` for the build:
> - **Gold:** Mars runtime = **100**; `DESIGN.md`'s tiered catalog lists Gold at **$150** (Tier 2). Mars uses the lower figure.
> - **Volume conventions differ.** `mars.json`/`mars_level_design.md` give Coal volume 1.0; `DESIGN.md`'s catalog lists Carbon/Coal at **5 units** (and Iron 3, Copper 3, Silicon 2). Different scales — don't mix them in one calc.

### Mars material distribution summary (`mars_level_design.md`)

| Material    | Depth Range | Frequency  | Value  | Volume | Visual           |
| ----------- | ----------- | ---------- | ------ | ------ | ---------------- |
| Coal        | 0-250m      | 60→40%     | 10     | 1.0    | Black with glow  |
| Iron        | 125-375m    | 25→15%     | 25     | 1.5    | Silver metallic  |
| Copper      | 250-500m    | 20→10%     | 30     | 1.8    | Orange-brown     |
| Silicon     | 375-500m    | 12%        | 50     | 1.3    | Gray crystal     |
| Gold        | 375-500m    | 8%         | 100    | 2.0    | Brilliant yellow |
| Dark Matter | 490m        | 1 (unique) | 10,000 | 0.1    | Orange-red pulse |

(Depths use the legacy 0–500m Mars scale; see [[Terrain and Strata#The grid and chunk model]] for the meters-vs-rows caveat. The current build's strata boundaries are in [[Mars]].)

### Mars deposit sizes

| Material | Radius Range | Blocks Occupied | Visual Size  |
| -------- | ------------ | --------------- | ------------ |
| Coal     | 10-18px      | 2-4 blocks      | Small-Medium |
| Iron     | 12-18px      | 3-4 blocks      | Medium       |
| Copper   | 13-20px      | 3-5 blocks      | Medium-Large |
| Silicon  | 12-18px      | 3-4 blocks      | Medium       |
| Gold     | 15-22px      | 4-6 blocks      | Large        |

## Full material catalog (`DESIGN.md`)

The galaxy-wide economy spans five tiers — ~24 materials of escalating rarity. Format: **volume units, $value each**.

### Tier 1 — Common Elements (Mars, Luna)
- **Carbon (Coal):** 5 units, $10 — black chunks, very common
- **Iron (Fe):** 3 units, $25 — reddish-brown ore veins
- **Copper (Cu):** 3 units, $30 — orange-brown metallic veins
- **Silicon (Si):** 2 units, $50 — gray crystalline formations
- **Aluminum (Al):** 2 units, $60 — silver-white metallic deposits

### Tier 2 — Precious Real Elements (Luna, Io)
- **Silver (Ag):** 2 units, $75 — shiny metallic veins
- **Gold (Au):** 2 units, $150 — yellow metallic veins
- **Platinum (Pt):** 2 units, $250 — silver-white, very shiny
- **Titanium (Ti):** 1.5 units, $200 — dark gray metallic

### Tier 3 — Rare Earth & Gems (Io, Europa, Titan)
- **Neodymium (Nd):** 1.5 units, $300 — purple-silver magnetic crystals
- **Palladium (Pd):** 1 unit, $400 — silvery-white metallic
- **Ruby:** 0.5 units, $500 — deep red crystalline gem
- **Emerald:** 0.5 units, $600 — green crystalline gem
- **Diamond:** 0.5 units, $800 — clear/white brilliant crystal
- **Rhodium (Rh):** 1 unit, $900 — silver-white, ultra-reflective

### Tier 4 — Exotic Fictional Materials (Venus, Mercury)
- **Pyronium:** 1 unit, $1,500 — glowing orange-red heat crystal; Venus volcanic zones (400m+)
- **Cryonite:** 1 unit, $1,500 — bright blue ice crystal; Europa deep ice (500m+)
- **Voltium:** 0.8 units, $2,000 — electric yellow crystal; Mercury magnetic storm zones
- **Gravitite:** 0.5 units, $2,500 — purple-black anti-gravity crystal (floats up when released); Titan deep hydrocarbon zones
- **Neutronium:** 0.3 units, $3,500 — ultra-dense silver sphere (slows movement when carried); near Mercury core (800m+)

### Tier 5 — Alien / Endgame Materials (Mercury, Enceladus)
- **Xenite:** 0.5 units, $4,000 — color-shifting iridescent crystal; all deep cores (700m+), rare
- **Chronite:** 0.4 units, $5,000 — time-distortion crystal; Enceladus alien structures
- **Quantum Foam:** 0.3 units, $6,000 — impossible geometry, phases in/out; Enceladus subsurface ocean (900m+)
- **Dark Matter:** 0.1 units, $10,000 — light-absorbing void crystal; planet cores exclusively (one guaranteed per core)
- **Stellarium:** 0.05 units, $25,000 — miniature star in crystal; Enceladus core only, 1–3 per run (ultimate chase item)

### Depth distribution (galaxy-wide)
- **0-50m:** Coal, Iron, Copper
- **50-150m:** Silver starts, Gold possible
- **150-300m:** Gold common, Platinum appears, occasional gems
- **300-500m:** Gems more common, Titanium veins
- **500m+:** Heavy gem concentration, radioactive materials
- **Core zone:** Alien artifacts, dark matter

## Planet value multiplier

The same mineral is worth more on harder planets. Base multipliers:

| Order | Planet | Base value | Unlock |
| --- | --- | --- | --- |
| 1 | Mars | 1× | None (tutorial) |
| 2 | Luna | 2× | None |
| 3 | Io | 5× | Heat Resistance Lv1 |
| 4 | Europa | 8× | Cold Resistance Lv1 |
| 5 | Titan | 15× | Cold Resistance Lv2 |
| 6 | Venus | 25× | Heat Resistance Lv2 |
| 7 | Mercury | 50× | Heat Resistance Lv3 |
| 8 | Enceladus | 100× | Cold Resistance Lv3 |

Examples: Iron on Mars = $25, Iron on Venus = $625 (25×). Diamond on Mars = $800, Diamond on Venus = $20,000. This is the core progression loop: grind early planets to afford the gear that unlocks later ones. `valueMultiplier` is stored per planet ([[Mars]] = 1.0).

## Soul Crystal bonus (prestige)

Extracting a planet core lets you **prestige**: reset Bocks and upgrades for a permanent earning multiplier.

- **Bonus:** each Soul Crystal = **+10% to all mineral values**, permanent and compounding across every planet. `mars_level_design.md` treats this as multiplicative: 50 crystals = 5× values (500% of base).
- **Resets on prestige:** Bocks → 0, all upgrades → Level 1, planet progress → surface, consumables → none.
- **Persists:** Soul Crystals, unlocked planets, Golden Gems (premium currency), permanent unlocks (scanner, auto-refuel, ejection pod).

> [!note] Conflicting Soul Crystal formulas
> Three sources disagree on the award amount — flag before relying on any:
> - `mars_level_design.md`: `Soul Crystals = totalLifetimeEarnings / 1000` (first Mars core run ≈ 40–60).
> - `DESIGN.md`: `Soul Crystals = √(Total Career Earnings / 1000)`.
> - `Resources/mars.json` → `economyBalance.prestigeSoulCrystals: 15`, `runsToMaxOut: 20`.

## Mars economy targets

Expected gross earnings by depth (`mars.json` → `economyBalance`):

| Depth (m) | Earnings (Bocks) |
| --- | --- |
| 100 | 500 |
| 200 | 1,200 |
| 500 | 3,500 |
| 1,000 | 8,000 |
| 1,500 | 15,000 |
| 2,000 | 25,000 |
| 2,500 | 40,000 |

Net-per-run progression (after fuel/repair) runs roughly 250 → 1,000 → 3,500 → 12,000+ Bocks as upgrades come online; full upgrade cost tables and consumable prices ($800 bomb, $500 teleporter, $200 repair, $100 fuel cell) are in [[Game Design]] and [[Supply Drops]].

## Related

[[Cargo System]] · [[Terrain and Strata]] · [[Game Design]] · [[Mars]] · [[Supply Drops]] · [[Data Model]]
