//
//  DamageSystem.swift
//  DESCENT
//
//  Handles damage-related logic: impacts, hazards, shields
//

import SpriteKit

protocol DamageSystemDelegate: AnyObject {
    func damageSystemDidDestroyHull()
    /// Non-fatal damage was taken — drive impact feedback (shake, flash, number).
    func damageSystemDidTakeDamage(_ amount: Double, at position: CGPoint)
}

class DamageSystem {

    // MARK: - Properties

    weak var delegate: DamageSystemDelegate?

    private var lastImpactTime: TimeInterval = 0

    // MARK: - Impact Damage

    /// Process an impact collision and apply damage if appropriate.
    /// `impactSpeed` is the closing speed (px/s) INTO the contacted surface — the pre-impact
    /// velocity's component along the contact normal, clamped upstream to `K.Damage.maxFallSpeed`.
    /// A head-on landing hurts; grazing/scraping a wall (velocity parallel to it) deals ~0,
    /// even while falling fast. Returns true if the hull was destroyed.
    @discardableResult
    func processImpact(
        impactSpeed: CGFloat,
        playerPosition: CGPoint,
        surfaceY: CGFloat,
        gameState: GameState
    ) -> Bool {
        // Check if player has active shield
        if gameState.hasActiveEffect("shield") {
            Log.v("🛡️ Shield absorbed impact (speed: \(Int(impactSpeed)))")
            return false
        }

        // Don't take damage near the surface (safe zone near the shop)
        let distanceFromSurface = surfaceY - playerPosition.y
        guard distanceFromSurface >= K.Damage.safeZoneDepth else { return false }

        // Below the dampener-level threshold, impacts are harmless.
        let threshold = K.Damage.threshold(dampeners: gameState.impactDampenersLevel)

        // Cooldown prevents multiple damage events from one collision.
        let currentTime = Date().timeIntervalSince1970
        guard impactSpeed > threshold, currentTime - lastImpactTime >= K.Damage.cooldown else {
            return false
        }

        let damage = Double((impactSpeed - threshold) * K.Damage.multiplier)
        let hullDestroyed = gameState.takeDamage(damage)
        lastImpactTime = currentTime

        Log.v("💥 Impact: \(Int(damage)) HP (speed: \(Int(impactSpeed)), threshold: \(Int(threshold)), dampeners: Lv.\(gameState.impactDampenersLevel)) → Hull \(Int(gameState.currentHull))/\(Int(gameState.maxHull))")

        delegate?.damageSystemDidTakeDamage(damage, at: playerPosition)

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
            Log.v("🛡️ Shield absorbed \(hazardType) damage (\(Int(amount)) HP)")
            return false
        }

        let hullDestroyed = gameState.takeDamage(amount)

        Log.v("☠️ \(hazardType) damage: \(Int(amount)) HP")
        Log.v("   Hull: \(Int(gameState.currentHull))/\(Int(gameState.maxHull))")

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
