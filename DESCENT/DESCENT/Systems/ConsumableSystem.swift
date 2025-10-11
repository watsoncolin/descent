//
//  ConsumableSystem.swift
//  DESCENT
//
//  Handles consumable item activation and effects
//

import SpriteKit

enum ConsumableType {
    case repairKit
    case fuelCell
    case bomb
    case teleporter
    case shield
}

protocol ConsumableSystemDelegate: AnyObject {
    func consumableSystemDidUseTeleporter()
    func consumableSystemDidUseBomb(at position: CGPoint)
    func consumableSystemDidActivateShield(duration: TimeInterval)
}

class ConsumableSystem {

    // MARK: - Properties

    weak var delegate: ConsumableSystemDelegate?
    private weak var gameState: GameState?

    // MARK: - Initialization

    init(gameState: GameState) {
        self.gameState = gameState
    }

    // MARK: - Activation

    /// Attempt to use a consumable item
    /// Returns true if successfully activated
    @discardableResult
    func useConsumable(_ type: ConsumableType, at position: CGPoint? = nil) -> Bool {
        guard let gameState = gameState else { return false }

        switch type {
        case .repairKit:
            return useRepairKit()

        case .fuelCell:
            return useFuelCell()

        case .bomb:
            guard let position = position else { return false }
            return useBomb(at: position)

        case .teleporter:
            return useTeleporter()

        case .shield:
            return useShield()
        }
    }

    // MARK: - Individual Consumables

    private func useRepairKit() -> Bool {
        guard let gameState = gameState else { return false }

        if gameState.useRepairKit() {
            // Visual feedback handled by delegate/GameScene
            return true
        }
        return false
    }

    private func useFuelCell() -> Bool {
        guard let gameState = gameState else { return false }

        if gameState.useFuelCell() {
            // Visual feedback handled by delegate/GameScene
            return true
        }
        return false
    }

    private func useBomb(at position: CGPoint) -> Bool {
        guard let gameState = gameState else { return false }

        if gameState.useBomb() {
            delegate?.consumableSystemDidUseBomb(at: position)
            return true
        }
        return false
    }

    private func useTeleporter() -> Bool {
        guard let gameState = gameState else { return false }

        if gameState.useTeleporter() {
            delegate?.consumableSystemDidUseTeleporter()
            return true
        }
        return false
    }

    private func useShield() -> Bool {
        guard let gameState = gameState else { return false }

        if gameState.useShield() {
            // Get the duration (default 10s from GameState)
            if let duration = gameState.getActiveEffectDuration("shield") {
                delegate?.consumableSystemDidActivateShield(duration: duration)
            }
            return true
        }
        return false
    }

    // MARK: - Query

    /// Check if a consumable can be used (has count > 0)
    func canUse(_ type: ConsumableType) -> Bool {
        guard let gameState = gameState else { return false }

        switch type {
        case .repairKit: return gameState.repairKitCount > 0
        case .fuelCell: return gameState.fuelCellCount > 0
        case .bomb: return gameState.bombCount > 0
        case .teleporter: return gameState.teleporterCount > 0
        case .shield: return gameState.shieldCount > 0
        }
    }

    /// Get the count for a consumable type
    func getCount(_ type: ConsumableType) -> Int {
        guard let gameState = gameState else { return 0 }

        switch type {
        case .repairKit: return gameState.repairKitCount
        case .fuelCell: return gameState.fuelCellCount
        case .bomb: return gameState.bombCount
        case .teleporter: return gameState.teleporterCount
        case .shield: return gameState.shieldCount
        }
    }
}
