//
//  Material.swift
//  DESCENT
//
//  Created by Colin Watson on 10/4/25.
//

import Foundation

/// Represents a mineable material with its properties
struct Material {
    let type: MaterialType
    let value: Double       // Base value in credits
    let volume: Int         // Cargo space it takes up
    let hardness: Int       // Drill level required (1-5)

    /// Material types available in the game
    enum MaterialType: String, CaseIterable {
        // Tier 1 - Common (Mars: 0-150m)
        case carbon = "carbon"
        case coal = "coal"
        case iron = "iron"
        case copper = "copper"
        case silicon = "silicon"
        case aluminum = "aluminum"

        // Tier 2 - Uncommon (Mars: 50-300m)
        case silver = "silver"
        case gold = "gold"

        // Tier 3 - Rare (Mars: 150-500m)
        case platinum = "platinum"
        case ruby = "ruby"
        case emerald = "emerald"
        case diamond = "diamond"
        case titanium = "titanium"
        case neodymium = "neodymium"
        case rhodium = "rhodium"

        // Tier 4 - Core
        case darkMatter = "darkMatter"

        var baseValue: Double {
            switch self {
            case .carbon, .coal: return 10
            case .iron: return 25
            case .copper: return 30
            case .silicon: return 50
            case .aluminum: return 60
            case .silver: return 75
            case .gold: return 150
            case .platinum: return 250
            case .titanium: return 200
            case .neodymium: return 300
            case .ruby: return 500
            case .emerald: return 600
            case .diamond: return 800
            case .rhodium: return 900
            case .darkMatter: return 10000
            }
        }

        var volume: Int {
            switch self {
            case .carbon, .coal, .iron: return 5
            case .copper, .silicon, .aluminum: return 3
            case .silver, .gold: return 2
            case .platinum, .titanium: return 2
            case .neodymium: return 2
            case .ruby, .emerald, .diamond: return 1  // Gems are small
            case .rhodium: return 1
            case .darkMatter: return 1  // Incredibly dense
            }
        }

        var hardness: Int {
            switch self {
            case .carbon, .coal: return 1
            case .iron, .copper, .silicon: return 1
            case .aluminum, .silver: return 2
            case .gold: return 2
            case .platinum, .neodymium: return 3
            case .ruby, .emerald: return 3
            case .titanium, .diamond: return 4
            case .rhodium: return 4
            case .darkMatter: return 5
            }
        }
    }

    /// Create a material instance with planet multiplier applied
    init(type: MaterialType, planetMultiplier: Double = 1.0) {
        self.type = type
        self.value = type.baseValue * planetMultiplier
        self.volume = type.volume
        self.hardness = type.hardness
    }
}
