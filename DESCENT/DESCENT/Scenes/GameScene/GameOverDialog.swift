//
//  GameOverDialog.swift
//  DESCENT
//
//  Game over modal showing reason and cargo lost
//

import SpriteKit

class GameOverDialog: SKNode {

    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    // UI Elements
    private var background: SKSpriteNode!
    private var panel: SKSpriteNode!
    private var titleLabel: SKLabelNode!
    private var reasonLabel: SKLabelNode!
    private var cargoLostLabel: SKLabelNode!
    private var continueButton: SKShapeNode!

    // Callbacks
    var onContinue: (() -> Void)?

    init(screenSize: CGSize) {
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        super.init()

        setupDialog()
        isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDialog() {
        // Semi-transparent background overlay
        background = SKSpriteNode(color: UIColor(white: 0, alpha: 0.85), size: CGSize(width: screenWidth, height: screenHeight))
        background.zPosition = 0
        addChild(background)

        // Dialog panel
        let panelWidth: CGFloat = 320
        let panelHeight: CGFloat = 280
        panel = SKSpriteNode(color: UIColor(red: 0.15, green: 0.1, blue: 0.1, alpha: 1.0), size: CGSize(width: panelWidth, height: panelHeight))
        panel.zPosition = 1
        addChild(panel)

        // Border
        let border = SKShapeNode(rectOf: panel.size, cornerRadius: 10)
        border.strokeColor = .red
        border.lineWidth = 3
        border.fillColor = .clear
        border.zPosition = 2
        panel.addChild(border)

        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "GAME OVER"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .red
        titleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 50)
        titleLabel.verticalAlignmentMode = .center
        titleLabel.zPosition = 2
        panel.addChild(titleLabel)

        // Reason label
        reasonLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        reasonLabel.text = "Out of Fuel"
        reasonLabel.fontSize = 20
        reasonLabel.fontColor = .white
        reasonLabel.position = CGPoint(x: 0, y: 20)
        reasonLabel.verticalAlignmentMode = .center
        reasonLabel.zPosition = 2
        panel.addChild(reasonLabel)

        // Cargo lost label
        cargoLostLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        cargoLostLabel.text = "Cargo Lost: $0"
        cargoLostLabel.fontSize = 24
        cargoLostLabel.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
        cargoLostLabel.position = CGPoint(x: 0, y: -20)
        cargoLostLabel.verticalAlignmentMode = .center
        cargoLostLabel.zPosition = 2
        panel.addChild(cargoLostLabel)

        // Continue button
        let buttonWidth: CGFloat = 180
        let buttonHeight: CGFloat = 50
        continueButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        continueButton.fillColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        continueButton.strokeColor = .white
        continueButton.lineWidth = 3
        continueButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 50)
        continueButton.zPosition = 2
        continueButton.name = "continueButton"
        panel.addChild(continueButton)

        let continueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        continueLabel.text = "CONTINUE"
        continueLabel.fontSize = 22
        continueLabel.fontColor = .white
        continueLabel.verticalAlignmentMode = .center
        continueButton.addChild(continueLabel)
    }

    func show(reason: String, cargoValue: Double) {
        isHidden = false
        reasonLabel.text = reason

        // Different message based on reason
        let isFuelOut = reason.contains("Fuel")
        if isFuelOut {
            let savedAmount = Int(cargoValue * 0.5)
            cargoLostLabel.text = "Saved 50%: $\(savedAmount)"
            cargoLostLabel.fontColor = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)  // Yellow/gold
        } else {
            cargoLostLabel.text = "Cargo Lost: $\(Int(cargoValue))"
            cargoLostLabel.fontColor = UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0)  // Red/orange
        }
    }

    func hide() {
        isHidden = true
    }

    func handleTouch(at location: CGPoint) -> Bool {
        let nodes = self.nodes(at: location)

        if nodes.contains(where: { $0.name == "continueButton" }) {
            onContinue?()
            return true
        }

        return false
    }
}
