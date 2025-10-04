//
//  TerrainBlock.swift
//  DESCENT
//
//  Individual terrain block that can contain materials
//

import SpriteKit

class TerrainBlock: SKSpriteNode {

    // MARK: - Properties
    let material: Material?
    let hardness: Int
    var health: Int

    // Block size (in pixels)
    static let size: CGFloat = 24

    // MARK: - Initialization

    init(material: Material?, depth: Double) {
        self.material = material
        self.hardness = material?.hardness ?? 1
        self.health = hardness * 2  // Tougher blocks take more hits

        // Determine block color based on material
        let color: UIColor
        if let material = material {
            color = TerrainBlock.colorForMaterial(material.type)
        } else {
            // Regular dirt/stone based on depth
            if depth < 100 {
                color = UIColor(red: 0.55, green: 0.45, blue: 0.35, alpha: 1.0)  // Light brown dirt
            } else if depth < 300 {
                color = UIColor(red: 0.45, green: 0.35, blue: 0.25, alpha: 1.0)  // Darker dirt
            } else {
                color = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)  // Stone
            }
        }

        super.init(texture: nil, color: color, size: CGSize(width: TerrainBlock.size, height: TerrainBlock.size))

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

    /// Apply damage to the block, returns true if destroyed
    func takeDamage(_ amount: Int) -> Bool {
        health -= amount
        if health <= 0 {
            return true
        }

        // Visual feedback - flash when damaged
        let flash = SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.8, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        run(flash)

        return false
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
