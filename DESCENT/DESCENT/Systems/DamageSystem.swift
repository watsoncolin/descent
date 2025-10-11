//
//  DamageSystem.swift
//  DESCENT
//
//  Handles damage-related logic: impacts, hazards, shields
//

import SpriteKit

protocol DamageSystemDelegate: AnyObject {
    func damageSystemDidDestroyHull()
}

class DamageSystem {

    // MARK: - Properties

    weak var delegate: DamageSystemDelegate?

    private var lastImpactTime: TimeInterval = 0
    private let impactCooldown: TimeInterval = 0.3

    // MARK: - Impact Damage

    /// Process an impact collision and apply damage if appropriate
    /// Returns true if hull was destroyed
    @discardableResult
    func processImpact(
        impulse: CGFloat,
        playerPosition: CGPoint,
        surfaceY: CGFloat,
        podSize: CGSize,
        gameState: GameState
    ) -> Bool {
        // Check if player has active shield
        if gameState.hasActiveEffect("shield") {
            print("🛡️ Shield absorbed impact (impulse: \(String(format: "%.1f", impulse)))")
            return false
        }

        // Don't take damage near the surface (within 150 pixels of surface level)
        let distanceFromSurface = surfaceY - playerPosition.y
        let nearSurface = distanceFromSurface < 150  // Safe zone near shop

        guard !nearSurface else { return false }

        // Calculate pod size scale factor relative to reference size (24x36 original pod)
        // Larger pods generate higher impulse values, so we scale thresholds accordingly
        let referencePodArea: CGFloat = 24 * 36  // Original pod size
        let currentPodArea = podSize.width * podSize.height
        let sizeScaleFactor = currentPodArea / referencePodArea

        // Use collision impulse for more accurate impact detection
        let impactForce = impulse * 0.85

        // Base damage thresholds (tuned for 24x36 pod)
        let baseDamageThreshold: CGFloat
        switch gameState.impactDampenersLevel {
        case 0: baseDamageThreshold = 10    // Very fragile
        case 1: baseDamageThreshold = 25    // Can handle moderate falls
        case 2: baseDamageThreshold = 50    // Can handle fast falls
        case 3: baseDamageThreshold = .infinity  // No fall damage ever
        default: baseDamageThreshold = 10
        }

        // Scale threshold by pod size (bigger pods need higher thresholds)
        let damageThreshold = baseDamageThreshold * sizeScaleFactor

        // Check cooldown to prevent multiple damage from same collision
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastImpact = currentTime - lastImpactTime

        guard impactForce > damageThreshold && timeSinceLastImpact >= impactCooldown else {
            return false
        }

        // Calculate and apply damage
        let damage = (impactForce - damageThreshold) * 2.0
        let hullDestroyed = gameState.takeDamage(damage)
        lastImpactTime = currentTime

        print("💥 Impact damage: \(Int(damage)) HP (impulse: \(String(format: "%.1f", impactForce)), threshold: \(Int(damageThreshold)) [base: \(Int(baseDamageThreshold)) × \(String(format: "%.1fx", sizeScaleFactor))], dampeners: Lv.\(gameState.impactDampenersLevel))")
        print("   Hull: \(Int(gameState.currentHull))/\(Int(gameState.maxHull))")

        if hullDestroyed {
            delegate?.damageSystemDidDestroyHull()
            return true
        }

        return false
    }

    // MARK: - Hazard Damage

    /// Apply damage from a hazard (gas pocket, cave-in, etc.)
    @discardableResult
    func applyHazardDamage(
        amount: Double,
        hazardType: String,
        gameState: GameState
    ) -> Bool {
        // Check if player has active shield
        if gameState.hasActiveEffect("shield") {
            print("🛡️ Shield absorbed \(hazardType) damage (\(Int(amount)) HP)")
            return false
        }

        let hullDestroyed = gameState.takeDamage(amount)

        print("☠️ \(hazardType) damage: \(Int(amount)) HP")
        print("   Hull: \(Int(gameState.currentHull))/\(Int(gameState.maxHull))")

        if hullDestroyed {
            delegate?.damageSystemDidDestroyHull()
            return true
        }

        return false
    }

    // MARK: - Reset

    /// Reset cooldown timers (used when starting new run)
    func reset() {
        lastImpactTime = 0
    }
}
