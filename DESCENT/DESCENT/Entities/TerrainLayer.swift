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

/// Seeded random number generator for deterministic randomness based on grid coordinates
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        // Linear congruential generator (LCG) algorithm
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

class TerrainLayer: SKNode {

    // MARK: - Properties

    let stratumRange: ClosedRange<Double>  // Depth range (e.g., 0...640)
    let terrainType: TerrainType
    let layerSize: CGSize

    // Dual-layer system
    private var baseTerrainContainer: SKNode!  // Base layer (always visible, shows surface initially)
    private var surfaceCropNode: SKCropNode!  // Initial surface layer with mask for cutting holes
    private var drilledBlocks: Set<String> = []  // Track which blocks have been drilled
    private var blockPhaseOffsets: [String: CGFloat] = [:] // Random phase offset per block for varied consumption patterns
    private var blockGlowVariations: [String: (frequency: CGFloat, amplitude: CGFloat, secondaryPhase: CGFloat, rotationDirection: CGFloat)] = [:] // Glow-specific variations including rotation

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

            print("🎨 Using custom colors from level config for \(terrainType)")
            print("   - Depth range: \(stratumRange.lowerBound)m - \(stratumRange.upperBound)m")
            print("   - Surface gradient: \(surface.count) colors")
            print("   - Surface hex values: \(surface.map { $0.toHex() })")
            print("   - Excavated gradient: \(excavated.count) colors")
            print("   - Excavated hex values: \(excavated.map { $0.toHex() })")
        }

        // Convert depth range (meters) to pixel height
        // Scale: 64px = 12.5m, so 1m = 64/12.5 = 5.12 pixels
        let depthInMeters = stratumRange.upperBound - stratumRange.lowerBound
        let pixelHeight = CGFloat(depthInMeters) * (TerrainBlock.size / TerrainBlock.metersPerBlock)

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
        // Base terrain uses excavatedColors (darker) - final state after drilling
        let excavatedColors = customExcavatedColors ?? terrainType.excavatedGradientColors

        // Create base terrain container with excavated appearance (revealed after drilling)
        let baseContainer = createContinuousTerrainContainer(
            colors: excavatedColors,
            zPosition: 0
        )

        // Add base container directly without clipping for now
        // Z-positioning should handle layer ordering
        baseTerrainContainer = baseContainer
        addChild(baseTerrainContainer)
        print("   ✅ Base terrain layer created with excavated colors")
        print("   - Layer size: \(layerSize)")
        print("   - Layer zPosition (relative): 0")

        // Create initial full surface layer (lighter) that covers entire terrain
        createInitialSurfaceLayer()
        print("   ✅ Initial surface layer created at relative zPosition 3")

        // Surface blocks shrink during drilling via inverse crop masks to reveal darker excavated base beneath
        print("   ✅ Dual-layer excavation system ready")
    }

    /// Create initial surface layer that covers entire terrain (before any drilling)
    private func createInitialSurfaceLayer() {
        let surfaceColors = customSurfaceColors ?? terrainType.surfaceGradientColors

        // Create full surface container matching base terrain size
        let surfaceContainer = createContinuousTerrainContainer(
            colors: surfaceColors,
            zPosition: 0  // Relative to surfaceCropNode
        )
        surfaceContainer.name = "initialSurfaceLayer"

        // Wrap in SKCropNode with relative z-position
        // Surface layer is 3 units above base layer (relative)
        surfaceCropNode = SKCropNode()
        surfaceCropNode.zPosition = 3
        surfaceCropNode.name = "surfaceCropNode"

        // Start with full white rectangle mask (all surface visible)
        let fullMask = SKShapeNode(rect: CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height))
        fullMask.fillColor = .white
        fullMask.strokeColor = .clear
        fullMask.name = "surfaceMask"
        surfaceCropNode.maskNode = fullMask

        surfaceCropNode.addChild(surfaceContainer)
        addChild(surfaceCropNode)
    }

    /// Cut a rectangular hole in the initial surface layer at the given block position
    /// Regenerates mask with ALL drilled blocks to ensure all cutouts are preserved
    /// gridX and gridY are LOCAL coordinates within this terrain layer
    private func cutHoleInSurfaceLayer(gridX: Int, gridY: Int, blockSize: CGFloat) {
        guard surfaceCropNode != nil else { return }

        // Use UIBezierPath to create mask with even-odd fill rule for cutouts
        let bezierPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height))

        // Add rectangular cutouts for all drilled blocks
        for drilledKey in drilledBlocks {
            let components = drilledKey.split(separator: ",")
            guard components.count == 2,
                  let blockX = Int(components[0]),
                  let blockY = Int(components[1]) else { continue }

            let posX = CGFloat(blockX) * blockSize
            let posY = layerSize.height - CGFloat(blockY + 1) * blockSize
            let cutoutRect = CGRect(x: posX, y: posY, width: blockSize, height: blockSize)
            bezierPath.append(UIBezierPath(rect: cutoutRect))
        }

        bezierPath.usesEvenOddFillRule = true

        let newMask = SKShapeNode(path: bezierPath.cgPath)
        newMask.fillColor = .white
        newMask.strokeColor = .clear
        newMask.name = "surfaceMask"

        surfaceCropNode.maskNode = newMask
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
                    width: CGFloat.random(in: 80...130),  // 80-130px ellipses
                    height: CGFloat.random(in: 80...130)
                )
            )

            // Random position across entire layer
            variation.position = CGPoint(
                x: CGFloat.random(in: 0...layerSize.width),
                y: CGFloat.random(in: 0...layerSize.height)
            )

            // Use custom variation color if available (darker/lighter from gradient), otherwise use TerrainType
            let variationColor: UIColor
            if let customColors = colors as? [UIColor], customColors.count > 0 {
                // Use a slightly darker version of the middle gradient color for variations
                variationColor = customColors[customColors.count / 2].adjustBrightness(by: 0.85)
            } else {
                variationColor = terrainType.variationColor
            }

            variation.fillColor = variationColor
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
                to: CGPoint(x: layerSize.width, y: startY + 20),  // 20px offset
                control: CGPoint(
                    x: layerSize.width / 2,
                    y: startY + CGFloat.random(in: -10...10)  // ±10px variation
                )
            )

            let line = SKShapeNode(path: path)

            // Use custom flow color if available (darker from gradient), otherwise use TerrainType
            let flowColor: UIColor
            if let customColors = colors as? [UIColor], customColors.count > 0 {
                // Use a darker version of the middle gradient color for flow lines
                flowColor = customColors[customColors.count / 2].adjustBrightness(by: 0.75)
            } else {
                flowColor = terrainType.flowColor
            }

            line.strokeColor = flowColor
            line.lineWidth = 2  // 2px line width (was 1px)
            line.alpha = 0.25  // More visible (was 0.08)
            line.blendMode = .alpha

            flowNode.addChild(line)
        }

        container.addChild(flowNode)

        return container
    }

    // MARK: - Mining Interface

    /// Cut the surface layer at the given grid position to reveal excavated terrain beneath
    /// Called when block is instantly destroyed (bombs, etc.) - plays final destruction animation
    /// gridX and gridY are world grid coordinates (in blocks, not meters)
    func cutSurfaceAt(gridX: Int, gridY: Int, blockSize: CGFloat) {
        // Convert gridY (grid coordinate) to depth in meters, then check if it's in this stratum's range
        let depthInMeters = Double(gridY) * Double(TerrainBlock.metersPerBlock)
        guard stratumRange.contains(depthInMeters) else { return }

        // Convert to local grid coordinate within this stratum
        let stratumStartGrid = Int(stratumRange.lowerBound / Double(TerrainBlock.metersPerBlock))
        let localGridY = gridY - stratumStartGrid

        let localBlockX = gridX
        let localBlockY = localGridY
        let key = "\(localBlockX),\(localBlockY)"

        guard !drilledBlocks.contains(key) else {
            return
        }

        let posX = CGFloat(localBlockX) * blockSize
        let posY = layerSize.height - CGFloat(localBlockY + 1) * blockSize
        let centerPos = CGPoint(x: posX + blockSize/2, y: posY + blockSize/2)

        // No need to place excavated block - background is already excavated layer (darker)

        // Check if there's a crop node (drilling in progress)
        if let cropNode = childNode(withName: "consumeCropNode_\(key)") as? SKCropNode {
            // Drilling in progress - mark as drilled and finish excavation
            drilledBlocks.insert(key)
            finishExcavation(cropNode: cropNode, centerPos: centerPos, blockSize: blockSize, instant: false)
        } else {
            // No crop node exists (bomb/instant destruction)
            drilledBlocks.insert(key)

            // Cut hole in initial surface layer to reveal dark excavated base (use local coordinates)
            cutHoleInSurfaceLayer(gridX: localBlockX, gridY: localBlockY, blockSize: blockSize)

            // Spawn destruction burst
            for _ in 0..<Int.random(in: 10...15) {
                spawnDestructionParticle(at: centerPos)
            }
        }
    }

    /// Finish excavation with destruction burst when block health reaches 0
    private func finishExcavation(cropNode: SKCropNode, centerPos: CGPoint, blockSize: CGFloat, instant: Bool) {
        let cropKey = cropNode.name ?? "unknown"

        // Remove consumption glow and particles if they exist
        if let parentKey = cropNode.name {
            let glowName = "consumptionGlow_\(parentKey)"
            childNode(withName: glowName)?.removeFromParent()
            stopParticleEmission(parentKey: parentKey)
        }

        // Spawn destruction burst
        for _ in 0..<Int.random(in: 10...15) {
            spawnDestructionParticle(at: centerPos)
        }

        // Add edge glow (only for normal drilling, not instant bomb removal)
        if !instant {
            addExcavationEdgeGlow(at: centerPos, blockSize: blockSize)
        }

        // Extract grid position from crop node name and cut hole in surface layer
        if let keyString = cropNode.name?.replacingOccurrences(of: "consumeCropNode_", with: "") {
            let components = keyString.split(separator: ",")
            if components.count == 2, let localGridX = Int(components[0]), let localGridY = Int(components[1]) {
                // Key contains local coordinates, pass them directly
                cutHoleInSurfaceLayer(gridX: localGridX, gridY: localGridY, blockSize: blockSize)
            }
        }

        print("🏁 Starting fade animation for \(cropKey)")

        // Use very quick fade for instant removal (bombs), normal fade for drilling
        let fadeDuration = instant ? 0.01 : 0.15
        let fadeAction = SKAction.fadeOut(withDuration: fadeDuration)
        let remove = SKAction.removeFromParent()
        cropNode.run(SKAction.sequence([fadeAction, remove])) { [weak self] in
            print("🏁 ✅ Crop node \(cropKey) removed from parent (fade complete)")

            // Check if it was actually removed
            if let strongSelf = self {
                if let stillExists = strongSelf.childNode(withName: cropKey) {
                    print("🏁 ⚠️ WARNING: Crop node \(cropKey) still exists after removal! Alpha: \(stillExists.alpha)")
                } else {
                    print("🏁 ✅ Confirmed: Crop node \(cropKey) no longer in scene tree")
                }
            }
        }
    }

    /// Update consumption mask - circular "bite" expanding from center outward
    /// gridX and gridY are world grid coordinates (in blocks, not meters)
    func updateConsumptionMask(gridX: Int, gridY: Int, progress: CGFloat, blockSize: CGFloat) {
        // Convert gridY (grid coordinate) to depth in meters, then check if it's in this stratum's range
        let depthInMeters = Double(gridY) * Double(TerrainBlock.metersPerBlock)
        guard stratumRange.contains(depthInMeters) else { return }

        // Convert to local grid coordinate within this stratum
        let stratumStartGrid = Int(stratumRange.lowerBound / Double(TerrainBlock.metersPerBlock))
        let localGridY = gridY - stratumStartGrid

        let localBlockX = gridX
        let localBlockY = localGridY
        // Use local coordinates for the key (local to this terrain layer)
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

            // Generate deterministic random values based on grid coordinates (ensures unique patterns)
            // Use grid coordinates as seed for deterministic but unique randomness
            let seed = UInt64(gridX) * 73856093 ^ UInt64(gridY) * 19349663  // Hash function for spatial hashing
            print("🎲 Block (\(gridX), \(gridY)) → seed: \(seed)")
            var rng = SeededRandomNumberGenerator(seed: seed)

            // Generate random phase offset for this block (makes each block's pattern unique)
            blockPhaseOffsets[key] = CGFloat.random(in: 0...(CGFloat.pi * 2), using: &rng)

            // Generate random glow variations (frequency, amplitude, secondary phase, rotation)
            let randomRotation: CGFloat = Bool.random(using: &rng) ? -1.0 : 1.0
            blockGlowVariations[key] = (
                frequency: CGFloat.random(in: 2.5...3.5, using: &rng),  // Varies wave frequency (2.5-3.5x, default was 3x)
                amplitude: CGFloat.random(in: 0.12...0.18, using: &rng), // Varies jitter amplitude (12-18%, default was 15%)
                secondaryPhase: CGFloat.random(in: 0...(CGFloat.pi * 2), using: &rng), // Additional phase shift for glow
                rotationDirection: randomRotation  // -1 or +1 for different rotation directions
            )

            // Create excavated block (darker) that expands via mask to show drilled area
            let excavatedColors = customExcavatedColors ?? terrainType.excavatedGradientColors
            let excavatedColor = excavatedColors[excavatedColors.count / 2]
            let excavatedBlock = SKSpriteNode(color: excavatedColor, size: CGSize(width: blockSize, height: blockSize))
            excavatedBlock.anchorPoint = CGPoint(x: 0, y: 0)
            excavatedBlock.position = CGPoint(x: posX, y: posY)

            // Create crop node with expanding mask for drilling visualization
            let cropNode = SKCropNode()
            cropNode.name = "consumeCropNode_\(key)"
            cropNode.position = .zero
            cropNode.zPosition = 8  // Above initial surface layer at z=7

            // Create consumption mask (expands from 0 to 1 as drilling progresses)
            let maskNode = createCircularConsumptionMaskExpanding(progress: progress, blockSize: blockSize, centerPos: centerPos, blockKey: key)
            maskNode.name = "consumptionMask"
            cropNode.maskNode = maskNode

            // Add excavated block to crop node
            cropNode.addChild(excavatedBlock)
            addChild(cropNode)
        }
    }

    /// Create an expanding circular mask for excavated blocks during drilling
    /// Progress 0.0 = tiny circle (just started), 1.0 = full coverage (fully drilled)
    private func createCircularConsumptionMaskExpanding(progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint, blockKey: String) -> SKNode {
        let maskContainer = SKNode()

        let maxRadius = blockSize * 0.7
        let consumptionRadius = progress * maxRadius

        if consumptionRadius < 2 {
            // Very start - tiny circle
            let path = CGMutablePath()
            path.addArc(center: centerPos, radius: 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            let maskShape = SKShapeNode(path: path)
            maskShape.fillColor = .white
            maskShape.strokeColor = .clear
            maskContainer.addChild(maskShape)
        } else {
            // Get random phase offset
            let phaseOffset = blockPhaseOffsets[blockKey] ?? 0

            // Create jagged circle
            let path = CGMutablePath()
            let numPoints = 16

            for i in 0...numPoints {
                let angle = (CGFloat(i) / CGFloat(numPoints)) * .pi * 2
                let jitter = sin(angle * 3 + progress * 10 + phaseOffset) * 0.15 + 1.0
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

    /// Create a consumption mask for surface layer (inverse with cutout hole) - DEPRECATED, keeping for reference
    /// For drilling visualization, progress represents drilling progress (0.0 = not drilled, 1.0 = fully drilled)
    /// inverseProgress (1.0 - progress) is passed in, so 1.0 = full surface visible, 0.0 = fully excavated
    private func createCircularConsumptionMask(progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint, blockKey: String) -> SKNode {
        let maskContainer = SKNode()

        // For surface blocks with inverseProgress:
        // progress=1.0 (not drilled) → full block visible
        // progress=0.0 (fully drilled) → nothing visible, dark base shows through

        if progress >= 0.98 {
            // Surface fully visible - full white rectangle
            let fullMask = SKShapeNode(rect: CGRect(x: centerPos.x - blockSize/2, y: centerPos.y - blockSize/2, width: blockSize, height: blockSize))
            fullMask.fillColor = .white
            fullMask.strokeColor = .clear
            maskContainer.addChild(fullMask)
        } else if progress < 0.02 {
            // Surface fully drilled - no mask (nothing visible)
            // Return empty container so surface block is completely hidden
            return maskContainer
        } else {
            // Partial drilling - create inverse mask (white rectangle with black cutout circle)
            // The cutout expands as drilling progresses (as inverseProgress decreases)

            // Create base white rectangle for full block visibility
            let fullRect = CGRect(x: centerPos.x - blockSize/2, y: centerPos.y - blockSize/2, width: blockSize, height: blockSize)

            // Calculate cutout radius (inverse of progress - as progress decreases, cutout grows)
            let maxRadius = blockSize * 0.7
            let cutoutRadius = (1.0 - progress) * maxRadius

            // Get the random phase offset for this block
            let phaseOffset = blockPhaseOffsets[blockKey] ?? 0
            let drillingProgress = 1.0 - progress  // Actual drilling progress

            // Create UIBezierPath with rectangular mask minus circular cutout
            let bezierPath = UIBezierPath(rect: fullRect)

            // Create jagged circular cutout path
            let cutoutBezier = UIBezierPath()
            let numPoints = 16

            for i in 0...numPoints {
                let angle = (CGFloat(i) / CGFloat(numPoints)) * .pi * 2
                let jitter = sin(angle * 3 + drillingProgress * 10 + phaseOffset) * 0.15 + 1.0
                let r = cutoutRadius * jitter

                let x = centerPos.x + cos(angle) * r
                let y = centerPos.y + sin(angle) * r

                if i == 0 {
                    cutoutBezier.move(to: CGPoint(x: x, y: y))
                } else {
                    cutoutBezier.addLine(to: CGPoint(x: x, y: y))
                }
            }
            cutoutBezier.close()

            // Subtract cutout from rectangle using even-odd fill rule
            bezierPath.append(cutoutBezier)
            bezierPath.usesEvenOddFillRule = true

            let maskShape = SKShapeNode(path: bezierPath.cgPath)
            maskShape.fillColor = .white
            maskShape.strokeColor = .clear
            maskContainer.addChild(maskShape)
        }

        return maskContainer
    }

    /// Update the circular consumption mask as drilling progresses
    private func updateCircularConsumptionMask(cropNode: SKCropNode, progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint) {
        // Extract block key from crop node name (format: "consumeCropNode_X,Y")
        let blockKey = cropNode.name?.replacingOccurrences(of: "consumeCropNode_", with: "") ?? ""

        // Remove old mask and create new one
        if let oldMask = cropNode.maskNode {
            oldMask.removeFromParent()
        }

        // Use expanding mask for excavated block (0.0 at start, 1.0 when fully drilled)
        let newMask = createCircularConsumptionMaskExpanding(progress: progress, blockSize: blockSize, centerPos: centerPos, blockKey: blockKey)
        cropNode.maskNode = newMask

        // Add orange/yellow consumption glow at the edge (only while drilling, not when complete)
        if progress > 0.05 && progress < 0.75 {
            addConsumptionEdgeGlow(progress: progress, blockSize: blockSize, centerPos: centerPos, parentKey: cropNode.name ?? "", blockKey: blockKey)

            // Start or update particle emission
            let particleName = "consumptionParticles_\(cropNode.name ?? "")"
            if let particles = childNode(withName: particleName) as? SKEmitterNode {
                updateParticleEmission(particles: particles, progress: progress)
            } else {
                startParticleEmission(at: centerPos, parentKey: cropNode.name ?? "")
            }
        } else if progress >= 0.75 {
            // Remove glow and particles when block is mostly consumed
            let glowName = "consumptionGlow_\(cropNode.name ?? "")"
            let particleName = "consumptionParticles_\(cropNode.name ?? "")"
            childNode(withName: glowName)?.removeFromParent()
            stopParticleEmission(parentKey: cropNode.name ?? "")
        }
    }


    /// Spawn a destruction particle (larger, more dramatic burst)
    private func spawnDestructionParticle(at position: CGPoint) {
        // Use small rectangles for more interesting particle shapes
        let size = CGSize(width: CGFloat.random(in: 3...6), height: CGFloat.random(in: 3...6))  // 3-6px particles
        let excavatedColors = customExcavatedColors ?? terrainType.excavatedGradientColors
        let particle = SKSpriteNode(color: excavatedColors.randomElement() ?? .gray, size: size)
        particle.position = position
        particle.zPosition = 20
        addChild(particle)

        // Explosive velocity burst (in pixels)
        let angle = CGFloat.random(in: 0...(2 * .pi))
        let speed = CGFloat.random(in: 50...100)  // 50-100px/sec
        let velocityX = cos(angle) * speed
        let velocityY = sin(angle) * speed

        // Add slight gravity effect
        let gravity = SKAction.moveBy(x: 0, y: -20, duration: 0.6)  // -20px downward
        let moveAction = SKAction.moveBy(x: velocityX, y: velocityY, duration: 0.6)
        let combinedMove = SKAction.group([moveAction, gravity])

        let fadeAction = SKAction.fadeOut(withDuration: 0.6)
        let scaleAction = SKAction.scale(to: 0.1, duration: 0.6)
        let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -.pi*3...(.pi*3)), duration: 0.6)
        let group = SKAction.group([combinedMove, fadeAction, scaleAction, rotateAction])
        let remove = SKAction.removeFromParent()

        particle.run(SKAction.sequence([group, remove]))
    }

    /// Add orange/yellow glowing edge along consumption boundary (during drilling)
    private func addConsumptionEdgeGlow(progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint, parentKey: String, blockKey: String) {
        let glowName = "consumptionGlow_\(parentKey)"

        // Get the base phase offset used for the mask
        let phaseOffset = blockPhaseOffsets[blockKey] ?? 0

        // Get glow-specific variations (with default values if not found)
        let glowVariation = blockGlowVariations[blockKey] ?? (frequency: 3.0, amplitude: 0.15, secondaryPhase: 0, rotationDirection: 1.0)

        // Calculate rotation phase based on time (for animated rotation effect)
        let rotationPhase: CGFloat
        if let existingGlow = childNode(withName: glowName) as? SKShapeNode {
            // Get elapsed time since glow was created (stored in userData)
            if let startTime = existingGlow.userData?["startTime"] as? TimeInterval {
                let elapsed = CACurrentMediaTime() - startTime
                // Negate to correct rotation direction (iOS coordinate system)
                rotationPhase = -CGFloat(elapsed) * glowVariation.rotationDirection * 0.5  // 0.5 rad/sec = ~28 degrees/sec
            } else {
                rotationPhase = 0
            }
        } else {
            rotationPhase = 0
        }

        // Create varied jagged circular path for the glow with rotation
        // Use same radius as mask (0.7) so glow appears at the expanding excavation edge
        let maxRadius = blockSize * 0.7
        let consumptionRadius = progress * maxRadius  // Expanding edge

        let path = CGMutablePath()
        let numPoints = 16

        for i in 0...numPoints {
            let angle = (CGFloat(i) / CGFloat(numPoints)) * .pi * 2 + rotationPhase  // Add rotation phase

            // Combine base jitter with glow-specific variations
            // Base wave from mask
            let baseJitter = sin(angle * 3 + progress * 10 + phaseOffset) * 0.15 + 1.0

            // Additional glow variation (different frequency, amplitude, and phase)
            let glowJitter = sin(angle * glowVariation.frequency + progress * 8 + glowVariation.secondaryPhase) * glowVariation.amplitude

            // Combine both jitters for unique glow shape
            let combinedJitter = baseJitter + glowJitter
            let r = consumptionRadius * combinedJitter

            let x = centerPos.x + cos(angle) * r
            let y = centerPos.y + sin(angle) * r

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        // Check if glow already exists - if so, just update its path
        if let existingGlow = childNode(withName: glowName) as? SKShapeNode {
            // Update the path to include rotation
            existingGlow.path = path
        } else {
            // First time - create glowing shape node
            let glowNode = SKShapeNode(path: path)
            glowNode.strokeColor = UIColor(red: 1.0, green: 0.85, blue: 0.2, alpha: 1.0) // Brighter, more yellow
            glowNode.lineWidth = 2  // 2px line width
            glowNode.fillColor = .clear
            glowNode.glowWidth = 1  // 1px glow - sharp glow with minimal blur
            glowNode.zPosition = 16 // Above terrain (excavated=4, surface crop=7)
            glowNode.name = glowName

            // Store start time for rotation calculation
            glowNode.userData = NSMutableDictionary()
            glowNode.userData?["startTime"] = CACurrentMediaTime()

            // Pulse animation for energy feel
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.7, duration: 0.15),
                SKAction.fadeAlpha(to: 1.0, duration: 0.15)
            ])
            glowNode.run(SKAction.repeatForever(pulse), withKey: "glowPulse")

            addChild(glowNode)
        }
    }

    // MARK: - Particle System

    /// Start continuous particle emission during drilling
    private func startParticleEmission(at position: CGPoint, parentKey: String) {
        let particles = SKEmitterNode()
        particles.position = position
        particles.zPosition = 17 // Above glow (16), below UI
        particles.name = "consumptionParticles_\(parentKey)"

        // Particle appearance - match excavated terrain color (darker)
        let excavatedColors = customExcavatedColors ?? terrainType.excavatedGradientColors
        let particleColor = excavatedColors[excavatedColors.count / 2]
        particles.particleColor = particleColor
        particles.particleColorBlendFactor = 1.0

        // Particle size (in pixels)
        particles.particleSize = CGSize(width: 4, height: 4)  // 4px particles
        particles.particleScale = 1.0
        particles.particleScaleRange = 0.5
        particles.particleScaleSpeed = -0.5 // Shrink over lifetime

        // Emission properties
        particles.particleBirthRate = 50 // Base rate, will increase with progress
        particles.numParticlesToEmit = 0 // Continuous
        particles.particleLifetime = 0.8
        particles.particleLifetimeRange = 0.3

        // Movement - radial emission (all directions, in pixels/sec)
        particles.emissionAngle = 0
        particles.emissionAngleRange = .pi * 2 // 360 degrees
        particles.particleSpeed = 80  // 80px/sec
        particles.particleSpeedRange = 40  // ±40px/sec

        // Physics - slight gravity
        particles.particlePositionRange = CGVector(dx: 10, dy: 10)  // ±10px spawn area
        particles.xAcceleration = 0
        particles.yAcceleration = -50 // Slight downward pull (-50px/sec²)

        // Alpha fade sequence (start full, fade out)
        particles.particleAlpha = 1.0
        particles.particleAlphaSpeed = -1.25 // Fade out over lifetime

        // Blend mode for better visual
        particles.particleBlendMode = .alpha

        addChild(particles)
    }

    /// Update particle emission rate based on drilling progress
    private func updateParticleEmission(particles: SKEmitterNode, progress: CGFloat) {
        // Increase emission rate as drilling progresses (50 -> 200)
        particles.particleBirthRate = 50 + (progress * 150)

        // Increase speed as drilling progresses (80 -> 180px/sec)
        particles.particleSpeed = 80 + (progress * 100)
    }

    /// Stop particle emission and clean up
    private func stopParticleEmission(parentKey: String) {
        let particleName = "consumptionParticles_\(parentKey)"
        if let particles = childNode(withName: particleName) as? SKEmitterNode {
            // Stop emitting new particles
            particles.particleBirthRate = 0

            // Remove after existing particles die (max lifetime + range = 1.1 seconds)
            let wait = SKAction.wait(forDuration: 1.2)
            let remove = SKAction.removeFromParent()
            particles.run(SKAction.sequence([wait, remove]))
        }
    }

    /// Add subtle edge glow at excavation boundary (optional enhancement)
    private func addExcavationEdgeGlow(at position: CGPoint, blockSize: CGFloat) {
        let edgeGlow = SKShapeNode(rectOf: CGSize(width: blockSize, height: blockSize), cornerRadius: 2)  // 2px corner radius
        edgeGlow.position = CGPoint(x: position.x + blockSize/2, y: position.y + blockSize/2)
        edgeGlow.strokeColor = terrainType.variationColor.withAlphaComponent(0.3)
        edgeGlow.lineWidth = 1  // 1px line width
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
        // Convert depth (meters) to pixels
        let worldX = sceneMinX
        let worldY = surfaceY - CGFloat(stratumRange.upperBound) * (TerrainBlock.size / TerrainBlock.metersPerBlock)
        position = CGPoint(x: worldX, y: worldY)

        let topY = worldY + layerSize.height
        print("📍 POSITIONED \(terrainType) layer:")
        print("   - Depth range: \(stratumRange.lowerBound)m - \(stratumRange.upperBound)m")
        print("   - Bottom Y: \(worldY) (at \(stratumRange.upperBound)m depth)")
        print("   - Top Y: \(topY) (at \(stratumRange.lowerBound)m depth)")
        print("   - Layer height: \(layerSize.height)px")
        print("   - zPosition: \(zPosition)")
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
