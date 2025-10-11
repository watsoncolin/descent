//
//  SupplyDropUI.swift
//  DESCENT
//
//  Emergency supply drop UI overlay with multi-item capacity system
//

import SpriteKit

class SupplyDropUI: SKNode {

    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    // Reference to supply drop system (for reading order state)
    private weak var supplyDropSystem: SupplyDropSystem?

    // UI Elements
    private var supplyButton: SKShapeNode!
    private var supplyButtonLabel: SKLabelNode!
    private var supplyButtonIcon: SKLabelNode!

    private var menuContainer: SKNode!
    private var menuBackground: SKSpriteNode!
    private var menuTitle: SKLabelNode!

    // Capacity bar
    private var capacityLabel: SKLabelNode!
    private var capacityBarBackground: SKShapeNode!
    private var capacityBarFill: SKShapeNode!

    // Item rows (one per SupplyItem)
    private var itemRows: [(
        container: SKNode,
        minusButton: SKShapeNode,
        plusButton: SKShapeNode,
        quantityLabel: SKLabelNode,
        lineTotalLabel: SKLabelNode,
        item: SupplyDropSystem.SupplyItem
    )] = []

    // Bottom section
    private var totalCostLabel: SKLabelNode!
    private var creditsLabel: SKLabelNode!
    private var warningLabel: SKLabelNode!
    private var orderButton: SKShapeNode!
    private var orderButtonLabel: SKLabelNode!
    private var clearButton: SKShapeNode!
    private var closeButton: SKShapeNode!

    // Countdown overlay
    private var countdownOverlay: SKNode!
    private var countdownLabel: SKLabelNode!
    private var countdownWarning: SKLabelNode!
    private var statusLabel: SKLabelNode!

    // Callbacks
    var onOrderSupplyDrop: ((SupplyDropSystem.SupplyItem) -> Void)?  // Legacy callback (will be replaced)
    var onOrderConfirmed: (() -> Void)?  // New callback for multi-item orders
    var onClearOrder: (() -> Void)?

    init(screenSize: CGSize, supplyDropSystem: SupplyDropSystem) {
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        self.supplyDropSystem = supplyDropSystem
        super.init()

        setupSupplyButton()
        setupMenu()
        setupCountdownOverlay()

        // Start with menu and countdown hidden
        menuContainer.isHidden = true
        countdownOverlay.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupSupplyButton() {
        // Supply button in top-left corner
        let buttonSize: CGFloat = 70
        let margin: CGFloat = 20

        supplyButton = SKShapeNode(rectOf: CGSize(width: buttonSize, height: buttonSize), cornerRadius: 8)
        supplyButton.fillColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.9)
        supplyButton.strokeColor = .white
        supplyButton.lineWidth = 2
        supplyButton.position = CGPoint(x: -screenWidth / 2 + buttonSize / 2 + margin, y: screenHeight / 2 - buttonSize / 2 - margin)
        supplyButton.zPosition = 100
        supplyButton.name = "supplyButton"
        addChild(supplyButton)

        // Icon
        supplyButtonIcon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        supplyButtonIcon.text = "📦"
        supplyButtonIcon.fontSize = 32
        supplyButtonIcon.verticalAlignmentMode = .center
        supplyButtonIcon.position = CGPoint(x: 0, y: 8)
        supplyButton.addChild(supplyButtonIcon)

        // Label
        supplyButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        supplyButtonLabel.text = "SUPPLY"
        supplyButtonLabel.fontSize = 10
        supplyButtonLabel.fontColor = .white
        supplyButtonLabel.verticalAlignmentMode = .center
        supplyButtonLabel.position = CGPoint(x: 0, y: -15)
        supplyButton.addChild(supplyButtonLabel)
    }

    private func setupMenu() {
        menuContainer = SKNode()
        menuContainer.zPosition = 200
        addChild(menuContainer)

        // Semi-transparent background
        menuBackground = SKSpriteNode(color: UIColor(white: 0.1, alpha: 0.95), size: CGSize(width: screenWidth, height: screenHeight))
        menuBackground.zPosition = 0
        menuContainer.addChild(menuBackground)

        // Title
        menuTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuTitle.text = "EMERGENCY SUPPLY DROP"
        menuTitle.fontSize = 24
        menuTitle.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        menuTitle.position = CGPoint(x: 0, y: screenHeight / 2 - 80)
        menuTitle.zPosition = 1
        menuContainer.addChild(menuTitle)

        // Capacity bar section
        setupCapacityBar()

        // Item rows
        setupItemRows()

        // Bottom section
        setupBottomSection()
    }

    private func setupCapacityBar() {
        let yPos: CGFloat = screenHeight / 2 - 140

        // Capacity label
        capacityLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        capacityLabel.text = "CAPACITY: 0/5 items"
        capacityLabel.fontSize = 16
        capacityLabel.fontColor = .white
        capacityLabel.position = CGPoint(x: 0, y: yPos)
        capacityLabel.zPosition = 1
        menuContainer.addChild(capacityLabel)

        // Capacity bar background
        let barWidth: CGFloat = 300
        let barHeight: CGFloat = 20
        capacityBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 10)
        capacityBarBackground.fillColor = UIColor(white: 0.2, alpha: 1.0)
        capacityBarBackground.strokeColor = UIColor(white: 0.4, alpha: 1.0)
        capacityBarBackground.lineWidth = 2
        capacityBarBackground.position = CGPoint(x: 0, y: yPos - 30)
        capacityBarBackground.zPosition = 1
        menuContainer.addChild(capacityBarBackground)

        // Capacity bar fill (starts at 0%)
        capacityBarFill = SKShapeNode(rectOf: CGSize(width: 1, height: barHeight - 4), cornerRadius: 8)
        capacityBarFill.fillColor = .green
        capacityBarFill.strokeColor = .clear
        capacityBarFill.position = CGPoint(x: -barWidth / 2, y: yPos - 30)
        capacityBarFill.zPosition = 2
        menuContainer.addChild(capacityBarFill)
    }

    private func setupItemRows() {
        let startY: CGFloat = screenHeight / 2 - 220
        let rowSpacing: CGFloat = 70

        let items = SupplyDropSystem.SupplyItem.allCases
        for (index, item) in items.enumerated() {
            let yPos = startY - CGFloat(index) * rowSpacing
            let row = createItemRow(item: item, yPos: yPos)
            itemRows.append(row)
        }
    }

    private func createItemRow(item: SupplyDropSystem.SupplyItem, yPos: CGFloat) -> (
        container: SKNode,
        minusButton: SKShapeNode,
        plusButton: SKShapeNode,
        quantityLabel: SKLabelNode,
        lineTotalLabel: SKLabelNode,
        item: SupplyDropSystem.SupplyItem
    ) {
        let container = SKNode()
        container.zPosition = 1
        menuContainer.addChild(container)

        // Item name and price
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = "\(item.icon) \(item.rawValue)"
        nameLabel.fontSize = 16
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: -150, y: yPos + 10)
        container.addChild(nameLabel)

        let priceLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        priceLabel.text = "$\(Int(item.supplyDropPrice)) ea"
        priceLabel.fontSize = 12
        priceLabel.fontColor = UIColor(white: 0.7, alpha: 1.0)
        priceLabel.horizontalAlignmentMode = .left
        priceLabel.verticalAlignmentMode = .center
        priceLabel.position = CGPoint(x: -150, y: yPos - 10)
        container.addChild(priceLabel)

        // Minus button
        let minusButton = SKShapeNode(rectOf: CGSize(width: 35, height: 35), cornerRadius: 5)
        minusButton.fillColor = UIColor(red: 0.6, green: 0.3, blue: 0.3, alpha: 0.9)
        minusButton.strokeColor = .white
        minusButton.lineWidth = 2
        minusButton.position = CGPoint(x: 20, y: yPos)
        minusButton.name = "minus_\(item.rawValue)"
        container.addChild(minusButton)

        let minusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        minusLabel.text = "−"
        minusLabel.fontSize = 24
        minusLabel.fontColor = .white
        minusLabel.verticalAlignmentMode = .center
        minusButton.addChild(minusLabel)

        // Quantity label
        let quantityLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        quantityLabel.text = "0"
        quantityLabel.fontSize = 18
        quantityLabel.fontColor = .white
        quantityLabel.verticalAlignmentMode = .center
        quantityLabel.position = CGPoint(x: 65, y: yPos)
        container.addChild(quantityLabel)

        // Plus button
        let plusButton = SKShapeNode(rectOf: CGSize(width: 35, height: 35), cornerRadius: 5)
        plusButton.fillColor = UIColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 0.9)
        plusButton.strokeColor = .white
        plusButton.lineWidth = 2
        plusButton.position = CGPoint(x: 110, y: yPos)
        plusButton.name = "plus_\(item.rawValue)"
        container.addChild(plusButton)

        let plusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        plusLabel.text = "+"
        plusLabel.fontSize = 20
        plusLabel.fontColor = .white
        plusLabel.verticalAlignmentMode = .center
        plusButton.addChild(plusLabel)

        // Line total
        let lineTotalLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lineTotalLabel.text = "= $0"
        lineTotalLabel.fontSize = 16
        lineTotalLabel.fontColor = .yellow
        lineTotalLabel.horizontalAlignmentMode = .right
        lineTotalLabel.verticalAlignmentMode = .center
        lineTotalLabel.position = CGPoint(x: 150, y: yPos)
        container.addChild(lineTotalLabel)

        return (container, minusButton, plusButton, quantityLabel, lineTotalLabel, item)
    }

    private func setupBottomSection() {
        // Total cost
        totalCostLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        totalCostLabel.text = "TOTAL: $0"
        totalCostLabel.fontSize = 20
        totalCostLabel.fontColor = .yellow
        totalCostLabel.position = CGPoint(x: 0, y: -screenHeight / 2 + 180)
        totalCostLabel.zPosition = 1
        menuContainer.addChild(totalCostLabel)

        // Credits
        creditsLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        creditsLabel.text = "Your Credits: $0"
        creditsLabel.fontSize = 16
        creditsLabel.fontColor = .white
        creditsLabel.position = CGPoint(x: 0, y: -screenHeight / 2 + 150)
        creditsLabel.zPosition = 1
        menuContainer.addChild(creditsLabel)

        // Warning
        warningLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        warningLabel.text = "⚠️ 30s delivery • Must remain stationary • No refunds"
        warningLabel.fontSize = 12
        warningLabel.fontColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        warningLabel.position = CGPoint(x: 0, y: -screenHeight / 2 + 120)
        warningLabel.zPosition = 1
        menuContainer.addChild(warningLabel)

        // Clear button
        clearButton = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 5)
        clearButton.fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        clearButton.strokeColor = .white
        clearButton.lineWidth = 2
        clearButton.position = CGPoint(x: -110, y: -screenHeight / 2 + 80)
        clearButton.zPosition = 1
        clearButton.name = "clearOrder"
        menuContainer.addChild(clearButton)

        let clearLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        clearLabel.text = "CLEAR"
        clearLabel.fontSize = 14
        clearLabel.fontColor = .white
        clearLabel.verticalAlignmentMode = .center
        clearButton.addChild(clearLabel)

        // Order button
        orderButton = SKShapeNode(rectOf: CGSize(width: 150, height: 40), cornerRadius: 5)
        orderButton.fillColor = UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0)
        orderButton.strokeColor = .white
        orderButton.lineWidth = 2
        orderButton.position = CGPoint(x: 20, y: -screenHeight / 2 + 80)
        orderButton.zPosition = 1
        orderButton.name = "orderSupply"
        menuContainer.addChild(orderButton)

        orderButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        orderButtonLabel.text = "ORDER $0"
        orderButtonLabel.fontSize = 14
        orderButtonLabel.fontColor = .white
        orderButtonLabel.verticalAlignmentMode = .center
        orderButton.addChild(orderButtonLabel)

        // Close button
        closeButton = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 5)
        closeButton.fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.position = CGPoint(x: 140, y: -screenHeight / 2 + 80)
        closeButton.zPosition = 1
        closeButton.name = "closeSupplyMenu"
        menuContainer.addChild(closeButton)

        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.text = "CLOSE"
        closeLabel.fontSize = 14
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeButton.addChild(closeLabel)
    }

    private func setupCountdownOverlay() {
        countdownOverlay = SKNode()
        countdownOverlay.zPosition = 150
        addChild(countdownOverlay)

        // Semi-transparent background
        let overlayBg = SKSpriteNode(color: UIColor(white: 0.0, alpha: 0.5), size: CGSize(width: screenWidth, height: screenHeight))
        overlayBg.zPosition = 0
        countdownOverlay.addChild(overlayBg)

        // Countdown display
        let countdownPanel = SKShapeNode(rectOf: CGSize(width: 300, height: 200), cornerRadius: 10)
        countdownPanel.fillColor = UIColor(white: 0.15, alpha: 0.95)
        countdownPanel.strokeColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        countdownPanel.lineWidth = 3
        countdownPanel.position = CGPoint(x: 0, y: 100)
        countdownPanel.zPosition = 1
        countdownOverlay.addChild(countdownPanel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "📦 SUPPLY DROP INCOMING"
        title.fontSize = 18
        title.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        title.position = CGPoint(x: 0, y: 70)
        countdownPanel.addChild(title)

        countdownLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countdownLabel.text = "⏱️ 30"
        countdownLabel.fontSize = 48
        countdownLabel.fontColor = .white
        countdownLabel.position = CGPoint(x: 0, y: 10)
        countdownPanel.addChild(countdownLabel)

        countdownWarning = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countdownWarning.text = "⚠️ REMAIN STATIONARY"
        countdownWarning.fontSize = 16
        countdownWarning.fontColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        countdownWarning.position = CGPoint(x: 0, y: -40)
        countdownPanel.addChild(countdownWarning)

        let warningDetail = SKLabelNode(fontNamed: "AvenirNext-Regular")
        warningDetail.text = "Moving will cancel order!"
        warningDetail.fontSize = 12
        warningDetail.fontColor = UIColor(white: 0.8, alpha: 1.0)
        warningDetail.position = CGPoint(x: 0, y: -60)
        countdownPanel.addChild(warningDetail)

        // Status indicator (bottom left)
        statusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        statusLabel.text = "█ STATIONARY ✓"
        statusLabel.fontSize = 14
        statusLabel.fontColor = .green
        statusLabel.horizontalAlignmentMode = .left
        statusLabel.position = CGPoint(x: -screenWidth / 2 + 20, y: -screenHeight / 2 + 20)
        statusLabel.zPosition = 1
        countdownOverlay.addChild(statusLabel)
    }

    // MARK: - Public Methods

    func show(gameState: GameState) {
        menuContainer.isHidden = false
        updateMenuDisplay(gameState: gameState)
    }

    func hide() {
        menuContainer.isHidden = true
    }

    func isMenuVisible() -> Bool {
        return !menuContainer.isHidden
    }

    func showCountdown(timeRemaining: TimeInterval, isMoving: Bool) {
        countdownOverlay.isHidden = false

        // Update countdown text
        let seconds = Int(ceil(timeRemaining))
        countdownLabel.text = "⏱️ \(seconds)"

        // Update status
        if isMoving {
            statusLabel.text = "█ MOVING ⚠️"
            statusLabel.fontColor = .red
            // Flash warning
            countdownWarning.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.fadeIn(withDuration: 0.2)
            ]))
        } else {
            statusLabel.text = "█ STATIONARY ✓"
            statusLabel.fontColor = .green
        }
    }

    func hideCountdown() {
        countdownOverlay.isHidden = true
    }

    func updateSupplyButton(countdown: TimeInterval?) {
        if let countdown = countdown {
            // Show countdown on button
            supplyButtonIcon.fontSize = 16
            supplyButtonIcon.position = CGPoint(x: 0, y: 12)
            supplyButtonLabel.text = "\(Int(ceil(countdown)))s"
            supplyButtonLabel.fontSize = 20
            supplyButtonLabel.position = CGPoint(x: 0, y: -8)

            // Pulse animation
            if supplyButton.action(forKey: "pulse") == nil {
                let pulse = SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeAlpha(to: 0.7, duration: 0.5),
                        SKAction.scale(to: 1.1, duration: 0.5)
                    ]),
                    SKAction.group([
                        SKAction.fadeAlpha(to: 1.0, duration: 0.5),
                        SKAction.scale(to: 1.0, duration: 0.5)
                    ])
                ])
                supplyButton.run(SKAction.repeatForever(pulse), withKey: "pulse")
            }
            supplyButton.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.9)
        } else {
            // Reset to normal
            supplyButtonIcon.fontSize = 32
            supplyButtonIcon.position = CGPoint(x: 0, y: 8)
            supplyButtonLabel.text = "SUPPLY"
            supplyButtonLabel.fontSize = 10
            supplyButtonLabel.position = CGPoint(x: 0, y: -15)
            supplyButton.removeAction(forKey: "pulse")
            supplyButton.setScale(1.0)
            supplyButton.alpha = 1.0
            supplyButton.fillColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.9)
        }
    }

    // MARK: - Update Display

    private func updateMenuDisplay(gameState: GameState) {
        guard let system = supplyDropSystem else { return }

        // Update credits
        creditsLabel.text = "Your Credits: $\(Int(gameState.credits))"

        // Update capacity bar
        let used = system.currentCapacityUsed()
        let capacity = system.getSupplyPodCapacity()
        capacityLabel.text = "CAPACITY: \(used)/\(capacity) items"

        // Update capacity bar fill and color
        let percentage = capacity > 0 ? CGFloat(used) / CGFloat(capacity) : 0
        let barWidth: CGFloat = 300
        let fillWidth = barWidth * percentage
        capacityBarFill.xScale = max(0.01, fillWidth / 1.0)

        // Color based on percentage
        if percentage < 0.7 {
            capacityBarFill.fillColor = .green
        } else if percentage < 0.9 {
            capacityBarFill.fillColor = .yellow
        } else {
            capacityBarFill.fillColor = .red
        }

        // Update all item rows
        for row in itemRows {
            let quantity = system.getQuantity(for: row.item)
            let maxQuantity = system.maxPerItem(row.item)
            let canAdd = system.canAddItem(row.item)
            let lineTotal = row.item.supplyDropPrice * Double(quantity)

            // Update quantity label
            row.quantityLabel.text = "\(quantity) (max \(maxQuantity))"
            if quantity == maxQuantity {
                row.quantityLabel.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
            } else {
                row.quantityLabel.fontColor = .white
            }

            // Update line total
            row.lineTotalLabel.text = "= $\(Int(lineTotal))"

            // Update button states
            row.minusButton.alpha = quantity > 0 ? 1.0 : 0.5
            row.plusButton.alpha = canAdd ? 1.0 : 0.5
        }

        // Update total cost
        let totalCost = system.getTotalCost()
        totalCostLabel.text = "TOTAL: $\(Int(totalCost)) (2x prices)"

        // Update order button
        let canOrder = system.canOrderSupplyDrop(credits: gameState.credits)
        orderButtonLabel.text = "ORDER $\(Int(totalCost))"
        orderButton.fillColor = canOrder ? UIColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1.0) : UIColor(white: 0.3, alpha: 0.5)
        orderButton.alpha = canOrder ? 1.0 : 0.5
    }

    // MARK: - Touch Handling

    func handleTouch(at location: CGPoint, gameState: GameState) -> Bool {
        guard let system = supplyDropSystem else { return false }

        let nodes = self.nodes(at: location)

        // Supply button
        if nodes.contains(where: { $0.name == "supplyButton" }) {
            if menuContainer.isHidden {
                show(gameState: gameState)
            } else {
                hide()
            }
            return true
        }

        // Close button
        if nodes.contains(where: { $0.name == "closeSupplyMenu" }) {
            hide()
            return true
        }

        // Clear button
        if nodes.contains(where: { $0.name == "clearOrder" }) {
            onClearOrder?()
            updateMenuDisplay(gameState: gameState)
            return true
        }

        // Order button
        if nodes.contains(where: { $0.name == "orderSupply" }) {
            if system.canOrderSupplyDrop(credits: gameState.credits) {
                onOrderConfirmed?()
                hide()
            }
            return true
        }

        // Plus/minus buttons
        for row in itemRows {
            if nodes.contains(row.plusButton) {
                // Add item
                _ = system.addItemToOrder(row.item)
                updateMenuDisplay(gameState: gameState)
                return true
            }
            if nodes.contains(row.minusButton) {
                // Remove item
                _ = system.removeItemFromOrder(row.item)
                updateMenuDisplay(gameState: gameState)
                return true
            }
        }

        return false
    }
}
