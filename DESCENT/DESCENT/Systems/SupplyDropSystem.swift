//
//  SupplyDropSystem.swift
//  DESCENT
//
//  Manages emergency supply drops during underground runs
//

import SpriteKit

protocol SupplyDropSystemDelegate: AnyObject {
    func supplyDropSystemDidStartDelivery()
    func supplyDropSystemDidCancelDelivery()
    func supplyDropSystemDidCompleteDelivery(items: [SupplyDropSystem.SupplyItem: Int])
    func supplyDropSystemNeedsSupplyPod(at position: CGPoint, items: [SupplyDropSystem.SupplyItem: Int])
}

class SupplyDropSystem {

    // MARK: - Types

    enum SupplyItem: String, CaseIterable {
        case repairKit = "Repair Kit"
        case fuelCell = "Fuel Cell"
        case bomb = "Mining Bomb"
        case teleporter = "Emergency Teleporter"
        case shield = "Shield Generator"

        var surfacePrice: Double {
            switch self {
            case .repairKit: return 150
            case .fuelCell: return 200
            case .bomb: return 75
            case .teleporter: return 150
            case .shield: return 600
            }
        }

        var supplyDropPrice: Double {
            return surfacePrice * 2.0  // 2x cost for emergency delivery
        }

        var icon: String {
            switch self {
            case .repairKit: return "🔧"
            case .fuelCell: return "⛽"
            case .bomb: return "💣"
            case .teleporter: return "📡"
            case .shield: return "🛡️"
            }
        }
    }

    enum DeliveryState {
        case idle
        case countdown(timeRemaining: TimeInterval, items: [SupplyItem: Int], orderPosition: CGPoint)
        case delivering(items: [SupplyItem: Int])
    }

    // MARK: - Properties

    weak var delegate: SupplyDropSystemDelegate?

    private(set) var deliveryState: DeliveryState = .idle
    private var countdownTimer: TimeInterval = 0
    private var orderStartPosition: CGPoint = .zero

    // Current order being built (before confirmation)
    private(set) var orderItems: [SupplyItem: Int] = [:]

    // Capacity system
    private var supplyPodCapacity: Int = 5  // Default capacity

    // Constants
    private let deliveryWaitTime: TimeInterval = 30.0
    private let maxMovementDistance: CGFloat = 96.0  // 2 tiles (48px each)
    private let maxVelocity: CGFloat = 5.0  // pixels per second

    // Statistics
    private(set) var totalDropsOrdered: Int = 0
    private(set) var totalCreditsSpent: Double = 0
    private(set) var deliveriesCancelled: Int = 0
    private(set) var totalItemsOrdered: Int = 0
    private var itemOrderCounts: [SupplyItem: Int] = [:]

    // MARK: - Public Methods

    // MARK: - Capacity Management

    /// Get per-item maximum limit
    func maxPerItem(_ item: SupplyItem) -> Int {
        switch item {
        case .repairKit, .fuelCell, .bomb:
            return 3  // Common items
        case .teleporter, .shield:
            return 2  // Expensive items
        }
    }

    /// Get current capacity used by order
    func currentCapacityUsed() -> Int {
        return orderItems.values.reduce(0, +)
    }

    /// Get remaining capacity
    func remainingCapacity() -> Int {
        return supplyPodCapacity - currentCapacityUsed()
    }

    /// Get current supply pod capacity
    func getSupplyPodCapacity() -> Int {
        return supplyPodCapacity
    }

    /// Update supply pod capacity (from game state upgrades)
    func updateCapacity(_ capacity: Int) {
        supplyPodCapacity = capacity
    }

    /// Get quantity of specific item in current order
    func getQuantity(for item: SupplyItem) -> Int {
        return orderItems[item] ?? 0
    }

    /// Check if can add one more of an item
    func canAddItem(_ item: SupplyItem) -> Bool {
        let currentQuantity = orderItems[item] ?? 0
        let totalUsed = currentCapacityUsed()

        // Check per-item limit and total capacity
        return currentQuantity < maxPerItem(item) && totalUsed < supplyPodCapacity
    }

    /// Add one item to order
    func addItemToOrder(_ item: SupplyItem) -> Bool {
        guard canAddItem(item) else { return false }

        orderItems[item, default: 0] += 1
        return true
    }

    /// Remove one item from order
    func removeItemFromOrder(_ item: SupplyItem) -> Bool {
        guard let currentQuantity = orderItems[item], currentQuantity > 0 else {
            return false
        }

        if currentQuantity == 1 {
            orderItems.removeValue(forKey: item)
        } else {
            orderItems[item] = currentQuantity - 1
        }
        return true
    }

    /// Clear all items from order
    func clearOrder() {
        orderItems.removeAll()
    }

    /// Calculate total cost of current order
    func getTotalCost() -> Double {
        var total = 0.0
        for (item, quantity) in orderItems {
            total += item.supplyDropPrice * Double(quantity)
        }
        return total
    }

    /// Get total number of items in order
    func getTotalItemCount() -> Int {
        return currentCapacityUsed()
    }

    /// Check if order is empty
    func isOrderEmpty() -> Bool {
        return orderItems.isEmpty
    }

    /// Check if a supply drop can be ordered
    func canOrderSupplyDrop(credits: Double) -> Bool {
        guard case .idle = deliveryState else {
            return false  // Already have an active delivery
        }
        guard !isOrderEmpty() else {
            return false  // No items in order
        }
        return credits >= getTotalCost()
    }

    /// Order a supply drop with current order items
    func orderSupplyDrop(playerPosition: CGPoint, gameState: GameState) -> Bool {
        // Check if can order
        guard canOrderSupplyDrop(credits: gameState.credits) else {
            return false
        }

        let totalCost = getTotalCost()
        let itemCount = getTotalItemCount()

        // Deduct credits immediately
        gameState.credits -= totalCost

        // Start countdown
        countdownTimer = deliveryWaitTime
        orderStartPosition = playerPosition
        deliveryState = .countdown(timeRemaining: countdownTimer, items: orderItems, orderPosition: orderStartPosition)

        // Update statistics
        totalDropsOrdered += 1
        totalCreditsSpent += totalCost
        totalItemsOrdered += itemCount

        for (item, quantity) in orderItems {
            itemOrderCounts[item, default: 0] += quantity
        }

        delegate?.supplyDropSystemDidStartDelivery()

        print("📦 Supply drop ordered: \(itemCount) items for $\(Int(totalCost))")
        print("   Items: \(orderItems.map { "\($0.value)x \($0.key.rawValue)" }.joined(separator: ", "))")
        print("   Delivery in \(Int(deliveryWaitTime)) seconds. Remain stationary!")

        // Clear order after starting delivery
        orderItems.removeAll()

        return true
    }

    /// Update delivery countdown
    func update(deltaTime: TimeInterval, playerPosition: CGPoint, playerVelocity: CGVector) {
        guard case .countdown(let timeRemaining, let items, let orderPosition) = deliveryState else {
            return
        }

        // Check if player has moved too much
        let distanceMoved = hypot(playerPosition.x - orderPosition.x, playerPosition.y - orderPosition.y)
        let currentSpeed = hypot(playerVelocity.dx, playerVelocity.dy)

        if distanceMoved > maxMovementDistance || currentSpeed > maxVelocity {
            // Cancel delivery (no refund!)
            cancelDelivery()
            return
        }

        // Update countdown
        countdownTimer -= deltaTime

        if countdownTimer <= 0 {
            // Delivery complete!
            completeDelivery(items: items, at: playerPosition)
        } else {
            // Update state with new time
            deliveryState = .countdown(timeRemaining: countdownTimer, items: items, orderPosition: orderPosition)
        }
    }

    /// Get current countdown time (for UI)
    func getCurrentCountdown() -> TimeInterval? {
        if case .countdown(let timeRemaining, _, _) = deliveryState {
            return timeRemaining
        }
        return nil
    }

    /// Check if player is moving (for UI warning)
    func isPlayerMoving(velocity: CGVector) -> Bool {
        let speed = hypot(velocity.dx, velocity.dy)
        return speed > maxVelocity
    }

    /// Get distance from order position (for UI warning)
    func getDistanceFromOrderPosition(playerPosition: CGPoint) -> CGFloat? {
        if case .countdown(_, _, let orderPosition) = deliveryState {
            return hypot(playerPosition.x - orderPosition.x, playerPosition.y - orderPosition.y)
        }
        return nil
    }

    /// Check if delivery is in progress
    func isDeliveryInProgress() -> Bool {
        if case .countdown = deliveryState {
            return true
        }
        return false
    }

    /// Get most ordered item (for statistics)
    func getMostOrderedItem() -> (item: SupplyItem, count: Int)? {
        guard let maxEntry = itemOrderCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        return (item: maxEntry.key, count: maxEntry.value)
    }

    // MARK: - Private Methods

    private func cancelDelivery() {
        guard case .countdown(_, let items, _) = deliveryState else { return }

        deliveryState = .idle
        deliveriesCancelled += 1

        delegate?.supplyDropSystemDidCancelDelivery()

        let itemCount = items.values.reduce(0, +)
        print("⚠️ Supply drop cancelled! Player moved too much. No refund.")
        print("   Lost \(itemCount) items: \(items.map { "\($0.value)x \($0.key.rawValue)" }.joined(separator: ", "))")
    }

    private func completeDelivery(items: [SupplyItem: Int], at position: CGPoint) {
        deliveryState = .delivering(items: items)

        // Spawn supply pod visual
        delegate?.supplyDropSystemNeedsSupplyPod(at: position, items: items)

        print("📦 Supply drop arriving!")

        // Actual item delivery happens when pod lands (via finishDelivery)
    }

    /// Called when supply pod lands and adds items to inventory
    func finishDelivery(items: [SupplyItem: Int], gameState: GameState) {
        // Add items to inventory via planet state
        guard let planetState = gameState.planetState else {
            print("❌ Cannot add items - no planet state")
            return
        }

        var totalItems = 0
        for (item, quantity) in items {
            totalItems += quantity
            switch item {
            case .repairKit:
                planetState.consumables.repairKits += quantity
            case .fuelCell:
                planetState.consumables.fuelCells += quantity
            case .bomb:
                planetState.consumables.bombs += quantity
            case .teleporter:
                planetState.consumables.teleporters += quantity
            case .shield:
                planetState.consumables.shields += quantity
            }
        }

        deliveryState = .idle

        delegate?.supplyDropSystemDidCompleteDelivery(items: items)

        print("✅ Supply drop delivered: \(totalItems) items")
        print("   Received: \(items.map { "\($0.value)x \($0.key.rawValue)" }.joined(separator: ", "))")
    }

    // MARK: - Reset

    func reset() {
        deliveryState = .idle
        countdownTimer = 0
        orderStartPosition = .zero
        orderItems.removeAll()
    }
}
