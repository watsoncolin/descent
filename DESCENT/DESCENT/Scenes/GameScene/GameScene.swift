import SpriteKit

class GameScene: SKScene {

    // MARK: - Properties
    private var lastUpdateTime: TimeInterval = 0
    private var gameState = GameState()
    private var player: PlayerPod!

    // Systems
    private var inputManager: InputManager!
    private var damageSystem: DamageSystem!
    private var consumableSystem: ConsumableSystem!
    private var supplyDropSystem: SupplyDropSystem!

    // Debug showcase (triple tap to activate)
    private var lastTapTime: TimeInterval = 0
    private var tapCount: Int = 0

    // Camera
    private var cameraNode: SKCameraNode!

    // HUD
    private var hud: HUD!
    private var consumableUI: ConsumableUI!
    private var supplyDropUI: SupplyDropUI!

    // Visual effects
    private var shieldEffect: SKShapeNode?

    // Surface UI
    private var surfaceUI: SurfaceUI!
    private var sellDialog: SellDialog!
    private var gameOverDialog: GameOverDialog!

    // Terrain
    private var terrainManager: TerrainManager!

    // Shop
    private var shopBuilding: SKSpriteNode!
    private var shopDoorPosition: CGPoint = .zero  // Door position for snapping

    // Drilling
    private var drillCooldown: TimeInterval = 0
    private var currentDrillSpeed: TimeInterval = 0.3  // Dynamic drill speed based on strata hardness

    // Movement lock (for dialog interactions)
    private var isMovementLocked: Bool = false

    // Game over lock (prevent multiple triggers)
    private var isGameOverInProgress: Bool = false

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
    }

    private func setupScene() {
        backgroundColor = UIColor(red: 0.1, green: 0.05, blue: 0.15, alpha: 1.0)  // Dark purple (space)

        // Set up physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8 * 0.38)  // Mars gravity
        physicsWorld.contactDelegate = self

        // Initialize systems
        inputManager = InputManager()
        inputManager.delegate = self

        damageSystem = DamageSystem()
        damageSystem.delegate = self

        consumableSystem = ConsumableSystem(gameState: gameState)
        consumableSystem.delegate = self

        supplyDropSystem = SupplyDropSystem()
        supplyDropSystem.delegate = self
        supplyDropSystem.updateCapacity(gameState.profile.epicUpgrades.actualSupplyPodCapacity)

        // Create camera
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)

        // Create terrain manager
        terrainManager = TerrainManager(scene: self, planet: gameState.currentPlanet)

        // Create shop building at surface
        setupShop()

        // Create player pod
        player = PlayerPod()
        player.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        player.zPosition = 100  // Always on top
        addChild(player)

        // Load initial terrain chunks
        terrainManager.updateChunks(playerY: player.position.y)

        // Create HUD (attach to camera so it stays on screen)
        hud = HUD(screenSize: view!.bounds.size)
        cameraNode.addChild(hud)

        // Create Consumable UI (attach to camera)
        consumableUI = ConsumableUI(screenSize: view!.bounds.size)
        consumableUI.zPosition = 150  // Above HUD, below dialogs
        consumableUI.onUseRepairKit = { [weak self] in
            guard let self = self else { return }
            if self.consumableSystem.useConsumable(.repairKit) {
                print("🔧 Repair Kit used!")
                self.createRepairEffect()
            }
        }
        consumableUI.onUseFuelCell = { [weak self] in
            guard let self = self else { return }
            if self.consumableSystem.useConsumable(.fuelCell) {
                print("⛽ Fuel Cell used!")
                self.createFuelEffect()
            }
        }
        consumableUI.onUseBomb = { [weak self] in
            guard let self = self else { return }
            if self.consumableSystem.useConsumable(.bomb, at: self.player.position) {
                print("💣 Bomb used!")
            }
        }
        consumableUI.onUseTeleporter = { [weak self] in
            guard let self = self else { return }
            if self.consumableSystem.useConsumable(.teleporter) {
                print("🌀 Teleporter used!")
            }
        }
        consumableUI.onUseShield = { [weak self] in
            guard let self = self else { return }
            if self.consumableSystem.useConsumable(.shield) {
                print("🛡️ Shield used!")
            }
        }
        consumableUI.isHidden = true  // Hidden until mining starts
        cameraNode.addChild(consumableUI)

        // Create Supply Drop UI (attach to camera)
        supplyDropUI = SupplyDropUI(screenSize: view!.bounds.size, supplyDropSystem: supplyDropSystem)
        supplyDropUI.zPosition = 160  // Above consumable UI, below dialogs
        supplyDropUI.onOrderConfirmed = { [weak self] in
            guard let self = self else { return }
            let success = self.supplyDropSystem.orderSupplyDrop(
                playerPosition: self.player.position,
                gameState: self.gameState
            )
            if !success {
                print("❌ Cannot order supply drop - insufficient credits or delivery in progress")
            }
        }
        supplyDropUI.onClearOrder = { [weak self] in
            self?.supplyDropSystem.clearOrder()
        }
        supplyDropUI.isHidden = true  // Hidden until mining starts
        cameraNode.addChild(supplyDropUI)

        // Create Surface UI (attach to camera)
        surfaceUI = SurfaceUI(screenSize: view!.bounds.size)
        surfaceUI.zPosition = 200  // Above everything
        surfaceUI.onLaunch = { [weak self] in
            self?.launchMiningRun()
            self?.hud.isHidden = false  // Show HUD when launching
        }
        surfaceUI.onPurchaseUpgrade = { [weak self] upgradeType in
            self?.purchaseUpgrade(upgradeType)
        }
        surfaceUI.onPurchaseConsumable = { [weak self] consumableType in
            self?.purchaseConsumable(consumableType)
        }
        surfaceUI.onResetProgress = { [weak self] in
            self?.resetProgressForTesting()
        }
        cameraNode.addChild(surfaceUI)

        // Create Sell Dialog (attach to camera)
        sellDialog = SellDialog(screenSize: view!.bounds.size)
        sellDialog.zPosition = 300  // Above surface UI
        sellDialog.onSell = { [weak self] in
            guard let self = self else { return }
            self.sellAllCargo()
            // Hide dialog and show surface UI
            self.sellDialog.hide()
            self.surfaceUI.show(gameState: self.gameState, hideHUD: { [weak self] hide in
                self?.hud.isHidden = hide
            })
            self.isMovementLocked = false
        }
        sellDialog.onClose = { [weak self] in
            guard let self = self else { return }
            // Close without selling (skip to surface UI)
            self.sellDialog.hide()
            self.surfaceUI.show(gameState: self.gameState, hideHUD: { [weak self] hide in
                self?.hud.isHidden = hide
            })
            self.isMovementLocked = false
        }
        cameraNode.addChild(sellDialog)

        // Create Game Over Dialog (attach to camera)
        gameOverDialog = GameOverDialog(screenSize: view!.bounds.size)
        gameOverDialog.zPosition = 400  // Above everything
        gameOverDialog.onContinue = { [weak self] in
            self?.completeGameOverReset()
        }
        cameraNode.addChild(gameOverDialog)

        // Start at surface
        surfaceUI.show(gameState: gameState, hideHUD: { [weak self] hide in
            self?.hud.isHidden = hide
        })

        print("🚀 DESCENT initialized - Touch and hold to move pod")
    }

    private func setupShop() {
        // Create a small shop building at the left side of the surface
        // Pod is 48px, so shop is 96px (2x)
        let shopWidth: CGFloat = 96
        let shopHeight: CGFloat = 96
        let surfaceY = frame.maxY - 100
        let shopX = frame.minX + 150  // Position on the left side

        // Create solid floor platform under the shop
        let floorWidth: CGFloat = 150
        let floorHeight: CGFloat = 20
        let floor = SKSpriteNode(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0), size: CGSize(width: floorWidth, height: floorHeight))
        floor.position = CGPoint(x: shopX, y: surfaceY - floorHeight / 2)
        floor.zPosition = 4
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = 2  // Terrain
        floor.physicsBody?.collisionBitMask = 1  // Player
        addChild(floor)

        shopBuilding = SKSpriteNode(color: UIColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1.0), size: CGSize(width: shopWidth, height: shopHeight))
        shopBuilding.position = CGPoint(x: shopX, y: surfaceY + shopHeight / 2)  // On top of surface
        shopBuilding.zPosition = 5
        shopBuilding.physicsBody = SKPhysicsBody(rectangleOf: shopBuilding.size)
        shopBuilding.physicsBody?.isDynamic = false
        shopBuilding.physicsBody?.categoryBitMask = 4  // Shop
        shopBuilding.physicsBody?.contactTestBitMask = 1  // Player
        shopBuilding.physicsBody?.collisionBitMask = 0  // No collision, just contact
        shopBuilding.name = "shop"
        addChild(shopBuilding)

        // Add a roof
        let roofPath = CGMutablePath()
        roofPath.move(to: CGPoint(x: -shopWidth / 2 - 5, y: shopHeight / 2))
        roofPath.addLine(to: CGPoint(x: 0, y: shopHeight / 2 + 20))
        roofPath.addLine(to: CGPoint(x: shopWidth / 2 + 5, y: shopHeight / 2))
        roofPath.closeSubpath()

        let roof = SKShapeNode(path: roofPath)
        roof.fillColor = UIColor(red: 0.5, green: 0.2, blue: 0.1, alpha: 1.0)
        roof.strokeColor = UIColor(red: 0.3, green: 0.1, blue: 0.05, alpha: 1.0)
        roof.lineWidth = 2
        roof.zPosition = 1
        shopBuilding.addChild(roof)

        // Add "SHOP" sign (smaller)
        let signLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        signLabel.text = "SHOP"
        signLabel.fontSize = 16
        signLabel.fontColor = .yellow
        signLabel.verticalAlignmentMode = .center
        signLabel.position = CGPoint(x: 0, y: 5)
        signLabel.zPosition = 2
        shopBuilding.addChild(signLabel)

        // Add door (smaller)
        let door = SKSpriteNode(color: UIColor(red: 0.2, green: 0.1, blue: 0.05, alpha: 1.0), size: CGSize(width: 24, height: 36))
        door.position = CGPoint(x: 0, y: -12)
        door.zPosition = 1
        shopBuilding.addChild(door)

        // Store door position in world coordinates (for pod snapping)
        // Door is at center-bottom of shop, slightly in front
        shopDoorPosition = CGPoint(x: shopX + 30, y: surfaceY + 10)  // Slightly right and up from shop center

        // Create invisible boundaries on left and right edges
        createBoundaries()
    }

    private func createBoundaries() {
        let boundaryHeight: CGFloat = 10000  // Very tall wall
        let boundaryThickness: CGFloat = 50

        // Left boundary
        let leftWall = SKSpriteNode(color: .clear, size: CGSize(width: boundaryThickness, height: boundaryHeight))
        leftWall.position = CGPoint(x: frame.minX - boundaryThickness / 2, y: frame.midY)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.categoryBitMask = 2  // Terrain
        leftWall.physicsBody?.collisionBitMask = 1  // Player
        leftWall.zPosition = 1
        addChild(leftWall)

        // Right boundary
        let rightWall = SKSpriteNode(color: .clear, size: CGSize(width: boundaryThickness, height: boundaryHeight))
        rightWall.position = CGPoint(x: frame.maxX + boundaryThickness / 2, y: frame.midY)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.categoryBitMask = 2  // Terrain
        rightWall.physicsBody?.collisionBitMask = 1  // Player
        rightWall.zPosition = 1
        addChild(rightWall)

        print("🧱 Created boundaries at x: \(frame.minX) and \(frame.maxX)")
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let locationInCamera = touch.location(in: cameraNode)

        // Debug: Triple tap to open showcase (only at surface)
        if !surfaceUI.isHidden && gameState.phase == .surface {
            let currentTime = Date().timeIntervalSince1970
            if currentTime - lastTapTime < 0.5 {
                tapCount += 1
                if tapCount >= 2 {  // Third tap (0, 1, 2)
                    openPodShowcase()
                    tapCount = 0
                    return
                }
            } else {
                tapCount = 0
            }
            lastTapTime = currentTime
        }

        // If game over dialog is visible, handle touches there first
        if !gameOverDialog.isHidden {
            if gameOverDialog.handleTouch(at: locationInCamera) {
                return
            }
        }

        // If sell dialog is visible, handle touches there first
        if !sellDialog.isHidden {
            if sellDialog.handleTouch(at: locationInCamera) {
                return
            }
        }

        // If surface UI is visible, handle touches there first
        if !surfaceUI.isHidden {
            if surfaceUI.handleTouch(at: locationInCamera, gameState: gameState) {
                return
            }
        }

        // Check if touch hit a consumable button
        if !consumableUI.isHidden {
            if consumableUI.handleTouch(at: locationInCamera) {
                return
            }
        }

        // Check if touch hit supply drop UI
        if !supplyDropUI.isHidden {
            if supplyDropUI.handleTouch(at: locationInCamera, gameState: gameState) {
                return
            }
        }

        // Normal movement controls - delegate to InputManager
        inputManager.handleTouchesBegan(touches, in: self)
    }

    private func openPodShowcase() {
        print("🎨 Opening Pod Showcase...")
        let showcaseScene = PodShowcaseScene(size: size)
        showcaseScene.scaleMode = scaleMode
        view?.presentScene(showcaseScene, transition: SKTransition.fade(withDuration: 0.3))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.handleTouchesMoved(touches, in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.handleTouchesEnded(touches, in: self)
        player.stopThrust()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputManager.handleTouchesCancelled(touches, in: self)
        player.stopThrust()
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        // Don't update during game over
        if isGameOverInProgress {
            return
        }

        // Calculate delta time
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Limit delta time to prevent large jumps
        let clampedDeltaTime = min(deltaTime, 1.0 / 30.0)

        // Update player movement (only if not locked by dialog AND actively mining)
        if !isMovementLocked && inputManager.isTouching && gameState.phase == .mining, let touchLocation = inputManager.currentTouchLocation {
            let gravity = gameState.currentPlanet.gravity * 9.8
            player.moveTowards(target: touchLocation, deltaTime: clampedDeltaTime, currentGravity: CGFloat(gravity))

            // Apply active physics (higher friction for control)
            player.applyActivePhysics()

            // Fuel consumption when thrusting (FUEL_SYSTEM.md:13-38)
            // Formula: fuelPerSecond = baseFuelConsumption × thrustIntensity × zoneModifier
            let distanceToFinger = hypot(touchLocation.x - player.position.x, touchLocation.y - player.position.y)
            let maxThrustDistance: CGFloat = 150  // Full thrust beyond this
            let thrustIntensity = min(1.0, distanceToFinger / maxThrustDistance)
            let baseFuelConsumption = 1.5  // fuel/second (FUEL_SYSTEM.md:19)
            let zoneModifier = 1.0  // No environmental zones yet

            let fuelPerSecond = baseFuelConsumption * thrustIntensity * zoneModifier
            let fuelConsumption = fuelPerSecond * deltaTime

            // Update exhaust particles based on thrust intensity
            player.updateExhaust(thrustIntensity: thrustIntensity)

            if !gameState.consumeFuel(fuelConsumption) {
                // Out of fuel - triggers 50% cargo penalty
                handleGameOver(reason: "Out of Fuel")
            }
        } else if !isMovementLocked && gameState.phase == .mining {
            // Apply edge physics when not thrusting (lower friction allows sliding)
            player.applyEdgePhysics()
            // Stop exhaust when not thrusting
            player.updateExhaust(thrustIntensity: 0)
        }

        // Update player
        player.update(deltaTime: clampedDeltaTime)

        // Update active effects (shield, etc.)
        gameState.updateActiveEffects(deltaTime: clampedDeltaTime)

        // Update drill cooldown (only during mining phase)
        if gameState.phase == .mining {
            if drillCooldown > 0 {
                drillCooldown -= clampedDeltaTime
            }

            // Try drilling (with cooldown)
            if drillCooldown <= 0 {
                tryDrilling()
                if player.getDrillDirection() != nil {
                    drillCooldown = currentDrillSpeed
                }
            }
        }

        // Update depth tracking
        let surfaceY = frame.maxY - 100
        // Calculate depth in meters (1 tile = 1 meter, tile size = 24px)
        let currentDepth = max(0, (surfaceY - player.position.y) / TerrainBlock.size)
        gameState.currentDepth = currentDepth

        // Update terrain chunks (load/unload based on player position)
        terrainManager.updateChunks(playerY: player.position.y)

        // Update camera to follow player
        updateCamera()

        // Update HUD
        hud.update(gameState: gameState)

        // Update Consumable UI
        consumableUI.update(gameState: gameState)

        // Update Supply Drop System
        if gameState.phase == .mining {
            supplyDropSystem.update(
                deltaTime: clampedDeltaTime,
                playerPosition: player.position,
                playerVelocity: player.physicsBody?.velocity ?? .zero
            )

            // Update supply drop UI
            if let countdown = supplyDropSystem.getCurrentCountdown() {
                let isMoving = supplyDropSystem.isPlayerMoving(velocity: player.physicsBody?.velocity ?? .zero)
                supplyDropUI.showCountdown(timeRemaining: countdown, isMoving: isMoving)
                supplyDropUI.updateSupplyButton(countdown: countdown)
            } else {
                supplyDropUI.hideCountdown()
                supplyDropUI.updateSupplyButton(countdown: nil)
            }
        }
    }

    private func updateCamera() {
        // Smooth camera follow - keep player in vertical center of screen
        let targetY = player.position.y
        let currentY = cameraNode.position.y
        let smoothing: CGFloat = 0.1
        cameraNode.position.y = currentY + (targetY - currentY) * smoothing
        cameraNode.position.x = frame.midX
    }

    // MARK: - Surface Management

    private func returnToSurface() {
        print("🚁 Teleporting to surface...")

        // Reset player position to surface (but don't sell cargo yet)
        player.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        player.physicsBody?.velocity = .zero

        // Reset camera
        cameraNode.position = CGPoint(x: frame.midX, y: frame.maxY - 100)

        // Reset depth but keep cargo
        gameState.currentDepth = 0.0
        gameState.phase = .surface

        print("📦 Returned with cargo worth: $\(Int(gameState.cargoValue))")

        // Show surface UI (player can now sell or launch again)
        surfaceUI.show(gameState: gameState, hideHUD: { [weak self] hide in
            self?.hud.isHidden = hide
        })
    }

    private func sellAllCargo() {
        // Process the successful run completion (adds cargo value to credits, updates stats, etc.)
        gameState.endRunSuccess()

        print("💰 Cargo sold and run completed!")
        print("💵 Total credits: $\(Int(gameState.credits))")
    }

    private func handleGameOver(reason: String) {
        // Prevent multiple game over triggers
        guard !isGameOverInProgress else { return }
        isGameOverInProgress = true

        print("💀 GAME OVER: \(reason)")

        let cargoValue = gameState.cargoValue

        // Determine if fuel-out (50% recovery) or hull-destroyed (total loss)
        let isFuelOut = reason.contains("Fuel")

        // Call the appropriate game over method
        if isFuelOut {
            gameState.endRunOutOfFuel()
        } else {
            gameState.endRunHullDestroyed()
        }

        // Show game over modal
        gameOverDialog.show(reason: reason, cargoValue: cargoValue)

        // Stop all player movement
        player.physicsBody?.velocity = .zero
        player.stopThrust()

        // Clear touch state
        inputManager.reset()

        // Hide consumable UI and supply drop UI
        consumableUI.isHidden = true
        supplyDropUI.isHidden = true
        supplyDropSystem.reset()
    }

    private func completeGameOverReset() {
        print("🔄 Returning to surface after game over...")

        // Hide game over dialog
        gameOverDialog.hide()

        // NOTE: Game over logic (cargo/credits) already handled in handleGameOver()
        // Credits and upgrades persist until prestige - only currentRun is cleared

        // Reset player position to surface
        player.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
        player.physicsBody?.velocity = .zero
        player.stopThrust()

        // Clear touch state
        inputManager.reset()
        isMovementLocked = false

        // Reset camera to surface
        cameraNode.position = CGPoint(x: frame.midX, y: frame.maxY - 100)

        // Reset game state to surface (this will be needed for next run)
        gameState.phase = .surface

        // Clear and regenerate terrain for next run
        print("🗑️ Clearing terrain...")
        terrainManager.removeAllTerrain()
        print("🌍 Creating new terrain...")
        terrainManager = TerrainManager(scene: self, planet: gameState.currentPlanet)
        print("📍 Loading chunks at surface position...")
        terrainManager.updateChunks(playerY: player.position.y)

        // Show surface UI (credits and upgrades persist)
        print("🎮 Showing surface UI...")
        print("💵 Current credits: $\(Int(gameState.credits))")
        surfaceUI.show(gameState: gameState, hideHUD: { [weak self] hide in
            self?.hud.isHidden = hide
        })

        print("✅ Returned to surface!")

        // Reset game over flag
        isGameOverInProgress = false
    }

    private func launchMiningRun() {
        // Don't launch if already mining with cargo
        if gameState.phase == .mining && !gameState.currentCargo.isEmpty {
            print("⚠️ Already on a mining run with cargo!")
            surfaceUI.hide(showHUD: { [weak self] _ in
                self?.hud.isHidden = false
            })
            return
        }

        print("🚀 Launching mining run...")

        // Update pod visuals based on current upgrade levels
        player.updateUpgrades(
            drillLevel: gameState.drillStrengthLevel,
            hullLevel: gameState.hullArmorLevel,
            engineLevel: gameState.engineSpeedLevel,
            fuelLevel: gameState.fuelTankLevel,
            cargoLevel: gameState.cargoLevel
        )

        // Regenerate terrain with new seed for this run
        terrainManager.removeAllTerrain()
        terrainManager = TerrainManager(scene: self, planet: gameState.currentPlanet)
        terrainManager.updateChunks(playerY: player.position.y)

        gameState.startMiningRun()
        surfaceUI.hide(showHUD: { [weak self] _ in
            self?.hud.isHidden = false
            self?.consumableUI.isHidden = false  // Show consumable buttons
            self?.supplyDropUI.isHidden = false  // Show supply drop button
        })
        isGameOverInProgress = false  // Reset game over flag
    }

    private func resetProgressForTesting() {
        print("🔄 RESETTING ALL PROGRESS FOR TESTING...")

        // Reset planet state completely
        gameState.planetState?.credits = 0
        gameState.planetState?.upgrades = CommonUpgrades()
        gameState.planetState?.consumables = Consumables()
        gameState.planetState?.statistics = PlanetStatistics()

        // Save the reset
        _ = SaveManager.shared.saveProfile(gameState.profile)

        // Refresh the UI manually
        surfaceUI.isHidden = true
        surfaceUI.isHidden = false

        print("✅ Progress reset complete!")
        print("   - Credits: $0")
        print("   - All upgrades: Level 1")
        print("   - All consumables: 0")
    }

    private func purchaseUpgrade(_ type: SurfaceUI.UpgradeType) {
        let baseCost: Double
        let maxLevel = 6

        switch type {
        case .fuelTank:
            baseCost = 100
            guard gameState.fuelTankLevel < maxLevel else {
                print("⚠️ Fuel Tank already at max level!")
                return
            }
            let cost = baseCost * pow(1.5, Double(gameState.fuelTankLevel - 1))
            if gameState.credits >= cost {
                gameState.credits -= cost
                gameState.fuelTankLevel += 1
                print("⛽ Upgraded Fuel Tank to Level \(gameState.fuelTankLevel) (Max Fuel: \(gameState.maxFuel))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .drillStrength:
            baseCost = 150
            guard gameState.drillStrengthLevel < 5 else {
                print("⚠️ Drill already at max level!")
                return
            }
            let cost = baseCost * pow(1.5, Double(gameState.drillStrengthLevel - 1))
            if gameState.credits >= cost {
                gameState.credits -= cost
                gameState.drillStrengthLevel += 1
                print("⛏️ Upgraded Drill Strength to Level \(gameState.drillStrengthLevel)")
                // Update player pod visuals
                player.updateUpgrades(
                    drillLevel: gameState.drillStrengthLevel,
                    hullLevel: gameState.hullArmorLevel,
                    engineLevel: gameState.engineSpeedLevel,
                    fuelLevel: gameState.fuelTankLevel,
                    cargoLevel: gameState.cargoLevel
                )
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .cargoCapacity:
            baseCost = 120
            guard gameState.cargoLevel < maxLevel else {
                print("⚠️ Cargo already at max level!")
                return
            }
            let cost = baseCost * pow(1.5, Double(gameState.cargoLevel - 1))
            if gameState.credits >= cost {
                gameState.credits -= cost
                gameState.cargoLevel += 1
                print("📦 Upgraded Cargo Capacity to Level \(gameState.cargoLevel) (Max Cargo: \(gameState.cargoCapacity))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .hullArmor:
            baseCost = 130
            guard gameState.hullArmorLevel < maxLevel else {
                print("⚠️ Hull already at max level!")
                return
            }
            let cost = baseCost * pow(1.5, Double(gameState.hullArmorLevel - 1))
            if gameState.credits >= cost {
                gameState.credits -= cost
                gameState.hullArmorLevel += 1
                print("🛡️ Upgraded Hull Armor to Level \(gameState.hullArmorLevel) (Max Hull: \(gameState.maxHull))")
                // Update player pod visuals
                player.updateUpgrades(
                    drillLevel: gameState.drillStrengthLevel,
                    hullLevel: gameState.hullArmorLevel,
                    engineLevel: gameState.engineSpeedLevel,
                    fuelLevel: gameState.fuelTankLevel,
                    cargoLevel: gameState.cargoLevel
                )
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .engineSpeed:
            baseCost = 110
            guard gameState.engineSpeedLevel < 5 else {
                print("⚠️ Engine already at max level!")
                return
            }
            let cost = baseCost * pow(1.5, Double(gameState.engineSpeedLevel - 1))
            if gameState.credits >= cost {
                gameState.credits -= cost
                gameState.engineSpeedLevel += 1
                print("🚀 Upgraded Engine Speed to Level \(gameState.engineSpeedLevel)")
                // Update player pod visuals
                player.updateUpgrades(
                    drillLevel: gameState.drillStrengthLevel,
                    hullLevel: gameState.hullArmorLevel,
                    engineLevel: gameState.engineSpeedLevel,
                    fuelLevel: gameState.fuelTankLevel,
                    cargoLevel: gameState.cargoLevel
                )
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .impactDampeners:
            baseCost = 200
            guard gameState.impactDampenersLevel < 3 else {
                print("⚠️ Impact Dampeners already at max level!")
                return
            }
            let cost = baseCost * pow(1.5, Double(gameState.impactDampenersLevel))
            if gameState.credits >= cost {
                gameState.credits -= cost
                gameState.impactDampenersLevel += 1
                print("💥 Upgraded Impact Dampeners to Level \(gameState.impactDampenersLevel)")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }
        }

        // Refresh surface UI to show updated values and pod preview
        surfaceUI.show(gameState: gameState)
    }

    private func purchaseConsumable(_ type: SurfaceUI.ConsumableType) {
        guard let planet = gameState.planetState else { return }

        let maxConsumables = 99
        let cost: Double
        switch type {
        case .repairKit:
            cost = 150  // HULL_SYSTEM.md:369
            if planet.consumables.repairKits >= maxConsumables {
                print("🔧 Repair Kit inventory full (max: \(maxConsumables))")
            } else if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.repairKits += 1
                print("🔧 Purchased Repair Kit (x\(planet.consumables.repairKits))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .fuelCell:
            cost = 200  // FUEL_SYSTEM.md:203
            if planet.consumables.fuelCells >= maxConsumables {
                print("⛽ Fuel Cell inventory full (max: \(maxConsumables))")
            } else if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.fuelCells += 1
                print("⛽ Purchased Fuel Cell (x\(planet.consumables.fuelCells))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .bomb:
            cost = 75
            if planet.consumables.bombs >= maxConsumables {
                print("💣 Mining Bomb inventory full (max: \(maxConsumables))")
            } else if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.bombs += 1
                print("💣 Purchased Mining Bomb (x\(planet.consumables.bombs))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .teleporter:
            cost = 150
            if planet.consumables.teleporters >= maxConsumables {
                print("🌀 Teleporter inventory full (max: \(maxConsumables))")
            } else if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.teleporters += 1
                print("🌀 Purchased Teleporter (x\(planet.consumables.teleporters))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .shield:
            cost = 600  // HULL_SYSTEM.md:517-519
            if planet.consumables.shields >= maxConsumables {
                print("🛡️ Shield inventory full (max: \(maxConsumables))")
            } else if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.shields += 1
                print("🛡️ Purchased Shield (x\(planet.consumables.shields))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }
        }
    }
}

// MARK: - Drilling System

extension GameScene {
    /// Check if we should drill in the current frame
    func tryDrilling() {
        guard let drillDirection = player.getDrillDirection() else {
            return  // Not drilling or trying to drill up
        }

        // Calculate the drill tip position (at the edge of the pod)
        // Pod dimensions: 48px wide × 72px tall (same width as a single tile)
        let podHalfWidth: CGFloat = 24   // Half of 48px width
        let podHalfHeight: CGFloat = 36  // Half of 72px height
        var drillTipPosition = player.position

        switch drillDirection {
        case .down:
            // For downward drilling, position tip at pod's bottom edge + small offset
            // This ensures we drill the block directly below, not the one further down
            drillTipPosition.y -= (podHalfHeight + 8)  // Just 8px below pod bottom
        case .left:
            // For horizontal drilling, position just beyond pod edge
            drillTipPosition.x -= (podHalfWidth + 8)  // Just 8px left of pod edge
        case .right:
            drillTipPosition.x += (podHalfWidth + 8)  // Just 8px right of pod edge
        }

        // For horizontal drilling, drill the 2 tiles that the pod is currently occupying
        // Pod is 72px tall (1.5 tiles), so it spans at most 2 tile rows
        var blockPositions: [(x: Int, y: Int)] = []

        if drillDirection == .left || drillDirection == .right {
            // Find tiles that the pod's body occupies (not the absolute edges)
            // Use positions slightly inside the pod to avoid rounding to adjacent tiles
            var topPos = drillTipPosition
            topPos.y = player.position.y + (podHalfHeight - 8)  // Just below top edge

            var bottomPos = drillTipPosition
            bottomPos.y = player.position.y - (podHalfHeight - 8)  // Just above bottom edge

            guard let topGridPos = terrainManager.worldToGrid(topPos),
                  let bottomGridPos = terrainManager.worldToGrid(bottomPos) else {
                return
            }

            // Drill the tiles that the pod currently occupies
            // This prevents drilling above or below the shaft
            blockPositions.append((x: topGridPos.x, y: topGridPos.y))

            // Only drill second tile if it's different from the first
            if bottomGridPos.y != topGridPos.y {
                blockPositions.append((x: bottomGridPos.x, y: bottomGridPos.y))
            }
        } else {
            // Vertical drilling - use drill tip position
            guard let gridPos = terrainManager.worldToGrid(drillTipPosition) else {
                return
            }
            blockPositions.append((x: gridPos.x, y: gridPos.y))
        }

        // Calculate drill speed based on hardest block's strata hardness (mars_level_design.md:386-405)
        // When drilling multiple blocks, use the hardest one to determine speed, then multiply by tile count
        // Formula: actualDrillTime = baseDrillTime × strataHardness / drillLevel × numberOfTiles
        var maxStrataHardness = 1.0
        var actualBlockCount = 0
        for blockPos in blockPositions {
            if let block = terrainManager.getBlock(x: blockPos.x, y: blockPos.y) {
                maxStrataHardness = max(maxStrataHardness, block.strataHardness)
                actualBlockCount += 1
            }
        }

        let baseDrillTime = 0.3  // seconds per tile (mars_level_design.md:392)
        let drillLevel = Double(gameState.drillStrengthLevel)
        // Drilling multiple tiles takes proportionally longer (e.g., 2 tiles = ~2x time)
        let tileMultiplier = max(1.0, Double(actualBlockCount) * 0.75)  // 0.75x per extra tile (slight efficiency bonus)
        // Horizontal drilling penalty: drilling sideways is harder, takes 2x as long
        let horizontalPenalty = (drillDirection == .left || drillDirection == .right) ? 2.0 : 1.0
        currentDrillSpeed = baseDrillTime * maxStrataHardness / drillLevel * tileMultiplier * horizontalPenalty

        // Try to drill all target blocks
        // NOTE: When drilling horizontally, this drills 2 tiles simultaneously
        // - Each tile consumes fuel individually based on its hardness (total fuel = sum of both tiles)
        // - All tiles take damage at once, but drill time is adjusted for multiple tiles above
        let drillPower = gameState.drillStrengthLevel
        for blockPos in blockPositions {
            if let targetBlock = terrainManager.getBlock(x: blockPos.x, y: blockPos.y) {
                if targetBlock.takeDamage(drillPower, drillLevel: drillPower, from: drillDirection) {
                    // Block destroyed! Consume fuel for THIS tile (FUEL_SYSTEM.md:45-68)
                    // Formula: fuelPerTile = baseDrillCost × strataHardness / drillLevel
                    let baseDrillCost = 1.0
                    let strataHardness = targetBlock.strataHardness
                    let drillLevel = Double(gameState.drillStrengthLevel)
                    let fuelCost = baseDrillCost * strataHardness / drillLevel

                    if !gameState.consumeFuel(fuelCost) {
                        // Out of fuel while drilling - triggers 50% cargo penalty
                        handleGameOver(reason: "Out of Fuel")
                        return
                    }

                    // Collect material if present
                    if let material = terrainManager.removeBlock(x: blockPos.x, y: blockPos.y) {
                        if gameState.addToCargo(material) {
                            print("⛏️ Mined \(material.type.rawValue) worth $\(Int(material.value)) (fuel: -\(String(format: "%.1f", fuelCost)))")
                        } else {
                            print("📦 Cargo full! Can't collect \(material.type.rawValue)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Physics Contact Delegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Ignore all contacts during game over
        if isGameOverInProgress {
            return
        }

        let bodies = [contact.bodyA, contact.bodyB]

        // Check for shop/surface contact
        if bodies.first(where: { $0.node?.name == "shop" }) != nil,
           bodies.contains(where: { $0.categoryBitMask == 1 }) {
            // Pod touched the surface/shop - check if we should end the run
            if gameState.phase == .mining {
                print("🏁 Surface reached! Ending run...")
                handleRunEnd()
                return
            }
        }

        // Check for terrain contact
        guard bodies.first(where: { $0.categoryBitMask == 1 }) != nil,
              bodies.first(where: { $0.categoryBitMask == 2 }) != nil else {
            return
        }

        // Take impact damage - delegate to DamageSystem
        let surfaceY = frame.maxY - 100
        damageSystem.processImpact(
            impulse: contact.collisionImpulse,
            playerPosition: player.position,
            surfaceY: surfaceY,
            podSize: player.size,
            gameState: gameState
        )
    }

    private func handleRunEnd() {
        // Prevent multiple triggers
        guard gameState.phase == .mining else { return }

        // Snap pod to surface position
        player.position = shopDoorPosition
        player.physicsBody?.velocity = .zero
        player.stopThrust()

        // Lock movement
        isMovementLocked = true

        // Clear touch state
        inputManager.reset()

        // Hide consumable UI and supply drop UI
        consumableUI.isHidden = true
        supplyDropUI.isHidden = true
        supplyDropSystem.reset()

        // Update phase (but don't process the sale yet - wait for user to click "Sell All")
        gameState.phase = .surface

        // Show sell dialog with run results BEFORE processing the sale
        sellDialog.show(gameState: gameState)

        print("🏁 Run ended - reached surface!")
        print("   - Cargo Value: $\(Int(gameState.cargoValue))")
        print("   - Depth Reached: \(Int(gameState.currentDepth))m")
    }
}

// MARK: - InputManager Delegate

extension GameScene: InputManagerDelegate {
    func inputDidBegin(at location: CGPoint) {
        // Input began - nothing special to do
    }

    func inputDidMove(to location: CGPoint) {
        // Input moved - nothing special to do (handled in update loop)
    }

    func inputDidEnd() {
        // Input ended - nothing special to do
    }

    func inputDidCancel() {
        // Input cancelled - nothing special to do
    }
}

// MARK: - DamageSystem Delegate

extension GameScene: DamageSystemDelegate {
    func damageSystemDidDestroyHull() {
        handleGameOver(reason: "Hull Destroyed")
    }
}

// MARK: - ConsumableSystem Delegate

extension GameScene: ConsumableSystemDelegate {
    func consumableSystemDidUseTeleporter() {
        print("🌀 Teleporting to surface...")
        createTeleportEffect(at: player.position)

        // Teleport pod to 200px above surface, centered
        let surfaceY = frame.maxY - 100
        let surfaceX = frame.midX + 50
        let targetPosition = CGPoint(x: surfaceX, y: surfaceY + 200)
        player.position = targetPosition
        player.physicsBody?.velocity = .zero

        print("   Teleported to (\(Int(targetPosition.x)), \(Int(targetPosition.y)))")
    }

    func consumableSystemDidUseBomb(at position: CGPoint) {
        print("💣 Bomb activated at \(position)")

        // Clear 3×3 area and collect materials
        let materials = terrainManager.clearBombArea(at: position)

        // Add collected materials to cargo
        for material in materials {
            if gameState.addToCargo(material) {
                print("   ⛏️ Collected \(material.type.rawValue) from bomb")
            }
        }

        // Add explosion visual effect
        createExplosionEffect(at: position)
    }

    func consumableSystemDidActivateShield(duration: TimeInterval) {
        print("🛡️ Shield activated for \(Int(duration))s")
        createShieldEffect(duration: duration)
    }
}

// MARK: - Visual Effects

extension GameScene {
    private func createExplosionEffect(at position: CGPoint) {
        // Create expanding orange circle
        let explosion = SKShapeNode(circleOfRadius: 10)
        explosion.fillColor = .orange
        explosion.strokeColor = .red
        explosion.lineWidth = 4
        explosion.glowWidth = 10
        explosion.position = position
        explosion.zPosition = 200
        addChild(explosion)

        // Expand and fade out
        let expand = SKAction.scale(to: 8.0, duration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([
            SKAction.group([expand, fadeOut]),
            remove
        ])
        explosion.run(sequence)

        // Add debris circles flying outward
        for i in 0..<12 {
            let angle = CGFloat(i) * .pi / 6
            let debris = SKShapeNode(circleOfRadius: 6)
            debris.fillColor = .orange
            debris.strokeColor = .red
            debris.lineWidth = 2
            debris.position = position
            debris.zPosition = 201
            addChild(debris)

            let distance: CGFloat = 120
            let moveBy = CGVector(dx: cos(angle) * distance, dy: sin(angle) * distance)
            let moveOut = SKAction.move(by: moveBy, duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let removeDebris = SKAction.removeFromParent()
            debris.run(SKAction.sequence([
                SKAction.group([moveOut, fade]),
                removeDebris
            ]))
        }
    }

    private func createShieldEffect(duration: TimeInterval) {
        // Remove existing shield if any
        shieldEffect?.removeFromParent()

        // Create glowing shield bubble around pod
        let shieldRadius: CGFloat = 50
        let shield = SKShapeNode(circleOfRadius: shieldRadius)
        shield.fillColor = UIColor.cyan.withAlphaComponent(0.2)
        shield.strokeColor = .cyan
        shield.lineWidth = 3
        shield.glowWidth = 10
        shield.zPosition = 150
        player.addChild(shield)
        shieldEffect = shield

        // Pulse animation
        let pulseUp = SKAction.scale(to: 1.1, duration: 0.3)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([pulseUp, pulseDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        shield.run(repeatPulse)

        // Fade out and remove after duration
        let wait = SKAction.wait(forDuration: duration - 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        shield.run(SKAction.sequence([wait, fadeOut, remove]))

        // Clear reference after removal
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.shieldEffect = nil
        }
    }

    private func createTeleportEffect(at position: CGPoint) {
        // White flash expanding from position
        let flash = SKShapeNode(circleOfRadius: 20)
        flash.fillColor = .white
        flash.strokeColor = .cyan
        flash.lineWidth = 5
        flash.glowWidth = 15
        flash.position = position
        flash.zPosition = 250
        flash.alpha = 0.8
        addChild(flash)

        // Expand rapidly and fade
        let expand = SKAction.scale(to: 10.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([
            SKAction.group([expand, fadeOut]),
            remove
        ]))

        // Add swirling cyan rings
        for i in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: 30 + CGFloat(i) * 15)
            ring.fillColor = .clear
            ring.strokeColor = .cyan
            ring.lineWidth = 3
            ring.glowWidth = 5
            ring.position = position
            ring.zPosition = 251
            ring.alpha = 0.8
            addChild(ring)

            let delay = Double(i) * 0.1
            let wait = SKAction.wait(forDuration: delay)
            let expandRing = SKAction.scale(to: 3.0, duration: 0.5)
            let fadeRing = SKAction.fadeOut(withDuration: 0.5)
            let removeRing = SKAction.removeFromParent()
            ring.run(SKAction.sequence([
                wait,
                SKAction.group([expandRing, fadeRing]),
                removeRing
            ]))
        }
    }

    private func createRepairEffect() {
        // Green pulse around pod
        let pulse = SKShapeNode(circleOfRadius: 60)
        pulse.fillColor = UIColor.green.withAlphaComponent(0.3)
        pulse.strokeColor = .green
        pulse.lineWidth = 4
        pulse.glowWidth = 8
        pulse.zPosition = 151
        player.addChild(pulse)

        // Pulse animation
        let expand = SKAction.scale(to: 1.5, duration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        pulse.run(SKAction.sequence([
            SKAction.group([expand, fadeOut]),
            remove
        ]))

        // Add sparkle circles
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let distance: CGFloat = 40
            let x = cos(angle) * distance
            let y = sin(angle) * distance

            let sparkle = SKShapeNode(circleOfRadius: 4)
            sparkle.fillColor = .green
            sparkle.strokeColor = .white
            sparkle.lineWidth = 1
            sparkle.position = CGPoint(x: x, y: y)
            sparkle.zPosition = 152
            player.addChild(sparkle)

            let moveOut = SKAction.move(by: CGVector(dx: x * 0.5, dy: y * 0.5), duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let removeSparkle = SKAction.removeFromParent()
            sparkle.run(SKAction.sequence([
                SKAction.group([moveOut, fade]),
                removeSparkle
            ]))
        }
    }

    private func createFuelEffect() {
        // Orange/yellow pulse around pod
        let pulse = SKShapeNode(circleOfRadius: 60)
        pulse.fillColor = UIColor.orange.withAlphaComponent(0.3)
        pulse.strokeColor = .orange
        pulse.lineWidth = 4
        pulse.glowWidth = 8
        pulse.zPosition = 151
        player.addChild(pulse)

        // Pulse animation
        let expand = SKAction.scale(to: 1.5, duration: 0.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        pulse.run(SKAction.sequence([
            SKAction.group([expand, fadeOut]),
            remove
        ]))

        // Add fuel droplet circles
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let distance: CGFloat = 40
            let x = cos(angle) * distance
            let y = sin(angle) * distance

            let droplet = SKShapeNode(circleOfRadius: 5)
            droplet.fillColor = .yellow
            droplet.strokeColor = .orange
            droplet.lineWidth = 1
            droplet.position = CGPoint(x: x, y: y)
            droplet.zPosition = 152
            player.addChild(droplet)

            let moveOut = SKAction.move(by: CGVector(dx: x * 0.5, dy: y * 0.5), duration: 0.5)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let removeDroplet = SKAction.removeFromParent()
            droplet.run(SKAction.sequence([
                SKAction.group([moveOut, fade]),
                removeDroplet
            ]))
        }
    }
}

// MARK: - SupplyDropSystemDelegate
extension GameScene: SupplyDropSystemDelegate {
    func supplyDropSystemDidStartDelivery() {
        print("📦 Supply drop order placed - 30 second countdown started")
    }

    func supplyDropSystemDidCancelDelivery() {
        print("⚠️ Supply drop cancelled - player moved too much!")
        // Show cancellation message (could add a toast notification here)
    }

    func supplyDropSystemDidCompleteDelivery(items: [SupplyDropSystem.SupplyItem: Int]) {
        let totalItems = items.values.reduce(0, +)
        print("✅ Supply drop completed: \(totalItems) items")
    }

    func supplyDropSystemNeedsSupplyPod(at position: CGPoint, items: [SupplyDropSystem.SupplyItem: Int]) {
        // Spawn the supply pod animation
        let supplyPod = SupplyPod(items: items)
        addChild(supplyPod)

        // Animate the drop
        supplyPod.animateDrop(to: position, screenHeight: view!.bounds.height)

        // When pod lands, add items to inventory
        supplyPod.onLanded = { [weak self] in
            guard let self = self else { return }
            self.supplyDropSystem.finishDelivery(items: items, gameState: self.gameState)
        }
    }
}
