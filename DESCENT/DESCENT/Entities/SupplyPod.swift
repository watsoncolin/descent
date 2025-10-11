//
//  SupplyPod.swift
//  DESCENT
//
//  Animated supply drop pod that falls from the sky
//

import SpriteKit

class SupplyPod: SKSpriteNode {

    private var rocketTrail: SKEmitterNode?
    var onLanded: (() -> Void)?
    private let items: [SupplyDropSystem.SupplyItem: Int]

    init(items: [SupplyDropSystem.SupplyItem: Int]) {
        self.items = items

        // Create pod sprite (small rocket/container)
        super.init(texture: nil, color: .clear, size: CGSize(width: 32, height: 48))

        setupVisuals(items: items)
        setupRocketTrail()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupVisuals(items: [SupplyDropSystem.SupplyItem: Int]) {
        // Pod body (capsule shape)
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: 0, y: 24))       // Top
        bodyPath.addLine(to: CGPoint(x: 12, y: 16))   // Upper right
        bodyPath.addLine(to: CGPoint(x: 12, y: -16))  // Lower right
        bodyPath.addLine(to: CGPoint(x: 0, y: -24))   // Bottom point
        bodyPath.addLine(to: CGPoint(x: -12, y: -16)) // Lower left
        bodyPath.addLine(to: CGPoint(x: -12, y: 16))  // Upper left
        bodyPath.closeSubpath()

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)  // Silver
        body.strokeColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        body.lineWidth = 2
        body.zPosition = 0
        addChild(body)

        // Stripe
        let stripe = SKShapeNode(rectOf: CGSize(width: 24, height: 6))
        stripe.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)  // Orange
        stripe.strokeColor = .clear
        stripe.position = CGPoint(x: 0, y: 0)
        stripe.zPosition = 1
        addChild(stripe)

        // Calculate total items
        let totalItemCount = items.values.reduce(0, +)

        // Show 📦 icon with item count
        let icon = SKLabelNode(fontNamed: "AvenirNext-Bold")
        icon.text = "📦"
        icon.fontSize = 16
        icon.verticalAlignmentMode = .center
        icon.position = CGPoint(x: 0, y: 4)
        icon.zPosition = 2
        addChild(icon)

        // Item count badge
        let countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.text = "\(totalItemCount)"
        countLabel.fontSize = 12
        countLabel.fontColor = .white
        countLabel.verticalAlignmentMode = .center
        countLabel.position = CGPoint(x: 0, y: -8)
        countLabel.zPosition = 2
        addChild(countLabel)

        // Parachute fins
        let fin1 = SKShapeNode(rectOf: CGSize(width: 4, height: 12))
        fin1.fillColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        fin1.strokeColor = .clear
        fin1.position = CGPoint(x: -14, y: 20)
        fin1.zPosition = 0
        addChild(fin1)

        let fin2 = SKShapeNode(rectOf: CGSize(width: 4, height: 12))
        fin2.fillColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        fin2.strokeColor = .clear
        fin2.position = CGPoint(x: 14, y: 20)
        fin2.zPosition = 0
        addChild(fin2)
    }

    private func setupRocketTrail() {
        // Create simple rocket trail effect
        rocketTrail = SKEmitterNode()
        guard let trail = rocketTrail else { return }

        trail.position = CGPoint(x: 0, y: 24)  // Top of pod
        trail.zPosition = -1

        // Create particle texture
        let particleTexture = createParticleTexture()
        trail.particleTexture = particleTexture

        trail.particleColor = UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        trail.particleColorBlendFactor = 1.0

        trail.particleSize = CGSize(width: 4, height: 4)
        trail.particleScale = 1.0
        trail.particleScaleSpeed = -0.5

        trail.particleBirthRate = 100
        trail.particleLifetime = 0.3
        trail.particleLifetimeRange = 0.1

        trail.emissionAngle = -.pi / 2  // Upward
        trail.emissionAngleRange = .pi / 8

        trail.particleSpeed = 50
        trail.particleSpeedRange = 20

        trail.particleAlpha = 0.8
        trail.particleAlphaSpeed = -2.0

        trail.particleBlendMode = .add

        addChild(trail)
    }

    private func createParticleTexture() -> SKTexture {
        let size: CGFloat = 8
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        context.clear(CGRect(x: 0, y: 0, width: size, height: size))
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    /// Animate the pod falling from top of screen to target position
    func animateDrop(to targetPosition: CGPoint, screenHeight: CGFloat) {
        // Start above screen
        let startY = targetPosition.y + screenHeight / 2 + 50

        position = CGPoint(x: targetPosition.x, y: startY)

        // Fall animation
        let fallDuration: TimeInterval = 2.0
        let fallAction = SKAction.moveTo(y: targetPosition.y, duration: fallDuration)
        fallAction.timingMode = .easeIn

        // Slight wobble
        let wobble = SKAction.sequence([
            SKAction.rotate(byAngle: 0.1, duration: 0.1),
            SKAction.rotate(byAngle: -0.2, duration: 0.2),
            SKAction.rotate(byAngle: 0.1, duration: 0.1)
        ])
        let repeatWobble = SKAction.repeatForever(wobble)

        // Run animations
        run(SKAction.group([fallAction, repeatWobble]))

        // Wait for landing
        run(SKAction.sequence([
            SKAction.wait(forDuration: fallDuration),
            SKAction.run { [weak self] in
                self?.land()
            }
        ]))
    }

    private func land() {
        // Stop wobbling
        removeAllActions()
        zRotation = 0

        // Stop trail
        rocketTrail?.particleBirthRate = 0

        // Impact effect
        spawnImpactParticles()

        // Small bounce
        let bounce = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.1),
            SKAction.moveBy(x: 0, y: -10, duration: 0.1)
        ])
        run(bounce)

        // Notify landed
        onLanded?()

        // Fade out and remove
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func spawnImpactParticles() {
        guard let scene = scene else { return }

        // Spawn dust particles
        let particleCount = 12
        for _ in 0..<particleCount {
            let particle = SKShapeNode(circleOfRadius: 2)
            particle.fillColor = UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0)  // Dust color
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 50
            scene.addChild(particle)

            // Random direction
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 30...60)
            let velocityX = cos(angle) * speed
            let velocityY = sin(angle) * speed

            // Animate
            let moveAction = SKAction.moveBy(x: velocityX, y: velocityY, duration: 0.4)
            let fadeAction = SKAction.fadeOut(withDuration: 0.4)
            let scaleAction = SKAction.scale(to: 0.2, duration: 0.4)
            let group = SKAction.group([moveAction, fadeAction, scaleAction])
            let remove = SKAction.removeFromParent()

            particle.run(SKAction.sequence([group, remove]))
        }
    }
}
