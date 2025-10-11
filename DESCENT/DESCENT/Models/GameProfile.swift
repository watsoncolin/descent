//
//  GameProfile.swift
//  DESCENT
//
//  Level 1 persistence - Never resets, saved across all play sessions
//

import Foundation

// MARK: - Game Profile

class GameProfile: Codable {

    // MARK: - Identity
    var profileId: String
    var playerName: String?
    var createdAt: Date
    var lastPlayed: Date
    var totalPlayTime: TimeInterval  // seconds

    // MARK: - Permanent Progression
    var soulCrystals: Int = 0
    var goldenGems: Int = 0
    var totalCreditsEarned: Double = 0
    var totalRunsCompleted: Int = 0
    var totalCoresExtracted: Int = 0
    var totalDeathCount: Int = 0

    // MARK: - Epic Upgrades (Permanent)
    var epicUpgrades: EpicUpgrades

    // MARK: - Planet States
    var planets: [PlanetState]

    // MARK: - Statistics
    var statistics: GlobalStatistics

    // MARK: - Collection/Compendium
    var discoveredMinerals: Set<String> = []

    // MARK: - Achievements
    var achievements: [Achievement] = []

    // MARK: - Settings
    var settings: GameSettings

    // MARK: - Initialization

    init() {
        self.profileId = UUID().uuidString
        self.createdAt = Date()
        self.lastPlayed = Date()
        self.totalPlayTime = 0

        self.epicUpgrades = EpicUpgrades()
        self.statistics = GlobalStatistics()
        self.settings = GameSettings()

        // Initialize all planets (locked except Mars)
        self.planets = [
            PlanetState(planetId: "mars", isUnlocked: true),
            PlanetState(planetId: "luna", isUnlocked: false),
            PlanetState(planetId: "io", isUnlocked: false),
            PlanetState(planetId: "europa", isUnlocked: false),
            PlanetState(planetId: "titan", isUnlocked: false),
            PlanetState(planetId: "venus", isUnlocked: false),
            PlanetState(planetId: "mercury", isUnlocked: false),
            PlanetState(planetId: "enceladus", isUnlocked: false)
        ]
    }

    // MARK: - Helper Methods

    func getPlanetState(_ planetId: String) -> PlanetState? {
        return planets.first { $0.planetId == planetId }
    }

    func addDiscoveredMineral(_ mineralType: String) {
        discoveredMinerals.insert(mineralType)
    }

    func unlockAchievement(_ achievementId: String, planetId: String? = nil) {
        // Check if already unlocked
        guard !achievements.contains(where: { $0.id == achievementId }) else { return }

        let achievement = Achievement(id: achievementId, unlockedAt: Date(), planetId: planetId)
        achievements.append(achievement)
    }

    // MARK: - Soul Crystal Earnings Bonus

    /// Total earnings bonus from Soul Crystals (each crystal = 10% or 12% with amplifier)
    var soulCrystalEarningsBonus: Double {
        return 1.0 + (Double(soulCrystals) * (epicUpgrades.soulCrystalMultiplier / 100.0))
    }

    /// Combined mineral value multiplier (Soul Crystals + Epic Mineral Value Boost)
    var totalMineralValueMultiplier: Double {
        return soulCrystalEarningsBonus * epicUpgrades.mineralValueMultiplier
    }
}

// MARK: - Epic Upgrades

struct EpicUpgrades: Codable {
    var soulCrystalAmplifier: Int = 0       // 0-5
    var mineralValueBoost: Int = 0          // 0-5
    var autoRefuel: Bool = false
    var autoRepair: Bool = false
    var advancedScanner: Bool = false
    var ejectionPod: Bool = false
    var cargoInsurance: Bool = false
    var advancedHUD: Bool = false
    var heatResistance: Int = 0             // 0-3
    var coldResistance: Int = 0             // 0-3
    var cheaperUpgrades: Int = 0            // 0-5
    var fasterDrilling: Int = 0             // 0-3
    var supplyPodCapacity: Int = 1          // 1-5 (default: 5 items)

    // Calculated multipliers
    var soulCrystalMultiplier: Double {
        return soulCrystalAmplifier == 5 ? 1.12 : 1.10
    }

    var mineralValueMultiplier: Double {
        return 1.0 + (Double(mineralValueBoost) * 0.25)
    }

    var upgradeDiscountMultiplier: Double {
        return pow(0.8, Double(cheaperUpgrades))
    }

    // Supply pod capacity based on level
    var actualSupplyPodCapacity: Int {
        switch supplyPodCapacity {
        case 1: return 5
        case 2: return 8
        case 3: return 12
        case 4: return 15
        case 5: return 20
        default: return 5
        }
    }

    var drillSpeedMultiplier: Double {
        return 1.0 + (Double(fasterDrilling) * 0.2)
    }
}

// MARK: - Global Statistics

struct GlobalStatistics: Codable {
    var deepestDepthReached: Double = 0
    var highestSingleRunValue: Double = 0
    var fastestCoreTime: TimeInterval = 0
    var totalMineralsCollected: Int = 0
    var favoriteMineral: String = ""
    var totalDistanceDrilled: Double = 0
}

// MARK: - Achievement

struct Achievement: Codable {
    let id: String
    let unlockedAt: Date
    let planetId: String?
}

// MARK: - Game Settings

struct GameSettings: Codable {
    var musicVolume: Float = 0.7
    var sfxVolume: Float = 0.8
    var hapticsEnabled: Bool = true
    var hapticsIntensity: Float = 0.5
    var touchSensitivity: Float = 0.5
    var colorblindMode: String = "none"  // "none", "protanopia", "deuteranopia", "tritanopia"
}
