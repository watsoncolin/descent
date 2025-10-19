//
//  LevelExplorerScene.swift
//  DESCENT
//
//  Level exploration scene - scroll through an entire level to review terrain, colors, and strata
//

import SpriteKit

class LevelExplorerScene: SKScene {

    // MARK: - Properties

    private var terrainContainer: SKNode!
    private var cameraNode: SKCameraNode!
    private var depthLabel: SKLabelNode!
    private var strataLabel: SKLabelNode!

    // Scrolling properties
    private var touchStartY: CGFloat = 0
    private var cameraStartY: CGFloat = 0
    private var isDragging: Bool = false

    // Level configuration
    private var levelConfig: PlanetConfig!

    // Level dimensions
    private var levelWidth: CGFloat = 0
    private var levelTotalDepth: Double = 0
    private var surfaceY: CGFloat = 0

    // MARK: - Initialization

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)

        // Disable physics for explorer scene
        physicsWorld.gravity = .zero

        // Setup camera
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(cameraNode)
        camera = cameraNode

        // Create terrain container
        terrainContainer = SKNode()
        terrainContainer.name = "terrainContainer"
        addChild(terrainContainer)

        // Setup UI
        setupUI()

        // Load and generate terrain
        loadLevel()
    }

    // MARK: - Setup

    private func setupUI() {
        // Title (fixed to camera)
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "LEVEL EXPLORER"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: frame.height / 2 - 50)
        cameraNode.addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.text = "Drag to scroll • Double-tap to return"
        subtitle.fontSize = 14
        subtitle.fontColor = UIColor(white: 0.7, alpha: 1.0)
        subtitle.position = CGPoint(x: 0, y: frame.height / 2 - 80)
        cameraNode.addChild(subtitle)

        // Depth meter (top right, fixed to camera)
        depthLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        depthLabel.text = "0m"
        depthLabel.fontSize = 32
        depthLabel.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)  // Gold
        depthLabel.position = CGPoint(x: frame.width / 2 - 80, y: frame.height / 2 - 130)
        depthLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(depthLabel)

        // Stratum name (below depth, fixed to camera)
        strataLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        strataLabel.text = ""
        strataLabel.fontSize = 16
        strataLabel.fontColor = UIColor(white: 0.8, alpha: 1.0)
        strataLabel.position = CGPoint(x: frame.width / 2 - 80, y: frame.height / 2 - 160)
        strataLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(strataLabel)
    }

    private func loadLevel() {
        print("🌍 LevelExplorerScene: Loading Mars level...")

        // Load Mars configuration
        guard let config = LevelConfigLoader.shared.loadPlanet("mars") else {
            print("❌ Failed to load Mars level configuration!")
            return
        }

        levelConfig = config
        levelTotalDepth = config.totalDepth
        levelWidth = 1200  // Fixed width for explorer (about 18 blocks)

        print("🌍 Level loaded: \(config.name)")
        print("   - Total depth: \(levelTotalDepth)m")
        print("   - Strata count: \(config.strata.count)")

        // Generate all terrain layers
        generateTerrain()

        // Position camera at surface
        surfaceY = frame.midY
        cameraNode.position = CGPoint(x: frame.midX, y: surfaceY)

        // Update initial depth display
        updateDepthDisplay()
    }

    private func generateTerrain() {
        print("🏔️ Generating terrain layers using TerrainLayer (same as TerrainManager)...")

        // Use the same logic as TerrainManager - create TerrainLayer objects
        for (stratumIndex, stratum) in levelConfig.strata.enumerated() {
            // Use canonical mapping (same as TerrainManager)
            let terrainType = TerrainType.fromStratumName(stratum.name)

            print("   - Stratum \(stratumIndex): \(stratum.name) (\(stratum.depthMin)m - \(stratum.depthMax)m) → \(terrainType)")

            // Create TerrainLayer (same as TerrainManager)
            let layer = TerrainLayer(
                stratumRange: stratum.depthMin...stratum.depthMax,
                terrainType: terrainType,
                levelWidth: levelWidth,
                surfaceColors: stratum.surfaceGradient,
                excavatedColors: stratum.excavatedGradient
            )

            // Set zPosition (same as TerrainManager)
            layer.zPosition = CGFloat(-stratumIndex)

            // Position in world (same as TerrainManager)
            layer.positionInWorld(surfaceY: surfaceY, sceneMinX: frame.minX)

            terrainContainer.addChild(layer)

            print("     ✅ TerrainLayer created and positioned")
        }

        print("✅ Terrain generation complete!")
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        // Check for double-tap to return to game
        if touch.tapCount == 2 {
            let gameScene = GameScene(size: size)
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
            return
        }

        // Start drag for scrolling
        touchStartY = touch.location(in: self).y
        cameraStartY = cameraNode.position.y
        isDragging = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDragging else { return }

        let currentY = touch.location(in: self).y
        let deltaY = currentY - touchStartY

        // Move camera (invert direction for natural scrolling - drag down to go deeper)
        let newY = cameraStartY - deltaY

        // Calculate scroll bounds based on level depth
        let pixelsPerMeter = TerrainBlock.size / TerrainBlock.metersPerBlock
        let totalLevelHeightInPixels = CGFloat(levelTotalDepth) * pixelsPerMeter

        // Allow scrolling from surface down to the bottom of the level
        let maxY = surfaceY  // Surface (0m depth)
        let minY = surfaceY - totalLevelHeightInPixels + frame.height / 2  // Bottom of level

        cameraNode.position.y = max(minY, min(newY, maxY))

        // Update depth display
        updateDepthDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }

    // MARK: - Depth Display

    private func updateDepthDisplay() {
        // Calculate current depth based on camera position
        // Camera at surfaceY = 0m depth
        // Camera below surfaceY = positive depth
        let pixelsPerMeter = TerrainBlock.size / TerrainBlock.metersPerBlock
        let depthInPixels = surfaceY - cameraNode.position.y
        let depthInMeters = depthInPixels / pixelsPerMeter

        // Update depth label
        depthLabel.text = String(format: "%.0fm", max(0, depthInMeters))

        // Determine which stratum we're currently viewing
        let currentStratum = levelConfig.strata.first { stratum in
            depthInMeters >= stratum.depthMin && depthInMeters < stratum.depthMax
        }

        if let stratum = currentStratum {
            strataLabel.text = stratum.name
        } else {
            strataLabel.text = "Beyond Level"
        }
    }
}
