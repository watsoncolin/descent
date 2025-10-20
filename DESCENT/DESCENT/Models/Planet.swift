//
//  Planet.swift
//  DESCENT
//
//  Created by Colin Watson on 10/4/25.
//

import Foundation

/// Represents the different planets you can mine on
enum Planet: String, CaseIterable {
    case mars = "Mars"
    case luna = "Luna"
    case io = "Io"
    case europa = "Europa"
    case titan = "Titan"
    case venus = "Venus"
    case mercury = "Mercury"
    case enceladus = "Enceladus"

    /// Cache for loaded planet configs (shared across all instances)
    private static var configCache: [Planet: PlanetConfig] = [:]

    /// Load planet configuration from JSON file with caching
    /// Returns nil if file cannot be loaded
    func loadConfig() -> PlanetConfig? {
        // Check cache first
        if let cached = Planet.configCache[self] {
            return cached
        }

        // Load from JSON
        let filename = rawValue.lowercased()
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ Could not find \(filename).json in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(PlanetConfig.self, from: data)

            // Cache the loaded config
            Planet.configCache[self] = config

            return config
        } catch {
            print("⚠️ Error loading \(filename).json: \(error)")
            return nil
        }
    }

    /// Value multiplier for materials on this planet (from JSON config)
    var multiplier: Double {
        return loadConfig()?.valueMultiplier ?? 1.0
    }

    /// Core depth in meters (from JSON config)
    var coreDepth: Double {
        return loadConfig()?.coreDepth ?? 2500
    }

    /// Gravity strength (affects falling speed) - from JSON config
    /// Fallback values used if not present in JSON for backward compatibility
    var gravity: Double {
        if let configGravity = loadConfig()?.gravity {
            return configGravity
        }

        // Fallback values for planets without gravity in JSON yet
        switch self {
        case .mars: return 0.38
        case .luna: return 0.165
        case .io: return 0.183
        case .europa: return 0.134
        case .titan: return 0.14
        case .venus: return 0.9
        case .mercury: return 0.38
        case .enceladus: return 0.011
        }
    }
}
