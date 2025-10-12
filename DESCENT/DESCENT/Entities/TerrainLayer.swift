//
//  TerrainLayer.swift
//  DESCENT
//
//  Represents a continuous geological terrain layer with:
//  - Base vertical gradient spanning entire stratum
//  - Organic variations (80-130px ellipses, 10-18% opacity)
//  - Diagonal flow patterns (15-40° angles)
//  - Dual-layer excavation system (surface + excavated)
//

import SpriteKit

class TerrainLayer: SKNode {

    // MARK: - Properties

    let stratumRange: ClosedRange<Double>  // Depth range (e.g., 0...640)
    let terrainType: TerrainType
    let layerSize: CGSize

    // Dual-layer system
    private var surfaceContainer: SKNode!    // Not used in consuming drill system (was: lighter layer)
    private var excavatedContainer: SKNode!  // Darker layer (background terrain - always visible)
    private var cutoutMask: SKCropNode!      // Mask to reveal excavated layer (legacy)
    private var maskShape: SKShapeNode!      // Shape for creating cutouts (legacy)
    private var drilledBlocks: Set<String> = []  // Track which blocks have been drilled

    // Custom colors from level config (override TerrainType colors if provided)
    private var customSurfaceColors: [UIColor]?
    private var customExcavatedColors: [UIColor]?

    // MARK: - Initialization

    init(stratumRange: ClosedRange<Double>, terrainType: TerrainType, levelWidth: CGFloat, surfaceColors: [UIColor]? = nil, excavatedColors: [UIColor]? = nil) {
        self.stratumRange = stratumRange
        self.terrainType = terrainType

        // Use provided color gradients from level config if available
        if let surface = surfaceColors, let excavated = excavatedColors {
            self.customSurfaceColors = surface
            self.customExcavatedColors = excavated

            print("🎨 Using custom colors from level config")
            print("   - Surface gradient: \(surface.count) colors")
            print("   - Excavated gradient: \(excavated.count) colors")
        }

        // Convert depth range (meters) to pixel height (64 pixels per meter)
        let depthInMeters = stratumRange.upperBound - stratumRange.lowerBound
        let pixelHeight = CGFloat(depthInMeters) * TerrainBlock.size

        print("🏔️ Creating TerrainLayer: \(terrainType)")
        print("   - Range: \(stratumRange.lowerBound)...\(stratumRange.upperBound)m")
        print("   - Depth: \(depthInMeters)m")
        print("   - Pixel height: \(pixelHeight)px")

        // Metal texture limit check
        if pixelHeight > 8192 {
            print("⚠️ ERROR: Texture height \(pixelHeight) exceeds Metal limit of 8192!")
            fatalError("Texture too large: \(pixelHeight)px. Maximum is 8192px. Stratum range: \(stratumRange)")
        }

        self.layerSize = CGSize(
            width: levelWidth,
            height: pixelHeight
        )

        super.init()

        print("   - Final size: \(layerSize)")

        setupDualLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupDualLayers() {
        // Use custom colors if provided, otherwise fall back to TerrainType colors
        let excavatedColors = customExcavatedColors ?? terrainType.excavatedGradientColors

        // 1. Create excavated layer as the ONLY background (darker, zPosition 4)
        excavatedContainer = createContinuousTerrainContainer(
            colors: excavatedColors,
            zPosition: 4
        )
        addChild(excavatedContainer)
        print("   ✅ Excavated layer (darker) created as background at zPosition 4")

        // 2. Surface layer is NOT added to background - it only appears on individual blocks during drilling
        // The surface blocks are created on-demand in updateConsumptionMask() at zPosition 7
        surfaceContainer = nil  // Not used in consuming drill system

        // 3. Prepare mask shape for cutting (not used in new system, but kept for compatibility)
        maskShape = SKShapeNode()
        maskShape.fillColor = .clear
        maskShape.strokeColor = .clear
        print("   ✅ Dual-layer excavation system ready (background = excavated)")
    }

    /// Create a continuous terrain container with gradient, variations, and flow patterns
    private func createContinuousTerrainContainer(colors: [UIColor], zPosition: CGFloat) -> SKNode {
        let container = SKNode()
        container.zPosition = zPosition

        // LAYER 1: Base continuous vertical gradient
        let gradientTexture = TextureGenerator.shared.createVerticalGradientTexture(
            size: layerSize,
            colors: colors
        )
        let gradientSprite = SKSpriteNode(texture: gradientTexture)
        gradientSprite.anchorPoint = CGPoint(x: 0, y: 0)
        gradientSprite.position = .zero
        gradientSprite.zPosition = 0
        container.addChild(gradientSprite)

        // LAYER 2: Organic color variations (3-6 large ellipses spanning multiple blocks)
        let variationCount = Int.random(in: 3...6)
        for _ in 0..<variationCount {
            let variation = SKShapeNode(
                ellipseOf: CGSize(
                    width: CGFloat.random(in: 80...130),
                    height: CGFloat.random(in: 80...130)
                )
            )

            // Random position across entire layer
            variation.position = CGPoint(
                x: CGFloat.random(in: 0...layerSize.width),
                y: CGFloat.random(in: 0...layerSize.height)
            )

            variation.fillColor = terrainType.variationColor
            variation.strokeColor = .clear
            variation.alpha = CGFloat.random(in: terrainType.variationOpacityRange)
            variation.zPosition = 1
            variation.blendMode = .alpha

            container.addChild(variation)
        }

        // LAYER 3: Diagonal flow pattern (15-40° angle)
        let flowNode = SKNode()
        flowNode.zPosition = 2

        let angle = CGFloat.random(in: 15...40)
        let flowLineCount = 5
        let spacing = layerSize.height / CGFloat(flowLineCount)

        for i in 0..<flowLineCount {
            let path = CGMutablePath()
            let startY = spacing * CGFloat(i)

            path.move(to: CGPoint(x: 0, y: startY))

            // Organic curve across layer
            path.addQuadCurve(
                to: CGPoint(x: layerSize.width, y: startY + 20),
                control: CGPoint(
                    x: layerSize.width / 2,
                    y: startY + CGFloat.random(in: -10...10)
                )
            )

            let line = SKShapeNode(path: path)
            line.strokeColor = terrainType.flowColor
            line.lineWidth = 1
            line.alpha = 0.08
            line.blendMode = .alpha

            flowNode.addChild(line)
        }

        container.addChild(flowNode)

        return container
    }

    // MARK: - Mining Interface

    /// Cut the surface layer at the given grid position to reveal excavated terrain beneath
    /// Called when block is instantly destroyed (bombs, etc.) - plays final destruction animation
    func cutSurfaceAt(gridX: Int, gridY: Int, blockSize: CGFloat) {
        let localGridY = Double(gridY) - stratumRange.lowerBound
        guard localGridY >= 0 && localGridY < (stratumRange.upperBound - stratumRange.lowerBound) else { return }

        let localBlockX = gridX
        let localBlockY = Int(localGridY)
        let key = "\(localBlockX),\(localBlockY)"

        guard !drilledBlocks.contains(key) else { return }
        drilledBlocks.insert(key)

        let posX = CGFloat(localBlockX) * blockSize
        let posY = layerSize.height - CGFloat(localBlockY + 1) * blockSize
        let centerPos = CGPoint(x: posX + blockSize/2, y: posY + blockSize/2)

        // No need to place excavated block - background is already excavated layer (darker)

        // Check if there's a crop node (drilling in progress)
        if let cropNode = childNode(withName: "consumeCropNode_\(key)") as? SKCropNode {
            // Remove consumption crop node with final destruction animation
            finishExcavation(cropNode: cropNode, centerPos: centerPos, blockSize: blockSize)
        } else if let cropNode = childNode(withName: "cropNode_\(key)") as? SKCropNode {
            // Remove old arch-based crop node (legacy support)
            finishExcavation(cropNode: cropNode, centerPos: centerPos, blockSize: blockSize)
        }
    }

    /// Finish excavation with destruction burst when block health reaches 0
    private func finishExcavation(cropNode: SKCropNode, centerPos: CGPoint, blockSize: CGFloat) {
        // Spawn destruction burst
        for _ in 0..<Int.random(in: 10...15) {
            spawnDestructionParticle(at: centerPos)
        }

        // Add edge glow
        addExcavationEdgeGlow(at: centerPos, blockSize: blockSize)

        // Quick fade and remove
        let fadeAction = SKAction.fadeOut(withDuration: 0.15)
        let remove = SKAction.removeFromParent()
        cropNode.run(SKAction.sequence([fadeAction, remove]))
    }

    /// Update consumption mask - circular "bite" expanding from center outward
    func updateConsumptionMask(gridX: Int, gridY: Int, progress: CGFloat, blockSize: CGFloat) {
        let localGridY = Double(gridY) - stratumRange.lowerBound
        guard localGridY >= 0 && localGridY < (stratumRange.upperBound - stratumRange.lowerBound) else { return }

        let localBlockX = gridX
        let localBlockY = Int(localGridY)
        let key = "\(localBlockX),\(localBlockY)"

        // Calculate position
        let posX = CGFloat(localBlockX) * blockSize
        let posY = layerSize.height - CGFloat(localBlockY + 1) * blockSize
        let centerPos = CGPoint(x: posX + blockSize/2, y: posY + blockSize/2)  // Center of block

        // Check if crop node already exists
        if let cropNode = childNode(withName: "consumeCropNode_\(key)") as? SKCropNode {
            // Update the consumption mask to expand
            updateCircularConsumptionMask(cropNode: cropNode, progress: progress, blockSize: blockSize, centerPos: centerPos)
        } else if !drilledBlocks.contains(key) {
            // First time drilling this block - create the consumption system
            drilledBlocks.insert(key)

            // No need to place excavated block - background is already excavated layer (darker)

            // Create surface block (lighter) that will be consumed to reveal excavated background
            let surfaceColors = customSurfaceColors ?? terrainType.surfaceGradientColors
            let surfaceColor = surfaceColors[surfaceColors.count / 2]
            let surfaceBlock = SKSpriteNode(color: surfaceColor, size: CGSize(width: blockSize, height: blockSize))
            surfaceBlock.anchorPoint = CGPoint(x: 0, y: 0)
            surfaceBlock.position = CGPoint(x: posX, y: posY)

            // Create crop node with mask for circular consumption
            let cropNode = SKCropNode()
            cropNode.name = "consumeCropNode_\(key)"
            cropNode.position = .zero
            cropNode.zPosition = 7

            // Create initial consumption mask (starts very small at center)
            let maskNode = createCircularConsumptionMask(progress: 0.0, blockSize: blockSize, centerPos: centerPos)
            maskNode.name = "consumptionMask"
            cropNode.maskNode = maskNode

            // Add surface block to crop node
            cropNode.addChild(surfaceBlock)
            addChild(cropNode)
        }
    }

    /// Create a circular consumption mask with jagged edges
    private func createCircularConsumptionMask(progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint) -> SKNode {
        let maskContainer = SKNode()

        // Circular consumption expands from center outward
        // Progress 0.0 = tiny hole, 1.0 = full block consumed
        let maxRadius = blockSize * 0.7  // 70% of block size for full consumption
        let consumptionRadius = progress * maxRadius

        if consumptionRadius < 2 {
            // Very start - just a tiny circle
            let path = CGMutablePath()
            path.addArc(center: centerPos, radius: 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            let maskShape = SKShapeNode(path: path)
            maskShape.fillColor = .white
            maskShape.strokeColor = .clear
            maskContainer.addChild(maskShape)
        } else {
            // Create jagged circle path for organic consumption edge
            let path = CGMutablePath()
            let numPoints = 16  // 16 points for jagged edge

            for i in 0...numPoints {
                let angle = (CGFloat(i) / CGFloat(numPoints)) * .pi * 2

                // Add jitter for organic edge
                let jitter = sin(angle * 3 + progress * 10) * 0.15 + 1.0
                let r = consumptionRadius * jitter

                let x = centerPos.x + cos(angle) * r
                let y = centerPos.y + sin(angle) * r

                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }

            path.closeSubpath()

            let maskShape = SKShapeNode(path: path)
            maskShape.fillColor = .white
            maskShape.strokeColor = .clear
            maskContainer.addChild(maskShape)
        }

        return maskContainer
    }

    /// Update the circular consumption mask as drilling progresses
    private func updateCircularConsumptionMask(cropNode: SKCropNode, progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint) {
        // Remove old mask and create new one
        if let oldMask = cropNode.maskNode {
            oldMask.removeFromParent()
        }

        let newMask = createCircularConsumptionMask(progress: progress, blockSize: blockSize, centerPos: centerPos)
        cropNode.maskNode = newMask
    }

    /// Update drilling progress visuals (called each frame while drilling)
    /// DEPRECATED: Use updateConsumptionMask for the new circular consumption system
    func updateDrillingProgress(gridX: Int, gridY: Int, currentHealth: Int, maxHealth: Int, blockSize: CGFloat) {
        let localGridY = Double(gridY) - stratumRange.lowerBound
        guard localGridY >= 0 && localGridY < (stratumRange.upperBound - stratumRange.lowerBound) else { return }

        let localBlockX = gridX
        let localBlockY = Int(localGridY)
        let key = "\(localBlockX),\(localBlockY)"

        // Calculate position
        let posX = CGFloat(localBlockX) * blockSize
        let posY = layerSize.height - CGFloat(localBlockY + 1) * blockSize
        let topCenterPos = CGPoint(x: posX + blockSize/2, y: posY + blockSize)  // Top-center of block

        // Calculate excavation progress (0.0 = full health, 1.0 = destroyed)
        let excavationProgress = 1.0 - (CGFloat(currentHealth) / CGFloat(maxHealth))

        // Check if crop node already exists
        if let cropNode = childNode(withName: "cropNode_\(key)") as? SKCropNode {
            // Update the excavation mask to expand
            updateExcavationMask(cropNode: cropNode, progress: excavationProgress, blockSize: blockSize, drillFromTop: topCenterPos)

            // Spawn drill particles occasionally at the excavation edge
            if Int.random(in: 0...2) == 0 {
                let particleY = topCenterPos.y - (excavationProgress * blockSize)
                let particleX = topCenterPos.x + CGFloat.random(in: -blockSize/4...blockSize/4)
                spawnDrillParticle(at: CGPoint(x: particleX, y: particleY))
            }
        } else if !drilledBlocks.contains(key) {
            // First time drilling this block - create the excavation system
            drilledBlocks.insert(key)

            // Place excavated (darker) block first
            let excavatedColors = customExcavatedColors ?? terrainType.excavatedGradientColors
            let excavatedColor = excavatedColors[excavatedColors.count / 2]
            let excavatedBlock = SKSpriteNode(color: excavatedColor, size: CGSize(width: blockSize, height: blockSize))
            excavatedBlock.anchorPoint = CGPoint(x: 0, y: 0)
            excavatedBlock.position = CGPoint(x: posX, y: posY)
            excavatedBlock.zPosition = 6
            addChild(excavatedBlock)

            // Create surface block
            let surfaceColors = customSurfaceColors ?? terrainType.surfaceGradientColors
            let surfaceColor = surfaceColors[surfaceColors.count / 2]
            let surfaceBlock = SKSpriteNode(color: surfaceColor, size: CGSize(width: blockSize, height: blockSize))
            surfaceBlock.anchorPoint = CGPoint(x: 0, y: 0)
            surfaceBlock.position = CGPoint(x: posX, y: posY)

            // Create crop node with mask for progressive excavation
            let cropNode = SKCropNode()
            cropNode.name = "cropNode_\(key)"
            cropNode.position = .zero
            cropNode.zPosition = 7

            // Create initial excavation mask (starts very small at top-center)
            let maskNode = createExcavationMask(progress: 0.0, blockSize: blockSize, drillFromTop: topCenterPos)
            maskNode.name = "excavationMask"
            cropNode.maskNode = maskNode

            // Add surface block to crop node
            cropNode.addChild(surfaceBlock)
            addChild(cropNode)
        }
    }

    /// Create an excavation mask that expands in an arch from the drilling point
    private func createExcavationMask(progress: CGFloat, blockSize: CGFloat, drillFromTop: CGPoint) -> SKNode {
        let maskContainer = SKNode()

        // Start with a small circle at the drill point, expand into a cone/arch
        // Progress 0.0 = tiny hole, 1.0 = full block removed
        let archHeight = progress * blockSize
        let archWidth = progress * blockSize * 1.2  // Wider at bottom for natural digging

        // Create arch shape using bezier path
        let path = CGMutablePath()

        if progress < 0.05 {
            // Very start - just a small circle
            let smallRadius = blockSize * 0.1
            path.addArc(center: drillFromTop, radius: smallRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        } else {
            // Create expanding arch shape
            let topRadius = max(blockSize * 0.15, archWidth * 0.3)
            let bottomRadius = archWidth * 0.5

            // Top of arch (drill entry point)
            path.move(to: CGPoint(x: drillFromTop.x - topRadius, y: drillFromTop.y))

            // Left side curves down and out
            path.addQuadCurve(
                to: CGPoint(x: drillFromTop.x - bottomRadius, y: drillFromTop.y - archHeight),
                control: CGPoint(x: drillFromTop.x - bottomRadius * 0.7, y: drillFromTop.y - archHeight * 0.5)
            )

            // Bottom arc
            path.addArc(
                tangent1End: CGPoint(x: drillFromTop.x, y: drillFromTop.y - archHeight - bottomRadius * 0.2),
                tangent2End: CGPoint(x: drillFromTop.x + bottomRadius, y: drillFromTop.y - archHeight),
                radius: bottomRadius * 0.3
            )

            // Right side curves up
            path.addQuadCurve(
                to: CGPoint(x: drillFromTop.x + topRadius, y: drillFromTop.y),
                control: CGPoint(x: drillFromTop.x + bottomRadius * 0.7, y: drillFromTop.y - archHeight * 0.5)
            )

            // Close the arch at the top with a small arc
            path.addArc(
                tangent1End: CGPoint(x: drillFromTop.x, y: drillFromTop.y + topRadius * 0.3),
                tangent2End: CGPoint(x: drillFromTop.x - topRadius, y: drillFromTop.y),
                radius: topRadius
            )
        }

        let maskShape = SKShapeNode(path: path)
        maskShape.fillColor = .white
        maskShape.strokeColor = .clear
        maskContainer.addChild(maskShape)

        return maskContainer
    }

    /// Update the excavation mask as drilling progresses
    private func updateExcavationMask(cropNode: SKCropNode, progress: CGFloat, blockSize: CGFloat, drillFromTop: CGPoint) {
        // Remove old mask and create new one
        if let oldMask = cropNode.maskNode {
            oldMask.removeFromParent()
        }

        let newMask = createExcavationMask(progress: progress, blockSize: blockSize, drillFromTop: drillFromTop)
        cropNode.maskNode = newMask
    }

    /// Spawn a single drill particle with optional delay
    private func spawnDrillParticle(at position: CGPoint, delay: Double = 0) {
        let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
        let surfaceColors = customSurfaceColors ?? terrainType.surfaceGradientColors
        particle.fillColor = surfaceColors.randomElement() ?? .gray
        particle.strokeColor = .clear
        particle.position = position
        particle.zPosition = 20
        addChild(particle)

        // Random velocity (more varied)
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speed = CGFloat.random(in: 20...50)
        let velocityX = cos(angle) * speed
        let velocityY = sin(angle) * speed

        let wait = delay > 0 ? SKAction.wait(forDuration: delay) : SKAction.wait(forDuration: 0)
        let moveAction = SKAction.moveBy(x: velocityX, y: velocityY, duration: 0.4)
        let fadeAction = SKAction.fadeOut(withDuration: 0.4)
        let scaleAction = SKAction.scale(to: 0.2, duration: 0.4)
        let group = SKAction.group([moveAction, fadeAction, scaleAction])
        let remove = SKAction.removeFromParent()

        particle.run(SKAction.sequence([wait, group, remove]))
    }

    /// Spawn a destruction particle (larger, more dramatic burst)
    private func spawnDestructionParticle(at position: CGPoint) {
        // Use small rectangles for more interesting particle shapes
        let size = CGSize(width: CGFloat.random(in: 3...6), height: CGFloat.random(in: 3...6))
        let surfaceColors = customSurfaceColors ?? terrainType.surfaceGradientColors
        let particle = SKSpriteNode(color: surfaceColors.randomElement() ?? .gray, size: size)
        particle.position = position
        particle.zPosition = 20
        addChild(particle)

        // Explosive velocity burst
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speed = CGFloat.random(in: 50...100)
        let velocityX = cos(angle) * speed
        let velocityY = sin(angle) * speed

        // Add slight gravity effect
        let gravity = SKAction.moveBy(x: 0, y: -20, duration: 0.6)
        let moveAction = SKAction.moveBy(x: velocityX, y: velocityY, duration: 0.6)
        let combinedMove = SKAction.group([moveAction, gravity])

        let fadeAction = SKAction.fadeOut(withDuration: 0.6)
        let scaleAction = SKAction.scale(to: 0.1, duration: 0.6)
        let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -.pi*3...(.pi*3)), duration: 0.6)
        let group = SKAction.group([combinedMove, fadeAction, scaleAction, rotateAction])
        let remove = SKAction.removeFromParent()

        particle.run(SKAction.sequence([group, remove]))
    }

    /// Add subtle edge glow at excavation boundary (optional enhancement)
    private func addExcavationEdgeGlow(at position: CGPoint, blockSize: CGFloat) {
        let edgeGlow = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize), cornerRadius: 2)
        edgeGlow.position = CGPoint(x: position.x + blockSize/2, y: position.y + blockSize/2)
        edgeGlow.strokeColor = terrainType.variationColor.withAlphaComponent(0.3)
        edgeGlow.lineWidth = 1
        edgeGlow.fillColor = .clear
        edgeGlow.zPosition = 7
        edgeGlow.alpha = 0.3

        // Fade out over time
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        edgeGlow.run(SKAction.sequence([fadeOut, remove]))

        addChild(edgeGlow)
    }

    // MARK: - Positioning

    /// Position this layer in world coordinates
    func positionInWorld(surfaceY: CGFloat, sceneMinX: CGFloat) {
        // Position at the bottom depth of this stratum
        // Since container has anchor (0,0), it extends upward from this position
        // Convert depth (meters) to pixels (64 pixels per meter)
        let worldX = sceneMinX
        let worldY = surfaceY - CGFloat(stratumRange.upperBound) * TerrainBlock.size
        position = CGPoint(x: worldX, y: worldY)
    }
}

// MARK: - UIColor Extensions for TerrainLayer

extension UIColor {
    /// Adjust brightness by a multiplier (1.0 = no change, >1.0 = lighter, <1.0 = darker)
    func adjustBrightness(by multiplier: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = min(max(brightness * multiplier, 0.0), 1.0)
            return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
        }

        return self
    }

    /// Convert UIColor to hex string
    func toHex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
}
