# DESCENT Design System

**Version:** 1.0  
**Last Updated:** October 2025  
**Platform:** iOS (SpriteKit)

---

## 🌊 Terrain-Material Interaction

### Visual Hierarchy

```
Material Deposits (Layer 10+)
    ↑ embedded at grid positions
    ↑ stand out with glow
    ↑ removed when collected
    ↑
Surface Terrain (Layer 5)
    ↓ lighter, visible by default
    ↓ continuous flow
    ↓ "cut away" when mined
    ↓
Excavated Terrain (Layer 4)
    ↑ darker (~35-45%)
    ↑ revealed when surface removed
    ↑ same material type
    ↑ shows depth/progress
    
```

### Mining Reveals Excavated Layer

**Visual Effect:**

```
BEFORE MINING (Sand strata):
┌────────────────────────────┐
│ ░░░░░ Light Sand ░░░░░░░░░ │  Surface texture
│ ░░░[M]░░░░░[M]░░░░░░░░░░░░ │  Materials embedded
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░ │
└────────────────────────────┘

AFTER MINING:
┌────────────────────────────┐
│ ░░░░░ Light Sand ░░░░░░░░░ │  Surface remains
│ ░░▓▓▓░░░░░▓▓▓░░░░░░░░░░░░ │  Excavated areas (darker)
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░ │  Material collected
└────────────────────────────┘
   ░ = Surface sand (#c4a57b)
   ▓ = Excavated sand (#8c7545) ~35% darker
```

**Geological Realism:**

- Mining sand reveals **compacted sand** underneath
- Mining stone reveals **dense bedrock** underneath
- Mining rock reveals **deep metamorphic rock** underneath
- Mining mars rock reveals **ancient planetary core** underneath

**Not** revealing a different material type entirely!

### Contrast Requirements

**Surface vs Excavated:**

- Sand strata: ~35% darker
- Stone strata: ~40% darker
- Rock strata: ~35% darker
- Mars rock strata: ~45% darker (approaching void)

**Material vs Terrain:**

- Common materials: 30%+ contrast with surface terrain
- Rare materials: 50%+ contrast with surface terrain
- Glow must be visible against both surface and excavated terrain

### Blending Guidelines

**Terrain Continuity:**

- Base gradient spans entire strata (no block boundaries)
- Color variations flow across 3-5 blocks minimum
- Both surface and excavated layers have same variation patterns
- Flow patterns diagonal (15-40° angles)
- Texture details span multiple blocks horizontally

**Material Embedding:**

- Deposits positioned at grid centers (64x64 grid)
- Outer glow extends 1.5x deposit size
- Glow blends with both surface and excavated terrain
- Core deposit maintains full opacity
- Size variation (small/medium/large) for visual interest

**Excavation Feedback:**

- Mined blocks show excavated texture (darker shade)
- Optional: subtle edge glow at excavation boundary
- Maintains continuous feel (no hard edges)
- Clear progress indication (darker = mined)

### Mining Interaction Sequence

When a block is mined:

1. **Material deposit** removed (if present) → collected by player
2. **Surface texture** "cut away" at that grid position (64x64 window)
3. **Excavated texture** revealed underneath (darker version)
4. **Collision grid** updated (block is now passable)
5. **Optional edge effect** subtle glow on cut boundary

Result: Natural "digging deeper" appearance within same geological layer

---

## 🎨 Terrain Generation Patterns

### Organic Variation Placement

```swift
// Generate large organic variations that span multiple blocks
func generateOrganicVariations(
    layerSize: CGSize,
    terrainType: TerrainType
) -> [SKNode] {
    var variations: [SKNode] = []
    let variationCount = 3...6

    for _ in 0..<Int.random(in: variationCount) {
        let variation = SKShapeNode(
            ellipseOf: CGSize(
                width: CGFloat.random(in: 80...130),
                height: CGFloat.random(in: 60...110)
            )
        )

        // Random position across entire layer
        variation.position = CGPoint(
            x: CGFloat.random(in: 0...layerSize.width),
            y: CGFloat.random(in: 0...layerSize.height)
        )

        variation.fillColor = terrainType.variationColor
        variation.alpha = CGFloat.random(in: 0.08...0.18)
        variation.zPosition = 1

        variations.append(variation)
    }

    return variations
}
```

### Flow Pattern Generation

```swift
// Create diagonal stratification flow
func generateFlowPattern(
    layerSize: CGSize,
    terrainType: TerrainType
) -> SKNode {
    let flowNode = SKNode()
    let angle = CGFloat.random(in: 15...40)

    // Create multiple flowing lines
    for i in 0..<5 {
        let path = CGMutablePath()
        let startY = layerSize.height * CGFloat(i) / 5

        path.move(to: CGPoint(x: 0, y: startY))

        // Organic curve across layer
        path.addQuadCurve(
            to: CGPoint(x: layerSize.width, y: startY + 20),
            control: CGPoint(
                x: layerSize.width / 2,
                y: startY + CGFloat.random(in: -10...10)
            )
        )

        let line = SKShapeNode(path: path)
        line.strokeColor = terrainType.flowColor
        line.lineWidth = 1
        line.alpha = 0.08

        flowNode.addChild(line)
    }

    return flowNode
}
```

### Material Distribution

```swift
// Distribute materials across grid with natural clustering
func distributeMaterials(
    gridSize: (width: Int, height: Int),
    material: MaterialType,
    frequency: ClosedRange<Int>
) -> [CGPoint] {
    var positions: [CGPoint] = []
    let totalBlocks = gridSize.width * gridSize.height
    let targetCount = Int(Double(totalBlocks) * Double.random(in: Double(frequency.lowerBound)...Double(frequency.upperBound)) / 100.0)

    // Create clusters for more natural distribution
    let clusterCount = 3...5

    for _ in 0..<Int.random(in: clusterCount) {
        let clusterCenter = CGPoint(
            x: CGFloat.random(in: 0...CGFloat(gridSize.width)),
            y: CGFloat.random(in: 0...CGFloat(gridSize.height))
        )

        let clusterSize = targetCount / Int.random(in: clusterCount)

        for _ in 0..<clusterSize {
            // Add position near cluster center
            let offset = CGPoint(
                x: CGFloat.random(in: -3...3),
                y: CGFloat.random(in: -3...3)
            )

            let gridPos = CGPoint(
                x: (clusterCenter.x + offset.x).clamped(to: 0...CGFloat(gridSize.width - 1)),
                y: (clusterCenter.y + offset.y).clamped(to: 0...CGFloat(gridSize.height - 1))
            )

            // Convert grid position to pixel position (center of block)
            let pixelPos = CGPoint(
                x: gridPos.x * 64 + 32,
                y: gridPos.y * 64 + 32
            )

            positions.append(pixelPos)
        }
    }

    return positions
}
```

---

## 🎨 Overview

DESCENT uses a modern sci-fi aesthetic with smooth gradients, atmospheric glows, and layered transparency. The visual style emphasizes **continuous geological terrain with embedded resource deposits**, creating an immersive planetary descent experience that feels organic and natural while maintaining clear grid-based gameplay.

### Core Principles

1. **Continuous over Discrete** - Terrain flows as unified geological layers, not individual blocks
2. **Embedded Resources** - Materials appear as natural deposits within terrain, not separate blocks
3. **Depth through Layers** - Build visual complexity with semi-transparent overlays spanning multiple blocks
4. **Organic Flow** - Large-scale color variations and diagonal stratification patterns
5. **Clear Contrast** - Materials stand out from terrain through glow and color differentiation
6. **Atmospheric Effects** - Add glows, halos, and soft shadows for depth
7. **Consistent Lighting** - Light source from top-left for all elements
8. **Grid-Based Gameplay** - Visual continuity doesn't sacrifice gameplay precision

### Visual Design Philosophy

**Traditional Block-Based Games:**

```
┌────┬────┬────┬────┐
│ █  │ █  │    │ █  │  ← Individual textured blocks
├────┼────┼────┼────┤
│ █  │    │ █  │    │  ← Visible grid lines
├────┼────┼────┼────┤
│    │ █  │ █  │ █  │  ← Each block is separate
└────┴────┴────┴────┘
```

**DESCENT Approach:**

```
┌─────────────────────┐
│ ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈ │  ← Continuous flowing terrain
│ ≈≈≈[M]≈≈≈≈[M]≈≈≈≈≈ │  ← Materials embedded in terrain
│ ≈≈≈≈≈≈≈[M]≈≈≈≈[M]≈ │  ← No visible block boundaries
│ ≈≈≈≈[M]≈≈≈≈≈≈≈≈≈≈ │  ← Organic, natural appearance
└─────────────────────┘
     [M] = Material Deposit
```

**Key Differences:**

- **Terrain:** One continuous surface vs. many separate blocks
- **Materials:** Deposits within terrain vs. colored blocks
- **Boundaries:** Invisible gameplay grid vs. visible block edges
- **Flow:** Natural geological layers vs. brick-like structure
- **Scale:** Large organic variations vs. per-block textures
- **Feel:** Mining deposits from rock vs. breaking colored blocks

This creates a more **immersive mining experience** where you're excavating natural resources from geological formations rather than collecting colored tiles.

---

## 🎨 Color Palette

### Primary Colors

#### Space/UI Colors

```
Deep Space Blue     #2a7fbf
Bright Blue         #4db8ff
Light Blue          #6dd5ff
Cyan Highlight      #9ef4ff
```

#### Background Colors

```
Deep Space Dark     #0a0e27
Space Medium        #1a1f3a
Space Dark          #0f1123
Ocean Deep          #1a3d5c
```

#### Accent Colors

```
White Highlight     #ffffff (30-80% opacity)
Pure White          #ffffff (100% for text)
```

### Material Colors

#### Common Materials

```
Rock Gray           #5a6a7a
Rock Dark           #3a4a5a
Rock Mid            #4a5a6a
Stone Blue-Gray     #4a5a6a
```

#### Metallic Materials

```
Iron Light          #7a8a9a
Iron Dark           #6a7a8a
Steel Gray          #8a9aaa
Metal Shine         #9aaaba
```

#### Crystal/Rare Materials

```
Crystal Bright      #6dd5ff
Crystal Core        #4db8ff
Crystal Glow        #2a7fbf
Gem Shine           #ffffff (50% opacity)
```

#### Planetary Surface

```
Mars Red            #e85d3a
Mars Orange         #c44228
Mars Brown          #a03520
Mars Dark           #8a2a18
Crater Shadow       #6a1a10
```

#### Energy/Effects

```
Thruster Yellow     #ffdd57
Flame Orange        #ff9d3a
Fire Red            #ff6b35
Energy White        #ffffff (60% opacity)
```

---

## 📐 Visual Techniques

### 1. Gradients

Replace all solid colors with gradients for depth and volume.

#### Linear Gradients

```xml
<!-- Vertical (Top to Bottom) - For lighting -->
<linearGradient id="verticalLight" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" style="stop-color:#4a5a6a" />
  <stop offset="100%" style="stop-color:#2a3a4a" />
</linearGradient>

<!-- Horizontal - For volume -->
<linearGradient id="horizontalVolume" x1="0%" y1="0%" x2="100%" y2="0%">
  <stop offset="0%" style="stop-color:#3a4a5a" />
  <stop offset="50%" style="stop-color:#4a5a6a" />
  <stop offset="100%" style="stop-color:#3a4a5a" />
</linearGradient>

<!-- Diagonal - For dynamic lighting -->
<linearGradient id="diagonalLight" x1="0%" y1="0%" x2="100%" y2="100%">
  <stop offset="0%" style="stop-color:#5a6a7a" />
  <stop offset="100%" style="stop-color:#2a3a4a" />
</linearGradient>
```

#### Radial Gradients

```xml
<!-- For glows and energy effects -->
<radialGradient id="glowEffect" cx="50%" cy="50%" r="50%">
  <stop offset="0%" style="stop-color:#6dd5ff;stop-opacity:0.8" />
  <stop offset="50%" style="stop-color:#4db8ff;stop-opacity:0.4" />
  <stop offset="100%" style="stop-color:#2a7fbf;stop-opacity:0" />
</radialGradient>
```

### 2. Glow Effects

Add atmospheric depth with multiple glow layers.

```xml
<!-- SVG Filter Definition -->
<filter id="softGlow">
  <feGaussianBlur stdDeviation="4" result="coloredBlur"/>
  <feMerge>
    <feMergeNode in="coloredBlur"/>
    <feMergeNode in="SourceGraphic"/>
  </feMerge>
</filter>

<!-- Usage -->
<circle cx="50" cy="50" r="20" fill="#4db8ff" filter="url(#softGlow)"/>
```

#### Glow Intensity by Material Type

- **Common:** 10-20% opacity, small blur (stdDeviation: 2-3)
- **Uncommon:** 30-40% opacity, medium blur (stdDeviation: 3-4)
- **Rare:** 50-80% opacity, large blur (stdDeviation: 4-6)
- **Energy:** 70-90% opacity, intense blur (stdDeviation: 5-8)

### 3. Layering & Depth

Build each element with 3-5 layers for visual complexity.

```
Layer 5: Outer Glow        (20-40% opacity, radial fade)
Layer 4: Edge Lighting     (thin lines, 50% opacity)
Layer 3: Highlight         (30-50% opacity, top-left)
Layer 2: Main Body         (100% opacity, gradient fill)
Layer 1: Shadow Base       (dark, 100% opacity)
```

### 4. Continuous Terrain Flow

Create organic, flowing terrain that spans multiple blocks seamlessly.

```xml
<!-- Base terrain gradient (spans entire layer) -->
<linearGradient id="sandTerrain" x1="0%" y1="0%" x2="0%" y2="100%">
  <stop offset="0%" style="stop-color:#c4a57b" />
  <stop offset="30%" style="stop-color:#b89a70" />
  <stop offset="60%" style="stop-color:#a89060" />
  <stop offset="100%" style="stop-color:#9c8555" />
</linearGradient>

<!-- Large organic variations (80-120px radius, span 3-5 blocks) -->
<ellipse cx="random" cy="random" rx="100" ry="80"
         fill="#9a8050" opacity="0.12"/>

<!-- Diagonal stratification flow -->
<linearGradient id="flowPattern" x1="0%" y1="0%" x2="100%" y2="100%">
  <stop offset="0%" style="stop-color:lighterShade" opacity="0.3" />
  <stop offset="50%" style="stop-color:baseShade" opacity="0.2" />
  <stop offset="100%" style="stop-color:darkerShade" opacity="0.3" />
</linearGradient>

<!-- Organic texture lines (flow horizontally across blocks) -->
<path d="M 0,y Q midX,y+variation endX,y"
      stroke="terrainColor" stroke-width="1"
      opacity="0.08" fill="none"/>
```

### 5. Material Deposits (Embedded in Terrain)

Materials appear as discrete deposits within continuous terrain.

```xml
<!-- Material deposit at grid position -->
<g transform="translate(gridX, gridY)">
  <!-- Outer glow (blends with terrain) -->
  <ellipse cx="0" cy="0" rx="glowRadius" ry="glowRadius"
           fill="url(#materialGlow)" opacity="0.5"/>

  <!-- Core deposit -->
  <ellipse cx="0" cy="0" rx="coreRadius" ry="coreRadius"
           fill="url(#materialGradient)"/>

  <!-- Internal texture -->
  <ellipse cx="-2" cy="-3" rx="4" ry="5"
           fill="highlightColor" opacity="0.7"/>
</g>
```

### 5. Edge Treatment

All shapes should have rounded corners and soft transitions.

```xml
<!-- Small elements -->
<rect rx="3" ry="3" />

<!-- Medium elements -->
<rect rx="8" ry="8" />

<!-- Large elements -->
<rect rx="15" ry="15" />

<!-- Avoid sharp 90° angles -->
<!-- Use bezier curves for organic shapes -->
```

---

## 🧱 Continuous Terrain Construction

### Design Philosophy

**Terrain flows as continuous geological layers** with dual-texture depth system. Each strata has a **surface texture (lighter)** and an **excavated texture (darker)** - mining reveals the deeper, compacted version of the same material. This creates:

- Geological realism (digging deeper into same material)
- Clear visual feedback (mined areas are darker)
- Depth perception (darker = deeper excavation)
- Cohesive aesthetics (color families stay consistent)

### Dual-Layer Terrain Structure

```
┌─────────────────────────────────────────────────┐
│  SURFACE LAYER (visible, lighter colors)        │
│  ┌───────────────────────────────────────────┐  │
│  │ 3. Organic Flow Patterns (large areas)   │  │
│  │ ┌─────────────────────────────────────┐   │  │
│  │ │ 2. Color Variations (3-5 block span)│   │  │
│  │ │ ┌───────────────────────────────┐   │   │  │
│  │ │ │ 1. Base Gradient (full depth) │   │   │  │
│  │ │ │                               │   │   │  │
│  │ │ │   [Material Deposit]          │   │   │  │
│  │ │ └───────────────────────────────┘   │   │  │
│  │ └─────────────────────────────────────┘   │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘

         ↓ WHEN BLOCK IS MINED ↓

┌─────────────────────────────────────────────────┐
│  SURFACE LAYER (with excavated areas revealed)  │
│  ┌───────────────────────────────────────────┐  │
│  │ Surface texture continues...              │  │
│  │ ┌─────────────────────────────────────┐   │  │
│  │ │ ████ Mined ████  ████ Mined ████  │   │  │
│  │ │ (Excavated    (Excavated         │   │  │
│  │ │  texture      texture shows)     │   │  │
│  │ │  shows ~35%                      │   │  │
│  │ │  darker)                         │   │  │
│  │ └─────────────────────────────────────┘   │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
│  EXCAVATED LAYER (underneath, darker colors)    │
│  (Revealed only where blocks are mined)         │
└─────────────────────────────────────────────────┘
```

### Implementation Template

```swift
// Pseudo-code for dual-layer continuous terrain generation
func createContinuousTerrainStrata(
    terrainType: TerrainType,
    size: CGSize
) -> (surface: SKNode, excavated: SKNode) {

    let surfaceContainer = SKNode()
    let excavatedContainer = SKNode()

    // SURFACE LAYER (lighter, visible by default)
    // 1. Base Continuous Gradient
    let surfaceGradient = createContinuousGradient(
        size: size,
        colors: terrainType.surfaceColors  // Lighter colors
    )
    surfaceGradient.zPosition = 0
    surfaceContainer.addChild(surfaceGradient)

    // 2. Organic Color Variations (span 3-5 blocks)
    let surfaceVariations = createOrganicVariations(
        size: size,
        count: 3-5,
        colors: terrainType.surfaceVariationColors
    )
    surfaceVariations.forEach {
        $0.zPosition = 1
        surfaceContainer.addChild($0)
    }

    // 3. Diagonal Flow Patterns
    let surfaceFlow = createFlowPattern(
        size: size,
        angle: terrainType.flowAngle,
        color: terrainType.surfaceFlowColor
    )
    surfaceFlow.zPosition = 2
    surfaceContainer.addChild(surfaceFlow)

    // EXCAVATED LAYER (darker, revealed when mined)
    // Same structure but ~35-45% darker colors
    let excavatedGradient = createContinuousGradient(
        size: size,
        colors: terrainType.excavatedColors  // Darker colors
    )
    excavatedGradient.zPosition = 0
    excavatedContainer.addChild(excavatedGradient)

    let excavatedVariations = createOrganicVariations(
        size: size,
        count: 3-5,
        colors: terrainType.excavatedVariationColors
    )
    excavatedVariations.forEach {
        $0.zPosition = 1
        excavatedContainer.addChild($0)
    }

    let excavatedFlow = createFlowPattern(
        size: size,
        angle: terrainType.flowAngle,
        color: terrainType.excavatedFlowColor
    )
    excavatedFlow.zPosition = 2
    excavatedContainer.addChild(excavatedFlow)

    // Set z-positions
    surfaceContainer.zPosition = 5  // Above excavated layer
    excavatedContainer.zPosition = 4  // Below surface layer

    return (surface: surfaceContainer, excavated: excavatedContainer)
}

// Mining reveals excavated layer
func removeBlock(at gridPosition: GridCoord) {
    // 1. Remove material deposit if present
    if let material = materialAt(gridPosition) {
        material.removeFromParent()
        collectMaterial(material.type)
    }

    // 2. Create "window" in surface layer to reveal excavated layer beneath
    let revealWindow = SKSpriteNode(
        color: .clear,
        size: CGSize(width: 64, height: 64)
    )
    revealWindow.position = gridToPixel(gridPosition)

    // Use crop node or mask to "cut out" this area from surface layer
    let cropNode = SKCropNode()
    let maskNode = SKShapeNode(rectOf: CGSize(width: 64, height: 64))
    maskNode.fillColor = .white
    maskNode.position = gridToPixel(gridPosition)
    cropNode.maskNode = maskNode

    // This reveals the darker excavated layer underneath
    surfaceLayer.addChild(cropNode)

    // 3. Optional: Add subtle edge highlight where cut was made
    let edgeGlow = SKShapeNode(rectOf: CGSize(width: 64, height: 64))
    edgeGlow.strokeColor = terrainType.accentColor
    edgeGlow.lineWidth = 1
    edgeGlow.alpha = 0.3
    edgeGlow.position = gridToPixel(gridPosition)
    edgeGlow.zPosition = 6
    addChild(edgeGlow)

    // 4. Update collision grid
    collisionGrid[gridPosition.x][gridPosition.y] = .empty
}
```

```

---

## 💎 Terrain Types & Material Deposits

### Terrain Base Types

Terrain creates continuous geological layers that span the entire level width and specific depth ranges. **Each strata has two states: surface (lighter) and excavated (darker)** - mining reveals the deeper, compacted version of the same material.

#### Sand Terrain
```

Surface Colors: #c4a57b → #b89a70 → #a89060 (light tan, warm)
Excavated Colors: #8c7545 → #7c6535 → #6c5525 (darker tan, compacted)
Contrast: ~35% darker
Variations: Large ellipses (80-120px), 10-15% opacity
Flow Pattern: Diagonal (15-30°), subtle color shifts
Texture: Horizontal organic lines, 8% opacity
Appearance: Light beachy sand → Deeper packed sand
Mining Reveals: Darker, compacted sand underneath
Depth Range: 0-640m

```

#### Stone Terrain
```

Surface Colors: #6a7a8a → #5a6a7a (medium gray)
Excavated Colors: #4a5a6a → #3a4a5a (dark gray, dense)
Contrast: ~40% darker
Variations: Medium ellipses (60-90px), 12-18% opacity
Flow Pattern: Diagonal (20-35°), more angular than sand
Texture: Horizontal stratification lines, 10% opacity
Appearance: Fresh stone → Ancient bedrock
Mining Reveals: Deep, dense stone layer
Depth Range: 640-1280m

```

#### Rock Terrain
```

Surface Colors: #7a8090 → #6a7080 (gray-blue)
Excavated Colors: #5a6070 → #4a5060 (deep gray-blue)
Contrast: ~35% darker
Variations: Large irregular shapes (70-110px), 15-20% opacity
Flow Pattern: Mixed angles (15-40°), varied stratification
Texture: Cracked texture patterns, 12% opacity
Appearance: Surface rock → Deep metamorphic rock
Mining Reveals: Ancient, compressed rock formations
Depth Range: 1280-1920m

```

#### Mars Rock Terrain
```

Surface Colors: #b85a40 → #a04a30 (rust red)
Excavated Colors: #8a3a20 → #6a2a10 (deep rust, almost black)
Contrast: ~45% darker (approaching void)
Variations: Large organic shapes (90-130px), 12-18% opacity
Flow Pattern: Wavy, geological upheaval patterns
Texture: Crater-like depressions, dust patterns, 10% opacity
Appearance: Oxidized surface → Ancient planetary core
Mining Reveals: Deep, ancient Martian bedrock
Depth Range: 1920m+

```

---

### Material Deposits (Embedded Resources)

Materials appear as discrete deposits at grid positions within the continuous terrain. Each material has characteristic appearance when embedded in host rock.

#### Coal (Common)
```

Deposit Size: 10-22px radius
Core Colors: #3a3a3a → #2a2a2a → #1a1a1a
Glow: 30-40% opacity, #3a3a3a, subtle
Internal Detail: Dark spots (#2a2a2a, #1a1a1a), 60-70% opacity
Grid Frequency: 50-70% of blocks
Appearance: Dark, matte, organic carbon deposit
Value: 10 credits/unit

```

#### Iron Ore (Uncommon)
```

Deposit Size: 12-20px radius
Core Colors: #9aaaba → #7a8a9a → #6a7a8a
Glow: 40-50% opacity, #9aaaba, metallic sheen
Internal Detail: Bright metallic spots (#9aaaba, #b4c4d4), 70-80% opacity
Grid Frequency: 20-30% of blocks
Appearance: Silvery, metallic, reflective vein
Value: 25 credits/unit

```

#### Copper Ore (Uncommon)
```

Deposit Size: 13-21px radius
Core Colors: #d4956e → #c4754e → #b4653e
Glow: 50-60% opacity, #d4956e, warm glow
Internal Detail: Orange-copper spots (#d4956e, #e4a57e), 70-90% opacity
Grid Frequency: 15-25% of blocks
Appearance: Orange-brown, warm metallic luster
Value: 30 credits/unit

```

#### Crystal/Diamond (Rare)
```

Deposit Size: 16-24px radius
Core Colors: #6dd5ff → #4db8ff → #2a7fbf
Glow: 70-90% opacity, multi-layer (#6dd5ff, #4db8ff), intense
Internal Detail: Faceted highlights, bright white core (#ffffff, 70% opacity)
Special: Animated pulse (0.9-1.1 scale, 2s cycle)
Grid Frequency: 3-8% of blocks
Appearance: Brilliant blue, luminous, crystalline structure
Value: 100 credits/unit

```

#### Gold Ore (Rare)
```

Deposit Size: 14-20px radius
Core Colors: #ffd700 → #f4c430 → #daa520
Glow: 60-80% opacity, #ffd700, golden radiance
Internal Detail: Metallic shine spots (#ffd700, #ffed4e), 80-90% opacity
Special: Subtle shimmer effect
Grid Frequency: 5-10% of blocks
Appearance: Rich golden, highly reflective, precious metal vein
Value: 150 credits/unit

```

---

## 🌍 Planetary Surfaces

### Mars-like Planet
```

Base: #c44228 → #a03520
Craters: #8a2a18 ellipses, 50% opacity
Highlights: #e85d3a ridges, 30% opacity
Atmosphere: #e85d3a glow, 20% opacity, large radius
Details: Random dark spots (#6a1a10, 40% opacity)

```

### Rocky Moon
```

Base: #4a5a6a → #3a4a5a
Craters: Many, various sizes, #2a3a4a
Highlights: Minimal, #5a6a7a edges
Atmosphere: None
Details: High contrast shadows

```

### Crystalline World
```

Base: #2a7fbf → #4db8ff with transparency
Craters: Faceted depressions, bright
Highlights: Intense, #6dd5ff, 70% opacity
Atmosphere: Bright glow, #4db8ff, 60% opacity
Details: Crystalline formations, geometric

```

---

## 🚀 UI Elements

### Pod/Player
```

Body: #2a7fbf → #4db8ff → #2a7fbf (horizontal)
Highlights: #6dd5ff, 50% opacity, top-left
Window: #1a3d5c, 90% opacity
Window Shine: #4db8ff, 60% opacity, small circle
Thrusters: #ffdd57 → #ff9d3a → #ff6b35
Thruster Glow: Intense, animated
Edge: Soft glow, #4db8ff, 40% opacity

```

### HUD Elements
```

Background: #0a0e27, 80% opacity
Border: #4db8ff, 2px, 60% opacity
Text: #6dd5ff for values, white for labels
Icons: #4db8ff with glow
Progress Bars: #2a7fbf → #6dd5ff gradient
Buttons: #1a3d5c bg, #4db8ff border

```

### Particles & Effects
```

Thruster: Yellow-orange gradient, fading
Collision: White flash, rapid fade
Collection: Material color, spiral upward
Landing: Dust cloud, gray with blue tint
Explosion: Orange-red, expanding ring

```

---

## 📏 Sizing & Spacing

### Block Sizes
```

Standard Block: 48x48 points
Large Block: 64x64 points
Small Block: 32x32 points
Particle: 4-12 points

```

### Spacing
```

Block Gap: 2-4 points
UI Padding: 16 points
Element Margin: 8 points
Text Line: 1.2x font size

```

### Corner Radius
```

Small (< 32pt): 3-4 points
Medium (32-64): 6-8 points
Large (> 64): 10-15 points
Buttons: 8-12 points
Containers: 12-16 points

```

---

## 💡 Lighting Model

### Light Source
Position: **Top-Left** (45° angle)

### Surface Lighting
```

Top Face: Base color + 20% brightness
Left Face: Base color + 10% brightness
Center: Base color (100%)
Right Face: Base color - 10% brightness
Bottom Face: Base color - 20% brightness

```

### Shadows
```

Position: Below and right of object
Shape: Ellipse, 80% of object width
Color: Black or very dark base color
Opacity: 15-25%
Blur: Soft edge, 2-4 point blur

```

### Specular Highlights
```

Position: Top-left corner
Shape: Small ellipse or circle
Color: White
Opacity: 30-60% (higher for shiny materials)
Size: 10-20% of object size

```

---

## 🎬 Animation Guidelines

### Material Animations

#### Idle States
```

Common: None or very subtle drift
Uncommon: Gentle pulse (0.95-1.05, 3s)
Rare: Noticeable pulse (0.9-1.1, 2s)
Crystal: Rotate glow (360°, 4s)
Energy: Flicker (opacity 0.8-1.0, 0.3-0.6s random)

```

#### Collection Animation
```

Duration: 0.5-0.8 seconds
Path: Curve toward player
Scale: 1.0 → 1.2 → 0
Opacity: 1.0 → 0
Effect: Trailing particles

```

#### Destruction Animation
```

Duration: 0.3-0.5 seconds
Effect: Break into 4-6 pieces
Movement: Outward explosion
Rotation: Random spin
Opacity: 1.0 → 0
Scale: 1.0 → 0.5 → 0

```

### UI Animations

#### Button Press
```

Duration: 0.1s press, 0.2s release
Scale: 1.0 → 0.95 → 1.0
Opacity: 1.0 → 0.8 → 1.0
Glow: Increase 20% on press

```

#### Value Change
```

Duration: 0.3-0.5 seconds
Effect: Pulse scale 1.0 → 1.15 → 1.0
Color: Flash bright, fade to normal

```

#### Screen Transition
```

Duration: 0.4-0.6 seconds
Type: Fade with slight scale
From: Opacity 0, scale 0.95
To: Opacity 1, scale 1.0

````

---

## 🔧 Implementation Notes

### SpriteKit Specifics

```swift
// Continuous Terrain Layer Generation
func createTerrainLayer(
    depth: ClosedRange<CGFloat>,
    terrainType: TerrainType,
    levelWidth: CGFloat
) -> SKNode {
    let layerHeight = depth.upperBound - depth.lowerBound
    let layerSize = CGSize(width: levelWidth, height: layerHeight)
    let container = SKNode()

    // 1. Base continuous gradient texture
    let baseTexture = createVerticalGradientTexture(
        size: layerSize,
        colors: terrainType.gradientColors
    )
    let baseSprite = SKSpriteNode(texture: baseTexture)
    baseSprite.anchorPoint = CGPoint(x: 0, y: 0)
    baseSprite.position = CGPoint(x: 0, y: depth.lowerBound)
    baseSprite.zPosition = 0
    container.addChild(baseSprite)

    // 2. Organic variations layer (multiple large shapes)
    let variations = generateOrganicVariations(
        layerSize: layerSize,
        terrainType: terrainType
    )
    variations.forEach {
        $0.position.y += depth.lowerBound
        $0.zPosition = 1
        container.addChild($0)
    }

    // 3. Flow pattern overlay
    let flowPattern = generateFlowPattern(
        layerSize: layerSize,
        terrainType: terrainType
    )
    flowPattern.position.y = depth.lowerBound
    flowPattern.zPosition = 2
    container.addChild(flowPattern)

    return container
}

// Material Deposit Generation
func createMaterialDeposit(
    material: Material,
    position: CGPoint
) -> SKNode {
    let container = SKNode()
    container.position = position

    // Outer glow effect
    let glowRadius = material.depositSize * 1.5
    let glowNode = SKShapeNode(circleOfRadius: glowRadius)
    glowNode.fillColor = material.glowColor
    glowNode.strokeColor = .clear
    glowNode.alpha = material.glowIntensity
    glowNode.zPosition = 10

    // Add blur filter for glow
    if let filter = CIFilter(name: "CIGaussianBlur", parameters: [
        "inputRadius": 3.0
    ]) {
        glowNode.filter = filter
    }
    container.addChild(glowNode)

    // Core deposit with gradient
    let coreTexture = createRadialGradientTexture(
        radius: material.depositSize,
        colors: material.coreColors
    )
    let coreSprite = SKSpriteNode(texture: coreTexture)
    coreSprite.zPosition = 11
    container.addChild(coreSprite)

    // Internal details (texture spots)
    for _ in 0..<Int.random(in: 2...4) {
        let detail = SKShapeNode(
            ellipseOf: CGSize(
                width: CGFloat.random(in: 4...7),
                height: CGFloat.random(in: 5...8)
            )
        )
        detail.fillColor = material.detailColor
        detail.strokeColor = .clear
        detail.alpha = 0.7
        detail.position = CGPoint(
            x: CGFloat.random(in: -material.depositSize/3...material.depositSize/3),
            y: CGFloat.random(in: -material.depositSize/3...material.depositSize/3)
        )
        detail.zPosition = 12
        container.addChild(detail)
    }

    return container
}

// Gradient Texture Helpers
func createVerticalGradientTexture(
    size: CGSize,
    colors: [UIColor]
) -> SKTexture {
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors.map { $0.cgColor } as CFArray,
            locations: stride(from: 0.0, through: 1.0, by: 1.0 / Double(colors.count - 1)).map { $0 }
        )
        context.cgContext.drawLinearGradient(
            gradient!,
            start: .zero,
            end: CGPoint(x: 0, y: size.height),
            options: []
        )
    }
    return SKTexture(image: image)
}

func createRadialGradientTexture(
    radius: CGFloat,
    colors: [UIColor]
) -> SKTexture {
    let size = CGSize(width: radius * 2, height: radius * 2)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors.map { $0.cgColor } as CFArray,
            locations: stride(from: 0.0, through: 1.0, by: 1.0 / Double(colors.count - 1)).map { $0 }
        )
        context.cgContext.drawRadialGradient(
            gradient!,
            startCenter: CGPoint(x: radius, y: radius),
            startRadius: 0,
            endCenter: CGPoint(x: radius, y: radius),
            endRadius: radius,
            options: []
        )
    }
    return SKTexture(image: image)
}
````

### Performance Considerations

```
✓ Pre-render terrain layers as single large textures
✓ Cache terrain base layers (reusable across levels)
✓ Generate material deposits dynamically on level load
✓ Use texture atlases for all material deposit sprites
✓ Limit glow effects based on device capability
✓ Batch material deposits with same type for efficiency
✓ Use tile map for collision detection (invisible grid)
✗ Don't create separate sprites for each block
✗ Don't regenerate terrain gradient every frame
✗ Avoid excessive use of CIFilters in real-time
✗ Don't create thousands of individual nodes

Optimization Tips:
- Terrain layers: 1 large sprite per geological layer
- Material deposits: Individual sprites at grid positions only
- Collision: Tile-based grid (64x64), invisible overlay
- Rendering: Layer order matters (terrain = 0, materials = 10+)
- Memory: Pre-generate textures, cache aggressively
```

### Terrain-Grid Relationship

```
Visual Layer (Continuous)          Game Logic Layer (Grid)
┌─────────────────────────┐        ┌───┬───┬───┬───┬───┐
│                         │        │   │   │   │   │   │
│   Flowing sand terrain  │   =    ├───┼───┼───┼───┼───┤
│                         │        │   │ M │   │   │ M │
│     [M]     [M]  [M]    │        ├───┼───┼───┼───┼───┤
│                         │        │   │   │ M │   │   │
│        [M]       [M]    │        ├───┼───┼───┼───┼───┤
│                         │        │ M │   │   │   │   │
└─────────────────────────┘        └───┴───┴───┴───┴───┘
                                   M = Material at grid position

Collision Detection:
- Invisible 64x64 grid overlay
- Check grid position for material presence
- Visual appearance = continuous
- Game logic = discrete grid
```

---

## 📱 Platform Guidelines

### iOS Requirements

- Support Dark Mode (already dark theme)
- Respect Dynamic Type for UI text
- Use SF Symbols for icons where appropriate
- Ensure 44x44pt minimum touch targets
- Support Safe Area on all devices

### Accessibility

```
Color Contrast:    Maintain 4.5:1 minimum
Reduce Motion:     Disable pulsing/rotation animations
Voice Over:        Label all interactive elements
Haptics:           Provide feedback for important actions
```

---

## 🎨 Asset Export Specifications

### Resolutions

```
@1x:  Base resolution (legacy)
@2x:  Standard (1170x2532 for iPhone 14 Pro Max)
@3x:  High density (recommended for all new assets)
```

### Format Guidelines

```
UI Elements:       PDF (vector) or PNG @3x
Terrain Textures:  PNG @2x with alpha
Backgrounds:       PNG @2x, optimized
Icons:             PDF (vector) or PNG @3x
Particles:         PNG @1x (small size)
```

### File Naming

```
terrain_rock_common@2x.png
terrain_crystal_rare@3x.png
ui_button_primary@3x.png
icon_material_iron.pdf
particle_dust.png
```

---

## 🌟 Future Considerations

### Planned Enhancements

- [ ] Animated planet rotation in background
- [ ] Dynamic lighting based on planet proximity
- [ ] Weather effects (dust storms, aurora)
- [ ] Material rarity particle effects
- [ ] Day/night cycle lighting changes
- [ ] Biome-specific visual themes

### Experimental Features

- [ ] Parallax scrolling backgrounds
- [ ] Procedural texture generation
- [ ] Real-time shader effects
- [ ] Dynamic glow intensity based on depth
- [ ] Haptic feedback synchronized with visuals

---

## 📚 Resources

### Tools

- **Vector Editor:** Figma, Sketch, or Adobe Illustrator
- **Bitmap Editor:** Photoshop or Affinity Photo
- **SVG to PNG:** ImageMagick, Figma export
- **Testing:** Xcode Simulator, TestFlight

### References

- SF Symbols: https://developer.apple.com/sf-symbols/
- iOS HIG: https://developer.apple.com/design/human-interface-guidelines/
- SpriteKit: https://developer.apple.com/documentation/spritekit/

---

## 📋 Quick Implementation Checklist

### Continuous Terrain Layer

- [ ] Create full-layer vertical gradient (entire depth range)
- [ ] Add 3-6 large organic variations (80-130px radius, 10-18% opacity)
- [ ] Add diagonal flow pattern overlay (15-40° angle)
- [ ] Add horizontal texture lines spanning multiple blocks
- [ ] Ensure total layer size = level width × depth range
- [ ] Cache terrain texture for reuse

### Material Deposits

- [ ] Position deposits at grid centers (x*64+32, y*64+32)
- [ ] Create radial gradient for each deposit core
- [ ] Add outer glow (1.5x deposit size, 40-90% opacity based on rarity)
- [ ] Add 2-4 internal texture details per deposit
- [ ] Ensure 30%+ contrast with terrain background
- [ ] Vary deposit sizes (small/medium/large)

### Grid System

- [ ] Maintain invisible 64×64 collision grid
- [ ] Map material positions to grid coordinates
- [ ] Handle mining by grid position, not visual position
- [ ] Update collision data when blocks mined
- [ ] Keep visual layer separate from logic layer

### Visual Quality

- [ ] All gradients smooth (3+ color stops)
- [ ] All shapes use rounded corners/ellipses
- [ ] Glow effects use Gaussian blur (stdDeviation 3-6)
- [ ] Organic variations overlap and blend
- [ ] No hard edges or straight lines in terrain
- [ ] Material glows visible against terrain

### Performance

- [ ] Pre-render terrain layers as single textures
- [ ] Use texture atlas for material deposits
- [ ] Batch materials of same type
- [ ] Limit real-time filters
- [ ] Cache all generated textures
- [ ] Profile on target device

---

## 🎯 Design Goals Summary

**Player Experience:**

- Feels like descending through natural geological layers
- Clear visual feedback on valuable materials
- Immersive sci-fi mining atmosphere
- Satisfying excavation and collection

**Visual Style:**

- Modern, polished, not retro
- Smooth gradients, soft glows
- Organic shapes, natural flow
- Clear material differentiation

**Technical Implementation:**

- Grid-based for gameplay precision
- Continuous for visual appeal
- Performant on mobile devices
- Easy to extend with new materials

---

**End of Design System Documentation**

For questions or contributions, please contact the development team.
