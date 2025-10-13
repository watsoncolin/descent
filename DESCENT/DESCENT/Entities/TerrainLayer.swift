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
    private var excavatedContainer: SKNode!  // Darker layer (background terrain - always visible)
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

            print("🎨 Using custom colors from level config")
            print("   - Surface gradient: \(surface.count) colors")
            print("   - Excavated gradient: \(excavated.count) colors")
        }

        // Convert depth range (meters) to pixel height
        // Scale: 64px = 12.5m, so 1m = 64/12.5 = 5.12 pixels
        let depthInMeters = stratumRange.upperBound - stratumRange.lowerBound
        let metersPerBlock: CGFloat = 12.5
        let pixelHeight = CGFloat(depthInMeters) * (TerrainBlock.size / metersPerBlock)

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

        // Surface layer is NOT added to background - it only appears on individual blocks during drilling
        // The surface blocks are created on-demand in updateConsumptionMask() at zPosition 7
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
                    width: CGFloat.random(in: 80...130),  // 80-130px ellipses
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
                to: CGPoint(x: layerSize.width, y: startY + 20),  // 20px offset
                control: CGPoint(
                    x: layerSize.width / 2,
                    y: startY + CGFloat.random(in: -10...10)  // ±10px variation
                )
            )

            let line = SKShapeNode(path: path)
            line.strokeColor = terrainType.flowColor
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
    func cutSurfaceAt(gridX: Int, gridY: Int, blockSize: CGFloat) {
        print("🎯 cutSurfaceAt called: gridX=\(gridX), gridY=\(gridY)")
        print("🎯 Stratum range: \(stratumRange)")

        let localGridY = Double(gridY) - stratumRange.lowerBound
        print("🎯 Local grid Y: \(localGridY)")

        guard localGridY >= 0 && localGridY < (stratumRange.upperBound - stratumRange.lowerBound) else {
            print("🎯 ❌ Local grid Y out of range!")
            return
        }

        let localBlockX = gridX
        let localBlockY = Int(localGridY)
        let key = "\(localBlockX),\(localBlockY)"
        print("🎯 Block key: \(key)")

        guard !drilledBlocks.contains(key) else {
            print("🎯 ❌ Block already in drilledBlocks set - skipping")
            return
        }

        let posX = CGFloat(localBlockX) * blockSize
        let posY = layerSize.height - CGFloat(localBlockY + 1) * blockSize
        let centerPos = CGPoint(x: posX + blockSize/2, y: posY + blockSize/2)
        print("🎯 Position: (\(posX), \(posY)), center: \(centerPos)")

        // No need to place excavated block - background is already excavated layer (darker)

        // Check if there's a crop node (drilling in progress)
        if let cropNode = childNode(withName: "consumeCropNode_\(key)") as? SKCropNode {
            // Drilling in progress - mark as drilled and finish excavation
            print("🎯 ✅ Found existing crop node - finishing excavation")
            drilledBlocks.insert(key)
            finishExcavation(cropNode: cropNode, centerPos: centerPos, blockSize: blockSize, instant: false)
        } else {
            // No crop node exists (bomb/instant destruction) - directly place excavated block
            print("🎯 No crop node exists - placing excavated block sprite directly")
            drilledBlocks.insert(key)

            // Create excavated block sprite (darker color) to show crater
            let excavatedColors = customExcavatedColors ?? terrainType.excavatedGradientColors
            let excavatedColor = excavatedColors[excavatedColors.count / 2]
            let excavatedBlock = SKSpriteNode(color: excavatedColor, size: CGSize(width: blockSize, height: blockSize))
            excavatedBlock.anchorPoint = CGPoint(x: 0, y: 0)
            excavatedBlock.position = CGPoint(x: posX, y: posY)
            excavatedBlock.zPosition = 5  // Above excavated background (4), below surface (7)
            excavatedBlock.name = "excavatedBlock_\(key)"
            addChild(excavatedBlock)

            // Spawn destruction burst
            for _ in 0..<Int.random(in: 10...15) {
                spawnDestructionParticle(at: centerPos)
            }

            print("🎯 ✅ Excavated block sprite placed at (\(posX), \(posY))")
        }
    }

    /// Finish excavation with destruction burst when block health reaches 0
    private func finishExcavation(cropNode: SKCropNode, centerPos: CGPoint, blockSize: CGFloat, instant: Bool) {
        let cropKey = cropNode.name ?? "unknown"
        print("🏁 finishExcavation called for crop node: \(cropKey), instant: \(instant)")
        print("🏁 Crop node alpha: \(cropNode.alpha), parent: \(cropNode.parent != nil)")

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

        print("🔧 updateConsumptionMask called: key=\(key), progress=\(progress), inDrilledBlocks=\(drilledBlocks.contains(key))")

        // Check if crop node already exists
        if let cropNode = childNode(withName: "consumeCropNode_\(key)") as? SKCropNode {
            // Update the consumption mask to expand
            print("🔄 updateConsumptionMask: Updating existing crop node at \(key) to progress \(progress)")
            updateCircularConsumptionMask(cropNode: cropNode, progress: progress, blockSize: blockSize, centerPos: centerPos)
        } else if !drilledBlocks.contains(key) {
            // First time drilling this block - create the consumption system
            print("🆕 Creating NEW surface block at \(key) with progress \(progress)")
            drilledBlocks.insert(key)

            // Generate random phase offset for this block (makes each block's pattern unique)
            blockPhaseOffsets[key] = CGFloat.random(in: 0...(CGFloat.pi * 2))

            // Generate random glow variations (frequency, amplitude, secondary phase, rotation)
            let directions: [CGFloat] = [-1.0, 1.0]
            let randomRotation: CGFloat = directions.randomElement() ?? 1.0  // Random direction
            blockGlowVariations[key] = (
                frequency: CGFloat.random(in: 2.5...3.5),  // Varies wave frequency (2.5-3.5x, default was 3x)
                amplitude: CGFloat.random(in: 0.12...0.18), // Varies jitter amplitude (12-18%, default was 15%)
                secondaryPhase: CGFloat.random(in: 0...(CGFloat.pi * 2)), // Additional phase shift for glow
                rotationDirection: randomRotation  // -1 or +1 for different rotation directions
            )
            print("🔄 Block \(key) glow rotation direction: \(randomRotation)")

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

            // Create initial consumption mask (use provided progress, not hardcoded 0.0)
            let maskNode = createCircularConsumptionMask(progress: progress, blockSize: blockSize, centerPos: centerPos, blockKey: key)
            maskNode.name = "consumptionMask"
            cropNode.maskNode = maskNode

            // Add surface block to crop node
            cropNode.addChild(surfaceBlock)
            addChild(cropNode)
        } else {
            print("⏭️ Skipping block \(key) - already in drilledBlocks set (block was already excavated)")
        }
    }

    /// Create a circular consumption mask with jagged edges
    private func createCircularConsumptionMask(progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint, blockKey: String) -> SKNode {
        let maskContainer = SKNode()

        // Circular consumption expands from center outward
        // Progress 0.0 = tiny hole, 1.0 = full block consumed
        let maxRadius = blockSize * 0.7  // 70% of block size for full consumption
        let consumptionRadius = progress * maxRadius

        if consumptionRadius < 2 {  // 2px minimum radius
            // Very start - just a tiny circle
            let path = CGMutablePath()
            path.addArc(center: centerPos, radius: 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            let maskShape = SKShapeNode(path: path)
            maskShape.fillColor = .white
            maskShape.strokeColor = .clear
            maskContainer.addChild(maskShape)
        } else {
            // Get the random phase offset for this block
            let phaseOffset = blockPhaseOffsets[blockKey] ?? 0

            // Create jagged circle path for organic consumption edge
            let path = CGMutablePath()
            let numPoints = 16  // 16 points for jagged edge

            for i in 0...numPoints {
                let angle = (CGFloat(i) / CGFloat(numPoints)) * .pi * 2

                // Add jitter for organic edge with block-specific phase offset
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

    /// Update the circular consumption mask as drilling progresses
    private func updateCircularConsumptionMask(cropNode: SKCropNode, progress: CGFloat, blockSize: CGFloat, centerPos: CGPoint) {
        // Extract block key from crop node name (format: "consumeCropNode_X,Y")
        let blockKey = cropNode.name?.replacingOccurrences(of: "consumeCropNode_", with: "") ?? ""

        // Remove old mask and create new one
        if let oldMask = cropNode.maskNode {
            oldMask.removeFromParent()
        }

        let newMask = createCircularConsumptionMask(progress: progress, blockSize: blockSize, centerPos: centerPos, blockKey: blockKey)
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
        let surfaceColors = customSurfaceColors ?? terrainType.surfaceGradientColors
        let particle = SKSpriteNode(color: surfaceColors.randomElement() ?? .gray, size: size)
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
        // Use same radius as mask (0.7) so glow appears at the consumption edge
        let maxRadius = blockSize * 0.7
        let consumptionRadius = progress * maxRadius

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

        // Particle appearance - match terrain surface color
        let surfaceColors = customSurfaceColors ?? terrainType.surfaceGradientColors
        let particleColor = surfaceColors[surfaceColors.count / 2]
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
        // Convert depth (meters) to pixels using scale: 64px = 12.5m
        let metersPerBlock: CGFloat = 12.5
        let worldX = sceneMinX
        let worldY = surfaceY - CGFloat(stratumRange.upperBound) * (TerrainBlock.size / metersPerBlock)
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
