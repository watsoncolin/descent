//
//  LevelConfigLoader.swift
//  DESCENT
//
//  Loads planet configuration from JSON files
//

import Foundation

class LevelConfigLoader {

    // MARK: - Singleton
    static let shared = LevelConfigLoader()

    // MARK: - Cache
    private var loadedConfigs: [String: PlanetConfig] = [:]

    private init() {
        // Private initializer for singleton
    }

    // MARK: - Load Planet Config

    /// Load planet configuration from JSON file
    /// - Parameter planetName: Name of the planet (e.g., "mars", "luna")
    /// - Returns: PlanetConfig if successful, nil if file not found or parsing failed
    func loadPlanet(_ planetName: String) -> PlanetConfig? {
        // Check cache first
        if let cached = loadedConfigs[planetName.lowercased()] {
            print("📦 Loaded \(planetName) config from cache")
            return cached
        }

        // Try to load from bundle
        guard let url = Bundle.main.url(forResource: planetName.lowercased(), withExtension: "json") else {
            print("❌ Failed to find \(planetName).json in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let config = try decoder.decode(PlanetConfig.self, from: data)

            // Cache it
            loadedConfigs[planetName.lowercased()] = config

            print("✅ Loaded \(config.name) config:")
            print("   - Total depth: \(config.totalDepth)m")
            print("   - Strata layers: \(config.strata.count)")
            print("   - Resources: \(config.strata.flatMap { $0.resources }.count)")

            return config
        } catch {
            print("❌ Failed to parse \(planetName).json: \(error)")
            return nil
        }
    }

    // MARK: - Helper Methods

    /// Get strata layer for a specific depth
    /// - Parameters:
    ///   - depth: Depth in meters
    ///   - config: Planet configuration
    /// - Returns: StrataLayer if found
    func getStrataLayer(at depth: Double, for config: PlanetConfig) -> StrataLayer? {
        return config.strata.first { $0.contains(depth: depth) }
    }

    /// Get all resources available at a specific depth
    /// - Parameters:
    ///   - depth: Depth in meters
    ///   - config: Planet configuration
    /// - Returns: Array of ResourceConfig
    func getResources(at depth: Double, for config: PlanetConfig) -> [ResourceConfig] {
        guard let layer = getStrataLayer(at: depth, for: config) else {
            return []
        }
        return layer.resources
    }

    /// Get all hazards at a specific depth
    /// - Parameters:
    ///   - depth: Depth in meters
    ///   - config: Planet configuration
    /// - Returns: Array of HazardConfig
    func getHazards(at depth: Double, for config: PlanetConfig) -> [HazardConfig] {
        guard let layer = getStrataLayer(at: depth, for: config) else {
            return []
        }
        return layer.hazards
    }

    /// Calculate actual drill time based on strata hardness and drill level
    /// - Parameters:
    ///   - depth: Current depth
    ///   - drillLevel: Player's drill level
    ///   - config: Planet configuration
    /// - Returns: Time in seconds to drill one tile
    func calculateDrillTime(at depth: Double, drillLevel: Int, for config: PlanetConfig) -> Double {
        guard let layer = getStrataLayer(at: depth, for: config) else {
            return 0.5 // Default
        }

        let baseDrillTime = 0.5 // seconds
        let actualTime = baseDrillTime * layer.hardness / Double(drillLevel)

        return actualTime
    }

    /// Clear the cache (useful for testing or reloading)
    func clearCache() {
        loadedConfigs.removeAll()
        print("🗑️ Cleared planet config cache")
    }

    /// Preload all planet configs (useful at app startup)
    func preloadAllPlanets() {
        let planetNames = ["mars", "luna", "io", "europa", "titan", "venus", "mercury", "enceladus"]

        for name in planetNames {
            _ = loadPlanet(name)
        }

        print("📦 Preloaded \(loadedConfigs.count) planet configs")
    }
}
