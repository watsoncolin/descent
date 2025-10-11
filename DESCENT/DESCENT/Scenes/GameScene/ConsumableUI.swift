//
//  ConsumableUI.swift
//  DESCENT
//
//  UI for consumable item buttons during mining
//

import SpriteKit

class ConsumableUI: SKNode {

    // MARK: - Properties

    private let screenSize: CGSize
    private var buttons: [ConsumableButton] = []

    // Callbacks
    var onUseRepairKit: (() -> Void)?
    var onUseFuelCell: (() -> Void)?
    var onUseBomb: (() -> Void)?
    var onUseTeleporter: (() -> Void)?
    var onUseShield: (() -> Void)?

    // MARK: - Initialization

    init(screenSize: CGSize) {
        self.screenSize = screenSize
        super.init()

        setupButtons()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupButtons() {
        let buttonSize: CGFloat = 60
        let spacing: CGFloat = 10
        let bottomMargin: CGFloat = 40

        // Calculate total width for centering
        let totalWidth = (buttonSize * 5) + (spacing * 4)
        let startX = -totalWidth / 2 + buttonSize / 2

        // Create 5 consumable buttons
        let consumables: [(icon: String, type: ConsumableType)] = [
            ("🔧", .repairKit),
            ("⛽", .fuelCell),
            ("💣", .bomb),
            ("🌀", .teleporter),
            ("🛡️", .shield)
        ]

        for (index, consumable) in consumables.enumerated() {
            let x = startX + (CGFloat(index) * (buttonSize + spacing))
            let y = -screenSize.height / 2 + bottomMargin

            let button = ConsumableButton(
                icon: consumable.icon,
                type: consumable.type,
                size: buttonSize
            )
            button.position = CGPoint(x: x, y: y)
            button.zPosition = 1000  // Above everything
            button.onTap = { [weak self] type in
                self?.handleButtonTap(type)
            }

            addChild(button)
            buttons.append(button)
        }
    }

    // MARK: - Update

    /// Update button states based on consumable counts
    func update(gameState: GameState) {
        for button in buttons {
            switch button.type {
            case .repairKit:
                button.updateCount(gameState.repairKitCount)
            case .fuelCell:
                button.updateCount(gameState.fuelCellCount)
            case .bomb:
                button.updateCount(gameState.bombCount)
            case .teleporter:
                button.updateCount(gameState.teleporterCount)
            case .shield:
                button.updateCount(gameState.shieldCount)
            }
        }
    }

    // MARK: - Touch Handling

    func handleTouch(at location: CGPoint) -> Bool {
        for button in buttons {
            if button.contains(location) && button.isEnabled {
                button.handleTap()
                return true
            }
        }
        return false
    }

    // MARK: - Button Callbacks

    private func handleButtonTap(_ type: ConsumableType) {
        switch type {
        case .repairKit:
            onUseRepairKit?()
        case .fuelCell:
            onUseFuelCell?()
        case .bomb:
            onUseBomb?()
        case .teleporter:
            onUseTeleporter?()
        case .shield:
            onUseShield?()
        }
    }
}

// MARK: - Consumable Button

private class ConsumableButton: SKNode {

    let type: ConsumableType
    private let size: CGFloat

    private var background: SKShapeNode!
    private var iconLabel: SKLabelNode!
    private var countLabel: SKLabelNode!

    var isEnabled: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    var onTap: ((ConsumableType) -> Void)?

    init(icon: String, type: ConsumableType, size: CGFloat) {
        self.type = type
        self.size = size
        super.init()

        setup(icon: icon)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(icon: String) {
        // Background circle
        background = SKShapeNode(circleOfRadius: size / 2)
        background.fillColor = UIColor(white: 0.2, alpha: 0.8)
        background.strokeColor = UIColor(white: 0.4, alpha: 1.0)
        background.lineWidth = 2
        addChild(background)

        // Icon
        iconLabel = SKLabelNode(text: icon)
        iconLabel.fontSize = size * 0.5
        iconLabel.verticalAlignmentMode = .center
        iconLabel.horizontalAlignmentMode = .center
        addChild(iconLabel)

        // Count badge
        countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.fontSize = 14
        countLabel.fontColor = .white
        countLabel.verticalAlignmentMode = .center
        countLabel.horizontalAlignmentMode = .center
        countLabel.position = CGPoint(x: size / 3, y: -size / 3)
        countLabel.zPosition = 1
        addChild(countLabel)

        updateAppearance()
    }

    func updateCount(_ count: Int) {
        countLabel.text = "\(count)"
        isEnabled = count > 0
    }

    private func updateAppearance() {
        if isEnabled {
            background.fillColor = UIColor(white: 0.3, alpha: 0.9)
            background.strokeColor = UIColor(white: 0.7, alpha: 1.0)
            iconLabel.alpha = 1.0
            countLabel.alpha = 1.0
        } else {
            background.fillColor = UIColor(white: 0.15, alpha: 0.7)
            background.strokeColor = UIColor(white: 0.25, alpha: 1.0)
            iconLabel.alpha = 0.3
            countLabel.alpha = 0.5
        }
    }

    func handleTap() {
        // Visual feedback - quick scale animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        run(sequence)

        onTap?(type)
    }
}
