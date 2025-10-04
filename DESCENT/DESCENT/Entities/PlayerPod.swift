//
//  PlayerPod.swift
//  DESCENT
//
//  The player's mining pod
//

import SpriteKit

class PlayerPod: SKSpriteNode {

    // MARK: - Properties
    private var velocity: CGVector = .zero
    private var isDrilling: Bool = false
    private var currentDrillDirection: DrillDirection? = nil

    // Movement parameters
    private let maxSpeed: CGFloat = 300.0
    private let acceleration: CGFloat = 1200.0
    private let drag: CGFloat = 0.85  // Friction when no input

    // MARK: - Initialization

    init() {
        // Create the pod as a custom shape (narrower: 24px × 36px)
        super.init(texture: nil, color: .clear, size: CGSize(width: 24, height: 36))

        setupPhysics()
        setupVisuals()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPhysics() {
        // Create capsule-shaped physics body (width: 24px, height: 36px)
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 22, height: 34))  // Slightly smaller for better collisions
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false  // Keep pod upright always
        physicsBody?.linearDamping = 0.1
        physicsBody?.restitution = 0.2  // Slight bounce
        physicsBody?.friction = 0.5

        // Collision categories (we'll set these up properly later)
        physicsBody?.categoryBitMask = 1  // Player
        physicsBody?.contactTestBitMask = 2  // Terrain
        physicsBody?.collisionBitMask = 2  // Terrain
    }

    private func setupVisuals() {
        // Create a narrow vertical capsule/rocket shape (24px × 36px)
        // In SpriteKit: positive Y is UP, negative Y is DOWN

        // Main body - narrow hexagonal pod shape
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: 0, y: 18))       // Top point
        bodyPath.addLine(to: CGPoint(x: 8, y: 12))    // Upper right
        bodyPath.addLine(to: CGPoint(x: 8, y: -12))   // Lower right
        bodyPath.addLine(to: CGPoint(x: 0, y: -18))   // Bottom point (drill end)
        bodyPath.addLine(to: CGPoint(x: -8, y: -12))  // Lower left
        bodyPath.addLine(to: CGPoint(x: -8, y: 12))   // Upper left
        bodyPath.closeSubpath()

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)  // Cyan-blue
        body.strokeColor = UIColor(red: 0.1, green: 0.4, blue: 0.6, alpha: 1.0)  // Darker outline
        body.lineWidth = 2
        body.zPosition = 0
        addChild(body)

        // Top marker - small circle to show "top" of pod
        let topMarker = SKShapeNode(circleOfRadius: 3)
        topMarker.fillColor = .yellow
        topMarker.strokeColor = .orange
        topMarker.lineWidth = 1
        topMarker.position = CGPoint(x: 0, y: 16)  // At the top (positive Y)
        topMarker.zPosition = 1
        addChild(topMarker)

        // Drill indicator - bright triangle showing drill direction
        // Points DOWN by default (negative Y direction)
        let drillPath = CGMutablePath()
        drillPath.move(to: CGPoint(x: 0, y: -5))      // Point towards drilling direction (down)
        drillPath.addLine(to: CGPoint(x: -4, y: 2))   // Left base
        drillPath.addLine(to: CGPoint(x: 4, y: 2))    // Right base
        drillPath.closeSubpath()

        let drillIndicator = SKShapeNode(path: drillPath)
        drillIndicator.fillColor = .red
        drillIndicator.strokeColor = .white
        drillIndicator.lineWidth = 1.5
        drillIndicator.position = CGPoint(x: 0, y: -18)  // Start at bottom of pod (negative Y)
        drillIndicator.zPosition = 2
        drillIndicator.name = "drillIndicator"
        addChild(drillIndicator)

        // Glow effect around pod (elliptical for narrow shape)
        let glowPath = CGMutablePath()
        glowPath.addEllipse(in: CGRect(x: -14, y: -20, width: 28, height: 40))
        let glow = SKShapeNode(path: glowPath)
        glow.fillColor = .clear
        glow.strokeColor = UIColor.cyan.withAlphaComponent(0.4)
        glow.lineWidth = 2
        glow.glowWidth = 4
        glow.alpha = 0.6
        glow.zPosition = -1
        addChild(glow)

        // Window on the pod (adds character)
        let window = SKShapeNode(circleOfRadius: 4)
        window.fillColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
        window.strokeColor = UIColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1.0)
        window.lineWidth = 1.5
        window.position = CGPoint(x: 0, y: 2)
        window.zPosition = 1
        addChild(window)
    }

    // MARK: - Movement

    /// Move the pod towards a target position (called from touch controls)
    func moveTowards(target: CGPoint, deltaTime: TimeInterval, currentGravity: CGFloat) {
        guard let physicsBody = physicsBody else { return }

        // Calculate direction from pod to target
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = sqrt(dx * dx + dy * dy)

        // Only apply thrust if target is far enough away
        if distance > 20 {
            // Normalize direction
            let dirX = dx / distance
            let dirY = dy / distance

            // Apply acceleration in the direction of the target
            let thrustX = dirX * acceleration * CGFloat(deltaTime)
            let thrustY = dirY * acceleration * CGFloat(deltaTime)

            physicsBody.applyImpulse(CGVector(dx: thrustX, dy: thrustY))

            // Determine drill direction based on movement (but don't rotate pod)
            let angle = atan2(dy, dx)
            let degrees = angle * 180 / .pi
            let normalizedDegrees = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)

            // Set drill direction based on movement direction
            // In SpriteKit: positive Y is UP, negative Y is DOWN
            if normalizedDegrees >= 315 || normalizedDegrees < 45 {
                currentDrillDirection = .right
            } else if normalizedDegrees >= 45 && normalizedDegrees < 135 {
                currentDrillDirection = nil  // Up - not allowed
            } else if normalizedDegrees >= 135 && normalizedDegrees < 225 {
                currentDrillDirection = .left
            } else {
                currentDrillDirection = .down  // Down (225-315 degrees)
            }

            isDrilling = currentDrillDirection != nil
        } else {
            isDrilling = false
            currentDrillDirection = nil
        }

        // Clamp velocity to max speed
        let currentSpeed = sqrt(pow(physicsBody.velocity.dx, 2) + pow(physicsBody.velocity.dy, 2))
        if currentSpeed > maxSpeed {
            let ratio = maxSpeed / currentSpeed
            physicsBody.velocity = CGVector(
                dx: physicsBody.velocity.dx * ratio,
                dy: physicsBody.velocity.dy * ratio
            )
        }
    }

    /// Stop applying thrust (touch released)
    func stopThrust() {
        isDrilling = false
        currentDrillDirection = nil
        // Apply drag when no input
        guard let physicsBody = physicsBody else { return }
        physicsBody.velocity = CGVector(
            dx: physicsBody.velocity.dx * drag,
            dy: physicsBody.velocity.dy * drag
        )
    }

    // MARK: - Update

    func update(deltaTime: TimeInterval) {
        // Ensure pod always stays upright (no rotation)
        zRotation = 0

        // Update drill indicator position and visual based on drill direction
        if let drillIndicator = childNode(withName: "drillIndicator") as? SKShapeNode {

            // Position drill indicator based on current drill direction
            let targetPosition: CGPoint
            let targetRotation: CGFloat

            if let direction = currentDrillDirection {
                switch direction {
                case .down:
                    targetPosition = CGPoint(x: 0, y: -18)  // Bottom of pod (negative Y)
                    targetRotation = 0                       // Points down
                case .left:
                    targetPosition = CGPoint(x: -14, y: 0)  // Left side (narrower)
                    targetRotation = -.pi / 2                // Rotate 90° CCW to point left
                case .right:
                    targetPosition = CGPoint(x: 14, y: 0)   // Right side (narrower)
                    targetRotation = .pi / 2                 // Rotate 90° CW to point right
                }

                // Smooth movement to target position
                drillIndicator.position = CGPoint(
                    x: drillIndicator.position.x + (targetPosition.x - drillIndicator.position.x) * 0.3,
                    y: drillIndicator.position.y + (targetPosition.y - drillIndicator.position.y) * 0.3
                )
                drillIndicator.zRotation = targetRotation

                // Pulsing red when actively drilling
                drillIndicator.fillColor = .red
                drillIndicator.strokeColor = .white

                // Add pulsing animation if not already running
                if drillIndicator.action(forKey: "pulse") == nil {
                    let pulse = SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ])
                    let repeatPulse = SKAction.repeatForever(pulse)
                    drillIndicator.run(repeatPulse, withKey: "pulse")
                }
            } else {
                // Return to default position (down, negative Y)
                drillIndicator.position = CGPoint(
                    x: drillIndicator.position.x * 0.9,
                    y: drillIndicator.position.y + (-18 - drillIndicator.position.y) * 0.3
                )
                drillIndicator.zRotation = drillIndicator.zRotation * 0.9

                // Dim orange when not drilling
                drillIndicator.fillColor = UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 0.6)
                drillIndicator.strokeColor = UIColor(white: 0.8, alpha: 0.6)

                // Remove pulsing animation
                drillIndicator.removeAction(forKey: "pulse")
                drillIndicator.setScale(1.0)
            }
        }
    }

    // MARK: - Drilling

    func getIsDrilling() -> Bool {
        return isDrilling
    }

    /// Get the current drilling direction
    func getDrillDirection() -> DrillDirection? {
        return currentDrillDirection
    }
}

// MARK: - Drill Direction

enum DrillDirection {
    case left
    case right
    case down

    /// Get the grid offset for this direction
    var gridOffset: (x: Int, y: Int) {
        switch self {
        case .left: return (-1, 0)
        case .right: return (1, 0)
        case .down: return (0, 1)
        }
    }
}
