---
tags: [descent, data, persistence]
updated: 2026-06-21
---

# Data Model

DESCENT persists progression across **three tiers**, distinguished by *what resets when*: `GameProfile` lives forever, `PlanetState` resets on prestige, and `CurrentRun` resets every run. Getting this hierarchy right is critical — it's the backbone of the prestige progression. See [[Architecture]] for how these models are wired into the engine and [[Game Design]] for the progression intent.

## Persistence Levels

- **Level 1 — Forever (Account):** never resets, saved across all sessions.
- **Level 2 — Until Prestige (Planet):** resets when you prestige a specific planet.
- **Level 3 — During Run Only (Session):** resets when a run ends (surface return or death).

```swift
GameProfile (Level 1) - Never resets
  └─ PlanetState (Level 2) - Resets on prestige
      └─ CurrentRun (Level 3) - Resets each run
```

All three are `Codable` for JSON serialization.

## 1. GameProfile — Level 1 (Forever)

Top-level save data, never resets.

```json
{
  "profileId": "uuid",
  "playerName": "string (optional)",
  "createdAt": "timestamp",
  "lastPlayed": "timestamp",
  "totalPlayTime": "seconds",

  // Permanent Progression
  "soulCrystals": 0,
  "goldenGems": 0,
  "totalCreditsEarned": 0,
  "totalRunsCompleted": 0,
  "totalCoresExtracted": 0,
  "totalDeathCount": 0,

  // Epic Upgrades (Permanent, never reset)
  "epicUpgrades": {
    "soulCrystalAmplifier": 0,        // 0-5
    "mineralValueBoost": 0,           // 0-5
    "autoRefuel": false,
    "autoRepair": false,
    "advancedScanner": false,
    "ejectionPod": false,
    "cargoInsurance": false,
    "advancedHUD": false,
    "heatResistance": 0,              // 0-3
    "coldResistance": 0,              // 0-3
    "cheaperUpgrades": 0,             // 0-5
    "fasterDrilling": 0               // 0-3
  },

  // Planet States (one per planet)
  "planets": [ /* PlanetState objects */ ],

  // Statistics
  "statistics": {
    "deepestDepthReached": 0,
    "highestSingleRunValue": 0,
    "fastestCoreTime": 0,
    "totalMineralsCollected": 0,
    "favoriteMineral": "string",
    "totalDistanceDrilled": 0
  },

  // Collection/Compendium
  "discoveredMinerals": ["Iron", "Gold", "Pyronium", "..."],

  // Achievements
  "achievements": [
    { "id": "first_core", "unlockedAt": "timestamp", "planetId": "mars" }
  ],

  // Settings
  "settings": {
    "musicVolume": 0.7,
    "sfxVolume": 0.8,
    "hapticsEnabled": true,
    "hapticsIntensity": 0.5,
    "touchSensitivity": 0.5,
    "colorblindMode": "none"
  }
}
```

## 2. PlanetState — Level 2 (Until Prestige)

One per planet; resets on prestige.

```json
{
  "planetId": "mars",     // mars, luna, io, europa, titan, venus, mercury, enceladus
  "isUnlocked": true,
  "timesCompleted": 0,    // Number of cores extracted
  "timesPrestiged": 0,
  "lastVisited": "timestamp",

  // Current Balance (resets on prestige)
  "credits": 0,

  // Common Upgrades (reset on prestige)
  "upgrades": {
    "fuelTank": 1,        // 1-6
    "drillStrength": 1,   // 1-5
    "cargoCapacity": 1,   // 1-6
    "hullArmor": 1,       // 1-5
    "engineSpeed": 1,     // 1-5
    "impactDampeners": 0  // 0-3
  },

  // Consumable Inventory (reset on prestige)
  "consumables": {
    "repairKits": 0,
    "fuelCells": 0,
    "bombs": 0,
    "teleporters": 0,
    "shields": 0
  },

  // Planet-specific statistics
  "statistics": {
    "totalRunsOnPlanet": 0,
    "totalCreditsEarnedHere": 0,
    "deepestDepthHere": 0,
    "fastestCoreHere": 0,
    "totalDeathsHere": 0
  }
}
```

## 3. CurrentRun — Level 3 (Current Run Only)

Active run state; resets when returning to surface or dying.

```json
{
  "planetId": "mars",
  "startTime": "timestamp",
  "currentDepth": 0,

  // Current Pod State
  "pod": {
    "position": {"x": 0, "y": 0},
    "velocity": {"x": 0, "y": 0},
    "fuel": 100,
    "hull": 50,
    "cargo": 0,
    "maxFuel": 100,
    "maxHull": 50,
    "maxCargo": 50
  },

  // Collected Minerals (this run only)
  "collectedMinerals": [
    { "type": "Iron", "quantity": 5, "totalValue": 125, "volumeUsed": 15 },
    { "type": "Gold", "quantity": 3, "totalValue": 450, "volumeUsed": 6 }
  ],

  // Run Statistics
  "statistics": {
    "deepestReached": 0,
    "tilesDestroyed": 0,
    "damagesTaken": 0,
    "hazardsEncountered": 0,
    "distanceTraveled": 0
  },

  // Active Consumables
  "activeEffects": [
    { "type": "shield", "remainingDuration": 5.2 }
  ]
}
```

## What Resets When

| Data | Forever | Until Prestige | During Run Only |
|------|:---:|:---:|:---:|
| Soul Crystals | ✓ | | |
| Golden Gems | ✓ | | |
| Epic Upgrades | ✓ | | |
| Planet Unlocks | ✓ | | |
| Achievements | ✓ | | |
| Compendium | ✓ | | |
| Statistics (Global) | ✓ | | |
| Credits | | ✓ | |
| Common Upgrades | | ✓ | |
| Consumables | | ✓ | |
| Statistics (Planet) | | ✓ | |
| Current Fuel/Hull | | | ✓ |
| Current Cargo | | | ✓ |
| Pod Position | | | ✓ |
| Collected Minerals | | | ✓ |
| Run Statistics | | | ✓ |

## Calculated Values (Not Stored)

Derived from persisted data:

**Earnings Bonus (EB)**
```
earningsBonus = (soulCrystals × soulCrystalMultiplier) × mineralValueBoostMultiplier

soulCrystalMultiplier      = 1.10 (or 1.12 with Epic Upgrade level 5)
mineralValueBoostMultiplier = 1.0 + (0.25 × mineralValueBoostLevel)
```

**Actual Fuel Capacity** — `actualFuelCapacity = baseFuelCapacity[fuelTankLevel]`

**Actual Drill Speed** — `actualDrillSpeed = baseDrillSpeed × (1 + (fasterDrillingLevel × 0.2))`

**Upgrade Costs** — `upgradeCost = baseUpgradeCost × (0.8 ^ cheaperUpgradesLevel)`

## Data Flow

### Starting a new run
1. Load `GameProfile` from storage.
2. Load `PlanetState` for the selected planet.
3. Create a fresh `CurrentRun`: `fuel` = fuelTank max, `hull` = hullArmor max, `cargo = 0`, `position` = surface spawn.
4. Generate planet terrain procedurally (fresh each run).
5. Begin gameplay.

### Ending a run — surface return
1. Sum mineral value from `CurrentRun.collectedMinerals` → add to `PlanetState.credits`.
2. Update planet + global statistics.
3. Check achievements and mineral discoveries.
4. Discard `CurrentRun`, save `GameProfile` and `PlanetState`.
5. Show run summary, then the upgrade shop.

### Ending a run — death
1. Check for Ejection Pod (consume one use, keep all cargo) or Cargo Insurance (keep 50% of mineral value); otherwise lose all cargo.
2. Update death statistics, discard `CurrentRun`, save, show death screen, return to surface.

### Prestige flow
1. Extract the core (must reach the core chamber).
2. `soulCrystalsEarned = sqrt(totalCreditsEarnedOnPlanet / 1000)` → add to `GameProfile.soulCrystals`.
3. Reset `PlanetState`: `credits = 0`, upgrades → level 1, consumables → 0.
4. Increment `PlanetState.timesPrestiged` and `GameProfile.totalCoresExtracted`.
5. Save, show prestige screen, unlock the next planet if requirements are met.

## Save File Structure

### iOS UserDefaults keys
```
"descent.gameProfile"   // JSON of entire GameProfile
"descent.lastSave"      // Timestamp
"descent.version"       // Game version for migration
```

### Alternative: JSON files (FileManager)
```
/Documents/DESCENT/
  ├── profile.json           // GameProfile
  ├── planets/
  │   ├── mars.json          // PlanetState
  │   ├── luna.json
  │   └── ...
  └── backups/
      └── profile_backup.json
```

## Validation & Recovery

**On load:** clamp `soulCrystals` to ≥ 0, cap upgrade levels at max, lock un-unlocked planets, validate numeric ranges, check for corruption.

**On save:** validate before writing, create a backup before overwriting, verify the write, retain old data if the write fails.

## Migration

Saves carry a version envelope; on structure change, detect old version → run a migration function → bump `dataVersion` → save.

```json
{ "dataVersion": 1, "gameVersion": "1.0.0", "profile": { "...": "..." } }
```

```swift
func migrateV1toV2(oldData: GameProfileV1) -> GameProfileV2 {
    var newData = GameProfileV2()
    newData.soulCrystals = oldData.soulCrystals
    // ... map old fields to new
    newData.newFeature = defaultValue
    return newData
}
```

## Cloud Save (Future)

Sync the entire `GameProfile` and all `PlanetState`s; exclude `CurrentRun` (device-specific). Conflict resolution candidates: most recent `lastPlayed` wins, highest `soulCrystals` wins, or let the player choose.

## Debug / Cheat Data

Development only:

```json
{
  "debugMode": true,
  "cheats": {
    "unlockAllPlanets": false,
    "infiniteFuel": false,
    "infiniteHull": false,
    "instantDrill": false,
    "freeSoulCrystals": 0,
    "freeGoldenGems": 0
  }
}
```

## Related

[[Architecture]] · [[Game Design]]
