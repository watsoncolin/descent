---
tags: [descent, vfx, animation]
updated: 2026-06-21
---

# Drill Animation and VFX

Drilling should feel like the pod is **consuming/eating** the terrain, not just bumping a block. The pod physically **descends into the block's space** while a **circular "bite" expands from the center outward**, atomizing the lighter surface layer and revealing the darker excavated layer beneath. Colors and z-ordering come straight from the [[Design System]]; the hosting scene is the `GameScene` god-object described in [[Architecture]].

## Visual Concept

Key mechanics:

1. **Pod movement** — pod starts above the block and descends *into* its position (not hovering above).
2. **Circular consumption** — a circular hole expands from the block center outward, eating the surface layer.
3. **Jagged edge** — the consumption boundary has organic, animated jaggedness (not a perfect circle).
4. **Energy glow** — orange/yellow glow along the edge shows material being vaporized.
5. **Particle stream** — particles flow outward from the drill point.
6. **Layer reveal** — the darker excavated layer is exposed as the surface layer disappears.

## Animation Stages

```
Stage 1 (0-25%):   Pod descends toward block; drill contacts center; small consumption begins
Stage 2 (25-50%):  Pod moves INTO block space; hole expands; heavy particle emission
Stage 3 (50-75%):  Pod halfway through; large jagged void; excavated layer clearly visible
Stage 4 (75-100%): Pod almost through; thin outer ring remains; final consumption burst
Stage 5 (100%):    Pod fully descended; surface layer gone; excavated layer revealed; ready to continue
```

## Data Structures

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
    case sand, stone, rock, marsRock

    var hardness: CGFloat {
        switch self {
        case .sand: return 1.0
        case .stone: return 1.5
        case .rock: return 2.5
        case .marsRock: return 3.5
        }
    }
}
```

`StrataType` also vends `surfaceColors` and `excavatedColors` — the same hex ramps documented in [[Design System#Terrain Color Ramp]]:

| Strata | Surface | Excavated |
|--------|---------|-----------|
| sand | `#c4a57b`, `#b89a70`, `#a89060` | `#8c7545`, `#7c6535`, `#6c5525` |
| stone | `#6a7a8a`, `#5a6a7a` | `#4a5a6a`, `#3a4a5a` |
| rock | `#7a8090`, `#6a7080` | `#5a6070`, `#4a5060` |
| marsRock | `#b85a40`, `#a04a30` | `#8a3a20`, `#6a2a10` |

## Drilling Loop

Drill time scales with strata hardness and the player's drill level:

```
drillDuration = (0.3 * block.strata.hardness) / player.drillLevel
```

`startDrilling(block:)` stores drill state (`drillStartPosition`, `drillTargetPosition = block.position`, `drillProgress = 0`) and kicks off the pod descent, consumption animation, drill rotation, particle emission, and a hardness-based sound.

Each frame, `updateDrilling(deltaTime:)`:

- Advances `drillProgress += deltaTime / drillDuration`, clamped to `1.0`.
- Lerps the pod's Y from start toward the block (descends *into* it).
- Updates the consumption mask and particle emission rate.
- Applies a subtle wobble: `zRotation = sin(drillProgress * 20) * 0.05 * drillProgress`.
- At `progress >= 1.0`, calls `completeDrilling`.

`completeDrilling(block:)` removes the surface layer, sets `excavatedLayer.alpha = 1.0`, clears its `physicsBody` (now passable), stops particles and drill rotation, resets pod rotation, clears drilling state, and checks for hazards.

## Consumption Mask

The surface layer is "eaten" via an `SKCropNode` whose mask is a growing **jagged circle**:

- Block size `64`; `maxRadius = blockSize * 0.9`; `consumptionRadius = progress * maxRadius`.
- The mask path is built from 16 points around the circle with per-vertex jitter for an organic edge:

```swift
let jitter = sin(angle * 3 + progress * 10) * 0.15 + 1.0
let r = radius * jitter
```

- The surface layer is reparented into the crop node so the masked-out region reveals the excavated layer beneath.
- Above `progress > 0.1`, a glowing edge is added.

## Visual Effects

### Consumption edge glow
A jagged `SKShapeNode` stroked in warm orange (`UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 0.8)`), `lineWidth = 3`, `glowWidth = 10`, at `z = 16`. It pulses (fade 1.0 ↔ 0.6 over 0.2s each) and self-removes after 0.3s.

### Particle stream
Continuous `SKEmitterNode` ("drillingParticles", `z = 17`):
```
particleBirthRate     = 50  (ramps to 50 + progress*150)
particleLifetime      = 0.8 (± 0.3)
particleSize          = 4×4
particleScale         = 1.0 (± 0.5), scaleSpeed -0.5
particleColor         = (r:0.8, g:0.7, b:0.5)  // matches terrain
emissionAngleRange    = 2π (all directions)
particleSpeed         = 80  (± 40; ramps to 80 + progress*100)
yAcceleration         = -50 (slight gravity)
alphaSequence         = [1.0, 0.7, 0.0] at times [0, 0.5, 1.0]
```

### Energy waves
Between `progress` 0.2 and 0.95, up to 3 expanding orange rings radiate from the drill point (`z = 18`), each fading out over 0.2s then self-removing. `waveRadius = waveProgress * 40 + 15`.

### Drill rotation
The pod's `drillNode` spins continuously — `rotate(byAngle: 2π, duration: 0.3)` repeated forever, keyed `"drillRotation"` and removed on completion.

### Sound by hardness
```
hardness 0..<1.5   → drill_soft.wav
hardness 1.5..<2.5 → drill_medium.wav
hardness 2.5...     → drill_hard.wav
```

## Z-Index Layers

```
Excavated Layer:   z = 4
Surface Layer:     z = 5
Consumption Glow:  z = 16
Particles:         z = 17
Energy Waves:      z = 18
Player Pod:        z = 20
```

These sit consistently with the [[Design System]] convention of terrain at `z = 0` and material deposits at `z = 10+`.

## Performance

- **Reuse crop nodes** instead of recreating them every frame.
- **Update the consumption mask at ~30fps** rather than 60 (imperceptible difference).
- **Pool particle emitters** for simultaneous drilling operations.
- **Remove completed effects** immediately to free memory.
- **Texture-atlas particles** to reduce draw calls.

### Alternative: shader-based
For best performance, a fragment shader can discard pixels inside the consumption radius, avoiding crop-node overhead:

```glsl
void main() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(v_tex_coord, center);
    float radius = u_progress * 0.9;
    if (dist < radius) {
        gl_FragColor = vec4(0.0);          // consumed - transparent
    } else {
        gl_FragColor = texture2D(u_texture, v_tex_coord);
    }
}
```

## Testing Notes

Verify: drill levels 1–5 scale time correctly; harder terrain gives more intense feedback; rapid sequential drilling doesn't overlap animations improperly; particle accumulation stays performant; edge cases (screen edges, multiple simultaneous blocks).

## Related

[[Design System]] · [[Architecture]]
