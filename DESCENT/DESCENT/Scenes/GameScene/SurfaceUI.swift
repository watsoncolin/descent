//
//  SurfaceUI.swift
//  DESCENT
//
//  Surface shop UI overlay with upgrades and consumables
//

import SpriteKit

class SurfaceUI: SKNode {

    private let screenWidth: CGFloat
    private let screenHeight: CGFloat

    // UI Elements
    private var background: SKSpriteNode!
    private var titleLabel: SKLabelNode!
    private var creditsLabel: SKLabelNode!
    private var launchButton: SKShapeNode!
    private var podPreview: PlayerPod!
    private var podPreviewLabel: SKLabelNode!

    // Tab system
    private var upgradesTab: SKShapeNode!
    private var consumablesTab: SKShapeNode!
    private var activeTab: TabType = .upgrades

    // Content containers
    private var upgradesContainer: SKNode!
    private var consumablesContainer: SKNode!

    // Callbacks
    var onLaunch: (() -> Void)?
    var onPurchaseUpgrade: ((UpgradeType) -> Void)?
    var onPurchaseConsumable: ((ConsumableType) -> Void)?
    var onResetProgress: (() -> Void)?
    var onShowcasePod: (() -> Void)?
    var onExplorePlanet: (() -> Void)?

    enum UpgradeType {
        case fuelTank
        case drillStrength
        case cargoCapacity
        case hullArmor
        case engineSpeed
        case impactDampeners
    }

    enum ConsumableType {
        case repairKit
        case fuelCell
        case bomb
        case teleporter
        case shield
    }

    enum TabType {
        case upgrades
        case consumables
    }

    init(screenSize: CGSize) {
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        super.init()

        setupUI()
        isHidden = true  // Start hidden
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Semi-transparent background
        background = SKSpriteNode(color: UIColor(white: 0.1, alpha: 0.9), size: CGSize(width: screenWidth, height: screenHeight))
        background.zPosition = 0
        addChild(background)

        // Safe area margins
        let topMargin: CGFloat = 100  // Below Dynamic Island/notch

        // Title
        titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "SURFACE SHOP"
        titleLabel.fontSize = 28
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: screenHeight / 2 - topMargin)
        titleLabel.zPosition = 1
        addChild(titleLabel)

        // Credits display
        creditsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        creditsLabel.text = "Credits: $0"
        creditsLabel.fontSize = 20
        creditsLabel.fontColor = .yellow
        creditsLabel.position = CGPoint(x: 0, y: screenHeight / 2 - topMargin - 35)
        creditsLabel.zPosition = 1
        addChild(creditsLabel)

        // Pod preview (centered, below tabs, above upgrade list)
        podPreview = PlayerPod()
        podPreview.position = CGPoint(x: 0, y: screenHeight / 2 - topMargin - 200)
        podPreview.zPosition = 2
        podPreview.setScale(1.8)  // Make it bigger for visibility
        podPreview.physicsBody?.isDynamic = false  // Static display
        addChild(podPreview)

        // Pod preview label
        podPreviewLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        podPreviewLabel.text = "YOUR POD"
        podPreviewLabel.fontSize = 14
        podPreviewLabel.fontColor = UIColor(white: 0.7, alpha: 1.0)
        podPreviewLabel.position = CGPoint(x: 0, y: screenHeight / 2 - topMargin - 300)
        podPreviewLabel.zPosition = 2
        addChild(podPreviewLabel)

        // Tab buttons
        let tabWidth: CGFloat = 150
        let tabHeight: CGFloat = 40
        let tabY = screenHeight / 2 - topMargin - 90

        upgradesTab = SKShapeNode(rectOf: CGSize(width: tabWidth, height: tabHeight), cornerRadius: 5)
        upgradesTab.position = CGPoint(x: -tabWidth / 2 - 10, y: tabY)
        upgradesTab.zPosition = 1
        upgradesTab.name = "upgradesTab"
        addChild(upgradesTab)

        let upgradesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        upgradesLabel.text = "UPGRADES"
        upgradesLabel.fontSize = 16
        upgradesLabel.fontColor = .white
        upgradesLabel.verticalAlignmentMode = .center
        upgradesTab.addChild(upgradesLabel)

        consumablesTab = SKShapeNode(rectOf: CGSize(width: tabWidth, height: tabHeight), cornerRadius: 5)
        consumablesTab.position = CGPoint(x: tabWidth / 2 + 10, y: tabY)
        consumablesTab.zPosition = 1
        consumablesTab.name = "consumablesTab"
        addChild(consumablesTab)

        let consumablesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        consumablesLabel.text = "CONSUMABLES"
        consumablesLabel.fontSize = 16
        consumablesLabel.fontColor = .white
        consumablesLabel.verticalAlignmentMode = .center
        consumablesTab.addChild(consumablesLabel)

        // Content containers
        upgradesContainer = SKNode()
        upgradesContainer.position = CGPoint(x: 0, y: 0)
        upgradesContainer.zPosition = 1
        addChild(upgradesContainer)

        consumablesContainer = SKNode()
        consumablesContainer.position = CGPoint(x: 0, y: 0)
        consumablesContainer.zPosition = 1
        consumablesContainer.isHidden = true
        addChild(consumablesContainer)

        // Launch button
        let buttonWidth: CGFloat = 200
        let buttonHeight: CGFloat = 50
        let bottomMargin: CGFloat = 80  // Above home indicator
        launchButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        launchButton.fillColor = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)
        launchButton.strokeColor = .white
        launchButton.lineWidth = 3
        launchButton.position = CGPoint(x: 0, y: -screenHeight / 2 + bottomMargin)
        launchButton.zPosition = 1
        launchButton.name = "launchButton"
        addChild(launchButton)

        let launchLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        launchLabel.text = "LAUNCH RUN"
        launchLabel.fontSize = 24
        launchLabel.fontColor = .white
        launchLabel.verticalAlignmentMode = .center
        launchButton.addChild(launchLabel)

        // Reset button (for testing) - small button in bottom-left corner
        let resetButton = SKShapeNode(rectOf: CGSize(width: 80, height: 30), cornerRadius: 5)
        resetButton.fillColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.8)
        resetButton.strokeColor = .white
        resetButton.lineWidth = 1
        resetButton.position = CGPoint(x: -screenWidth / 2 + 50, y: -screenHeight / 2 + 25)
        resetButton.zPosition = 1
        resetButton.name = "resetButton"
        addChild(resetButton)

        let resetLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resetLabel.text = "RESET"
        resetLabel.fontSize = 12
        resetLabel.fontColor = .white
        resetLabel.verticalAlignmentMode = .center
        resetButton.addChild(resetLabel)

        // Showcase button - next to reset button
        let showcaseButton = SKShapeNode(rectOf: CGSize(width: 80, height: 30), cornerRadius: 5)
        showcaseButton.fillColor = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 0.8)
        showcaseButton.strokeColor = .white
        showcaseButton.lineWidth = 1
        showcaseButton.position = CGPoint(x: -screenWidth / 2 + 145, y: -screenHeight / 2 + 25)
        showcaseButton.zPosition = 1
        showcaseButton.name = "showcaseButton"
        addChild(showcaseButton)

        let showcaseLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        showcaseLabel.text = "POD"
        showcaseLabel.fontSize = 12
        showcaseLabel.fontColor = .white
        showcaseLabel.verticalAlignmentMode = .center
        showcaseButton.addChild(showcaseLabel)

        // Explorer button - next to showcase button
        let explorerButton = SKShapeNode(rectOf: CGSize(width: 80, height: 30), cornerRadius: 5)
        explorerButton.fillColor = UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 0.8)
        explorerButton.strokeColor = .white
        explorerButton.lineWidth = 1
        explorerButton.position = CGPoint(x: -screenWidth / 2 + 240, y: -screenHeight / 2 + 25)
        explorerButton.zPosition = 1
        explorerButton.name = "explorerButton"
        addChild(explorerButton)

        let explorerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        explorerLabel.text = "MAP"
        explorerLabel.fontSize = 12
        explorerLabel.fontColor = .white
        explorerLabel.verticalAlignmentMode = .center
        explorerButton.addChild(explorerLabel)

        updateTabColors()
    }

    private func updateTabColors() {
        if activeTab == .upgrades {
            upgradesTab.fillColor = UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
            upgradesTab.strokeColor = .white
            upgradesTab.lineWidth = 3
            consumablesTab.fillColor = UIColor(white: 0.3, alpha: 1.0)
            consumablesTab.strokeColor = .gray
            consumablesTab.lineWidth = 2
        } else {
            consumablesTab.fillColor = UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
            consumablesTab.strokeColor = .white
            consumablesTab.lineWidth = 3
            upgradesTab.fillColor = UIColor(white: 0.3, alpha: 1.0)
            upgradesTab.strokeColor = .gray
            upgradesTab.lineWidth = 2
        }
    }

    func show(gameState: GameState, hideHUD: ((Bool) -> Void)? = nil) {
        isHidden = false
        hideHUD?(true)  // Hide HUD when surface UI is visible

        // Update credits display
        creditsLabel.text = "Credits: $\(Int(gameState.credits))"

        // Update pod preview with current upgrades
        updatePodPreview(gameState: gameState)

        // Rebuild shop items
        rebuildUpgradesShop(gameState: gameState)
        rebuildConsumablesShop(gameState: gameState)
    }

    /// Update the pod preview to show current upgrade levels
    func updatePodPreview(gameState: GameState) {
        // Remove old pod preview
        podPreview.removeFromParent()

        // Create new pod preview
        podPreview = PlayerPod()
        podPreview.position = CGPoint(x: 0, y: screenHeight / 2 - 100 - 200)
        podPreview.zPosition = 2
        podPreview.setScale(1.8)
        podPreview.physicsBody?.isDynamic = false

        // Force update upgrades by setting them directly before adding to scene
        podPreview.forceUpdateUpgrades(
            drillLevel: gameState.drillStrengthLevel,
            hullLevel: gameState.hullArmorLevel,
            engineLevel: gameState.engineSpeedLevel,
            fuelLevel: gameState.fuelTankLevel,
            cargoLevel: gameState.cargoLevel
        )

        addChild(podPreview)
    }

    func hide(showHUD: ((Bool) -> Void)? = nil) {
        isHidden = true
        showHUD?(false)  // Show HUD when surface UI is hidden
    }

    private func rebuildUpgradesShop(gameState: GameState) {
        upgradesContainer.removeAllChildren()

        var yPos: CGFloat = -100  // Start lower to make room for pod preview
        let spacing: CGFloat = 50

        // Fuel Tank
        addUpgradeButton(
            name: "Fuel Tank",
            level: gameState.fuelTankLevel,
            maxLevel: 6,
            upgradeKey: "fuelTank",
            type: .fuelTank,
            yPos: yPos,
            gameState: gameState
        )
        yPos -= spacing

        // Drill Strength
        addUpgradeButton(
            name: "Drill Strength",
            level: gameState.drillStrengthLevel,
            maxLevel: 5,
            upgradeKey: "drillStrength",
            type: .drillStrength,
            yPos: yPos,
            gameState: gameState
        )
        yPos -= spacing

        // Cargo Capacity
        addUpgradeButton(
            name: "Cargo Capacity",
            level: gameState.cargoLevel,
            maxLevel: 6,
            upgradeKey: "cargoCapacity",
            type: .cargoCapacity,
            yPos: yPos,
            gameState: gameState
        )
        yPos -= spacing

        // Hull Armor
        addUpgradeButton(
            name: "Hull Armor",
            level: gameState.hullArmorLevel,
            maxLevel: 5,
            upgradeKey: "hullArmor",
            type: .hullArmor,
            yPos: yPos,
            gameState: gameState
        )
    }

    private func rebuildConsumablesShop(gameState: GameState) {
        consumablesContainer.removeAllChildren()

        var yPos: CGFloat = -100  // Start lower to make room for pod preview
        let spacing: CGFloat = 50

        // Repair Kit
        addConsumableButton(
            name: "Repair Kit",
            count: gameState.repairKitCount,
            cost: Consumables.getCost("repairKit"),
            type: .repairKit,
            yPos: yPos,
            gameState: gameState
        )
        yPos -= spacing

        // Fuel Cell
        addConsumableButton(
            name: "Fuel Cell",
            count: gameState.fuelCellCount,
            cost: Consumables.getCost("fuelCell"),
            type: .fuelCell,
            yPos: yPos,
            gameState: gameState
        )
        yPos -= spacing

        // Bomb
        addConsumableButton(
            name: "Mining Bomb",
            count: gameState.bombCount,
            cost: Consumables.getCost("bomb"),
            type: .bomb,
            yPos: yPos,
            gameState: gameState
        )
        yPos -= spacing

        // Teleporter
        addConsumableButton(
            name: "Teleporter",
            count: gameState.teleporterCount,
            cost: Consumables.getCost("teleporter"),
            type: .teleporter,
            yPos: yPos,
            gameState: gameState
        )
        yPos -= spacing

        // Shield
        addConsumableButton(
            name: "Shield",
            count: gameState.shieldCount,
            cost: Consumables.getCost("shield"),
            type: .shield,
            yPos: yPos,
            gameState: gameState
        )
    }

    private func addUpgradeButton(name: String, level: Int, maxLevel: Int, upgradeKey: String, type: UpgradeType, yPos: CGFloat, gameState: GameState) {
        let cost = CommonUpgrades.getUpgradeCost(upgradeType: upgradeKey, currentLevel: level)
        let canAfford = gameState.credits >= cost
        let isMaxLevel = level >= maxLevel

        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        if isMaxLevel {
            label.text = "\(name) [MAX]"
            label.fontColor = .green
        } else {
            label.text = "\(name) Lv.\(level) → $\(Int(cost))"
            label.fontColor = canAfford ? .white : .gray
        }
        label.fontSize = 16
        label.position = CGPoint(x: 0, y: yPos)
        label.name = "upgrade_\(type)"
        upgradesContainer.addChild(label)
    }

    private func addConsumableButton(name: String, count: Int, cost: Double, type: ConsumableType, yPos: CGFloat, gameState: GameState) {
        let canAfford = gameState.credits >= cost

        let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
        label.text = "\(name) (x\(count)) → $\(Int(cost))"
        label.fontColor = canAfford ? .white : .gray
        label.fontSize = 16
        label.position = CGPoint(x: 0, y: yPos)
        label.name = "consumable_\(type)"
        consumablesContainer.addChild(label)
    }

    func handleTouch(at location: CGPoint, gameState: GameState) -> Bool {
        let nodes = self.nodes(at: location)

        if nodes.contains(where: { $0.name == "launchButton" }) {
            onLaunch?()
            return true
        }

        if nodes.contains(where: { $0.name == "resetButton" }) {
            onResetProgress?()
            return true
        }

        if nodes.contains(where: { $0.name == "showcaseButton" }) {
            onShowcasePod?()
            return true
        }

        if nodes.contains(where: { $0.name == "explorerButton" }) {
            onExplorePlanet?()
            return true
        }

        if nodes.contains(where: { $0.name == "upgradesTab" }) {
            activeTab = .upgrades
            upgradesContainer.isHidden = false
            consumablesContainer.isHidden = true
            updateTabColors()
            return true
        }

        if nodes.contains(where: { $0.name == "consumablesTab" }) {
            activeTab = .consumables
            upgradesContainer.isHidden = true
            consumablesContainer.isHidden = false
            updateTabColors()
            return true
        }

        // Check upgrade purchases
        for node in nodes {
            if let name = node.name, name.starts(with: "upgrade_") {
                let typeString = String(name.dropFirst("upgrade_".count))
                if let upgradeType = parseUpgradeType(typeString) {
                    onPurchaseUpgrade?(upgradeType)
                    // Refresh the UI after purchase
                    show(gameState: gameState)
                    return true
                }
            }

            if let name = node.name, name.starts(with: "consumable_") {
                let typeString = String(name.dropFirst("consumable_".count))
                if let consumableType = parseConsumableType(typeString) {
                    onPurchaseConsumable?(consumableType)
                    // Refresh the UI after purchase
                    show(gameState: gameState)
                    return true
                }
            }
        }

        return false
    }

    private func parseUpgradeType(_ string: String) -> UpgradeType? {
        switch string {
        case "fuelTank": return .fuelTank
        case "drillStrength": return .drillStrength
        case "cargoCapacity": return .cargoCapacity
        case "hullArmor": return .hullArmor
        case "engineSpeed": return .engineSpeed
        case "impactDampeners": return .impactDampeners
        default: return nil
        }
    }

    private func parseConsumableType(_ string: String) -> ConsumableType? {
        switch string {
        case "repairKit": return .repairKit
        case "fuelCell": return .fuelCell
        case "bomb": return .bomb
        case "teleporter": return .teleporter
        case "shield": return .shield
        default: return nil
        }
    }
}
