# Consuming Drill Animation - Implementation Guide

## Overview

The drilling animation in DESCENT should feel like the player's pod is **consuming/eating** the terrain block as it drills. The pod physically **descends into the block space** while a **circular "bite" expands from the center outward**, atomizing the surface layer and revealing the darker excavated layer beneath.

---

## Visual Concept

### Key Mechanics
1. **Pod Movement**: Pod starts above block and descends INTO the block's position (not just hovering above)
2. **Circular Consumption**: A circular hole expands from the block's center outward, eating away the surface layer
3. **Jagged Edge**: The consumption edge has organic, animated jaggedness (not a perfect circle)
4. **Energy Glow**: Orange/yellow glow along the consumption edge showing material being vaporized
5. **Particle Stream**: Particles flow outward from the drill point as material is consumed
6. **Layer Reveal**: Excavated layer (darker) is revealed underneath as surface layer disappears

### Animation Stages

```
Stage 1 (0-25%):   Pod descends toward block
                   Drill makes contact at center
                   Small circular consumption begins

Stage 2 (25-50%):  Pod moves INTO block space
                   Circular hole expands outward
                   Material consumed continuously
                   Heavy particle emission

Stage 3 (50-75%):  Pod halfway through block
                   Large circular void with jagged edges
                   Most of surface layer consumed
                   Excavated layer clearly visible

Stage 4 (75-100%): Pod almost through
                   Only thin outer ring of surface remains
                   Final consumption burst

Stage 5 (100%):    Pod fully descended into block position
                   Surface layer completely gone
                   Excavated layer fully revealed
                   Pod ready to continue downward
```

---

## Swift/SpriteKit Implementation

### Data Structures

```swift
struct TerrainBlock {
    var position: CGPoint
    var strata: StrataType
    var surfaceLayer: SKSpriteNode?
    var excavatedLayer: SKSpriteNode
    var materialDeposits: [MaterialDeposit]
    var isFullyMined: Bool = false
    
    // Consumption state
    var consumptionProgress: CGFloat = 0.0
    var consumptionMask: SKShapeNode?
}

enum StrataType {
    case sand
    case stone
    case rock
    case marsRock
    
    var hardness: CGFloat {
        switch self {
        case .sand: return 1.0
        case .stone: return 1.5
        case .rock: return 2.5
        case .marsRock: return 3.5
        }
    }
    
    var surfaceColors: [UIColor] {
        switch self {
        case .sand: return [
            UIColor(hex: "#c4a57b"),
            UIColor(hex: "#b89a70"),
            UIColor(hex: "#a89060")
        ]
        case .stone: return [
            UIColor(hex: "#6a7a8a"),
            UIColor(hex: "#5a6a7a")
        ]
        case .rock: return [
            UIColor(hex: "#7a8090"),
            UIColor(hex: "#6a7080")
        ]
        case .marsRock: return [
            UIColor(hex: "#b85a40"),
            UIColor(hex: "#a04a30")
        ]
        }
    }
    
    var excavatedColors: [UIColor] {
        switch self {
        case .sand: return [
            UIColor(hex: "#8c7545"),
            UIColor(hex: "#7c6535"),
            UIColor(hex: "#6c5525")
        ]
        case .stone: return [
            UIColor(hex: "#4a5a6a"),
            UIColor(hex: "#3a4a5a")
        ]
        case .rock: return [
            UIColor(hex: "#5a6070"),
            UIColor(hex: "#4a5060")
        ]
        case .marsRock: return [
            UIColor(hex: "#8a3a20"),
            UIColor(hex: "#6a2a10")
        ]
        }
    }
}
```

### Core Drilling Function

```swift
class GameScene: SKScene {
    var playerPod: PlayerPod!
    var currentDrillingBlock: TerrainBlock?
    var drillStartPosition: CGPoint = .zero
    var drillTargetPosition: CGPoint = .zero
    var drillProgress: CGFloat = 0.0
    var drillDuration: TimeInterval = 0.0
    
    /// Initiate drilling animation on a terrain block
    func startDrilling(block: TerrainBlock) {
        guard let player = playerPod else { return }
        
        // Calculate drill time based on hardness and drill level
        drillDuration = (0.3 * block.strata.hardness) / player.drillLevel
        
        // Store drilling state
        currentDrillingBlock = block
        drillStartPosition = player.position
        drillTargetPosition = CGPoint(
            x: block.position.x,
            y: block.position.y // Pod will move INTO the block position
        )
        drillProgress = 0.0
        
        // Start animations
        startPodDescentAnimation()
        startConsumptionAnimation(block: block)
        startDrillRotation()
        startParticleEmission(at: block.position)
        playSoundEffect(for: block.strata)
    }
    
    /// Update drilling progress each frame
    func updateDrilling(deltaTime: TimeInterval) {
        guard var block = currentDrillingBlock else { return }
        
        // Update progress (0.0 to 1.0)
        drillProgress += CGFloat(deltaTime / drillDuration)
        drillProgress = min(1.0, drillProgress)
        
        // Update pod position (descend into block)
        let newY = drillStartPosition.y + (drillTargetPosition.y - drillStartPosition.y) * drillProgress
        playerPod.position.y = newY
        
        // Update consumption visual
        updateConsumptionMask(block: &block, progress: drillProgress)
        
        // Update particle emission rate based on progress
        updateParticleEmission(progress: drillProgress)
        
        // Apply slight wobble to pod
        let wobble = sin(drillProgress * 20) * 0.05 * drillProgress
        playerPod.zRotation = wobble
        
        // Check if drilling complete
        if drillProgress >= 1.0 {
            completeDrilling(block: block)
        }
    }
    
    /// Complete the drilling action
    func completeDrilling(block: TerrainBlock) {
        // Remove surface layer completely
        block.surfaceLayer?.removeFromParent()
        
        // Excavated layer is now fully visible
        block.excavatedLayer.alpha = 1.0
        
        // Update collision (block is now mined)
        block.excavatedLayer.physicsBody = nil
        
        // Stop animations
        stopParticleEmission()
        stopDrillRotation()
        
        // Reset pod rotation
        playerPod.zRotation = 0
        
        // Clear drilling state
        currentDrillingBlock = nil
        
        // Trigger hazards if any
        checkHazards(in: block)
    }
}
```

### Consumption Mask Implementation

```swift
extension GameScene {
    /// Create and update the consumption mask that "eats" the surface layer
    func updateConsumptionMask(block: inout TerrainBlock, progress: CGFloat) {
        guard let surfaceLayer = block.surfaceLayer else { return }
        
        // Remove old mask if exists
        block.consumptionMask?.removeFromParent()
        
        // Calculate consumption radius (expands from center)
        let blockSize: CGFloat = 64
        let maxRadius = blockSize * 0.9 // Slightly less than full block
        let consumptionRadius = progress * maxRadius
        
        // Create jagged consumption path
        let consumptionPath = createJaggedCirclePath(
            center: block.position,
            radius: consumptionRadius,
            progress: progress
        )
        
        // Create mask shape
        let maskShape = SKShapeNode(path: consumptionPath)
        maskShape.fillColor = .black
        maskShape.strokeColor = .clear
        maskShape.lineWidth = 0
        
        // Apply mask to surface layer using crop node
        let cropNode = SKCropNode()
        cropNode.maskNode = maskShape
        cropNode.zPosition = surfaceLayer.zPosition
        
        // Move surface layer into crop node
        if let parent = surfaceLayer.parent {
            surfaceLayer.removeFromParent()
            cropNode.addChild(surfaceLayer)
            surfaceLayer.position = .zero
            parent.addChild(cropNode)
        }
        
        block.consumptionMask = maskShape
        
        // Add glowing edge effect
        if progress > 0.1 {
            addConsumptionEdgeGlow(path: consumptionPath, at: block.position)
        }
    }
    
    /// Create jagged circular path for organic consumption edge
    func createJaggedCirclePath(center: CGPoint, radius: CGFloat, progress: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let numPoints = 16
        
        for i in 0...numPoints {
            let angle = (CGFloat(i) / CGFloat(numPoints)) * .pi * 2
            
            // Add jitter for organic edge
            let jitter = sin(angle * 3 + progress * 10) * 0.15 + 1.0
            let r = radius * jitter
            
            let x = center.x + cos(angle) * r
            let y = center.y + sin(angle) * r
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.close()
        return path.cgPath
    }
    
    /// Add glowing orange edge along consumption boundary
    func addConsumptionEdgeGlow(path: CGPath, at position: CGPoint) {
        let glowNode = SKShapeNode(path: path)
        glowNode.strokeColor = UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 0.8)
        glowNode.lineWidth = 3
        glowNode.fillColor = .clear
        glowNode.glowWidth = 10
        glowNode.zPosition = 16 // Above terrain, below particles
        glowNode.name = "consumptionGlow"
        
        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ])
        glowNode.run(SKAction.repeatForever(pulse))
        
        addChild(glowNode)
        
        // Remove after a short time
        let remove = SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.removeFromParent()
        ])
        glowNode.run(remove)
    }
}
```

### Particle System

```swift
extension GameScene {
    /// Start particle emission during drilling
    func startParticleEmission(at position: CGPoint) {
        let particles = SKEmitterNode()
        particles.particleTexture = SKTexture(imageNamed: "particle")
        particles.position = position
        particles.zPosition = 17
        particles.name = "drillingParticles"
        
        // Particle properties
        particles.particleBirthRate = 50
        particles.numParticlesToEmit = 0 // Continuous
        particles.particleLifetime = 0.8
        particles.particleLifetimeRange = 0.3
        
        // Appearance
        particles.particleSize = CGSize(width: 4, height: 4)
        particles.particleScale = 1.0
        particles.particleScaleRange = 0.5
        particles.particleScaleSpeed = -0.5
        
        // Color (matches terrain being drilled)
        particles.particleColorSequence = nil
        particles.particleColorBlendFactor = 1.0
        particles.particleColor = .init(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0)
        particles.particleColorBlendFactorSequence = nil
        particles.particleAlphaSequence = createAlphaSequence()
        
        // Movement
        particles.emissionAngle = 0
        particles.emissionAngleRange = .pi * 2 // All directions
        particles.particleSpeed = 80
        particles.particleSpeedRange = 40
        
        // Physics
        particles.particlePositionRange = CGVector(dx: 10, dy: 10)
        particles.xAcceleration = 0
        particles.yAcceleration = -50 // Slight gravity
        
        addChild(particles)
    }
    
    func updateParticleEmission(progress: CGFloat) {
        guard let particles = childNode(withName: "drillingParticles") as? SKEmitterNode else { return }
        
        // Increase emission rate as drilling progresses
        particles.particleBirthRate = 50 + (progress * 150)
        particles.particleSpeed = 80 + (progress * 100)
    }
    
    func stopParticleEmission() {
        childNode(withName: "drillingParticles")?.removeFromParent()
    }
    
    func createAlphaSequence() -> SKKeyframeSequence {
        let times: [NSNumber] = [0, 0.5, 1.0]
        let alphas: [NSNumber] = [1.0, 0.7, 0.0]
        return SKKeyframeSequence(keyframeValues: alphas, times: times)
    }
}
```

### Energy Wave Effect

```swift
extension GameScene {
    /// Create radiating energy waves during consumption
    func addEnergyWaves(at position: CGPoint, progress: CGFloat) {
        guard progress > 0.2 && progress < 0.95 else { return }
        
        for i in 0..<3 {
            let waveProgress = (progress * 3 + CGFloat(i) * 0.3).truncatingRemainder(dividingBy: 1.0)
            let alpha = max(0, 1 - waveProgress * 2) * 0.4
            
            if alpha > 0.05 {
                let waveRadius = waveProgress * 40 + 15
                
                let waveCircle = SKShapeNode(circleOfRadius: waveRadius)
                waveCircle.position = position
                waveCircle.strokeColor = UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: alpha)
                waveCircle.lineWidth = 2
                waveCircle.fillColor = .clear
                waveCircle.zPosition = 18
                
                addChild(waveCircle)
                
                // Fade out and remove
                let fadeOut = SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.removeFromParent()
                ])
                waveCircle.run(fadeOut)
            }
        }
    }
}
```

### Drill Rotation Animation

```swift
extension GameScene {
    func startDrillRotation() {
        let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 0.3)
        let repeatRotate = SKAction.repeatForever(rotateAction)
        playerPod.drillNode?.run(repeatRotate, withKey: "drillRotation")
    }
    
    func stopDrillRotation() {
        playerPod.drillNode?.removeAction(forKey: "drillRotation")
        playerPod.drillNode?.zRotation = 0
    }
}
```

### Sound Effects

```swift
extension GameScene {
    func playSoundEffect(for strata: StrataType) {
        let soundName: String
        
        switch strata.hardness {
        case 0..<1.5:
            soundName = "drill_soft.wav"
        case 1.5..<2.5:
            soundName = "drill_medium.wav"
        case 2.5...:
            soundName = "drill_hard.wav"
        default:
            soundName = "drill_medium.wav"
        }
        
        let sound = SKAction.playSoundFileNamed(soundName, waitForCompletion: false)
        run(sound)
    }
}
```

---

## Implementation Checklist

### Core System
- [ ] Create dual-layer terrain blocks (surface + excavated)
- [ ] Implement drill time calculation: `0.3 * hardness / drillLevel`
- [ ] Add pod descent animation (moves into block position)
- [ ] Create consumption mask system (circular expanding hole)
- [ ] Add jagged edge generation for organic feel

### Visual Effects
- [ ] Implement orange glow along consumption edge
- [ ] Create particle emitter for consumed material
- [ ] Add energy wave rings radiating from drill point
- [ ] Implement drill bit rotation animation
- [ ] Add pod wobble during drilling
- [ ] Create screen shake for hard terrain (optional)

### Performance
- [ ] Use SKCropNode for efficient masking
- [ ] Pool particle emitters for reuse
- [ ] Remove old consumption glow nodes
- [ ] Limit active particle count
- [ ] Update only visible drilling animations

### Sound Design
- [ ] Add drill contact sound (start)
- [ ] Add continuous grinding sound (varies by hardness)
- [ ] Add consumption/vaporization sound
- [ ] Add completion "break through" sound
- [ ] Adjust pitch/volume based on terrain hardness

---

## Technical Considerations

### Z-Index Layers
```
Excavated Layer:        z = 4
Surface Layer:          z = 5
Consumption Glow:       z = 16
Particles:              z = 17
Energy Waves:           z = 18
Player Pod:             z = 20
```

### Performance Tips
1. **Reuse crop nodes** instead of creating new ones each frame
2. **Update consumption mask** at 30fps instead of 60fps (imperceptible)
3. **Pool particle emitters** for multiple simultaneous drilling operations
4. **Remove completed drilling effects** immediately to free memory
5. **Use texture atlases** for particles to reduce draw calls

### Alternative Approach: Shader-Based

For even better performance, consider using a custom shader:

```swift
// Fragment shader for consumption effect
let consumptionShader = """
void main() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(v_tex_coord, center);
    float radius = u_progress * 0.9;
    
    if (dist < radius) {
        // Consumed area - transparent
        gl_FragColor = vec4(0.0);
    } else {
        // Normal surface rendering
        gl_FragColor = texture2D(u_texture, v_tex_coord);
    }
}
"""
```

---

## Testing Notes

Test the following scenarios:
1. **Different drill levels** (1-5) - ensure time scales correctly
2. **Different terrain hardness** - visual feedback should be more intense for harder terrain
3. **Rapid sequential drilling** - ensure animations don't overlap improperly
4. **Particle accumulation** - verify particles don't cause performance issues
5. **Edge cases** - drilling at screen edges, multiple blocks simultaneously

---

## Example Usage

```swift
// In your game loop
override func update(_ currentTime: TimeInterval) {
    let deltaTime = currentTime - lastUpdateTime
    lastUpdateTime = currentTime
    
    // Update active drilling
    if currentDrillingBlock != nil {
        updateDrilling(deltaTime: deltaTime)
        
        // Add energy waves periodically
        if let block = currentDrillingBlock {
            addEnergyWaves(at: block.position, progress: drillProgress)
        }
    }
}

// When player collides with terrain
func didBegin(_ contact: SKPhysicsContact) {
    if let block = getTerrainBlock(from: contact) {
        if !block.isFullyMined {
            startDrilling(block: block)
        }
    }
}
```

---

## Visual Reference

The key to making this feel right:
- **Pod MOVES into the block** (not just stationary above it)
- **Circular consumption** expands from center outward
- **Jagged, organic edge** on the consumption boundary
- **Particles stream outward** from the drill point
- **Orange/yellow glow** shows material being vaporized
- **Excavated layer revealed** as surface is consumed

This creates the visceral feeling of the pod "eating" through the terrain rather than just breaking it.
