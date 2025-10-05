import SpriteKit

class GameScene: SKScene {

    // MARK: - Properties
    private var lastUpdateTime: TimeInterval = 0
    private var gameState = GameState()
    private var player: PlayerPod!

    // Touch control state
    private var currentTouchLocation: CGPoint?
    private var isTouching: Bool = false

    // Debug showcase (triple tap to activate)
    private var lastTapTime: TimeInterval = 0
    private var tapCount: Int = 0

    // Impact damage cooldown (prevent multiple damage from same collision)
    private var lastImpactTime: TimeInterval = 0
    private let impactCooldown: TimeInterval = 0.5  // 0.5 seconds between impacts

    // Camera
    private var cameraNode: SKCameraNode!

    // HUD
    private var hud: HUD!

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
        let location = touch.location(in: self)
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

        // TODO: Check consumable item buttons (Teleporter, Repair, Fuel, etc.)

        // Normal movement controls
        currentTouchLocation = location
        isTouching = true
    }

    private func openPodShowcase() {
        print("🎨 Opening Pod Showcase...")
        let showcaseScene = PodShowcaseScene(size: size)
        showcaseScene.scaleMode = scaleMode
        view?.presentScene(showcaseScene, transition: SKTransition.fade(withDuration: 0.3))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        currentTouchLocation = touch.location(in: self)
        isTouching = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouchLocation = nil
        isTouching = false
        player.stopThrust()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouchLocation = nil
        isTouching = false
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
        if !isMovementLocked && isTouching && gameState.phase == .mining, let touchLocation = currentTouchLocation {
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
    }

    private func updateCamera() {
        // Smooth camera follow
        let targetY = player.position.y + 200  // Offset so player is slightly below center
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
        currentTouchLocation = nil
        isTouching = false
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
        currentTouchLocation = nil
        isTouching = false
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
            engineLevel: gameState.engineSpeedLevel
        )

        // Regenerate terrain with new seed for this run
        terrainManager.removeAllTerrain()
        terrainManager = TerrainManager(scene: self, planet: gameState.currentPlanet)
        terrainManager.updateChunks(playerY: player.position.y)

        gameState.startMiningRun()
        surfaceUI.hide(showHUD: { [weak self] _ in
            self?.hud.isHidden = false
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
                // Update pod visuals
                player.updateUpgrades(
                    drillLevel: gameState.drillStrengthLevel,
                    hullLevel: gameState.hullArmorLevel,
                    engineLevel: gameState.engineSpeedLevel
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
                // Update pod visuals
                player.updateUpgrades(
                    drillLevel: gameState.drillStrengthLevel,
                    hullLevel: gameState.hullArmorLevel,
                    engineLevel: gameState.engineSpeedLevel
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
                // Update pod visuals
                player.updateUpgrades(
                    drillLevel: gameState.drillStrengthLevel,
                    hullLevel: gameState.hullArmorLevel,
                    engineLevel: gameState.engineSpeedLevel
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
    }

    private func purchaseConsumable(_ type: SurfaceUI.ConsumableType) {
        guard let planet = gameState.planetState else { return }

        let cost: Double
        switch type {
        case .repairKit:
            cost = 150  // HULL_SYSTEM.md:369
            if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.repairKits += 1
                print("🔧 Purchased Repair Kit (x\(planet.consumables.repairKits))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .fuelCell:
            cost = 200  // FUEL_SYSTEM.md:203
            if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.fuelCells += 1
                print("⛽ Purchased Fuel Cell (x\(planet.consumables.fuelCells))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .bomb:
            cost = 75
            if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.bombs += 1
                print("💣 Purchased Mining Bomb (x\(planet.consumables.bombs))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .teleporter:
            cost = 150
            if gameState.credits >= cost {
                gameState.credits -= cost
                planet.consumables.teleporters += 1
                print("🌀 Purchased Teleporter (x\(planet.consumables.teleporters))")
            } else {
                print("💸 Not enough credits! Need $\(Int(cost))")
            }

        case .shield:
            cost = 600  // HULL_SYSTEM.md:517-519
            if gameState.credits >= cost {
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
        // Pod dimensions: 24px wide × 36px tall (same width as a single tile)
        let podHalfWidth: CGFloat = 12   // Half of 24px width
        let podHalfHeight: CGFloat = 18  // Half of 36px height
        let drillTipOffset: CGFloat = podHalfHeight + (TerrainBlock.size / 2)
        var drillTipPosition = player.position

        switch drillDirection {
        case .down:
            drillTipPosition.y -= drillTipOffset  // Drill tip below center
        case .left:
            drillTipPosition.x -= (podHalfWidth + TerrainBlock.size / 2)  // Drill tip to the left
        case .right:
            drillTipPosition.x += (podHalfWidth + TerrainBlock.size / 2)  // Drill tip to the right
        }

        // Since pod is exactly 1 tile wide, just drill the single tile at drill tip position
        guard let gridPos = terrainManager.worldToGrid(drillTipPosition) else {
            return
        }

        let blockPositions = [(x: gridPos.x, y: gridPos.y)]

        // Calculate drill speed based on first block's strata hardness (mars_level_design.md:386-405)
        // Formula: actualDrillTime = baseDrillTime × strataHardness / drillLevel
        if let firstBlockPos = blockPositions.first,
           let firstBlock = terrainManager.getBlock(x: firstBlockPos.x, y: firstBlockPos.y) {
            let baseDrillTime = 0.3  // seconds per tile (mars_level_design.md:392)
            let strataHardness = firstBlock.strataHardness
            let drillLevel = Double(gameState.drillStrengthLevel)
            currentDrillSpeed = baseDrillTime * strataHardness / drillLevel
        }

        // Try to drill all target blocks
        let drillPower = gameState.drillStrengthLevel
        for blockPos in blockPositions {
            if let targetBlock = terrainManager.getBlock(x: blockPos.x, y: blockPos.y) {
                if targetBlock.takeDamage(drillPower, drillLevel: drillPower) {
                    // Block destroyed! Consume fuel for drilling (FUEL_SYSTEM.md:45-68)
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

        // Take impact damage ONLY when hitting terrain from above (falling down)
        // No damage from side impacts (hitting walls while moving horizontally)
        // No damage when actively thrusting (isTouching = true means player is controlling the pod)
        // Don't take damage near the surface (within 150 pixels of surface level)
        let surfaceY = frame.maxY - 100
        let distanceFromSurface = surfaceY - player.position.y
        let nearSurface = distanceFromSurface < 150  // Safe zone near shop

        // Use collision impulse instead of velocity for more accurate impact detection
        // collisionImpulse is the actual force of the collision, not accumulated velocity
        let impactForce = contact.collisionImpulse * 0.85

        // Damage threshold based on Impact Dampeners level
        // These values are tuned for collision impulse (not velocity)
        let damageThreshold: CGFloat
        switch gameState.impactDampenersLevel {
        case 0: damageThreshold = 10    // Very fragile
        case 1: damageThreshold = 25    // Can handle moderate falls
        case 2: damageThreshold = 50    // Can handle fast falls
        case 3: damageThreshold = .infinity  // No fall damage ever
        default: damageThreshold = 10
        }

        // Check cooldown to prevent multiple damage from same collision
        let currentTime = Date().timeIntervalSince1970
        let timeSinceLastImpact = currentTime - lastImpactTime

        // Only take damage if impact force is high enough and not actively thrusting
        if impactForce > damageThreshold && !nearSurface && timeSinceLastImpact >= impactCooldown {
            // Formula: damage scales with impact force
            // Higher multiplier since impulse values are lower than velocity
            let damage = (impactForce - damageThreshold) * 2.0
            let hullDestroyed = gameState.takeDamage(damage)
            lastImpactTime = currentTime  // Update last impact time

            print("💥 Impact damage: \(Int(damage)) HP (impulse: \(String(format: "%.1f", impactForce)), threshold: \(Int(damageThreshold)), dampeners: Lv.\(gameState.impactDampenersLevel))")
            print("   Hull: \(Int(gameState.currentHull))/\(Int(gameState.maxHull))")

            if hullDestroyed {
                handleGameOver(reason: "Hull Destroyed")
            }
        }
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
        currentTouchLocation = nil
        isTouching = false

        // Update phase (but don't process the sale yet - wait for user to click "Sell All")
        gameState.phase = .surface

        // Show sell dialog with run results BEFORE processing the sale
        sellDialog.show(gameState: gameState)

        print("🏁 Run ended - reached surface!")
        print("   - Cargo Value: $\(Int(gameState.cargoValue))")
        print("   - Depth Reached: \(Int(gameState.currentDepth))m")
    }
}
