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

    // Crack overlay sprites (additive layers)
    private var crackOverlay1: SKSpriteNode?  // Light cracks (generated once)
    private var crackOverlay2: SKSpriteNode?  // Medium cracks (generated once)
    private var crackOverlay3: SKSpriteNode?  // Heavy cracks (generated once)
    private var currentCrackLevel: Int = 0    // Track which level we've reached

    // Block size (in pixels)
    static let size: CGFloat = 48

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

        // Determine texture and color based on block type or material
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
        } else if let material = material {
            // Material blocks show soil with embedded ore/crystal
            let soilColor = TerrainBlock.getSoilColor(forDepth: depth)
            let materialColor = TerrainBlock.colorForMaterial(material.type)

            // Generate embedded material texture based on visual type
            if material.type.visualType == .crystal {
                texture = TextureGenerator.shared.embeddedCrystalTexture(
                    materialColor: materialColor,
                    soilColor: soilColor
                )
            } else {
                texture = TextureGenerator.shared.embeddedOreTexture(
                    materialColor: materialColor,
                    soilColor: soilColor
                )
            }
            color = .white
        } else {
            // Use procedural terrain texture for dirt/stone
            texture = TextureGenerator.shared.terrainTexture(depth: depth)
            color = .white
        }

        super.init(texture: texture, color: color, size: CGSize(width: TerrainBlock.size, height: TerrainBlock.size))

        setupPhysics()

        // Only setup crack overlay for normal drillable blocks
        if blockType == .normal {
            setupCrackOverlay()
        }
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

    private func setupCrackOverlay() {
        // Create three invisible crack overlay layers (will be shown progressively when damaged)
        crackOverlay1 = SKSpriteNode(color: .clear, size: CGSize(width: TerrainBlock.size, height: TerrainBlock.size))
        crackOverlay1?.zPosition = 1
        crackOverlay1?.alpha = 0
        if let overlay = crackOverlay1 {
            addChild(overlay)
        }

        crackOverlay2 = SKSpriteNode(color: .clear, size: CGSize(width: TerrainBlock.size, height: TerrainBlock.size))
        crackOverlay2?.zPosition = 2
        crackOverlay2?.alpha = 0
        if let overlay = crackOverlay2 {
            addChild(overlay)
        }

        crackOverlay3 = SKSpriteNode(color: .clear, size: CGSize(width: TerrainBlock.size, height: TerrainBlock.size))
        crackOverlay3?.zPosition = 3
        crackOverlay3?.alpha = 0
        if let overlay = crackOverlay3 {
            addChild(overlay)
        }
    }

    private func updateCrackOverlay() {
        // Calculate damage percentage
        let healthPercent = Double(health) / Double(maxHealth)

        // Level 1: Light cracks (50-75% health)
        if healthPercent <= 0.75 && currentCrackLevel < 1 {
            // Generate light cracks ONCE and keep them
            crackOverlay1?.texture = TextureGenerator.shared.crackTexture(level: 1)
            crackOverlay1?.alpha = 0.7
            currentCrackLevel = 1
        }

        // Level 2: Add medium cracks (25-50% health)
        if healthPercent <= 0.5 && currentCrackLevel < 2 {
            // Generate medium cracks ONCE and add on top of light cracks
            crackOverlay2?.texture = TextureGenerator.shared.crackTexture(level: 2)
            crackOverlay2?.alpha = 0.8
            currentCrackLevel = 2
        }

        // Level 3: Add heavy cracks (<25% health)
        if healthPercent <= 0.25 && currentCrackLevel < 3 {
            // Generate heavy cracks ONCE and add on top of previous cracks
            crackOverlay3?.texture = TextureGenerator.shared.crackTexture(level: 3)
            crackOverlay3?.alpha = 0.9
            currentCrackLevel = 3
        }
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

    /// Apply damage to the block, returns true if destroyed
    func takeDamage(_ amount: Int, drillLevel: Int = 1) -> Bool {
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

        health -= amount

        // Spawn drill particles
        spawnDrillParticles()

        if health <= 0 {
            // Spawn extra particles on destruction
            spawnDestructionParticles()
            return true
        }

        // Calculate health percentage
        let healthPercent = CGFloat(health) / CGFloat(maxHealth)

        // Progressively scale block down as it takes damage (from 100% to 20% size)
        let minScale: CGFloat = 0.2
        let scale = minScale + (1.0 - minScale) * healthPercent
        setScale(scale)

        // Update physics body to match new size
        let scaledSize = CGSize(width: TerrainBlock.size * scale, height: TerrainBlock.size * scale)
        physicsBody = SKPhysicsBody(rectangleOf: scaledSize)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = 2  // Terrain
        physicsBody?.contactTestBitMask = 1  // Player
        physicsBody?.collisionBitMask = 1  // Player

        // Update crack overlay based on new health
        updateCrackOverlay()

        // Visual feedback - flash white when damaged (works with textures)
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(flash)

        return false
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

    /// Get soil color based on depth (matching terrain texture generation)
    private static func getSoilColor(forDepth depth: Double) -> UIColor {
        if depth < 100 {
            return UIColor(red: 0.55, green: 0.45, blue: 0.35, alpha: 1.0) // Light brown dirt
        } else if depth < 300 {
            return UIColor(red: 0.45, green: 0.35, blue: 0.25, alpha: 1.0) // Darker dirt
        } else {
            return UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Stone
        }
    }

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
