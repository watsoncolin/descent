//
//  PrestigeDialog.swift
//  DESCENT
//
//  Dialog shown when player extracts planet core and can prestige
//

import SpriteKit

class PrestigeDialog: SKNode {

    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    // UI Elements
    private var background: SKSpriteNode!
    private var panel: SKSpriteNode!
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!

    // Stats
    private var earningsLabel: SKLabelNode!
    private var soulCrystalsLabel: SKLabelNode!
    private var bonusLabel: SKLabelNode!

    // What you lose/keep
    private var loseLabel: SKLabelNode!
    private var keepLabel: SKLabelNode!

    // Buttons
    private var prestigeButton: SKShapeNode!
    private var prestigeButtonLabel: SKLabelNode!
    private var continueButton: SKShapeNode!
    private var continueButtonLabel: SKLabelNode!

    // Callbacks
    var onPrestige: (() -> Void)?
    var onContinue: (() -> Void)?

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
        background = SKSpriteNode(color: UIColor(white: 0, alpha: 0.8), size: CGSize(width: screenWidth, height: screenHeight))
        background.zPosition = 0
        addChild(background)

        // Panel
        let panelWidth: CGFloat = 380
        let panelHeight: CGFloat = 600
        panel = SKSpriteNode(color: UIColor(white: 0.1, alpha: 0.95), size: CGSize(width: panelWidth, height: panelHeight))
        panel.zPosition = 1
        addChild(panel)

        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "💎 CORE EXTRACTED! 💎"
        titleLabel.fontSize = 26
        titleLabel.fontColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)  // Gold
        titleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 40)
        titleLabel.zPosition = 2
        panel.addChild(titleLabel)

        // Subtitle
        subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        subtitleLabel.text = "You can prestige to gain Soul Crystals"
        subtitleLabel.fontSize = 14
        subtitleLabel.fontColor = UIColor(white: 0.9, alpha: 1.0)
        subtitleLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 70)
        subtitleLabel.zPosition = 2
        panel.addChild(subtitleLabel)

        // Separator line
        let separator1 = SKShapeNode(rectOf: CGSize(width: panelWidth - 40, height: 2))
        separator1.fillColor = UIColor(white: 0.3, alpha: 1.0)
        separator1.strokeColor = .clear
        separator1.position = CGPoint(x: 0, y: panelHeight / 2 - 95)
        separator1.zPosition = 2
        panel.addChild(separator1)

        // Earnings label
        earningsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        earningsLabel.text = "Total Earnings: $0"
        earningsLabel.fontSize = 18
        earningsLabel.fontColor = .white
        earningsLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 130)
        earningsLabel.zPosition = 2
        panel.addChild(earningsLabel)

        // Soul Crystals label
        soulCrystalsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        soulCrystalsLabel.text = "Soul Crystals Earned: +0"
        soulCrystalsLabel.fontSize = 20
        soulCrystalsLabel.fontColor = UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)  // Light blue
        soulCrystalsLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 160)
        soulCrystalsLabel.zPosition = 2
        panel.addChild(soulCrystalsLabel)

        // Bonus label (EB before → after)
        bonusLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        bonusLabel.text = "Earnings Bonus: 100% → 100%"
        bonusLabel.fontSize = 14
        bonusLabel.fontColor = UIColor(white: 0.8, alpha: 1.0)
        bonusLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 185)
        bonusLabel.zPosition = 2
        panel.addChild(bonusLabel)

        // Separator line
        let separator2 = SKShapeNode(rectOf: CGSize(width: panelWidth - 40, height: 2))
        separator2.fillColor = UIColor(white: 0.3, alpha: 1.0)
        separator2.strokeColor = .clear
        separator2.position = CGPoint(x: 0, y: panelHeight / 2 - 215)
        separator2.zPosition = 2
        panel.addChild(separator2)

        // What you lose
        let loseTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        loseTitle.text = "YOU WILL LOSE:"
        loseTitle.fontSize = 14
        loseTitle.fontColor = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)  // Red
        loseTitle.position = CGPoint(x: 0, y: panelHeight / 2 - 245)
        loseTitle.zPosition = 2
        panel.addChild(loseTitle)

        loseLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        loseLabel.text = "• All Credits\n• All Common Upgrades\n• Planet Progress"
        loseLabel.fontSize = 12
        loseLabel.fontColor = UIColor(white: 0.7, alpha: 1.0)
        loseLabel.numberOfLines = 3
        loseLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 295)
        loseLabel.zPosition = 2
        panel.addChild(loseLabel)

        // What you keep
        let keepTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        keepTitle.text = "YOU WILL KEEP:"
        keepTitle.fontSize = 14
        keepTitle.fontColor = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)  // Green
        keepTitle.position = CGPoint(x: 0, y: panelHeight / 2 - 340)
        keepTitle.zPosition = 2
        panel.addChild(keepTitle)

        keepLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
        keepLabel.text = "• Soul Crystals (+10% bonus each)\n• Epic Upgrades\n• Golden Gems\n• Planet Unlocks"
        keepLabel.fontSize = 12
        keepLabel.fontColor = UIColor(white: 0.7, alpha: 1.0)
        keepLabel.numberOfLines = 4
        keepLabel.position = CGPoint(x: 0, y: panelHeight / 2 - 410)
        keepLabel.zPosition = 2
        panel.addChild(keepLabel)

        // Prestige button (primary action)
        let buttonWidth: CGFloat = 320
        let buttonHeight: CGFloat = 50

        prestigeButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        prestigeButton.fillColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9)  // Red
        prestigeButton.strokeColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        prestigeButton.lineWidth = 2
        prestigeButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 120)
        prestigeButton.zPosition = 2
        prestigeButton.name = "prestigeButton"
        panel.addChild(prestigeButton)

        prestigeButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        prestigeButtonLabel.text = "PRESTIGE NOW"
        prestigeButtonLabel.fontSize = 20
        prestigeButtonLabel.fontColor = .white
        prestigeButtonLabel.verticalAlignmentMode = .center
        prestigeButtonLabel.zPosition = 3
        prestigeButton.addChild(prestigeButtonLabel)

        // Continue button (secondary action)
        continueButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 8)
        continueButton.fillColor = UIColor(white: 0.3, alpha: 0.9)
        continueButton.strokeColor = UIColor(white: 0.5, alpha: 1.0)
        continueButton.lineWidth = 2
        continueButton.position = CGPoint(x: 0, y: -panelHeight / 2 + 60)
        continueButton.zPosition = 2
        continueButton.name = "continueButton"
        panel.addChild(continueButton)

        continueButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        continueButtonLabel.text = "CONTINUE WITHOUT PRESTIGE"
        continueButtonLabel.fontSize = 16
        continueButtonLabel.fontColor = .white
        continueButtonLabel.verticalAlignmentMode = .center
        continueButtonLabel.zPosition = 3
        continueButton.addChild(continueButtonLabel)
    }

    /// Show the prestige dialog with current game state
    func show(gameState: GameState) {
        // Calculate prestige rewards
        guard let planetState = gameState.planetState else { return }

        let totalEarnings = planetState.statistics.totalCreditsEarnedHere
        let soulCrystalsToEarn = Int(sqrt(totalEarnings / 1000.0))

        let currentSoulCrystals = gameState.profile.soulCrystals
        let currentBonus = gameState.profile.soulCrystalEarningsBonus
        let newBonus = 1.0 + (Double(currentSoulCrystals + soulCrystalsToEarn) * (gameState.profile.epicUpgrades.soulCrystalMultiplier / 100.0))

        // Update labels
        earningsLabel.text = "Total Earnings: $\(Int(totalEarnings))"
        soulCrystalsLabel.text = "Soul Crystals Earned: +\(soulCrystalsToEarn) 💎"

        let currentPercent = Int((currentBonus - 1.0) * 100)
        let newPercent = Int((newBonus - 1.0) * 100)
        bonusLabel.text = "Earnings Bonus: \(currentPercent)% → \(newPercent)%"

        // Show with animation
        isHidden = false
        alpha = 0
        run(SKAction.fadeIn(withDuration: 0.3))

        // Scale animation
        panel.setScale(0.8)
        panel.run(SKAction.scale(to: 1.0, duration: 0.3))
    }

    /// Hide the dialog
    func hide(completion: (() -> Void)? = nil) {
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.run { [weak self] in
                self?.isHidden = true
                completion?()
            }
        ]))
    }

    /// Handle touch events
    func handleTouch(at location: CGPoint) -> Bool {
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "prestigeButton" || node.parent?.name == "prestigeButton" {
                onPrestige?()
                return true
            }
            if node.name == "continueButton" || node.parent?.name == "continueButton" {
                onContinue?()
                return true
            }
        }

        return false
    }
}
