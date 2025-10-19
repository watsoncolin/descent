//
//  TerrainType.swift
//  DESCENT
//
//  Defines visual terrain types with gradient colors for continuous terrain rendering
//

import UIKit

enum TerrainType {
    case sand
    case stone
    case rock
    case marsRock

    /// Surface layer gradient colors (lighter, visible by default)
    var surfaceGradientColors: [UIColor] {
        switch self {
        case .sand:
            return [
                UIColor(hex: "#c4a57b")!,  // Light sandy brown
                UIColor(hex: "#b89a70")!,
                UIColor(hex: "#a89060")!,
                UIColor(hex: "#9c8555")!   // Dark sandy brown
            ]
        case .stone:
            return [
                UIColor(hex: "#6a7a8a")!,  // Light gray
                UIColor(hex: "#5a6a7a")!   // Dark gray
            ]
        case .rock:
            return [
                UIColor(hex: "#7a8090")!,  // Light rock gray
                UIColor(hex: "#6a7080")!   // Dark rock gray
            ]
        case .marsRock:
            return [
                UIColor(hex: "#b85a40")!,  // Mars red-brown
                UIColor(hex: "#a04a30")!   // Dark mars brown
            ]
        }
    }

    /// Excavated layer gradient colors (darker, revealed when mined)
    /// ~35-45% darker than surface to show depth/compaction
    var excavatedGradientColors: [UIColor] {
        switch self {
        case .sand:  // ~35% darker - compacted sand
            return [
                UIColor(hex: "#8c7545")!,
                UIColor(hex: "#7c6535")!,
                UIColor(hex: "#6c5525")!,
                UIColor(hex: "#5c4515")!
            ]
        case .stone:  // ~40% darker - dense bedrock
            return [
                UIColor(hex: "#4a5a6a")!,
                UIColor(hex: "#3a4a5a")!
            ]
        case .rock:  // ~35% darker - deep metamorphic rock
            return [
                UIColor(hex: "#5a6070")!,
                UIColor(hex: "#4a5060")!
            ]
        case .marsRock:  // ~45% darker - ancient planetary core
            return [
                UIColor(hex: "#8a3a20")!,
                UIColor(hex: "#6a2a10")!
            ]
        }
    }

    /// Legacy: returns surface colors for backwards compatibility
    var gradientColors: [UIColor] {
        return surfaceGradientColors
    }

    /// Color for organic variations (large ellipses)
    var variationColor: UIColor {
        switch self {
        case .sand:
            return UIColor(hex: "#9a8050")!
        case .stone:
            return UIColor(hex: "#4a5a6a")!
        case .rock:
            return UIColor(hex: "#5a6070")!
        case .marsRock:
            return UIColor(hex: "#9a4a30")!
        }
    }

    /// Color for diagonal flow patterns
    var flowColor: UIColor {
        switch self {
        case .sand:
            return UIColor(hex: "#b89a60")!
        case .stone:
            return UIColor(hex: "#5a6a7a")!
        case .rock:
            return UIColor(hex: "#6a7080")!
        case .marsRock:
            return UIColor(hex: "#a85a40")!
        }
    }

    /// Variation opacity range
    var variationOpacityRange: ClosedRange<CGFloat> {
        switch self {
        case .sand:
            return 0.08...0.15
        case .stone:
            return 0.12...0.18
        case .rock:
            return 0.15...0.20
        case .marsRock:
            return 0.12...0.18
        }
    }

    /// Map a stratum name to its appropriate TerrainType
    /// This is the canonical mapping used by both TerrainManager and LevelExplorerScene
    static func fromStratumName(_ name: String) -> TerrainType {
        let lowerName = name.lowercased()

        // Match in order of specificity (most specific first)
        if lowerName.contains("core") {
            return .marsRock  // Core zones use Mars rock coloring
        } else if lowerName.contains("deep") {
            return .rock  // Deep rock layers
        } else if lowerName.contains("stone") || lowerName.contains("sediment") {
            return .stone  // Stone/sediment layers
        } else if lowerName.contains("sand") || lowerName.contains("surface") || lowerName.contains("regolith") {
            return .sand  // Surface sand/regolith
        } else if lowerName.contains("rock") {
            return .rock  // Generic rock
        } else {
            return .sand  // Default fallback
        }
    }
}
