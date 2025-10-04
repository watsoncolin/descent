//
//  SaveManager.swift
//  DESCENT
//
//  Handles all data persistence, save/load operations, and backups
//

import Foundation

class SaveManager {

    // MARK: - Singleton
    static let shared = SaveManager()

    // MARK: - UserDefaults Keys
    private let profileKey = "descent.gameProfile"
    private let lastSaveKey = "descent.lastSave"
    private let versionKey = "descent.version"
    private let dataVersionKey = "descent.dataVersion"

    // MARK: - Current Data Version
    private let currentDataVersion = 1

    // MARK: - Initialization
    private init() {
        print("💾 SaveManager initialized")
    }

    // MARK: - Save Game Profile

    func saveProfile(_ profile: GameProfile) -> Bool {
        do {
            // Update last played timestamp
            profile.lastPlayed = Date()

            // Create backup before saving
            createBackup()

            // Encode to JSON
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profile)

            // Save to UserDefaults
            UserDefaults.standard.set(data, forKey: profileKey)
            UserDefaults.standard.set(Date(), forKey: lastSaveKey)
            UserDefaults.standard.set(currentDataVersion, forKey: dataVersionKey)
            UserDefaults.standard.synchronize()

            print("💾 Game saved successfully")
            print("   - Soul Crystals: \(profile.soulCrystals)")
            print("   - Total Credits: $\(Int(profile.totalCreditsEarned))")
            print("   - Planets: \(profile.planets.filter { $0.isUnlocked }.count)/\(profile.planets.count)")

            return true
        } catch {
            print("❌ Failed to save game: \(error)")
            return false
        }
    }

    // MARK: - Load Game Profile

    func loadProfile() -> GameProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else {
            print("📂 No save file found - creating new profile")
            return nil
        }

        do {
            // Check data version for migration
            let dataVersion = UserDefaults.standard.integer(forKey: dataVersionKey)
            if dataVersion < currentDataVersion {
                print("🔄 Data migration needed: v\(dataVersion) → v\(currentDataVersion)")
                // TODO: Implement migration logic
            }

            // Decode from JSON
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let profile = try decoder.decode(GameProfile.self, from: data)

            // Validate data
            if validateProfile(profile) {
                print("✅ Game loaded successfully")
                print("   - Profile: \(profile.profileId)")
                print("   - Soul Crystals: \(profile.soulCrystals)")
                print("   - Play Time: \(Int(profile.totalPlayTime / 3600))h")
                return profile
            } else {
                print("⚠️ Data validation failed - attempting backup restore")
                return restoreFromBackup()
            }
        } catch {
            print("❌ Failed to load game: \(error)")
            print("🔄 Attempting backup restore...")
            return restoreFromBackup()
        }
    }

    // MARK: - Backup System

    private func createBackup() {
        if let data = UserDefaults.standard.data(forKey: profileKey) {
            UserDefaults.standard.set(data, forKey: "\(profileKey).backup")
            print("📦 Backup created")
        }
    }

    private func restoreFromBackup() -> GameProfile? {
        guard let backupData = UserDefaults.standard.data(forKey: "\(profileKey).backup") else {
            print("❌ No backup available")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let profile = try decoder.decode(GameProfile.self, from: backupData)

            if validateProfile(profile) {
                print("✅ Restored from backup")
                return profile
            } else {
                print("❌ Backup data also invalid")
                return nil
            }
        } catch {
            print("❌ Failed to restore backup: \(error)")
            return nil
        }
    }

    // MARK: - Data Validation

    private func validateProfile(_ profile: GameProfile) -> Bool {
        // Validate soul crystals
        if profile.soulCrystals < 0 {
            print("⚠️ Invalid soul crystals: \(profile.soulCrystals)")
            profile.soulCrystals = 0
        }

        // Validate golden gems
        if profile.goldenGems < 0 {
            print("⚠️ Invalid golden gems: \(profile.goldenGems)")
            profile.goldenGems = 0
        }

        // Validate upgrade levels
        for planet in profile.planets {
            validatePlanetState(planet)
        }

        return true
    }

    private func validatePlanetState(_ planet: PlanetState) {
        // Cap upgrades at max levels
        planet.upgrades.fuelTank = min(max(planet.upgrades.fuelTank, 1), 6)
        planet.upgrades.drillStrength = min(max(planet.upgrades.drillStrength, 1), 5)
        planet.upgrades.cargoCapacity = min(max(planet.upgrades.cargoCapacity, 1), 6)
        planet.upgrades.hullArmor = min(max(planet.upgrades.hullArmor, 1), 5)
        planet.upgrades.engineSpeed = min(max(planet.upgrades.engineSpeed, 1), 5)
        planet.upgrades.impactDampeners = min(max(planet.upgrades.impactDampeners, 0), 3)

        // Validate credits
        if planet.credits < 0 {
            planet.credits = 0
        }
    }

    // MARK: - Quick Save Current Planet

    func saveCurrentPlanet(_ profile: GameProfile, planetId: String) -> Bool {
        guard let planet = profile.getPlanetState(planetId) else {
            print("❌ Planet not found: \(planetId)")
            return false
        }

        planet.lastVisited = Date()
        return saveProfile(profile)
    }

    // MARK: - Delete Save

    func deleteSave() {
        UserDefaults.standard.removeObject(forKey: profileKey)
        UserDefaults.standard.removeObject(forKey: lastSaveKey)
        UserDefaults.standard.removeObject(forKey: "\(profileKey).backup")
        UserDefaults.standard.synchronize()
        print("🗑️ Save data deleted")
    }

    // MARK: - Export/Import (for cloud save future)

    func exportProfileToJSON(_ profile: GameProfile) -> String? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(profile)
            return String(data: data, encoding: .utf8)
        } catch {
            print("❌ Failed to export: \(error)")
            return nil
        }
    }

    func importProfileFromJSON(_ jsonString: String) -> GameProfile? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let profile = try decoder.decode(GameProfile.self, from: data)
            return validateProfile(profile) ? profile : nil
        } catch {
            print("❌ Failed to import: \(error)")
            return nil
        }
    }

    // MARK: - Debug Helpers

    func printSaveInfo() {
        if let lastSave = UserDefaults.standard.object(forKey: lastSaveKey) as? Date {
            print("💾 Last save: \(lastSave)")
        } else {
            print("💾 No save data")
        }

        let dataVersion = UserDefaults.standard.integer(forKey: dataVersionKey)
        print("📊 Data version: \(dataVersion)")
    }

    #if DEBUG
    func generateTestProfile() -> GameProfile {
        let profile = GameProfile()
        profile.playerName = "Test Player"
        profile.soulCrystals = 100
        profile.goldenGems = 50
        profile.totalCreditsEarned = 50000

        // Unlock first few planets
        profile.planets[0].isUnlocked = true  // Mars
        profile.planets[1].isUnlocked = true  // Luna
        profile.planets[2].isUnlocked = true  // Io

        // Add some upgrades to Mars
        if let mars = profile.getPlanetState("mars") {
            mars.credits = 5000
            mars.upgrades.fuelTank = 3
            mars.upgrades.drillStrength = 2
            mars.upgrades.cargoCapacity = 3
        }

        return profile
    }
    #endif
}
