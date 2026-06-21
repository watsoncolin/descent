
import CoreGraphics
import SpriteKit

struct K {

    // MARK: - Game Config
    struct Game {
        static let targetFPS = 60
        static let physicsTimeStep: CGFloat = 1.0 / 60.0
    }

    // MARK: - Sizes
    struct Size {
        static let terrainTile: CGFloat = 24
        static let podSize: CGFloat = 48
    }

    // MARK: - Physics Categories
    struct Physics {
        static let pod: UInt32 = 0x1 << 0
        static let terrain: UInt32 = 0x1 << 1
        static let material: UInt32 = 0x1 << 2
        static let hazard: UInt32 = 0x1 << 3
    }

    // MARK: - Z-Positions
    struct ZPosition {
        static let background: CGFloat = 0
        static let terrain: CGFloat = 10
        static let materials: CGFloat = 15
        static let pod: CGFloat = 20
        static let particles: CGFloat = 25
        static let hud: CGFloat = 100
    }

    // MARK: - Colors (will expand later)
    struct Colors {
        static let mars = UIColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1.0)
        // Add more colors as needed
    }
}

// MARK: - Logging

/// Lightweight gated logger. All gameplay logging routes through here so the
/// console stays quiet by default. Flip `Log.verbose = true` to surface gameplay
/// logs while debugging. Compiles to nothing in release builds.
enum Log {
    /// Set to `true` during a debug session to see verbose gameplay logs.
    static var verbose = false

    @inline(__always)
    static func v(_ message: @autoclosure () -> String) {
        #if DEBUG
        if verbose { print(message()) }
        #endif
    }
}

// MARK: - Tuning (fuel & damage)

extension K {
    /// Fuel costs. See docs/wiki/Fuel System.md.
    struct Fuel {
        /// Fuel to drill one block = baseDrillCost × strataHardness / drillLevel.
        /// Linear in hardness; charged once, up front (not per frame).
        static let baseDrillCost: Double = 1.5
        /// Fuel per second at full thrust while flying.
        static let baseMoveCost: Double = 1.5
    }

    /// Impact-damage tuning. See docs/wiki/Hull and Damage.md.
    struct Damage {
        /// Terminal velocity (px/s). All velocity is clamped to this every frame so
        /// impact speed — and therefore damage — stays bounded and predictable.
        static let maxFallSpeed: CGFloat = 350
        /// HP of damage per (px/s) of impact speed above the dampener threshold.
        static let multiplier: CGFloat = 0.3
        /// No impact damage within this many px of the surface (safe zone near the shop).
        static let safeZoneDepth: CGFloat = 150
        /// Minimum seconds between impact-damage events.
        static let cooldown: TimeInterval = 0.4
        /// Impact speed (px/s) below which the given dampener level takes no damage.
        static func threshold(dampeners: Int) -> CGFloat {
            switch dampeners {
            case 0: return 200
            case 1: return 275
            case 2: return 330
            default: return .infinity   // Level 3+: immune to fall damage
            }
        }
    }
}
