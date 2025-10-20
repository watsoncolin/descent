//
//  LevelConfig.swift
//  DESCENT
//
//  Level configuration data structures for planet design
//

import Foundation
import UIKit

// MARK: - Planet Configuration

struct PlanetConfig: Codable {
    let name: String
    let totalDepth: Double
    let coreDepth: Double
    let valueMultiplier: Double
    let gravity: Double?                // Gravity multiplier relative to Earth (e.g., Mars = 0.38, optional for backward compatibility)
    let tileSize: Double

    // Planet metadata (optional for backward compatibility)
    let difficulty: String?             // Tutorial/Beginner/Easy/Medium/Hard/Expert/Master
    let theme: String?                  // Brief description of visual/geological theme
    let planetOrder: Int?               // Position in 8-planet sequence (1-8)
    let unlockRequirements: String?     // Prerequisites to access (e.g., "Extract Mars core")

    let strata: [StrataLayer]
    let progressionGates: [ProgressionGate]
    let economyBalance: EconomyBalance
}

// MARK: - Strata Layer

struct StrataLayer: Codable {
    let name: String
    let depthMin: Double
    let depthMax: Double
    let hardness: Double
    let colorHex: String?                // Legacy: single base color (optional for backward compatibility)
    let surfaceColors: [String]?         // Surface layer gradient colors (lighter, visible before mining)
    let excavatedColors: [String]?       // Excavated layer gradient colors (darker, revealed after mining)
    let contrast: Double?                // Contrast percentage between surface and excavated (~35-45%)
    let drillSpeedModifier: Double
    let minimumDrillLevel: Int?
    let resources: [ResourceConfig]
    let hazards: [HazardConfig]
    let obstacles: [ObstacleConfig]
    let specialFeatures: [String]

    // Computed property for base color (legacy support)
    var color: UIColor {
        // If colorHex is provided, use it
        if let hex = colorHex {
            return UIColor(hex: hex) ?? .red
        }
        // Otherwise use middle color from surface gradient
        if let surface = surfaceColors, let middleHex = surface[safe: surface.count / 2] {
            return UIColor(hex: middleHex) ?? .red
        }
        return .red
    }

    // Computed property for surface gradient colors
    var surfaceGradient: [UIColor] {
        if let colors = surfaceColors {
            return colors.compactMap { UIColor(hex: $0) }
        }
        // Fallback: generate from colorHex (legacy)
        if let hex = colorHex, let baseColor = UIColor(hex: hex) {
            let lighter = baseColor.adjustBrightness(by: 1.2)
            return [lighter, baseColor]
        }
        return [.gray, .darkGray]
    }

    // Computed property for excavated gradient colors
    var excavatedGradient: [UIColor] {
        if let colors = excavatedColors {
            return colors.compactMap { UIColor(hex: $0) }
        }
        // Fallback: generate from colorHex (legacy)
        if let hex = colorHex, let baseColor = UIColor(hex: hex) {
            let darker = baseColor.adjustBrightness(by: 0.7)
            return [baseColor, darker]
        }
        return [.darkGray, .black]
    }

    // Check if a depth is within this layer
    func contains(depth: Double) -> Bool {
        return depth >= depthMin && depth < depthMax
    }
}

// MARK: - Array Safe Subscript Extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Resource Configuration

struct ResourceConfig: Codable {
    let type: String              // e.g., "carbon", "iron", "gold"
    let seedRate: Double           // 0.0 to 1.0 (vein seed placement rate)
    let value: Double              // Base dollar value
    let size: Double               // Cargo space units
    let veinSizeMin: Int           // Minimum tiles in vein
    let veinSizeMax: Int           // Maximum tiles in vein
    let colorHex: String?          // Optional color override
    let clusterRadiusMin: Int?     // Minimum cluster radius in blocks
    let clusterRadiusMax: Int?     // Maximum cluster radius in blocks
    let clusterSizeMin: Int?       // Minimum number of veins per cluster
    let clusterSizeMax: Int?       // Maximum number of veins per cluster

    var color: UIColor {
        return UIColor(hex: colorHex ?? "#FFFFFF") ?? .white
    }
}

// MARK: - Hazard Configuration

struct HazardConfig: Codable {
    let type: String               // "gasPocket", "caveIn", "unstableRock", etc.
    let spawnRate: Double          // 0.0 to 1.0 (percentage chance)
    let damage: Double             // HP damage when triggered
    let size: Int?                 // Tiles affected (for gas pockets)
    let description: String?
    let specialEffects: String?    // Additional effects (e.g., "20% DoT over 3s")
}

// MARK: - Obstacle Configuration

struct ObstacleConfig: Codable {
    let type: String               // "bedrock", "hardCrystal", "reinforcedRock"
    let coverage: Double           // 0.0 to 1.0 (percentage of layer coverage)
    let formationSizes: [FormationSize]  // Possible formation dimensions
    let minimumDrillLevel: Int?    // Drill level required (nil = indestructible)
    let bombOnly: Bool?            // If true, only bombs can destroy
    let description: String?       // Description of obstacle
}

struct FormationSize: Codable {
    let width: Int
    let height: Int
}

// MARK: - Progression Gate

struct ProgressionGate: Codable {
    let depth: Double
    let requirement: String        // Description of what's needed
    let recommendedDrillLevel: Int?
}

// MARK: - Economy Balance

struct EconomyBalance: Codable {
    let expectedEarnings: [DepthEarning]
    let prestigeSoulCrystals: Int
    let runsToMaxOut: Int
}

struct DepthEarning: Codable {
    let depth: Double
    let earnings: Double
}

// MARK: - UIColor Hex Extension

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count
        let r, g, b, a: CGFloat

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
