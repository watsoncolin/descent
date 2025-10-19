//
//  HUD.swift
//  DESCENT
//
//  Heads-up display showing fuel, hull, cargo, depth, and credits
//

import SpriteKit

class HUD: SKNode {

    // MARK: - UI Elements

    private var fuelBar: ProgressBar!
    private var hullBar: ProgressBar!
    private var depthLabel: SKLabelNode!
    private var cargoLabel: SKLabelNode!
    private var creditsLabel: SKLabelNode!

    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    // MARK: - Initialization

    init(screenSize: CGSize) {
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        super.init()

        setupHUD()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupHUD() {
        // Position HUD elements below the Dynamic Island/notch
        // Use a safe margin that works for all iPhone models (Pro Max has ~59px Dynamic Island)
        let topMargin: CGFloat = 100  // Safe distance below Dynamic Island/notch
        let leftMargin: CGFloat = 20

        // Fuel bar (top left)
        fuelBar = ProgressBar(
            width: 120,
            height: 12,
            backgroundColor: .darkGray,
            fillColor: .green,
            label: "FUEL"
        )
        fuelBar.position = CGPoint(x: leftMargin, y: screenHeight / 2 - topMargin)
        fuelBar.zPosition = 1000  // Always on top
        addChild(fuelBar)

        // Hull bar (below fuel)
        hullBar = ProgressBar(
            width: 120,
            height: 12,
            backgroundColor: .darkGray,
            fillColor: .red,
            label: "HULL"
        )
        hullBar.position = CGPoint(x: leftMargin, y: screenHeight / 2 - topMargin - 30)
        hullBar.zPosition = 1000  // Always on top
        addChild(hullBar)

        // Depth label (top right)
        depthLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        depthLabel.fontSize = 18
        depthLabel.fontColor = .white
        depthLabel.horizontalAlignmentMode = .right
        depthLabel.position = CGPoint(x: screenWidth / 2 - leftMargin, y: screenHeight / 2 - topMargin)
        depthLabel.zPosition = 1000  // Always on top
        depthLabel.text = "0m"
        addChild(depthLabel)

        // Cargo label (below depth)
        cargoLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        cargoLabel.fontSize = 16
        cargoLabel.fontColor = .yellow
        cargoLabel.horizontalAlignmentMode = .right
        cargoLabel.position = CGPoint(x: screenWidth / 2 - leftMargin, y: screenHeight / 2 - topMargin - 30)
        cargoLabel.zPosition = 1000  // Always on top
        cargoLabel.text = "0/50"
        addChild(cargoLabel)

        // Credits label (below cargo)
        creditsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        creditsLabel.fontSize = 16
        creditsLabel.fontColor = .cyan
        creditsLabel.horizontalAlignmentMode = .right
        creditsLabel.position = CGPoint(x: screenWidth / 2 - leftMargin, y: screenHeight / 2 - topMargin - 55)
        creditsLabel.zPosition = 1000  // Always on top
        creditsLabel.text = "$0"
        addChild(creditsLabel)
    }

    // MARK: - Update

    func update(gameState: GameState) {
        // Update fuel bar
        let fuelPercent = gameState.currentFuel / gameState.maxFuel
        fuelBar.setProgress(CGFloat(fuelPercent))

        // Change color based on fuel level
        if fuelPercent < 0.25 {
            fuelBar.setFillColor(.red)
        } else if fuelPercent < 0.5 {
            fuelBar.setFillColor(.orange)
        } else {
            fuelBar.setFillColor(.green)
        }

        // Update hull bar
        let hullPercent = gameState.currentHull / gameState.maxHull
        hullBar.setProgress(CGFloat(hullPercent))

        // Update depth
        depthLabel.text = "\(Int(gameState.currentDepth))m"

        // Update cargo (show volume and value)
        let cargoValue = Int(gameState.cargoValue)
        cargoLabel.text = "\(gameState.cargoUsed)/\(gameState.cargoCapacity) ($\(cargoValue))"

        // Update credits
        creditsLabel.text = "$\(Int(gameState.credits))"
    }

    // MARK: - Notifications

    /// Show a large notification message that fades out after a few seconds
    func showNotification(message: String, color: UIColor = .orange) {
        // Create notification label
        let notification = SKLabelNode(fontNamed: "AvenirNext-Bold")
        notification.text = message
        notification.fontSize = 24
        notification.fontColor = color
        notification.horizontalAlignmentMode = .center
        notification.verticalAlignmentMode = .center
        notification.position = CGPoint(x: 0, y: 0)  // Center of screen
        notification.zPosition = 2000  // Above everything

        // Add glow effect
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        if let glowFilter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10.0]) {
            glow.filter = glowFilter
        }
        glow.addChild(notification)
        glow.zPosition = 2000
        addChild(glow)

        // Animate: fade in, stay, fade out
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let wait = SKAction.wait(forDuration: 3.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])

        glow.run(sequence)
    }
}

// MARK: - Progress Bar Component

class ProgressBar: SKNode {

    private let background: SKSpriteNode
    private let fill: SKSpriteNode
    private let label: SKLabelNode?
    private let width: CGFloat

    init(width: CGFloat, height: CGFloat, backgroundColor: UIColor, fillColor: UIColor, label: String? = nil) {
        self.width = width

        // Background
        background = SKSpriteNode(color: backgroundColor, size: CGSize(width: width, height: height))
        background.anchorPoint = CGPoint(x: 0, y: 0.5)

        // Fill (starts at full width)
        fill = SKSpriteNode(color: fillColor, size: CGSize(width: width, height: height - 2))
        fill.anchorPoint = CGPoint(x: 0, y: 0.5)
        fill.position = CGPoint(x: 1, y: 0)

        // Label
        if let labelText = label {
            self.label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            self.label?.fontSize = 10
            self.label?.fontColor = .white
            self.label?.text = labelText
            self.label?.horizontalAlignmentMode = .left
            self.label?.verticalAlignmentMode = .center
            self.label?.position = CGPoint(x: 0, y: -20)
        } else {
            self.label = nil
        }

        super.init()

        addChild(background)
        background.addChild(fill)
        if let label = self.label {
            addChild(label)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ percent: CGFloat) {
        let clampedPercent = max(0, min(1, percent))
        fill.size.width = width * clampedPercent - 2
    }

    func setFillColor(_ color: UIColor) {
        fill.color = color
    }
}
