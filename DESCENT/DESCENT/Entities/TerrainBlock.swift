//
//  TerrainBlock.swift
//  DESCENT
//
//  Individual terrain block that can contain materials
//

import SpriteKit

class TerrainBlock: SKSpriteNode {

    // MARK: - Block Types
    enum BlockType {
        case normal          // Regular drillable terrain
        case bedrock        // Completely indestructible
        case hardCrystal    // Requires bomb to break
        case reinforcedRock // Requires Drill Level 4+ or bomb
    }

    // MARK: - Properties
    let blockType: BlockType
    let material: Material?
    let hardness: Int
    var health: Int
    let maxHealth: Int  // Store initial health for damage percentage calculation
    let strataHardness: Double  // Strata layer hardness for fuel consumption

    // Track the primary drill direction (most recent direction drilled from)
    private var primaryDrillDirection: DrillDirection?
    private var originalPosition: CGPoint = .zero  // Store initial position

    // Block size (in pixels) - Grid size for continuous terrain system (64px = 12.5m)
    static let size: CGFloat = 64

    // Conversion factor: meters per block (1 block = 12.5 meters)
    static let metersPerBlock: CGFloat = 12.5

    // MARK: - Initialization

    init(material: Material?, depth: Double, strataHardness: Double = 1.0, blockType: BlockType = .normal) {
        self.blockType = blockType
        self.material = material

        // Set hardness based on block type
        if blockType != .normal {
            self.hardness = 999  // Indestructible blocks have very high hardness
        } else {
            self.hardness = material?.hardness ?? 1
        }

        self.health = hardness * 2  // Tougher blocks take more hits
        self.maxHealth = hardness * 2  // Store initial health
        self.strataHardness = strataHardness

        // Determine texture and color based on block type
        // NOTE: Materials are no longer rendered as TerrainBlocks - they use MaterialDeposit with PNG assets
        let texture: SKTexture?
        let color: UIColor

        // Special handling for obstacle blocks
        if blockType == .bedrock {
            texture = TextureGenerator.shared.bedrockTexture()
            color = .white
        } else if blockType == .hardCrystal {
            texture = TextureGenerator.shared.hardCrystalTexture()
            color = .white
        } else if blockType == .reinforcedRock {
            texture = TextureGenerator.shared.reinforcedRockTexture()
            color = .white
        } else {
            // Regular terrain blocks (no longer used for materials)
            // Materials are now rendered via MaterialDeposit system
            texture = TextureGenerator.shared.terrainTexture(depth: depth)
            color = .white
        }

        super.init(texture: texture, color: color, size: CGSize(width: TerrainBlock.size, height: TerrainBlock.size))

        setupPhysics()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = 2  // Terrain
        physicsBody?.contactTestBitMask = 1  // Player
        physicsBody?.collisionBitMask = 1  // Player
    }

    // MARK: - Damage

    /// Check if block can be drilled with given drill strength
    func canDrill(withDrillLevel drillLevel: Int) -> Bool {
        switch blockType {
        case .normal:
            return true
        case .bedrock:
            return false  // Never drillable
        case .hardCrystal:
            return false  // Only bombs can break (not implemented yet)
        case .reinforcedRock:
            return drillLevel >= 4  // Requires Drill Level 4+
        }
    }

    /// Apply damage to the block from a specific direction, returns true if destroyed
    func takeDamage(_ amount: Int, drillLevel: Int = 1, from direction: DrillDirection) -> Bool {
        // Check if block can be drilled
        if !canDrill(withDrillLevel: drillLevel) {
            // Visual feedback for hitting indestructible block
            let flash = SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.05),
                SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
            ])
            run(flash)
            return false
        }

        // If drill direction changed, reset original position to current position
        if primaryDrillDirection != direction {
            originalPosition = position
        }

        // Store original position on first damage
        if primaryDrillDirection == nil {
            originalPosition = position
        }

        // Update primary drill direction to current direction
        primaryDrillDirection = direction

        health -= amount

        // Spawn drill particles
        spawnDrillParticles()

        if health <= 0 {
            // Spawn extra particles on destruction
            spawnDestructionParticles()
            return true
        }

        // Apply directional scaling and positioning based on current direction
        updateDirectionalAppearance()

        // Visual feedback - flash white when damaged (works with textures)
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(flash)

        return false
    }

    /// Update block appearance based on directional drilling progress
    private func updateDirectionalAppearance() {
        guard let direction = primaryDrillDirection else { return }

        // Calculate total damage percentage
        let healthPercent = CGFloat(health) / CGFloat(maxHealth)
        let damagePercent = 1.0 - healthPercent

        // Scale: from 100% to 20% (keep 20% minimum so block doesn't disappear)
        let minScale: CGFloat = 0.2
        let scaleReduction = damagePercent * 0.8  // Max 80% reduction

        var horizontalScale: CGFloat = 1.0
        var verticalScale: CGFloat = 1.0
        var offset = CGPoint.zero
        let blockHalf = TerrainBlock.size / 2

        // Apply scaling and offset based on primary drill direction
        switch direction {
        case .left:
            // Pod drilling LEFT (from right side) → remove RIGHT side of block → shift left
            horizontalScale = max(minScale, 1.0 - scaleReduction)
            offset.x = -blockHalf * scaleReduction
        case .right:
            // Pod drilling RIGHT (from left side) → remove LEFT side of block → shift right
            horizontalScale = max(minScale, 1.0 - scaleReduction)
            offset.x = blockHalf * scaleReduction
        case .down:
            // Pod drilling DOWN (from above) → remove TOP of block → shift down
            verticalScale = max(minScale, 1.0 - scaleReduction)
            offset.y = -blockHalf * scaleReduction
        }

        // Apply scaling
        xScale = horizontalScale
        yScale = verticalScale

        // Apply position offset
        position = CGPoint(x: originalPosition.x + offset.x, y: originalPosition.y + offset.y)

        // Update physics body to match new size and position
        let scaledSize = CGSize(
            width: TerrainBlock.size * horizontalScale,
            height: TerrainBlock.size * verticalScale
        )
        physicsBody = SKPhysicsBody(rectangleOf: scaledSize)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = 2  // Terrain
        physicsBody?.contactTestBitMask = 1  // Player
        physicsBody?.collisionBitMask = 1  // Player
    }

    // MARK: - Particle Effects

    private func spawnDrillParticles() {
        guard let scene = scene else { return }

        // Spawn 3-5 small debris particles
        let particleCount = Int.random(in: 3...5)
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 1.5)

            // Use material color or terrain color
            if let material = material {
                particle.fillColor = TerrainBlock.colorForMaterial(material.type)
            } else {
                particle.fillColor = color
            }

            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 50
            scene.addChild(particle)

            // Random velocity away from block
            let velocityX = CGFloat.random(in: -30...30)
            let velocityY = CGFloat.random(in: -30...30)

            // Animate particle
            let moveAction = SKAction.moveBy(x: velocityX, y: velocityY, duration: 0.3)
            let fadeAction = SKAction.fadeOut(withDuration: 0.3)
            let scaleAction = SKAction.scale(to: 0.5, duration: 0.3)
            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
        }
    }

    private func spawnDestructionParticles() {
        guard let scene = scene else { return }

        // Spawn more particles on destruction (8-12)
        let particleCount = Int.random(in: 8...12)
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 2)

            // Use material color or terrain color
            if let material = material {
                particle.fillColor = TerrainBlock.colorForMaterial(material.type)
            } else {
                particle.fillColor = color
            }

            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 50
            scene.addChild(particle)

            // Stronger velocity for destruction
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 40...80)
            let velocityX = cos(angle) * speed
            let velocityY = sin(angle) * speed

            // Animate particle
            let moveAction = SKAction.moveBy(x: velocityX, y: velocityY, duration: 0.5)
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let scaleAction = SKAction.scale(to: 0.2, duration: 0.5)
            let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 0.5)
            let group = SKAction.group([moveAction, fadeAction, scaleAction, rotateAction])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
        }
    }

    // MARK: - Helper Methods
    // NOTE: getSoilColor removed - no longer needed with PNG material assets

    // MARK: - Material Colors

    static func colorForMaterial(_ type: Material.MaterialType) -> UIColor {
        switch type {
        case .carbon, .coal:
            return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)  // Black
        case .iron:
            return UIColor(red: 0.72, green: 0.45, blue: 0.20, alpha: 1.0)  // Rusty brown
        case .copper:
            return UIColor(red: 0.72, green: 0.45, blue: 0.20, alpha: 1.0)  // Orange-brown
        case .silicon:
            return UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1.0)  // Gray
        case .aluminum:
            return UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1.0)  // Light gray
        case .silver:
            return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)  // Silver
        case .gold:
            return UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)  // Gold
        case .platinum:
            return UIColor(red: 0.9, green: 0.89, blue: 0.88, alpha: 1.0)  // Platinum white
        case .titanium:
            return UIColor(red: 0.53, green: 0.53, blue: 0.51, alpha: 1.0)  // Dark silver
        case .neodymium:
            return UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)  // Purple-silver
        case .ruby:
            return UIColor(red: 0.88, green: 0.07, blue: 0.37, alpha: 1.0)  // Red
        case .emerald:
            return UIColor(red: 0.31, green: 0.78, blue: 0.47, alpha: 1.0)  // Green
        case .diamond:
            return UIColor(red: 0.73, green: 0.95, blue: 1.0, alpha: 1.0)  // Light blue
        case .rhodium:
            return UIColor(red: 1.0, green: 0.98, blue: 0.98, alpha: 1.0)  // Ultra-reflective silver
        case .darkMatter:
            return UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1.0)  // Dark purple
        }
    }
}
