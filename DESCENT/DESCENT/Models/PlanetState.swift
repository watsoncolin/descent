//
//  PlanetState.swift
//  DESCENT
//
//  Level 2 persistence - Resets on prestige
//

import Foundation

// MARK: - Planet State

class PlanetState: Codable {

    // MARK: - Identity
    let planetId: String
    var isUnlocked: Bool
    var timesCompleted: Int = 0
    var timesPrestiged: Int = 0
    var lastVisited: Date?

    // MARK: - Current Balance (resets on prestige)
    var credits: Double = 0

    // MARK: - Common Upgrades (reset on prestige)
    var upgrades: CommonUpgrades

    // MARK: - Consumable Inventory (reset on prestige)
    var consumables: Consumables

    // MARK: - Planet-Specific Statistics
    var statistics: PlanetStatistics

    // MARK: - Initialization

    init(planetId: String, isUnlocked: Bool) {
        self.planetId = planetId
        self.isUnlocked = isUnlocked
        self.upgrades = CommonUpgrades()
        self.consumables = Consumables()
        self.statistics = PlanetStatistics()
    }

    // MARK: - Prestige

    /// Reset planet state for prestige
    func prestige() {
        credits = 0
        upgrades = CommonUpgrades()
        consumables = Consumables()
        timesPrestiged += 1

        print("🔄 Prestige on \(planetId) - Reset credits and upgrades")
    }

    // MARK: - Computed Properties

    var maxFuel: Double {
        // Based on FUEL_SYSTEM.md
        switch upgrades.fuelTank {
        case 1: return 100
        case 2: return 250
        case 3: return 500
        case 4: return 1000
        case 5: return 2000
        case 6: return 4000
        default: return 100
        }
    }

    var maxHull: Double {
        // Based on HULL_SYSTEM.md
        switch upgrades.hullArmor {
        case 1: return 50
        case 2: return 75
        case 3: return 100
        case 4: return 150
        case 5: return 200
        default: return 50
        }
    }

    var cargoCapacity: Int {
        // Level 1: 50, Level 2: 75, Level 3: 100, Level 4: 125, Level 5: 150, Level 6: 175
        return 50 + (upgrades.cargoCapacity - 1) * 25
    }
}

// MARK: - Common Upgrades

struct CommonUpgrades: Codable {
    var fuelTank: Int = 1           // 1-6
    var drillStrength: Int = 1      // 1-5
    var cargoCapacity: Int = 1      // 1-6
    var hullArmor: Int = 1          // 1-5
    var engineSpeed: Int = 1        // 1-5
    var impactDampeners: Int = 0    // 0-3

    // Upgrade costs per level (level 1 -> level 2 cost, level 2 -> level 3 cost, etc.)
    static let upgradeCosts: [String: [Int: Double]] = [
        "fuelTank": [
            1: 500,   // Level 1 -> 2
            2: 1500,   // Level 2 -> 3
            3: 4000,   // Level 3 -> 4
            4: 10000,   // Level 4 -> 5
            5: 15000    // Level 5 -> 6
        ],
        "drillStrength": [
            1: 150,   // Level 1 -> 2
            2: 225,   // Level 2 -> 3
            3: 340,   // Level 3 -> 4
            4: 510    // Level 4 -> 5
        ],
        "cargoCapacity": [
            1: 120,   // Level 1 -> 2
            2: 180,   // Level 2 -> 3
            3: 270,   // Level 3 -> 4
            4: 405,   // Level 4 -> 5
            5: 608    // Level 5 -> 6
        ],
        "hullArmor": [
            1: 130,   // Level 1 -> 2
            2: 195,   // Level 2 -> 3
            3: 293,   // Level 3 -> 4
            4: 440    // Level 4 -> 5
        ],
        "engineSpeed": [
            1: 140,   // Level 1 -> 2
            2: 210,   // Level 2 -> 3
            3: 315,   // Level 3 -> 4
            4: 473    // Level 4 -> 5
        ],
        "impactDampeners": [
            1: 200,   // Level 1 -> 2
            2: 300    // Level 2 -> 3
        ]
    ]

    /// Get upgrade cost for a specific upgrade type at current level
    static func getUpgradeCost(upgradeType: String, currentLevel: Int) -> Double {
        return upgradeCosts[upgradeType]?[currentLevel] ?? 0
    }
}

// MARK: - Consumables

struct Consumables: Codable {
    var repairKits: Int = 100
    var fuelCells: Int = 100
    var bombs: Int = 100
    var teleporters: Int = 100
    var shields: Int = 100

    // Consumable costs (fixed prices)
    static let costs: [String: Double] = [
        "repairKit": 300,
        "fuelCell": 200,
        "bomb": 500,
        "teleporter": 400,
        "shield": 600
    ]

    /// Get cost for a specific consumable type
    static func getCost(_ type: String) -> Double {
        return costs[type] ?? 0
    }
}

// MARK: - Planet Statistics

struct PlanetStatistics: Codable {
    var totalRunsOnPlanet: Int = 0
    var totalCreditsEarnedHere: Double = 0
    var deepestDepthHere: Double = 0
    var fastestCoreHere: TimeInterval = 0
    var totalDeathsHere: Int = 0
}
