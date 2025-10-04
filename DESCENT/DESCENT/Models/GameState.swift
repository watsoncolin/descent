//
//  GameState.swift
//  DESCENT
//
//  Facade that provides easy access to the three-level data model
//  - GameProfile (Level 1: Forever)
//  - PlanetState (Level 2: Until Prestige)
//  - CurrentRun (Level 3: Current Run Only)
//

import Foundation

/// Represents the current state of the game (mining, at surface, menu, etc.)
enum GamePhase {
    case mining      // Player is underground drilling
    case surface     // At surface, can buy upgrades
    case gameOver    // Out of fuel or destroyed
}

/// The main game state facade that provides easy access to all game data
class GameState {

    // MARK: - Core Data Models
    var profile: GameProfile
    var currentRun: CurrentRun?
    var phase: GamePhase = .surface

    // MARK: - Current Planet (convenience)
    var currentPlanet: Planet = .mars {
        didSet {
            // Update last visited when switching planets
            planetState?.lastVisited = Date()
        }
    }

    // MARK: - Computed Access to Current Planet State
    var planetState: PlanetState? {
        return profile.getPlanetState(currentPlanet.rawValue.lowercased())
    }

    // MARK: - Initialization

    init() {
        // Try to load existing profile
        if let loadedProfile = SaveManager.shared.loadProfile() {
            self.profile = loadedProfile
            print("📂 Loaded existing profile")
        } else {
            // Create new profile
            self.profile = GameProfile()
            SaveManager.shared.saveProfile(profile)
            print("✨ Created new profile")
        }
    }

    #if DEBUG
    /// Initialize with a test profile (for debugging)
    init(testProfile: GameProfile) {
        self.profile = testProfile
        print("🧪 Initialized with test profile")
    }
    #endif

    // MARK: - Run Management

    /// Start a new mining run
    func startMiningRun() {
        guard let planet = planetState else {
            print("❌ Cannot start run - planet state not found")
            return
        }

        // Create new run with current upgrade values
        currentRun = CurrentRun(
            planetId: currentPlanet.rawValue.lowercased(),
            maxFuel: planet.maxFuel,
            maxHull: planet.maxHull,
            maxCargo: planet.cargoCapacity
        )

        phase = .mining
        planet.statistics.totalRunsOnPlanet += 1
        profile.totalRunsCompleted += 1

        print("🚀 Started mining run on \(currentPlanet.rawValue)")
        print("   - Fuel: \(planet.maxFuel)")
        print("   - Hull: \(planet.maxHull)")
        print("   - Cargo: \(planet.cargoCapacity)")
    }

    /// End run successfully (returned to surface with cargo)
    func endRunSuccess() {
        guard let run = currentRun, let planet = planetState else {
            print("❌ No active run to end")
            return
        }

        let earnings = run.totalCargoValue
        planet.credits += earnings
        planet.statistics.totalCreditsEarnedHere += earnings
        profile.totalCreditsEarned += earnings

        // Update statistics
        if run.currentDepth > planet.statistics.deepestDepthHere {
            planet.statistics.deepestDepthHere = run.currentDepth
        }

        if run.currentDepth > profile.statistics.deepestDepthReached {
            profile.statistics.deepestDepthReached = run.currentDepth
        }

        if earnings > profile.statistics.highestSingleRunValue {
            profile.statistics.highestSingleRunValue = earnings
        }

        // Add discovered minerals to compendium
        for mineral in run.collectedMinerals {
            profile.addDiscoveredMineral(mineral.type)
        }

        print("✅ Run completed successfully!")
        print("   - Earned: $\(Int(earnings))")
        print("   - Depth: \(Int(run.currentDepth))m")

        // Clean up
        currentRun = nil
        phase = .surface

        // Auto-save
        SaveManager.shared.saveProfile(profile)
    }

    /// Handle fuel-out game over (keeps 50% of cargo value)
    func endRunOutOfFuel() {
        guard let run = currentRun, let planet = planetState else {
            print("❌ No active run for fuel-out")
            return
        }

        // Keep 50% of cargo value
        let fullValue = run.totalCargoValue
        let halfValue = fullValue * 0.5
        planet.credits += halfValue
        planet.statistics.totalCreditsEarnedHere += halfValue
        profile.totalCreditsEarned += halfValue

        print("⛽ OUT OF FUEL - Kept 50% of cargo ($\(Int(halfValue)) / $\(Int(fullValue)))")

        // Update death statistics
        planet.statistics.totalDeathsHere += 1
        profile.totalDeathCount += 1

        // Clean up
        currentRun = nil
        phase = .gameOver

        // Auto-save
        SaveManager.shared.saveProfile(profile)
    }

    /// Handle hull-destroyed game over (loses all cargo)
    func endRunHullDestroyed() {
        guard let planet = planetState else {
            print("❌ No active run for hull destroyed")
            return
        }

        let lostValue = currentRun?.totalCargoValue ?? 0
        print("💥 HULL DESTROYED - Lost all cargo ($\(Int(lostValue)))")

        // Update death statistics
        planet.statistics.totalDeathsHere += 1
        profile.totalDeathCount += 1

        // Clean up
        currentRun = nil
        phase = .gameOver

        // Auto-save
        SaveManager.shared.saveProfile(profile)
    }

    // MARK: - Prestige

    /// Extract core and prestige
    func prestige() -> Int {
        guard let planet = planetState else {
            print("❌ Cannot prestige - no planet state")
            return 0
        }

        // Calculate soul crystals earned
        let totalEarnings = planet.statistics.totalCreditsEarnedHere
        let soulCrystalsEarned = Int(sqrt(totalEarnings / 1000.0))

        // Add to profile
        profile.soulCrystals += soulCrystalsEarned
        profile.totalCoresExtracted += 1

        // Reset planet state
        planet.prestige()
        planet.timesCompleted += 1

        print("🌟 PRESTIGE!")
        print("   - Soul Crystals Earned: +\(soulCrystalsEarned)")
        print("   - Total Soul Crystals: \(profile.soulCrystals)")

        // Auto-save
        SaveManager.shared.saveProfile(profile)

        return soulCrystalsEarned
    }

    // MARK: - Convenience Properties (for backward compatibility)

    var currentFuel: Double {
        get { return currentRun?.pod.fuel ?? 0 }
        set { currentRun?.pod.fuel = newValue }
    }

    var maxFuel: Double {
        return planetState?.maxFuel ?? 100
    }

    var currentHull: Double {
        get { return currentRun?.pod.hull ?? 0 }
        set { currentRun?.pod.hull = newValue }
    }

    var maxHull: Double {
        return planetState?.maxHull ?? 100
    }

    var currentDepth: Double {
        get { return currentRun?.currentDepth ?? 0 }
        set { currentRun?.currentDepth = newValue }
    }

    var currentCargo: [Material] {
        get {
            // Convert CollectedMineral back to Material array (for backward compatibility)
            return currentRun?.collectedMinerals.flatMap { collected -> [Material] in
                guard let materialType = Material.MaterialType(rawValue: collected.type) else {
                    return []
                }
                let singleValue = collected.totalValue / Double(collected.quantity)
                return (0..<collected.quantity).map { _ in
                    var material = Material(type: materialType, planetMultiplier: currentPlanet.multiplier)
                    // Override value to match what was collected
                    return Material(type: materialType, planetMultiplier: singleValue / materialType.baseValue)
                }
            } ?? []
        }
        set {
            // This setter is less efficient, try to use addToCargo instead
            currentRun?.collectedMinerals = []
            for material in newValue {
                _ = addToCargo(material)
            }
        }
    }

    var cargoCapacity: Int {
        return planetState?.cargoCapacity ?? 50
    }

    var cargoUsed: Int {
        return currentRun?.totalCargoVolume ?? 0
    }

    var cargoValue: Double {
        return currentRun?.totalCargoValue ?? 0
    }

    var credits: Double {
        get { return planetState?.credits ?? 0 }
        set { planetState?.credits = newValue }
    }

    var soulCrystals: Int {
        return profile.soulCrystals
    }

    var totalCareerEarnings: Double {
        return profile.totalCreditsEarned
    }

    // Upgrade levels (from current planet state)
    var fuelTankLevel: Int {
        get { return planetState?.upgrades.fuelTank ?? 1 }
        set { planetState?.upgrades.fuelTank = newValue }
    }

    var drillStrengthLevel: Int {
        get { return planetState?.upgrades.drillStrength ?? 1 }
        set { planetState?.upgrades.drillStrength = newValue }
    }

    var cargoLevel: Int {
        get { return planetState?.upgrades.cargoCapacity ?? 1 }
        set { planetState?.upgrades.cargoCapacity = newValue }
    }

    var hullArmorLevel: Int {
        get { return planetState?.upgrades.hullArmor ?? 1 }
        set { planetState?.upgrades.hullArmor = newValue }
    }

    var engineSpeedLevel: Int {
        get { return planetState?.upgrades.engineSpeed ?? 1 }
        set { planetState?.upgrades.engineSpeed = newValue }
    }

    var impactDampenersLevel: Int {
        get { return planetState?.upgrades.impactDampeners ?? 0 }
        set { planetState?.upgrades.impactDampeners = newValue }
    }

    var isFuelEmpty: Bool {
        return currentRun?.pod.isFuelEmpty ?? true
    }

    var isHullDestroyed: Bool {
        return currentRun?.pod.isHullDestroyed ?? true
    }

    var isCargoFull: Bool {
        return currentRun?.pod.isCargoFull ?? false
    }

    // MARK: - Methods

    @discardableResult
    func consumeFuel(_ amount: Double) -> Bool {
        return currentRun?.consumeFuel(amount) ?? false
    }

    func takeDamage(_ amount: Double) -> Bool {
        return currentRun?.takeDamage(amount) ?? false
    }

    func addToCargo(_ material: Material) -> Bool {
        guard let run = currentRun else { return false }

        // Check if cargo has space
        if run.totalCargoVolume + material.volume > run.pod.maxCargo {
            return false
        }

        run.addMineral(material)
        print("➕ Added \(material.type.rawValue) to cargo")
        return true
    }

    // MARK: - Consumables

    /// Use a repair kit (restores hull)
    func useRepairKit() -> Bool {
        guard let planet = planetState, planet.consumables.repairKits > 0 else {
            return false
        }

        planet.consumables.repairKits -= 1
        currentRun?.pod.hull = min(currentRun!.pod.hull + 50, currentRun!.pod.maxHull)
        print("🔧 Used Repair Kit - Hull: \(Int(currentHull))")
        return true
    }

    /// Use a fuel cell (restores fuel)
    func useFuelCell() -> Bool {
        guard let planet = planetState, planet.consumables.fuelCells > 0 else {
            return false
        }

        planet.consumables.fuelCells -= 1
        currentRun?.pod.fuel = min(currentRun!.pod.fuel + 100, currentRun!.pod.maxFuel)
        print("⛽ Used Fuel Cell - Fuel: \(Int(currentFuel))")
        return true
    }

    /// Use a bomb (clears blocks around player)
    func useBomb() -> Bool {
        guard let planet = planetState, planet.consumables.bombs > 0 else {
            return false
        }

        planet.consumables.bombs -= 1
        print("💣 Used Bomb!")
        return true
    }

    /// Use a teleporter (returns to surface)
    func useTeleporter() -> Bool {
        guard let planet = planetState, planet.consumables.teleporters > 0 else {
            return false
        }

        planet.consumables.teleporters -= 1
        print("🌀 Used Teleporter!")
        return true
    }

    /// Use a shield (temporary damage immunity)
    func useShield() -> Bool {
        guard let planet = planetState, planet.consumables.shields > 0 else {
            return false
        }

        planet.consumables.shields -= 1
        currentRun?.addActiveEffect("shield", duration: 10.0)
        print("🛡️ Used Shield - 10s immunity")
        return true
    }

    // Consumable counts
    var repairKitCount: Int {
        return planetState?.consumables.repairKits ?? 0
    }

    var fuelCellCount: Int {
        return planetState?.consumables.fuelCells ?? 0
    }

    var bombCount: Int {
        return planetState?.consumables.bombs ?? 0
    }

    var teleporterCount: Int {
        return planetState?.consumables.teleporters ?? 0
    }

    var shieldCount: Int {
        return planetState?.consumables.shields ?? 0
    }

    // MARK: - Save/Load

    func save() {
        SaveManager.shared.saveProfile(profile)
    }
}
