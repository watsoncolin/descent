---
tags: [descent, gameplay, economy]
updated: 2026-06-21
---

# Cargo System

Cargo is the pod's mineral storage, measured in **volume units, not item slots** — minerals occupy different amounts of space by size/density. When cargo is full, an **auto-drop** algorithm jettisons the lowest value-per-unit minerals to make room for better finds, so the player focuses on mining rather than inventory micromanagement. Mineral values come from [[Materials and Economy]]; storage interacts with [[Fuel System#Emergency return (0 fuel)|emergency return]] and [[Hull and Damage#Radioactive cargo|radioactive cargo]] penalties.

> [!note]
> Capacity tiers, mineral sizes, and material values are live tuning constants tracked in [[Code Review]]. Values restated verbatim from the source.

---

## Capacity tiers

| Level | Units | Cost |
| --- | --- | --- |
| 1 | 50 | $0 (start) |
| 2 | 75 | $400 |
| 3 | 100 | $900 |
| 4 | 150 | $2,000 |
| 5 | 200 | $4,500 |
| 6 | 250 | $9,000 (max) |

**Example (50 units):** 10 Coal (5u each) = 50u · OR 16 Iron (3u) = 48u · OR 100 Diamonds (0.5u) = 50u · OR mix: 5 Coal (25u) + 5 Iron (15u) + 20 Diamonds (10u) = 50u.

---

## Mineral sizes reference

Size in volume units per unit of mineral:

**Tier 1 — Common Elements (bulky):** Carbon/Coal 5 · Iron 3 · Copper 3 · Silicon 2 · Aluminum 2

**Tier 2 — Precious Metals (dense):** Silver 2 · Gold 2 · Platinum 2 · Titanium 1.5

**Tier 3 — Rare Earth & Gems (small):** Neodymium 1.5 · Palladium 1 · Ruby 0.5 · Emerald 0.5 · Diamond 0.5 · Rhodium 1

**Tier 4 — Exotic (compact):** Pyronium 1 · Cryonite 1 · Voltium 0.8 · Gravitite 0.5 · Neutronium 0.3

**Tier 5 — Alien (ultra-compact):** Xenite 0.5 · Chronite 0.4 · Quantum Foam 0.3 · Dark Matter 0.1 · Stellarium 0.05

---

## Auto-drop algorithm

On collecting a new mineral:

1. **Check space:**
   ```
   if (currentCargo + mineralSize <= maxCargo):
       collect mineral normally
       return
   ```
2. **Compute space needed:**
   ```
   spaceNeeded = (currentCargo + mineralSize) - maxCargo
   ```
3. **Sort cargo by value per unit, lowest first:**
   ```
   For each mineral in cargo:
       valuePerUnit = (totalValue / totalSize)
   Sort ascending (lowest value per unit first)
   ```
4. **Drop lowest-value minerals until space is freed:**
   ```
   freedSpace = 0
   droppedItems = []
   while (freedSpace < spaceNeeded):
       lowestValueItem = cargo.first()
       freedSpace += lowestValueItem.size
       currentCargo -= lowestValueItem.size
       droppedItems.push(lowestValueItem)
       cargo.remove(lowestValueItem)
   ```
5. **Collect the new mineral:**
   ```
   cargo.add(newMineral)
   currentCargo += mineralSize
   ```
6. **Notify:** `"Dropped [items] for [new mineral]"`

### Value per unit

```
valuePerUnit = totalValue / totalSize

- Coal:    $10 / 5 units   = $2 per unit
- Iron:    $25 / 3 units   = $8.33 per unit
- Gold:    $150 / 2 units  = $75 per unit
- Diamond: $800 / 0.5 units = $1,600 per unit
```

This keeps Diamonds over Coal even though diamonds are physically smaller — the system prioritizes **value density**, not size.

---

## Worked examples

**1 — Basic replacement.** Cargo 50/50 of 10 Coal ($10, 5u). Collect 1 Gold ($150, 2u). Need 2u; Coal is $2/unit → drop 1 Coal (frees 5u). Result: 9 Coal + 1 Gold = 47/50, $240.

**2 — Multiple items.** Cargo 50/50: 5 Coal (25u, $50), 5 Iron (15u, $125), 5 Copper (15u, $150). Collect 10 Diamonds ($800 each, 0.5u = 5u needed, $8,000). Sorted: Coal $2 < Iron $8.33 < Copper $10/unit → drop 1 Coal (5u). Result: 4 Coal + 5 Iron + 5 Copper + 10 Diamonds = 50/50, $8,525.

**3 — Won't collect worse items.** Cargo full of Diamonds ($1,600/unit) + Gold ($75/unit) + platinum. Try to collect Coal ($2/unit) — worse than everything → not collected; "Coal ignored (low value)".

**4 — Planet multiplier.** On Venus (25x) with 1000% Soul Crystal bonus (11x → **275x total**): Coal = $10×275 = $2,750 (=$550/unit), collect Pyronium $1,500×275 = $412,500/unit → drop 1 Coal ($2,750), net +$409,750. The algorithm is multiplier-agnostic; it just compares value-per-unit. See [[Materials and Economy]] for multipliers.

---

## Edge cases

- **Drop multiple types** — keep dropping lowest-value items until enough space (e.g. drop 2 Coal, then 1 Iron). Notify "Dropped Coal x2, Iron x1 for Stellarium".
- **Exact tie in value/unit** — break with: (1) value per unit, (2) total value (drop smaller total first), (3) collection order (drop oldest first). Deterministic.
- **Cargo full, find worse mineral** — don't collect, don't notify (avoid spam); mineral is drilled/destroyed normally. Optional yellow cargo-icon flash.
- **Radioactive materials** — Radioactive Crystal $400, 1u = $400/unit (decent), but deals 1 HP/sec ([[Hull and Damage#Radioactive cargo]]). Auto-drop keeps it by value alone; player decides. Future hybrid mode: mark "never auto-collect".

---

## UI and feedback

**Main HUD:**
```
┌──────────────────────────┐
│ CARGO: 45/50 units       │
│ [████████████░░] 90%     │
│ VALUE: $3,250            │
└──────────────────────────┘
```
Cargo bar color: **Green** <80% · **Yellow** 80–95% · **Red** 95–100% · **Flashing red** 100% (auto-dropping likely).

**Auto-drop notification** ("CARGO AUTO-MANAGED / Dropped: 2 Coal / Collected: 1 Gold") appears ~2s and fades. Dropped mineral shows a small sprite falling behind the pod (~0.5s, not collectible). Sounds: soft whoosh on drop, clink on collect, pitch varies by tier.

**Detailed view** (tap to expand) lists items sorted by value (highest first) with totals.

**Tutorial** — first time cargo fills (~Run 2–3): a one-time "CARGO FULL!" popup explains auto-drop and nudges a Cargo Capacity upgrade. Shown once, saved in profile.

---

## Statistics

Tracks: total items auto-dropped (count), total value dropped ($), most valuable single auto-drop, most common dropped type. Displayed e.g. "Items Dropped: 1,247 · Value Dropped: $45,320 · Most Dropped: Coal (823 times)".

---

## Performance notes

- **Don't recalc every frame** — compute value-per-unit only on collect or when cargo composition changes; cache between calculations.
- **Batch drops** — drop multiples of one type at once; single notification "Dropped Coal x5".
- **Limit notifications** — when constantly auto-dropping, show every 5th drop or summarize post-run ("Auto-dropped 15 items").

---

## Future enhancements (hybrid mode)

- **Manual management** — Cargo Manager screen, tap-to-drop, lock items against auto-drop, sort/filter.
- **Settings** — toggle auto-drop, set threshold (90% vs 100%), notification prefs.
- **Advanced** — mark types "never collect", auto-sell commons at surface, loadout presets.

See also: [[Fuel System]] · [[Hull and Damage]] · [[Supply Drops]] · [[Materials and Economy]] · [[Game Design]]
