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

    /// Apply fall damage based on how many TILES the pod free-fell before landing.
    /// Speed is unusable here — the pod reaches terminal velocity within ~4 tiles, so a short
    /// drop and a long plunge look identical by speed; distance separates them, and makes the
    /// cost depth-independent (N tiles costs the same shallow or deep). Returns true if the
    /// hull was destroyed.
    @discardableResult
    func processFallDamage(
        fallTiles: CGFloat,
        playerPosition: CGPoint,
        surfaceY: CGFloat,
        gameState: GameState
    ) -> Bool {
        // Check if player has active shield
        if gameState.hasActiveEffect("shield") {
            Log.v("🛡️ Shield absorbed fall (\(String(format: "%.1f", fallTiles)) tiles)")
            return false
        }

        // Don't take damage near the surface (safe zone near the shop)
        let distanceFromSurface = surfaceY - playerPosition.y
        guard distanceFromSurface >= K.Damage.safeZoneDepth else { return false }

        // Free-fall up to the dampener's safe distance; only the excess tiles hurt.
        let safeTiles = K.Damage.safeFallTiles(dampeners: gameState.impactDampenersLevel)
        let excess = fallTiles - safeTiles

        let currentTime = Date().timeIntervalSince1970
        guard excess > 0, currentTime - lastImpactTime >= K.Damage.cooldown else {
            return false
        }

        let damage = Double(excess * K.Damage.damagePerTile)
        let hullDestroyed = gameState.takeDamage(damage)
        lastImpactTime = currentTime

        Log.v("💥 Fall: \(Int(damage)) HP (\(String(format: "%.1f", fallTiles)) tiles, safe: \(Int(safeTiles)), dampeners: Lv.\(gameState.impactDampenersLevel)) → Hull \(Int(gameState.currentHull))/\(Int(gameState.maxHull))")

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
