//
//  CurrentRun.swift
//  DESCENT
//
//  Level 3 persistence - Only during active run, resets when returning to surface or dying
//

import Foundation
import CoreGraphics

// MARK: - Current Run

class CurrentRun: Codable {

    // MARK: - Run Info
    let planetId: String
    let startTime: Date
    var currentDepth: Double = 0

    // MARK: - Pod State
    var pod: PodState

    // MARK: - Collected Minerals
    var collectedMinerals: [CollectedMineral] = []

    // MARK: - Run Statistics
    var statistics: RunStatistics

    // MARK: - Active Consumables
    var activeEffects: [ActiveEffect] = []

    // MARK: - Initialization

    init(planetId: String, maxFuel: Double, maxHull: Double, maxCargo: Int) {
        self.planetId = planetId
        self.startTime = Date()
        self.pod = PodState(
            fuel: maxFuel,
            hull: maxHull,
            cargo: 0,
            maxFuel: maxFuel,
            maxHull: maxHull,
            maxCargo: maxCargo
        )
        self.statistics = RunStatistics()
    }

    // MARK: - Computed Properties

    var totalCargoValue: Double {
        return collectedMinerals.reduce(0) { $0 + $1.totalValue }
    }

    var totalCargoVolume: Int {
        return collectedMinerals.reduce(0) { $0 + $1.volumeUsed }
    }

    var runDuration: TimeInterval {
        return Date().timeIntervalSince(startTime)
    }

    // MARK: - Methods

    func addMineral(_ material: Material) {
        // Check if we already have this mineral type
        if let index = collectedMinerals.firstIndex(where: { $0.type == material.type.rawValue }) {
            // Add to existing entry
            collectedMinerals[index].quantity += 1
            collectedMinerals[index].totalValue += material.value
            collectedMinerals[index].volumeUsed += material.volume
        } else {
            // Create new entry
            let collected = CollectedMineral(
                type: material.type.rawValue,
                quantity: 1,
                totalValue: material.value,
                volumeUsed: material.volume
            )
            collectedMinerals.append(collected)
        }

        pod.cargo = totalCargoVolume
        statistics.deepestReached = max(statistics.deepestReached, currentDepth)
    }

    /// Remove one unit of a mineral from cargo (for auto-drop)
    func removeMineral(type: String) -> Bool {
        guard let index = collectedMinerals.firstIndex(where: { $0.type == type }) else {
            return false
        }

        var mineral = collectedMinerals[index]

        if mineral.quantity > 1 {
            // Calculate single unit values
            let singleValue = mineral.totalValue / Double(mineral.quantity)
            let singleVolume = mineral.volumeUsed / mineral.quantity

            // Remove one unit
            mineral.quantity -= 1
            mineral.totalValue -= singleValue
            mineral.volumeUsed -= singleVolume

            collectedMinerals[index] = mineral
        } else {
            // Remove entire entry if only one left
            collectedMinerals.remove(at: index)
        }

        pod.cargo = totalCargoVolume
        return true
    }

    func consumeFuel(_ amount: Double) -> Bool {
        if pod.fuel >= amount {
            pod.fuel -= amount
            return true
        } else {
            pod.fuel = 0
            return false
        }
    }

    func takeDamage(_ amount: Double) -> Bool {
        pod.hull = max(0, pod.hull - amount)
        statistics.damagesTaken += 1
        return pod.hull <= 0
    }

    func addActiveEffect(_ type: String, duration: TimeInterval) {
        activeEffects.append(ActiveEffect(type: type, remainingDuration: duration))
    }

    func updateActiveEffects(deltaTime: TimeInterval) {
        // Decrement durations
        for i in 0..<activeEffects.count {
            activeEffects[i].remainingDuration -= deltaTime
        }

        // Remove expired effects
        activeEffects.removeAll { $0.remainingDuration <= 0 }
    }
}

// MARK: - Pod State

struct PodState: Codable {
    var position: CGPoint = .zero
    var velocity: CGVector = .zero
    var fuel: Double
    var hull: Double
    var cargo: Int
    var maxFuel: Double
    var maxHull: Double
    var maxCargo: Int

    var isFuelEmpty: Bool {
        return fuel <= 0
    }

    var isHullDestroyed: Bool {
        return hull <= 0
    }

    var isCargoFull: Bool {
        return cargo >= maxCargo
    }
}

// MARK: - Collected Mineral

struct CollectedMineral: Codable {
    var type: String
    var quantity: Int
    var totalValue: Double
    var volumeUsed: Int
}

// MARK: - Run Statistics

struct RunStatistics: Codable {
    var deepestReached: Double = 0
    var tilesDestroyed: Int = 0
    var damagesTaken: Int = 0
    var hazardsEncountered: Int = 0
    var distanceTraveled: Double = 0
}

// MARK: - Active Effect

struct ActiveEffect: Codable {
    let type: String
    var remainingDuration: TimeInterval
}
