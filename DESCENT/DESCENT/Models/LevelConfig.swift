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
    let tileSize: Double
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
    let colorHex: String
    let drillSpeedModifier: Double
    let minimumDrillLevel: Int?
    let resources: [ResourceConfig]
    let hazards: [HazardConfig]
    let specialFeatures: [String]

    // Computed property for UIColor (not part of JSON)
    var color: UIColor {
        return UIColor(hex: colorHex) ?? .red
    }

    // Check if a depth is within this layer
    func contains(depth: Double) -> Bool {
        return depth >= depthMin && depth < depthMax
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
