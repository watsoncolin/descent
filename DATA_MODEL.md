# DESCENT - Data Model & Persistence

## Overview

This document defines all data that persists between runs, sessions, and prestiges. Understanding what resets vs what persists is critical for the game's progression system.

---

## Data Persistence Levels

### Level 1: Persists Forever (Account Level)
Never resets, saved across all play sessions

### Level 2: Persists Until Prestige (Planet Level)
Resets when you prestige a specific planet

### Level 3: Persists During Run Only (Session Level)
Resets when run ends (return to surface or die)

---

## Core Data Structures

### 1. GameProfile (Level 1 - Forever)

**Top-level save data, never resets**

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
    "mineralValueBoost": 0,            // 0-5
    "autoRefuel": false,
    "autoRepair": false,
    "advancedScanner": false,
    "ejectionPod": false,
    "cargoInsurance": false,
    "advancedHUD": false,
    "heatResistance": 0,               // 0-3
    "coldResistance": 0,               // 0-3
    "cheaperUpgrades": 0,              // 0-5
    "fasterDrilling": 0                // 0-3
  },
  
  // Planet States (one per planet)
  "planets": [
    // PlanetState objects (see below)
  ],
  
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
  "discoveredMinerals": [
    "Iron", "Gold", "Pyronium", etc.
  ],
  
  // Achievements
  "achievements": [
    {
      "id": "first_core",
      "unlockedAt": "timestamp",
      "planetId": "mars"
    }
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

---

### 2. PlanetState (Level 2 - Until Prestige)

**One per planet, resets on prestige**

```json
{
  "planetId": "mars",               // mars, luna, io, europa, titan, venus, mercury, enceladus
  "isUnlocked": true,
  "timesCompleted": 0,              // Number of cores extracted
  "timesPrestiged": 0,
  "lastVisited": "timestamp",
  
  // Current Balance (resets on prestige)
  "credits": 0,
  
  // Common Upgrades (reset on prestige)
  "upgrades": {
    "fuelTank": 1,                  // 1-6
    "drillStrength": 1,             // 1-5
    "cargoCapacity": 1,             // 1-6
    "hullArmor": 1,                 // 1-5
    "engineSpeed": 1,               // 1-5
    "impactDampeners": 0            // 0-3
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

---

### 3. CurrentRun (Level 3 - Current Run Only)

**Active run state, resets when returning to surface or dying**

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
    {
      "type": "Iron",
      "quantity": 5,
      "totalValue": 125,
      "volumeUsed": 15
    },
    {
      "type": "Gold",
      "quantity": 3,
      "totalValue": 450,
      "volumeUsed": 6
    }
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
    {
      "type": "shield",
      "remainingDuration": 5.2
    }
  ]
}
```

---

## Calculated Values (Not Stored)

These are derived from persisted data:

### Earnings Bonus (EB)
```
earningsBonus = (soulCrystals × soulCrystalMultiplier) × mineralValueBoostMultiplier

Where:
- soulCrystalMultiplier = 1.10 (or 1.12 with Epic Upgrade level 5)
- mineralValueBoostMultiplier = 1.0 + (0.25 × mineralValueBoostLevel)
```

### Actual Fuel Capacity
```
actualFuelCapacity = baseFuelCapacity[fuelTankLevel]
```

### Actual Drill Speed
```
actualDrillSpeed = baseDrillSpeed × (1 + (fasterDrillingLevel × 0.2))
```

### Upgrade Costs
```
upgradeCost = baseUpgradeCost × (0.8 ^ cheaperUpgradesLevel)
```

---

## Data Flow Diagrams

### Starting a New Run
```
1. Load GameProfile from storage
2. Load PlanetState for selected planet
3. Create new CurrentRun with initial values:
   - fuel = planetState.upgrades.fuelTank max value
   - hull = planetState.upgrades.hullArmor max value
   - cargo = 0
   - position = surface spawn point
4. Generate planet terrain (procedurally, fresh each run)
5. Begin gameplay
```

### Ending a Run (Surface Return)
```
1. Calculate total mineral value from CurrentRun.collectedMinerals
2. Add to PlanetState.credits
3. Update PlanetState.statistics
4. Update GameProfile.statistics
5. Check for new achievements
6. Check for new mineral discoveries
7. Discard CurrentRun data
8. Save GameProfile and PlanetState
9. Show run summary screen
10. Show upgrade shop
```

### Ending a Run (Death)
```
1. Check for Ejection Pod or Cargo Insurance
2. If Ejection Pod active:
   - Consume one use
   - Keep all cargo
3. Else if Cargo Insurance:
   - Keep 50% of mineral value
4. Else:
   - Lose all cargo
5. Update death statistics
6. Discard CurrentRun data
7. Save GameProfile and PlanetState
8. Show death screen with stats
9. Return to surface
```

### Prestige Flow
```
1. Extract core (must reach core chamber)
2. Calculate Soul Crystals earned:
   soulCrystalsEarned = sqrt(totalCreditsEarnedOnPlanet / 1000)
3. Add to GameProfile.soulCrystals
4. Reset PlanetState:
   - credits = 0
   - upgrades = all back to level 1
   - consumables = all back to 0
5. Increment PlanetState.timesPrestiged
6. Increment GameProfile.totalCoresExtracted
7. Save GameProfile and PlanetState
8. Show prestige screen with new Soul Crystal total
9. Unlock next planet if requirements met
```

---

## Save File Structure

### iOS UserDefaults Keys
```
"descent.gameProfile"              // JSON of entire GameProfile
"descent.lastSave"                 // Timestamp
"descent.version"                  // Game version for migration
```

### Alternative: JSON Files (FileManager)
```
/Documents/
  └── DESCENT/
      ├── profile.json           // GameProfile
      ├── planets/
      │   ├── mars.json         // PlanetState
      │   ├── luna.json
      │   └── ...
      └── backups/
          └── profile_backup.json
```

---

## Data Validation Rules

### On Load
- If soulCrystals < 0, reset to 0
- If upgrade level > max, cap at max
- If planet not unlocked, lock it
- Validate all numeric ranges
- Check for data corruption

### On Save
- Validate all data before writing
- Create backup before overwriting
- Verify write succeeded
- If write fails, retain old data

---

## Cloud Save Support (Future)

**Data to sync:**
- Entire GameProfile
- All PlanetStates
- Exclude: CurrentRun (device-specific)

**Conflict resolution:**
- Most recent lastPlayed wins
- Or: Highest soulCrystals wins
- Or: Let player choose

---

## Migration Strategy

### Version Updates
```json
{
  "dataVersion": 1,
  "gameVersion": "1.0.0",
  "profile": { ... }
}
```

**When structure changes:**
1. Detect old version
2. Run migration function
3. Update dataVersion
4. Save migrated data

**Example Migration:**
```swift
func migrateV1toV2(oldData: GameProfileV1) -> GameProfileV2 {
    var newData = GameProfileV2()
    newData.soulCrystals = oldData.soulCrystals
    // ... map old fields to new
    newData.newFeature = defaultValue
    return newData
}
```

---

## Debug/Cheat Data

**For development only:**

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

---

## Summary Table

| Data | Forever | Until Prestige | During Run Only |
|------|---------|----------------|-----------------|
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

---

## Implementation Checklist

- [ ] Define Swift structs/classes for each data model
- [ ] Implement Codable for JSON serialization
- [ ] Create SaveManager singleton
- [ ] Implement save/load functions
- [ ] Add data validation
- [ ] Add backup system
- [ ] Create migration system
- [ ] Add debug/cheat menu for testing
- [ ] Test save/load cycle
- [ ] Test prestige reset behavior
- [ ] Test data corruption recovery