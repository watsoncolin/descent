//
//  PodShowcaseScene.swift
//  DESCENT
//
//  Debug scene to showcase all pod upgrade combinations
//

import SpriteKit

class PodShowcaseScene: SKScene {

    private var pods: [[PlayerPod]] = []
    private var labels: [SKLabelNode] = []
    private var contentNode: SKNode!
    private var cameraNode: SKCameraNode!

    // Scrolling properties
    private var touchStartY: CGFloat = 0
    private var cameraStartY: CGFloat = 0
    private var lastTouchY: CGFloat = 0
    private var isDragging: Bool = false

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.1, green: 0.05, blue: 0.15, alpha: 1.0)

        // Disable physics for showcase scene
        physicsWorld.gravity = .zero

        // Setup camera for scrolling
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(cameraNode)
        camera = cameraNode

        // Create content node to hold all showcase content
        contentNode = SKNode()
        addChild(contentNode)

        setupShowcase()
    }

    private func setupShowcase() {
        // Title (fixed to camera, not scrollable)
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "POD UPGRADE SHOWCASE"
        title.fontSize = 24
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: frame.height / 2 - 50)
        cameraNode.addChild(title)

        let subtitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitle.text = "Scroll to view all upgrades • Double-tap to return"
        subtitle.fontSize = 14
        subtitle.fontColor = UIColor(white: 0.7, alpha: 1.0)
        subtitle.position = CGPoint(x: 0, y: frame.height / 2 - 80)
        cameraNode.addChild(subtitle)

        // Create grid layout
        let startY = frame.maxY - 150
        let spacing: CGFloat = 100

        // Section 1: Drill Strength Levels
        addSectionLabel("DRILL STRENGTH", at: CGPoint(x: frame.midX, y: startY))
        createPodRow(
            startY: startY - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 1"),
                (drill: 2, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 2"),
                (drill: 3, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 3"),
                (drill: 4, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 4"),
                (drill: 5, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 5")
            ]
        )

        // Section 2: Hull Armor Levels
        addSectionLabel("HULL ARMOR", at: CGPoint(x: frame.midX, y: startY - spacing))
        createPodRow(
            startY: startY - spacing - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 1"),
                (drill: 1, hull: 2, engine: 1, fuel: 1, cargo: 1, label: "Lv 2"),
                (drill: 1, hull: 3, engine: 1, fuel: 1, cargo: 1, label: "Lv 3"),
                (drill: 1, hull: 4, engine: 1, fuel: 1, cargo: 1, label: "Lv 4"),
                (drill: 1, hull: 5, engine: 1, fuel: 1, cargo: 1, label: "Lv 5"),
                (drill: 1, hull: 6, engine: 1, fuel: 1, cargo: 1, label: "Lv 6")
            ]
        )

        // Section 3: Engine Speed Levels
        addSectionLabel("ENGINE SPEED", at: CGPoint(x: frame.midX, y: startY - spacing * 2))
        createPodRow(
            startY: startY - spacing * 2 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 1"),
                (drill: 1, hull: 1, engine: 2, fuel: 1, cargo: 1, label: "Lv 2"),
                (drill: 1, hull: 1, engine: 3, fuel: 1, cargo: 1, label: "Lv 3"),
                (drill: 1, hull: 1, engine: 4, fuel: 1, cargo: 1, label: "Lv 4"),
                (drill: 1, hull: 1, engine: 5, fuel: 1, cargo: 1, label: "Lv 5")
            ]
        )

        // Section 4: Fuel Tank Levels
        addSectionLabel("FUEL TANK", at: CGPoint(x: frame.midX, y: startY - spacing * 3))
        createPodRow(
            startY: startY - spacing * 3 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 1"),
                (drill: 1, hull: 1, engine: 1, fuel: 2, cargo: 1, label: "Lv 2"),
                (drill: 1, hull: 1, engine: 1, fuel: 3, cargo: 1, label: "Lv 3"),
                (drill: 1, hull: 1, engine: 1, fuel: 4, cargo: 1, label: "Lv 4"),
                (drill: 1, hull: 1, engine: 1, fuel: 5, cargo: 1, label: "Lv 5"),
                (drill: 1, hull: 1, engine: 1, fuel: 6, cargo: 1, label: "Lv 6")
            ]
        )

        // Section 5: Cargo Capacity Levels
        addSectionLabel("CARGO CAPACITY", at: CGPoint(x: frame.midX, y: startY - spacing * 4))
        createPodRow(
            startY: startY - spacing * 4 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Lv 1"),
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 2, label: "Lv 2"),
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 3, label: "Lv 3"),
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 4, label: "Lv 4"),
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 5, label: "Lv 5"),
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 6, label: "Lv 6")
            ]
        )

        // Section 7: Combined Examples
        addSectionLabel("COMBINED UPGRADES", at: CGPoint(x: frame.midX, y: startY - spacing * 5))
        createPodRow(
            startY: startY - spacing * 5 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Basic"),
                (drill: 3, hull: 3, engine: 3, fuel: 3, cargo: 3, label: "Mid Tier"),
                (drill: 5, hull: 6, engine: 5, fuel: 6, cargo: 6, label: "Max Power"),
                (drill: 2, hull: 5, engine: 1, fuel: 4, cargo: 2, label: "Tank Build"),
                (drill: 5, hull: 2, engine: 5, fuel: 2, cargo: 5, label: "Speed Build")
            ]
        )

        // Section 8: Progressive Upgrade Path
        addSectionLabel("PROGRESSION EXAMPLE", at: CGPoint(x: frame.midX, y: startY - spacing * 6))
        createPodRow(
            startY: startY - spacing * 6 - 30,
            configs: [
                (drill: 1, hull: 1, engine: 1, fuel: 1, cargo: 1, label: "Start"),
                (drill: 2, hull: 2, engine: 1, fuel: 2, cargo: 2, label: "Early"),
                (drill: 3, hull: 3, engine: 2, fuel: 3, cargo: 3, label: "Mid"),
                (drill: 4, hull: 4, engine: 3, fuel: 4, cargo: 4, label: "Late"),
                (drill: 5, hull: 5, engine: 4, fuel: 5, cargo: 5, label: "End"),
                (drill: 5, hull: 6, engine: 5, fuel: 6, cargo: 6, label: "Max")
            ]
        )

        // Section 9: Material Blocks (embedded in soil)
        addSectionLabel("MATERIALS (Embedded in Soil)", at: CGPoint(x: frame.midX, y: startY - spacing * 7))
        createMaterialRow(startY: startY - spacing * 7 - 30)

        // Section 10: Terrain Strata Types
        addSectionLabel("TERRAIN STRATA", at: CGPoint(x: frame.midX, y: startY - spacing * 8.5))
        createStrataRow(startY: startY - spacing * 8.5 - 30)
    }

    private func addSectionLabel(_ text: String, at position: CGPoint) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 18
        label.fontColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)  // Gold
        label.position = position
        contentNode.addChild(label)
    }

    private func createPodRow(startY: CGFloat, configs: [(drill: Int, hull: Int, engine: Int, fuel: Int, cargo: Int, label: String)]) {
        let totalWidth = frame.width * 0.9
        let spacing = totalWidth / CGFloat(configs.count)
        let startX = (frame.width - totalWidth) / 2 + spacing / 2

        for (index, config) in configs.enumerated() {
            let x = startX + CGFloat(index) * spacing
            let y = startY

            // Create pod
            let pod = PlayerPod()
            pod.position = CGPoint(x: x, y: y)
            pod.forceUpdateUpgrades(
                drillLevel: config.drill,
                hullLevel: config.hull,
                engineLevel: config.engine,
                fuelLevel: config.fuel,
                cargoLevel: config.cargo
            )

            // Disable physics for showcase (these are static displays)
            pod.physicsBody?.isDynamic = false
            pod.physicsBody?.affectedByGravity = false

            contentNode.addChild(pod)

            // Add label below pod
            let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
            label.text = config.label
            label.fontSize = 12
            label.fontColor = .white
            label.position = CGPoint(x: x, y: y - 35)
            contentNode.addChild(label)

            // Add detail labels (smaller, showing D/H/E/F/C levels)
            let detailLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            detailLabel.text = "D:\(config.drill) H:\(config.hull) E:\(config.engine) F:\(config.fuel) C:\(config.cargo)"
            detailLabel.fontSize = 9
            detailLabel.fontColor = UIColor(white: 0.6, alpha: 1.0)
            detailLabel.position = CGPoint(x: x, y: y - 48)
            contentNode.addChild(detailLabel)

            // Add background panel for each pod
            let panel = SKShapeNode(rectOf: CGSize(width: spacing * 0.9, height: 90), cornerRadius: 5)
            panel.fillColor = UIColor(white: 0.1, alpha: 0.3)
            panel.strokeColor = UIColor(white: 0.3, alpha: 0.5)
            panel.lineWidth = 1
            panel.position = CGPoint(x: x, y: y - 5)
            panel.zPosition = -1
            contentNode.addChild(panel)
        }
    }

    private func createMaterialRow(startY: CGFloat) {
        // Get all material types
        let materials = Material.MaterialType.allCases

        // Create multiple rows if needed (7 materials per row)
        let materialsPerRow = 7
        let rowCount = (materials.count + materialsPerRow - 1) / materialsPerRow
        let blockSize: CGFloat = 48
        let horizontalSpacing: CGFloat = 70
        let verticalSpacing: CGFloat = 85

        for row in 0..<rowCount {
            let startIndex = row * materialsPerRow
            let endIndex = min(startIndex + materialsPerRow, materials.count)
            let rowMaterials = Array(materials[startIndex..<endIndex])

            let totalWidth = CGFloat(rowMaterials.count - 1) * horizontalSpacing
            let startX = frame.midX - totalWidth / 2
            let y = startY - CGFloat(row) * verticalSpacing

            for (index, materialType) in rowMaterials.enumerated() {
                let x = startX + CGFloat(index) * horizontalSpacing

                // Create material block embedded in soil (depth 150 for mid-level dirt)
                let material = Material(type: materialType)
                let block = TerrainBlock(material: material, depth: 150)
                block.position = CGPoint(x: x, y: y)
                block.physicsBody?.isDynamic = false
                contentNode.addChild(block)

                // Add material name label
                let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
                label.text = materialType.rawValue.capitalized
                label.fontSize = 10
                label.fontColor = .white
                label.position = CGPoint(x: x, y: y - 35)
                contentNode.addChild(label)

                // Add visual type label (ore/crystal)
                let typeLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
                typeLabel.text = materialType.visualType == .ore ? "ore" : "crystal"
                typeLabel.fontSize = 8
                typeLabel.fontColor = UIColor(white: 0.6, alpha: 1.0)
                typeLabel.position = CGPoint(x: x, y: y - 47)
                contentNode.addChild(typeLabel)

                // Add background panel
                let panel = SKShapeNode(rectOf: CGSize(width: 65, height: 75), cornerRadius: 3)
                panel.fillColor = UIColor(white: 0.1, alpha: 0.3)
                panel.strokeColor = UIColor(white: 0.3, alpha: 0.5)
                panel.lineWidth = 1
                panel.position = CGPoint(x: x, y: y - 5)
                panel.zPosition = -1
                contentNode.addChild(panel)
            }
        }
    }

    private func createStrataRow(startY: CGFloat) {
        // Create terrain blocks at different depths to show strata variations
        let depths: [(depth: Double, label: String)] = [
            (0, "0m\nShallow Dirt"),
            (50, "50m\nLight Dirt"),
            (100, "100m\nDeep Dirt"),
            (200, "200m\nDark Dirt"),
            (300, "300m\nStone"),
            (500, "500m\nDeep Stone")
        ]

        let blockSize: CGFloat = 48
        let spacing: CGFloat = 90
        let totalWidth = CGFloat(depths.count - 1) * spacing
        let startX = frame.midX - totalWidth / 2

        for (index, depthInfo) in depths.enumerated() {
            let x = startX + CGFloat(index) * spacing
            let y = startY

            // Create plain terrain block (no material)
            let block = TerrainBlock(material: nil, depth: depthInfo.depth)
            block.position = CGPoint(x: x, y: y)
            block.physicsBody?.isDynamic = false
            contentNode.addChild(block)

            // Add depth label
            let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
            label.text = depthInfo.label
            label.numberOfLines = 2
            label.fontSize = 10
            label.fontColor = .white
            label.position = CGPoint(x: x, y: y - 40)
            label.verticalAlignmentMode = .top
            label.horizontalAlignmentMode = .center
            contentNode.addChild(label)

            // Add background panel
            let panel = SKShapeNode(rectOf: CGSize(width: 80, height: 95), cornerRadius: 3)
            panel.fillColor = UIColor(white: 0.1, alpha: 0.3)
            panel.strokeColor = UIColor(white: 0.3, alpha: 0.5)
            panel.lineWidth = 1
            panel.position = CGPoint(x: x, y: y - 5)
            panel.zPosition = -1
            contentNode.addChild(panel)
        }
    }

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
        lastTouchY = touchStartY
        isDragging = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDragging else { return }

        let currentY = touch.location(in: self).y
        let deltaY = currentY - touchStartY

        // Move camera (invert direction for natural scrolling)
        let newY = cameraStartY - deltaY

        // Clamp camera position to content bounds
        // Content extends from top (frame.maxY - 150) down to bottom (frame.maxY - 1200)
        // Allow scrolling down to see bottom content and up to see top content
        let minY = frame.midY - 800  // Allow scrolling down to see bottom content
        let maxY = frame.midY + 200   // Allow scrolling up slightly from start position
        cameraNode.position.y = max(minY, min(newY, maxY))

        lastTouchY = currentY
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
}
