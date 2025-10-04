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
        case 2: return 150
        case 3: return 200
        case 4: return 300
        case 5: return 400
        case 6: return 500
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

    // Upgrade costs (base costs, scaled by 1.5x per level)
    static let baseCosts: [String: Double] = [
        "fuelTank": 100,
        "drillStrength": 150,
        "cargoCapacity": 120,
        "hullArmor": 130,
        "engineSpeed": 140,
        "impactDampeners": 200
    ]

    /// Calculate upgrade cost for a specific upgrade type
    static func calculateCost(upgradeType: String, currentLevel: Int, discountMultiplier: Double = 1.0) -> Double {
        guard let baseCost = baseCosts[upgradeType] else { return 0 }
        let cost = baseCost * pow(1.5, Double(currentLevel - 1))
        return cost * discountMultiplier
    }
}

// MARK: - Consumables

struct Consumables: Codable {
    var repairKits: Int = 0
    var fuelCells: Int = 0
    var bombs: Int = 0
    var teleporters: Int = 0
    var shields: Int = 0
}

// MARK: - Planet Statistics

struct PlanetStatistics: Codable {
    var totalRunsOnPlanet: Int = 0
    var totalCreditsEarnedHere: Double = 0
    var deepestDepthHere: Double = 0
    var fastestCoreHere: TimeInterval = 0
    var totalDeathsHere: Int = 0
}
