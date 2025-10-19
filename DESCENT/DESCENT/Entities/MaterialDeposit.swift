//
//  MaterialDeposit.swift
//  DESCENT
//
//  Represents a material deposit embedded in continuous terrain
//  Renders as overlay node with:
//  - Outer glow with Gaussian blur (1.5x size)
//  - Core deposit with radial gradient
//  - Internal texture details (2-4 spots)
//  - Pulse animation for rare materials
//

import SpriteKit

class MaterialDeposit: SKNode {

    // MARK: - Properties

    let material: Material
    let gridPosition: (x: Int, y: Int)
    private var glowEffectNode: SKEffectNode!  // Wrapper for blur effect
    private var glowNode: SKShapeNode!
    private var coreNode: SKShapeNode!
    private var detailNodes: [SKShapeNode] = []

    // Deposit size based on material type
    private let depositSize: CGFloat

    // MARK: - Initialization

    init(material: Material, gridPosition: (Int, Int)) {
        self.material = material
        self.gridPosition = gridPosition

        // Determine deposit size with random variation
        self.depositSize = MaterialDeposit.getDepositSize(for: material)

        super.init()

        setupVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupVisuals() {
        // Check if this material has a custom image asset
        // Asset names: coal, iron, copper, gold, silicon, dark_matter
        let assetName = material.type.rawValue.lowercased().replacingOccurrences(of: "darkmatter", with: "dark_matter")

        if let materialImage = UIImage(named: assetName) {
            // Use custom material image from asset catalog
            let texture = SKTexture(image: materialImage)
            let imageNode = SKSpriteNode(texture: texture)

            // Dark Matter gets special treatment (larger size, pulsing animation)
            if material.type == .darkMatter {
                imageNode.size = CGSize(width: depositSize * 5, height: depositSize * 5)  // Larger than normal
                imageNode.zPosition = 15  // Higher z to ensure always visible
                addChild(imageNode)

                // Add pulsing animation (0.8 → 1.2 → 0.8 scale, 2 second cycle)
                let scaleDown = SKAction.scale(to: 0.8, duration: 1.0)
                scaleDown.timingMode = .easeInEaseOut
                let scaleUp = SKAction.scale(to: 1.2, duration: 1.0)
                scaleUp.timingMode = .easeInEaseOut
                let pulse = SKAction.sequence([scaleDown, scaleUp])
                let repeatPulse = SKAction.repeatForever(pulse)
                imageNode.run(repeatPulse, withKey: "darkMatterPulse")

                // Add outer glow for Dark Matter
                let glowSize = depositSize * 7
                let glowSprite = SKSpriteNode(texture: texture)
                glowSprite.size = CGSize(width: glowSize, height: glowSize)
                glowSprite.alpha = 0.3
                glowSprite.zPosition = 14
                glowSprite.colorBlendFactor = 1.0
                glowSprite.color = UIColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0)  // Orange glow

                // Add blur effect to glow
                let glowEffect = SKEffectNode()
                glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 15.0])
                glowEffect.addChild(glowSprite)
                glowEffect.zPosition = 14
                addChild(glowEffect)

                // Glow also pulses (slightly offset for visual interest)
                let glowPulse = SKAction.sequence([scaleUp, scaleDown])
                let repeatGlowPulse = SKAction.repeatForever(glowPulse)
                glowEffect.run(repeatGlowPulse, withKey: "darkMatterGlowPulse")

                // Add physics body for contact-based collection (no collision, just detection)
                let physicsRadius = depositSize * 2.5  // Slightly larger than visual size for easy collection
                self.physicsBody = SKPhysicsBody(circleOfRadius: physicsRadius)
                self.physicsBody?.isDynamic = false  // Stationary
                self.physicsBody?.categoryBitMask = 8  // MaterialDeposit category
                self.physicsBody?.contactTestBitMask = 1  // Player category
                self.physicsBody?.collisionBitMask = 0  // No collisions, just contacts

                // Set node name for identification in contact detection
                self.name = "darkMatter"

                print("💎 Dark Matter core crystal created with pulsing animation and physics body")
            } else {
                // Normal size for other materials
                imageNode.size = CGSize(width: depositSize * 3, height: depositSize * 3)
                imageNode.zPosition = 11
                addChild(imageNode)
            }

            // Store as coreNode for animation compatibility (hidden, no shadow)
            coreNode = SKShapeNode(circleOfRadius: 0)
            coreNode.isHidden = true

            // Create empty glow nodes for compatibility
            glowNode = SKShapeNode(circleOfRadius: 0)
            glowNode.isHidden = true
            glowEffectNode = SKEffectNode()
            glowEffectNode.isHidden = true

            return
        }

        // Original procedural generation for other materials
        // 1. Outer glow with Gaussian blur (1.5x size, blurred)
        let glowRadius = depositSize * 1.5
        glowNode = SKShapeNode(circleOfRadius: glowRadius)
        glowNode.fillColor = material.glowColor
        glowNode.strokeColor = .clear
        glowNode.alpha = material.glowIntensity
        glowNode.zPosition = 0

        // Wrap glow in SKEffectNode for Gaussian blur
        glowEffectNode = SKEffectNode()
        glowEffectNode.zPosition = 10

        // Apply Gaussian blur filter
        if let blurFilter = CIFilter(name: "CIGaussianBlur") {
            blurFilter.setValue(3.0 + (CGFloat(material.rarity) * 0.5), forKey: kCIInputRadiusKey)
            glowEffectNode.filter = blurFilter
            glowEffectNode.shouldRasterize = true  // Performance optimization
        }

        glowEffectNode.addChild(glowNode)
        addChild(glowEffectNode)

        // 2. Core deposit with solid color (could use radial gradient texture)
        coreNode = SKShapeNode(circleOfRadius: depositSize)
        coreNode.fillColor = material.coreColor
        coreNode.strokeColor = .clear
        coreNode.zPosition = 11
        addChild(coreNode)

        // 3. Internal texture details (2-4 random spots)
        let detailCount = Int.random(in: 2...4)
        for _ in 0..<detailCount {
            let detailSize = CGSize(
                width: CGFloat.random(in: 4...7),
                height: CGFloat.random(in: 5...8)
            )
            let detail = SKShapeNode(ellipseOf: detailSize)
            detail.fillColor = material.detailColor
            detail.strokeColor = .clear
            detail.alpha = 0.7
            detail.position = CGPoint(
                x: CGFloat.random(in: -depositSize/3...depositSize/3),
                y: CGFloat.random(in: -depositSize/3...depositSize/3)
            )
            detail.zPosition = 12
            addChild(detail)
            detailNodes.append(detail)
        }

        // 4. Add pulse animation for rare materials
        if material.rarity >= 3 {
            addPulseAnimation()
        }
    }

    // MARK: - Animations

    private func addPulseAnimation() {
        // Core pulse
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.9, duration: 1.0)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let forever = SKAction.repeatForever(sequence)
        coreNode.run(forever)

        // Glow pulse with different timing
        let glowUp = SKAction.fadeAlpha(to: material.glowIntensity * 1.2, duration: 1.2)
        let glowDown = SKAction.fadeAlpha(to: material.glowIntensity * 0.8, duration: 1.2)
        let glowSequence = SKAction.sequence([glowUp, glowDown])
        let glowForever = SKAction.repeatForever(glowSequence)
        glowNode.run(glowForever)
    }

    // MARK: - Size Determination

    private static func getDepositSize(for material: Material) -> CGFloat {
        // Size ranges based on rarity (as per DESIGN_SYSTEM.md)
        let sizeRange: ClosedRange<CGFloat>
        switch material.rarity {
        case 0...1:  // Common
            sizeRange = 10...14
        case 2...3:  // Uncommon/Rare
            sizeRange = 15...19
        default:     // Very Rare/Legendary
            sizeRange = 20...24
        }

        return CGFloat.random(in: sizeRange)
    }

    // MARK: - Removal Animation

    func removeWithAnimation(completion: @escaping () -> Void) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.3)
        let group = SKAction.group([fadeOut, scaleUp])

        run(group) { [weak self] in
            guard let self = self else {
                return
            }
            self.removeFromParent()
            completion()
        }
    }
}

// MARK: - Material Extensions for Deposits

extension Material {
    /// Color for the outer glow
    var glowColor: UIColor {
        return TerrainBlock.colorForMaterial(type)
    }

    /// Color for the core deposit
    var coreColor: UIColor {
        return TerrainBlock.colorForMaterial(type)
    }

    /// Color for internal detail spots (lighter)
    var detailColor: UIColor {
        let baseColor = TerrainBlock.colorForMaterial(type)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        baseColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s * 0.8, brightness: min(b * 1.2, 1.0), alpha: a)
    }

    /// Glow intensity based on rarity (0.4-0.9)
    var glowIntensity: CGFloat {
        switch rarity {
        case 0: return 0.4  // Common
        case 1: return 0.5  // Uncommon
        case 2: return 0.6  // Rare
        case 3: return 0.7  // Very Rare
        case 4: return 0.8  // Epic
        default: return 0.9 // Legendary
        }
    }

    /// Rarity level based on value
    var rarity: Int {
        switch value {
        case 0..<50: return 0      // Common (Coal, Iron)
        case 50..<100: return 1    // Uncommon (Copper, Silicon)
        case 100..<200: return 2   // Rare (Silver, Gold)
        case 200..<400: return 3   // Very Rare (Platinum, Ruby)
        case 400..<800: return 4   // Epic (Diamond, Rhodium)
        default: return 5          // Legendary (Dark Matter)
        }
    }
}
