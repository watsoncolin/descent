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

    // Upgrade levels (for visual customization)
    private var drillStrengthLevel: Int = 1
    private var hullArmorLevel: Int = 1
    private var engineSpeedLevel: Int = 1
    private var fuelTankLevel: Int = 1
    private var cargoLevel: Int = 1

    // Visual elements (named for easy updates)
    private var bodyNode: SKShapeNode?
    private var armorPlates: [SKShapeNode] = []
    private var drillBits: [SKShapeNode] = []
    private var engineThrusters: [SKShapeNode] = []
    private var fuelTanks: [SKShapeNode] = []
    private var cargoPods: [SKShapeNode] = []

    // Particle effects
    private var exhaustEmitter: SKEmitterNode?
    private var currentThrustIntensity: CGFloat = 0

    // MARK: - Initialization

    init() {
        // Create the pod as a custom shape (narrower: 24px × 36px)
        super.init(texture: nil, color: .clear, size: CGSize(width: 48, height: 72))

        setupPhysics()
        setupVisuals()
        setupExhaustParticles()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupExhaustParticles() {
        // Create engine exhaust particle emitter
        exhaustEmitter = SKEmitterNode()
        guard let emitter = exhaustEmitter else { return }

        // Position at top of pod (where engines are)
        emitter.position = CGPoint(x: 0, y: 36)
        emitter.zPosition = -1  // Behind the pod

        // Create simple circular particle texture
        let particleTexture = createParticleTexture()
        emitter.particleTexture = particleTexture
        emitter.particleColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)  // Orange flame
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = nil

        // Color variation
        emitter.particleColorRedRange = 0.3
        emitter.particleColorGreenRange = 0.2
        emitter.particleColorBlueRange = 0.1
        emitter.particleColorAlphaRange = 0.3
        emitter.particleColorAlphaSpeed = -0.8  // Fade out

        // Particle size
        emitter.particleSize = CGSize(width: 4, height: 4)
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.3
        emitter.particleScaleSpeed = -0.5  // Shrink over lifetime

        // Emission properties
        emitter.particleBirthRate = 0  // Start with no particles (will update based on thrust)
        emitter.numParticlesToEmit = 0  // Continuous emission
        emitter.particleLifetime = 0.4
        emitter.particleLifetimeRange = 0.2

        // Emission angle (downward, away from engines)
        emitter.emissionAngle = .pi / 2  // Downward (90 degrees)
        emitter.emissionAngleRange = .pi / 6  // 30 degree spread

        // Particle speed
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 40

        // Physics
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -2.0
        emitter.yAcceleration = -50  // Slight gravity effect

        // Blend mode for glow effect
        emitter.particleBlendMode = .add

        addChild(emitter)
    }

    private func createParticleTexture() -> SKTexture {
        let size: CGFloat = 8
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        // Draw a radial gradient circle
        context.clear(CGRect(x: 0, y: 0, width: size, height: size))

        // Draw solid white circle (will be tinted by particle color)
        context.setFillColor(UIColor.white.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: size, height: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    // MARK: - Setup

    private func setupPhysics() {
        // Create capsule-shaped physics body (width: 48px, height: 72px)
        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 44, height: 68))  // Slightly smaller for better collisions
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false  // Keep pod upright always
        physicsBody?.linearDamping = 0.1
        physicsBody?.restitution = 0.2  // Slight bounce
        physicsBody?.friction = 0.1  // Lower friction to allow sliding off edges

        // Collision categories (we'll set these up properly later)
        physicsBody?.categoryBitMask = 1  // Player
        physicsBody?.contactTestBitMask = 2  // Terrain
        physicsBody?.collisionBitMask = 2  // Terrain
    }

    private func setupVisuals() {
        // Create a narrow vertical capsule/rocket shape (48px × 72px)
        // In SpriteKit: positive Y is UP, negative Y is DOWN

        // Main body - narrow hexagonal pod shape (scaled 2x)
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: 0, y: 36))       // Top point
        bodyPath.addLine(to: CGPoint(x: 16, y: 24))   // Upper right
        bodyPath.addLine(to: CGPoint(x: 16, y: -24))  // Lower right
        bodyPath.addLine(to: CGPoint(x: 0, y: -36))   // Bottom point (drill end)
        bodyPath.addLine(to: CGPoint(x: -16, y: -24)) // Lower left
        bodyPath.addLine(to: CGPoint(x: -16, y: 24))  // Upper left
        bodyPath.closeSubpath()

        bodyNode = SKShapeNode(path: bodyPath)
        bodyNode?.fillColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)  // Cyan-blue
        bodyNode?.strokeColor = UIColor(red: 0.1, green: 0.4, blue: 0.6, alpha: 1.0)  // Darker outline
        bodyNode?.lineWidth = 4
        bodyNode?.zPosition = 0
        bodyNode?.name = "body"
        if let body = bodyNode {
            addChild(body)
        }

        // Top marker - small circle to show "top" of pod
        let topMarker = SKShapeNode(circleOfRadius: 6)
        topMarker.fillColor = .yellow
        topMarker.strokeColor = .orange
        topMarker.lineWidth = 2
        topMarker.position = CGPoint(x: 0, y: 32)  // At the top (positive Y)
        topMarker.zPosition = 1
        addChild(topMarker)

        // Drill indicator - bright triangle showing drill direction
        // Points DOWN by default (negative Y direction)
        let drillPath = CGMutablePath()
        drillPath.move(to: CGPoint(x: 0, y: -10))     // Point towards drilling direction (down)
        drillPath.addLine(to: CGPoint(x: -8, y: 4))   // Left base
        drillPath.addLine(to: CGPoint(x: 8, y: 4))    // Right base
        drillPath.closeSubpath()

        let drillIndicator = SKShapeNode(path: drillPath)
        drillIndicator.fillColor = .red
        drillIndicator.strokeColor = .white
        drillIndicator.lineWidth = 3
        drillIndicator.position = CGPoint(x: 0, y: -36)  // Start at bottom of pod (negative Y)
        drillIndicator.zPosition = 2
        drillIndicator.name = "drillIndicator"
        addChild(drillIndicator)

        // Glow effect around pod (elliptical for narrow shape)
        let glowPath = CGMutablePath()
        glowPath.addEllipse(in: CGRect(x: -28, y: -40, width: 56, height: 80))
        let glow = SKShapeNode(path: glowPath)
        glow.fillColor = .clear
        glow.strokeColor = UIColor.cyan.withAlphaComponent(0.4)
        glow.lineWidth = 4
        glow.glowWidth = 8
        glow.alpha = 0.6
        glow.zPosition = -1
        addChild(glow)

        // Window on the pod (adds character)
        let window = SKShapeNode(circleOfRadius: 8)
        window.fillColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.8)
        window.strokeColor = UIColor(red: 0.1, green: 0.3, blue: 0.5, alpha: 1.0)
        window.lineWidth = 3
        window.position = CGPoint(x: 0, y: 4)
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
        currentThrustIntensity = 0  // Stop exhaust
        updateExhaust()

        // Apply drag when no input, but allow horizontal drift to slide off edges
        guard let physicsBody = physicsBody else { return }
        physicsBody.velocity = CGVector(
            dx: physicsBody.velocity.dx * 0.95,  // Less drag on X to allow sliding
            dy: physicsBody.velocity.dy * drag
        )
    }

    /// Update exhaust particles based on thrust intensity
    func updateExhaust(thrustIntensity: CGFloat = 0) {
        currentThrustIntensity = thrustIntensity
        guard let emitter = exhaustEmitter else { return }

        if thrustIntensity > 0 {
            // Calculate birth rate based on thrust (0-100 particles/sec)
            let birthRate = thrustIntensity * 150  // 0-150 particles per second
            emitter.particleBirthRate = birthRate

            // Adjust particle speed based on thrust
            emitter.particleSpeed = 80 + (thrustIntensity * 80)  // 80-160

            // More intense thrust = brighter, faster particles
            if thrustIntensity > 0.7 {
                // High thrust: blue-white hot flame
                emitter.particleColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
            } else if thrustIntensity > 0.4 {
                // Medium thrust: yellow-orange
                emitter.particleColor = UIColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
            } else {
                // Low thrust: orange-red
                emitter.particleColor = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
            }
        } else {
            // No thrust - stop particles
            emitter.particleBirthRate = 0
        }
    }

    /// Apply minimal friction when not thrusting (allows sliding off edges)
    func applyEdgePhysics() {
        guard let physicsBody = physicsBody else { return }
        // Very low friction when not actively thrusting
        physicsBody.friction = 0.1
    }

    /// Apply normal friction when thrusting (more control)
    func applyActivePhysics() {
        guard let physicsBody = physicsBody else { return }
        physicsBody.friction = 0.4
    }

    // MARK: - Visual Upgrades

    /// Update pod visuals based on upgrade levels
    func updateUpgrades(drillLevel: Int, hullLevel: Int, engineLevel: Int, fuelLevel: Int = 1, cargoLevel: Int = 1) {
        // Only update if levels actually changed
        let needsUpdate = drillLevel != drillStrengthLevel ||
                         hullLevel != hullArmorLevel ||
                         engineLevel != engineSpeedLevel ||
                         fuelLevel != fuelTankLevel ||
                         cargoLevel != self.cargoLevel

        guard needsUpdate else { return }

        drillStrengthLevel = drillLevel
        hullArmorLevel = hullLevel
        engineSpeedLevel = engineLevel
        fuelTankLevel = fuelLevel
        self.cargoLevel = cargoLevel

        updateDrillVisuals()
        updateHullVisuals()
        updateEngineVisuals()
        updateFuelTankVisuals()
        updateCargoVisuals()
    }

    /// Force update pod visuals without checking if levels changed (for preview/showcase)
    func forceUpdateUpgrades(drillLevel: Int, hullLevel: Int, engineLevel: Int, fuelLevel: Int = 1, cargoLevel: Int = 1) {
        drillStrengthLevel = drillLevel
        hullArmorLevel = hullLevel
        engineSpeedLevel = engineLevel
        fuelTankLevel = fuelLevel
        self.cargoLevel = cargoLevel

        updateDrillVisuals()
        updateHullVisuals()
        updateEngineVisuals()
        updateFuelTankVisuals()
        updateCargoVisuals()
    }

    private func updateDrillVisuals() {
        // Remove old drill bits
        drillBits.forEach { $0.removeFromParent() }
        drillBits.removeAll()

        // Add drill bits based on level (1-5) - scaled 2x
        switch drillStrengthLevel {
        case 2:
            // Level 2: Small drill bits on sides
            addDrillBit(at: CGPoint(x: -12, y: -32), size: 4)
            addDrillBit(at: CGPoint(x: 12, y: -32), size: 4)

        case 3:
            // Level 3: Larger drill bits
            addDrillBit(at: CGPoint(x: -14, y: -30), size: 6)
            addDrillBit(at: CGPoint(x: 14, y: -30), size: 6)
            addDrillBit(at: CGPoint(x: 0, y: -34), size: 4)

        case 4:
            // Level 4: Reinforced drill with multiple bits
            addDrillBit(at: CGPoint(x: -16, y: -28), size: 6)
            addDrillBit(at: CGPoint(x: 16, y: -28), size: 6)
            addDrillBit(at: CGPoint(x: -8, y: -34), size: 4)
            addDrillBit(at: CGPoint(x: 8, y: -34), size: 4)

        case 5:
            // Level 5: Maximum drill power - glowing bits
            addDrillBit(at: CGPoint(x: -16, y: -26), size: 8, glow: true)
            addDrillBit(at: CGPoint(x: 16, y: -26), size: 8, glow: true)
            addDrillBit(at: CGPoint(x: -10, y: -34), size: 6, glow: true)
            addDrillBit(at: CGPoint(x: 10, y: -34), size: 6, glow: true)
            addDrillBit(at: CGPoint(x: 0, y: -36), size: 6, glow: true)

        default:
            break  // Level 1: No additional drill bits
        }
    }

    private func addDrillBit(at position: CGPoint, size: CGFloat, glow: Bool = false) {
        let bit = SKShapeNode(circleOfRadius: size)
        bit.fillColor = glow ? .yellow : UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        bit.strokeColor = glow ? .orange : UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        bit.lineWidth = 1
        bit.position = position
        bit.zPosition = 2

        if glow {
            bit.glowWidth = 3
        }

        addChild(bit)
        drillBits.append(bit)
    }

    private func updateHullVisuals() {
        // Remove old armor plates
        armorPlates.forEach { $0.removeFromParent() }
        armorPlates.removeAll()

        // Add armor plates based on level (1-6) - scaled 2x
        if hullArmorLevel >= 2 {
            // Level 2+: Side armor strips
            addArmorPlate(at: CGPoint(x: -18, y: 0), width: 4, height: 24)
            addArmorPlate(at: CGPoint(x: 18, y: 0), width: 4, height: 24)
        }

        if hullArmorLevel >= 3 {
            // Level 3+: Top armor
            addArmorPlate(at: CGPoint(x: 0, y: 28), width: 16, height: 4)
        }

        if hullArmorLevel >= 4 {
            // Level 4+: Bottom armor
            addArmorPlate(at: CGPoint(x: 0, y: -20), width: 12, height: 4)
        }

        if hullArmorLevel >= 5 {
            // Level 5+: Reinforced corners
            addArmorPlate(at: CGPoint(x: -14, y: 20), width: 6, height: 6)
            addArmorPlate(at: CGPoint(x: 14, y: 20), width: 6, height: 6)
        }

        if hullArmorLevel >= 6 {
            // Level 6: Heavy plating with metallic sheen
            bodyNode?.strokeColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            bodyNode?.lineWidth = 6
        }
    }

    private func addArmorPlate(at position: CGPoint, width: CGFloat, height: CGFloat) {
        let plate = SKShapeNode(rectOf: CGSize(width: width, height: height))
        plate.fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.8)
        plate.strokeColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        plate.lineWidth = 1
        plate.position = position
        plate.zPosition = 1
        addChild(plate)
        armorPlates.append(plate)
    }

    private func updateEngineVisuals() {
        // Remove old thrusters
        engineThrusters.forEach { $0.removeFromParent() }
        engineThrusters.removeAll()

        // Add engine thrusters based on level (1-5) - scaled 2x
        if engineSpeedLevel >= 2 {
            // Level 2+: Small side thrusters
            addThruster(at: CGPoint(x: -14, y: 28), size: 4)
            addThruster(at: CGPoint(x: 14, y: 28), size: 4)
        }

        if engineSpeedLevel >= 3 {
            // Level 3+: Larger thrusters
            addThruster(at: CGPoint(x: -16, y: 30), size: 6, color: UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0))
            addThruster(at: CGPoint(x: 16, y: 30), size: 6, color: UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0))
        }

        if engineSpeedLevel >= 4 {
            // Level 4+: Central booster
            addThruster(at: CGPoint(x: 0, y: 32), size: 6, color: UIColor(red: 0.2, green: 0.9, blue: 1.0, alpha: 1.0))
        }

        if engineSpeedLevel >= 5 {
            // Level 5: Maximum thrust - glowing thrusters
            engineThrusters.forEach { thruster in
                thruster.glowWidth = 8
                thruster.fillColor = UIColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }

    private func addThruster(at position: CGPoint, size: CGFloat, color: UIColor = UIColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 1.0)) {
        let thruster = SKShapeNode(circleOfRadius: size)
        thruster.fillColor = color
        thruster.strokeColor = UIColor(red: 0.2, green: 0.5, blue: 0.7, alpha: 1.0)
        thruster.lineWidth = 1
        thruster.position = position
        thruster.zPosition = 1
        addChild(thruster)
        engineThrusters.append(thruster)
    }

    private func updateFuelTankVisuals() {
        // Remove old fuel tanks
        fuelTanks.forEach { $0.removeFromParent() }
        fuelTanks.removeAll()

        // Add external fuel tanks based on level (1-6)
        if fuelTankLevel >= 2 {
            // Level 2+: Small external tanks on sides
            addFuelTank(at: CGPoint(x: -20, y: 10), width: 4, height: 16)
            addFuelTank(at: CGPoint(x: 20, y: 10), width: 4, height: 16)
        }

        if fuelTankLevel >= 3 {
            // Level 3+: Larger tanks
            addFuelTank(at: CGPoint(x: -22, y: 8), width: 5, height: 20)
            addFuelTank(at: CGPoint(x: 22, y: 8), width: 5, height: 20)
        }

        if fuelTankLevel >= 4 {
            // Level 4+: Extended tanks with caps
            addFuelTank(at: CGPoint(x: -24, y: 6), width: 6, height: 24)
            addFuelTank(at: CGPoint(x: 24, y: 6), width: 6, height: 24)
            // Add cap indicators (fuel level indicators)
            addFuelCap(at: CGPoint(x: -24, y: 18))
            addFuelCap(at: CGPoint(x: 24, y: 18))
        }

        if fuelTankLevel >= 5 {
            // Level 5+: Dual tank configuration
            addFuelTank(at: CGPoint(x: -26, y: 12), width: 5, height: 12)
            addFuelTank(at: CGPoint(x: 26, y: 12), width: 5, height: 12)
            addFuelTank(at: CGPoint(x: -26, y: -6), width: 5, height: 12)
            addFuelTank(at: CGPoint(x: 26, y: -6), width: 5, height: 12)
        }

        if fuelTankLevel >= 6 {
            // Level 6: Maximum capacity - glowing tanks with orange fuel color
            fuelTanks.forEach { tank in
                tank.glowWidth = 2
                tank.fillColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.8)
            }
        }
    }

    private func addFuelTank(at position: CGPoint, width: CGFloat, height: CGFloat) {
        let tank = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 2)
        tank.fillColor = UIColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 0.7)  // Orange fuel
        tank.strokeColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)  // Gray metal
        tank.lineWidth = 1
        tank.position = position
        tank.zPosition = 0.5  // Behind armor but above body
        addChild(tank)
        fuelTanks.append(tank)
    }

    private func addFuelCap(at position: CGPoint) {
        let cap = SKShapeNode(circleOfRadius: 2)
        cap.fillColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        cap.strokeColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        cap.lineWidth = 1
        cap.position = position
        cap.zPosition = 1.5
        addChild(cap)
        fuelTanks.append(cap)
    }

    private func updateCargoVisuals() {
        // Remove old cargo pods
        cargoPods.forEach { $0.removeFromParent() }
        cargoPods.removeAll()

        // Add cargo containers based on level (1-6)
        if cargoLevel >= 2 {
            // Level 2+: Small cargo compartments
            addCargoPod(at: CGPoint(x: -18, y: -10), width: 8, height: 8)
            addCargoPod(at: CGPoint(x: 18, y: -10), width: 8, height: 8)
        }

        if cargoLevel >= 3 {
            // Level 3+: Expanded cargo bays
            addCargoPod(at: CGPoint(x: -20, y: -8), width: 10, height: 10)
            addCargoPod(at: CGPoint(x: 20, y: -8), width: 10, height: 10)
        }

        if cargoLevel >= 4 {
            // Level 4+: Large cargo containers
            addCargoPod(at: CGPoint(x: -22, y: -6), width: 12, height: 14)
            addCargoPod(at: CGPoint(x: 22, y: -6), width: 12, height: 14)
            // Add cargo straps/indicators
            addCargoStrap(at: CGPoint(x: -22, y: -2))
            addCargoStrap(at: CGPoint(x: 22, y: -2))
        }

        if cargoLevel >= 5 {
            // Level 5+: Reinforced cargo with multiple compartments
            addCargoPod(at: CGPoint(x: -24, y: 2), width: 10, height: 10)
            addCargoPod(at: CGPoint(x: 24, y: 2), width: 10, height: 10)
            addCargoPod(at: CGPoint(x: -24, y: -14), width: 10, height: 10)
            addCargoPod(at: CGPoint(x: 24, y: -14), width: 10, height: 10)
        }

        if cargoLevel >= 6 {
            // Level 6: Maximum capacity - metallic sheen with golden trim
            cargoPods.forEach { pod in
                pod.strokeColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
                pod.lineWidth = 2
            }
        }
    }

    private func addCargoPod(at position: CGPoint, width: CGFloat, height: CGFloat) {
        let pod = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 2)
        pod.fillColor = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 0.8)  // Brown cargo
        pod.strokeColor = UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0)  // Tan trim
        pod.lineWidth = 1
        pod.position = position
        pod.zPosition = 0.5  // Behind armor but above body
        addChild(pod)
        cargoPods.append(pod)
    }

    private func addCargoStrap(at position: CGPoint) {
        let strap = SKShapeNode(rectOf: CGSize(width: 2, height: 6))
        strap.fillColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        strap.strokeColor = .clear
        strap.position = position
        strap.zPosition = 1.5
        addChild(strap)
        cargoPods.append(strap)
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
                    targetPosition = CGPoint(x: 0, y: -36)  // Bottom of pod (negative Y)
                    targetRotation = 0                       // Points down
                case .left:
                    targetPosition = CGPoint(x: -28, y: 0)  // Left side (narrower)
                    targetRotation = -.pi / 2                // Rotate 90° CCW to point left
                case .right:
                    targetPosition = CGPoint(x: 28, y: 0)   // Right side (narrower)
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
                    y: drillIndicator.position.y + (-36 - drillIndicator.position.y) * 0.3
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
