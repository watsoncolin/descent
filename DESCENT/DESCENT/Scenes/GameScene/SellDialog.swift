//
//  SellDialog.swift
//  DESCENT
//
//  Dialog for selling cargo when run ends
//

import SpriteKit

class SellDialog: SKNode {

    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    // UI Elements
    private var background: SKSpriteNode!
    private var panel: SKSpriteNode!
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!
    private var depthLabel: SKLabelNode!

    // Cargo section
    private var cargoTitleLabel: SKLabelNode!
    private var itemsContainer: SKNode!
    private var totalValueLabel: SKLabelNode!
    private var sellButton: SKShapeNode!
    private var closeButton: SKShapeNode!

    // Callbacks
    var onSell: (() -> Void)?
    var onClose: (() -> Void)?

    init(screenSize: CGSize) {
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        super.init()

        setupUI()
        isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Dimmed background
        background = SKSpriteNode(color: UIColor(white: 0, alpha: 0.7), size: CGSize(width: screenWidth, height: screenHeight))
        background.zPosition = 0
        addChild(background)

        // Panel
        let panelWidth: CGFloat = 350
        let panelHeight: CGFloat = 500
        panel = SKSpriteNode(color: UIColor(white: 0.15, alpha: 0.95), size: CGSize(width: panelWidth, height: panelHeight))
        panel.zPosition = 1
        addChild(panel)

        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "RUN COMPLETE!"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .green
        titleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 40)
        titleLabel.zPosition = 2
        panel.addChild(titleLabel)

        // Subtitle
        subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitleLabel.text = "You returned safely to surface"
        subtitleLabel.fontSize = 14
        subtitleLabel.fontColor = .white
        subtitleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 65)
        subtitleLabel.zPosition = 2
        panel.addChild(subtitleLabel)

        // Depth reached
        depthLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        depthLabel.text = "Depth: 0m"
        depthLabel.fontSize = 16
        depthLabel.fontColor = .cyan
        depthLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 95)
        depthLabel.zPosition = 2
        panel.addChild(depthLabel)

        // Cargo section title
        cargoTitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        cargoTitleLabel.text = "— CARGO —"
        cargoTitleLabel.fontSize = 18
        cargoTitleLabel.fontColor = .orange
        cargoTitleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 130)
        cargoTitleLabel.zPosition = 2
        panel.addChild(cargoTitleLabel)

        // Items container (for listing minerals)
        itemsContainer = SKNode()
        itemsContainer.position = CGPoint(x: 0, y: panelHeight / 2 - 160)
        itemsContainer.zPosition = 2
        panel.addChild(itemsContainer)

        // Total value
        totalValueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        totalValueLabel.text = "Total Value: $0"
        totalValueLabel.fontSize = 22
        totalValueLabel.fontColor = .yellow
        totalValueLabel.position = CGPoint(x: 0, y: -panelHeight / 2 + 120)
        totalValueLabel.zPosition = 2
        panel.addChild(totalValueLabel)

        // Sell button
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        sellButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        sellButton.fillColor = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        sellButton.strokeColor = .white
        sellButton.lineWidth = 3
        sellButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 70)
        sellButton.zPosition = 2
        sellButton.name = "sellButton"
        panel.addChild(sellButton)

        let sellLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        sellLabel.text = "SELL ALL"
        sellLabel.fontSize = 24
        sellLabel.fontColor = .white
        sellLabel.verticalAlignmentMode = .center
        sellButton.addChild(sellLabel)

        // Close button (X)
        closeButton = SKShapeNode(circleOfRadius: 20)
        closeButton.fillColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.position = CGPoint(x: panelWidth / 2 - 30, y: panelHeight / 2 - 30)
        closeButton.zPosition = 2
        closeButton.name = "closeButton"
        panel.addChild(closeButton)

        let xLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        xLabel.text = "×"
        xLabel.fontSize = 28
        xLabel.fontColor = .white
        xLabel.verticalAlignmentMode = .center
        closeButton.addChild(xLabel)
    }

    func show(gameState: GameState) {
        isHidden = false

        // Update depth
        depthLabel.text = "Depth Reached: \(Int(gameState.currentDepth))m"

        // Update cargo display
        updateCargoDisplay(gameState: gameState)

        // Update total value
        let totalValue = gameState.cargoValue
        totalValueLabel.text = "Total Value: $\(Int(totalValue))"

        // Show/hide sell button based on cargo
        if gameState.currentCargo.isEmpty {
            sellButton.alpha = 0.5
            if let label = sellButton.children.first as? SKLabelNode {
                label.text = "NO CARGO"
            }
        } else {
            sellButton.alpha = 1.0
            if let label = sellButton.children.first as? SKLabelNode {
                label.text = "SELL ALL"
            }
        }
    }

    func hide() {
        isHidden = true
    }

    private func updateCargoDisplay(gameState: GameState) {
        // Clear existing items
        itemsContainer.removeAllChildren()

        // Group cargo by type
        var cargoGroups: [String: (count: Int, totalValue: Double)] = [:]
        for material in gameState.currentCargo {
            let type = material.type.rawValue
            if var existing = cargoGroups[type] {
                existing.count += 1
                existing.totalValue += material.value
                cargoGroups[type] = existing
            } else {
                cargoGroups[type] = (count: 1, totalValue: material.value)
            }
        }

        // Display grouped items
        var yPos: CGFloat = 0
        for (type, data) in cargoGroups.sorted(by: { $0.value.totalValue > $1.value.totalValue }) {
            let itemLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            itemLabel.text = "\(type) x\(data.count) - $\(Int(data.totalValue))"
            itemLabel.fontSize = 14
            itemLabel.fontColor = .white
            itemLabel.position = CGPoint(x: 0, y: yPos)
            itemLabel.verticalAlignmentMode = .top
            itemsContainer.addChild(itemLabel)
            yPos -= 22
        }

        // Empty cargo message
        if cargoGroups.isEmpty {
            let emptyLabel = SKLabelNode(fontNamed: "AvenirNext-Italic")
            emptyLabel.text = "No minerals collected"
            emptyLabel.fontSize = 14
            emptyLabel.fontColor = .gray
            emptyLabel.position = CGPoint(x: 0, y: 0)
            itemsContainer.addChild(emptyLabel)
        }
    }

    func handleTouch(at location: CGPoint) -> Bool {
        let nodes = self.nodes(at: location)

        if nodes.contains(where: { $0.name == "sellButton" }) {
            onSell?()
            return true
        }

        if nodes.contains(where: { $0.name == "closeButton" }) {
            onClose?()
            return true
        }

        return false
    }
}
