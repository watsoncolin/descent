---
tags: [descent, gameplay, economy]
updated: 2026-06-21
---

# Supply Drops

Supply Drops let players order consumables mid-run while underground, so they're never permanently stuck (especially out of bombs at a blocked path). The catch: items cost **2x surface price** and the delivery requires a risky **30-second stationary wait**. Good players plan ahead and rarely need them; stuck players get an expensive but reliable escape. Consumables and prices align with [[Fuel System]], [[Hull and Damage]], and [[Materials and Economy]].

> [!note]
> Prices, capacity tiers, per-item limits, and the 30s timer are live tuning constants tracked in [[Code Review]]. Values restated verbatim from the source.

---

## Core mechanic

**Access:** an always-visible "Emergency Supply" button (bottom-right HUD) opens the menu anytime underground.

**Ordering flow:**
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
- Consumables only (no upgrades)
- Must have sufficient Credits
- Cannot exceed capacity (5–20 items, see tiers) or per-item limits
- Cannot order while moving (menu grays out)
- Moving during countdown cancels delivery — **no refund**
- One delivery at a time (can't stack orders)

---

## Pricing and per-item limits

All items cost **2x normal surface price:**

| Item | Surface Price | Supply Drop Price | Max Per Order |
| --- | --- | --- | --- |
| Repair Kit | $150 | $300 | 3 |
| Fuel Cell | $200 | $400 | 3 |
| Mining Bomb | $400 | $800 | 3 |
| Shield Generator | $600 | $1,200 | 2 |
| Emergency Teleporter | $800 | $1,600 | 2 |

The 2x markup discourages spam, rewards planning, and keeps the economy intact while staying affordable in emergencies. Per-item caps (common items max 3, expensive items max 2) prevent loading up on a single type and encourage balanced orders.

---

## Supply pod capacity tiers

Total items per drop, upgraded with Golden Gems (Epic Upgrade):

| Level | Capacity | Golden Gems Cost | Cumulative |
| --- | --- | --- | --- |
| 1 (Default) | 5 items | 0 | 0 |
| 2 | 8 items | 3,000 | 3,000 |
| 3 | 12 items | 6,000 | 9,000 |
| 4 | 15 items | 12,000 | 21,000 |
| 5 (Max) | 20 items | 25,000 | 46,000 |

**Rules:** total ordered can't exceed capacity; per-item limits still apply within it. With 5 capacity you can't order 5 bombs (max 3). With 20 capacity you could order 3 bombs + 3 fuel + 3 repair + 2 shields + 2 teleporters = 13 items.

**Upgrade value:** Lv1 (5) = emergency only, choose carefully · Lv3 (12) = comfortable restocks · Lv5 (20) = full restock, late-game luxury.

---

## Delivery mechanics

### The 30-second wait

A countdown overlay ("SUPPLY DROP INCOMING / ⏱ 23 seconds / REMAIN STATIONARY / Moving will cancel order!") updates every second and flashes if the player starts moving.

**Stationary requirement:** pod velocity must be **< 5 pixels/sec**. Small drifting (floating in place) is fine; any thrust triggers a cancellation warning; moving **> 2 tiles** cancels the order. On cancellation: "DELIVERY CANCELLED — Credits NOT refunded"; can re-order immediately.

### Arrival

At 5 seconds: warning beep, downward-arrow indicator at top of screen. At 0: supply pod sprite falls with a rocket trail, lands within 1 tile, dust impact, items auto-collected, confirmation. Total animation ~2s. Audio: countdown beeps at 10/5/3/2/1, rocket descent, impact thud, "restock complete" chime.

---

## Risk / reward — the vulnerability window

Standing still for 30s exposes the pod:

- **Hazards continue** — gas pockets, cave-ins, and environmental damage (lava, acid) all still apply; you can't dodge. See [[Hull and Damage#Hazard damage]].
- **Hull math** — waiting in sulfur gas (10 HP/sec) for 30s = **300 HP** damage; if hull < 300 you die. Find a safe zone first.
- **Fuel drain** — in a hazard zone you must thrust against pressure, burning [[Fuel System|fuel]] during the wait; you might run dry before delivery.
- **Positioning** — clear a safe alcove, ensure you aren't falling, plan an escape route before ordering.

---

## Strategic use

**Good cases:**
- **Blocked by hard crystal, no bombs** (e.g. 250m): order 2 bombs ($1,600), continue rather than restart from 0m. Worth it if cargo > ~$3,000.
- **Low fuel, deep dive** (e.g. 400m, 30 fuel, want core): with 12 capacity, 3 fuel cells + 2 repair kits = 5 items, $2,100; worth it if core extraction > $10,000.
- **Complete restock** (20 capacity): 3 bombs + 3 fuel + 3 repair + 2 shields + 2 teleporters = 13 items, $10,100 — full restock, late-game luxury.
- **Critical hull, valuable cargo** (15 HP, $8,000 cargo): repair kit $300 to secure a safe return — almost always worth it.
- **Trapped by cave-in:** bomb $800 to blast out, if cargo > $800.

**Bad cases:**
- Early game / low-value run (carrying $500, ordering $400 fuel = $100 profit) — just return.
- Near surface (50m) — navigate around instead of a $800 bomb shortcut.
- Chronic poor planning — paying 2x every run; buy at surface and plan better.

---

## Economic balance

**Bomb-shortage scenario (250m, hard crystal, no bombs, $6,000 cargo):**
- **Return to surface:** sell $6,000 but restart from 0m (~5 min to get back).
- **Supply drop:** $800, wait 30s, continue immediately.
- If you survive the wait: net $5,200 cargo + a continued run; if you die: lose cargo + $800 (worst case). Usually worth it when cargo > $1,500.

**Why 2x prevents abuse:** at surface price there'd be no reason to plan — players would buy everything mid-run and trivialize preparation. 2x is expensive enough to avoid spam, cheap enough for genuine emergencies. It also breaks the "grief yourself" loop where you repeatedly restart a deep run after hitting crystal walls with no bombs.

---

## UI

**Emergency Supply button** — bottom-right HUD, always visible. Idle: white icon. Active delivery: pulsing orange with countdown ("23s").

**Supply Drop menu** shows: capacity bar ("CAPACITY: 4/5 items", 80%), per-item rows with `[−] n [+]` quantity selectors, per-item max ("(max 3)"), per-line subtotal, running TOTAL ("$2,300 (2x prices)"), current Credits, and reminders (one delivery, 30s, must stay stationary), with `[ORDER]` `[CLEAR]` `[CLOSE]`. Feedback: unaffordable items grayed; at-capacity disables `+` and grays items; per-item-max shows "(max X)"; warning "Supply pod capacity full" when over.

**Delivery overlay** — semi-transparent "SUPPLY DROP INCOMING / ⏱ 18s / STAY STILL" with a live velocity readout: green "STATIONARY ✓" or red "MOVING ⚠".

---

## Tutorial integration

Three one-time popups (saved in profile):
- **First menu open** — explains 2x pricing, 5-item default capacity, multi-item single delivery, 30s stationary requirement, and Golden Gem capacity upgrades.
- **First time at capacity** — "SUPPLY POD FULL" (5 items per delivery; remove items or upgrade).
- **First time at per-item limit** — "ITEM LIMIT REACHED" (max 3 Mining Bombs per order).

---

## Edge cases

- **Multiple items, one delivery** — the intended use: e.g. 2 bombs + 1 fuel + 1 repair = 4 items ($3,000), one 30s wait, all arrive together.
- **At capacity** — 3 bombs + 2 fuel fills 5/5; `+` disabled; must remove to add a repair kit.
- **Per-item limit** — 4th bomb blocked ("Maximum 3 Mining Bombs per order"); other types still addable up to capacity.
- **Low capacity vs high needs** — 5 capacity but needing 2 bombs + 2 fuel + 2 repair (6) forces a choice (progression vs survival vs balanced). Incentivizes upgrading.
- **Upgraded capacity payoff** — 20 capacity fits 3 bombs + 3 fuel + 3 repair + 2 shields = 11 items ($6,300), essentially a full restock.
- **Die during wait** — order cancelled, Credits already spent (no refund), normal death consequences, cargo lost unless Ejection Pod ([[Hull and Damage#Hull destruction (0 HP)]]). Find a safe spot first.
- **Out of Credits mid-run** — items gray out ("Insufficient Credits"); must return to sell cargo or use a teleporter. Prevents infinite resources.
- **Surface during wait** — delivery still arrives; items added at surface; no penalty (handled edge case).
- **Drift tolerance** — < 5 px/sec is OK ("Minimal movement detected" warning); exceeding 5 px/sec for > 1s cancels. Allows natural floating, blocks active movement.

---

## Statistics

Tracks: total drops ordered, total Credits spent, most-ordered item, deliveries cancelled (moved), times saved by a drop. Example: "Drops Ordered: 47 · Credits Spent: $28,400 · Most Ordered: Mining Bombs (23) · Deliveries Cancelled: 3".

---

## Future enhancements (V2)

- **Express Delivery** — 3x price for 10s delivery; doesn't change capacity.
- **Capacity efficiency bonus** — fill to 100% capacity for 5% discount.
- **Cooldown reduction (Epic Upgrade)** — Lv1 30s → Lv2 25s (5,000 gems) → Lv3 20s (10,000 gems).
- **Per-item limit increases (Epic Upgrade)** — e.g. bombs 3 → 5 max (15,000 gems).

See also: [[Fuel System]] · [[Hull and Damage]] · [[Cargo System]] · [[Materials and Economy]] · [[Game Design]]
