# Terrain System Refactor Plan

**Goal**: Transition from discrete block-based terrain to continuous geological layers with embedded material deposits.

**Status**: Planning Phase
**Date**: October 11, 2025

---

## 📊 Current vs. New Architecture

### Current System (Block-Based)
```
┌────┬────┬────┬────┐
│ █  │ █  │    │ █  │  ← Each block is a 48x48 SKSpriteNode
├────┼────┼────┼────┤
│ █  │    │ █  │    │  ← Materials ARE blocks (colored differently)
├────┼────┼────┼────┤
│    │ █  │ █  │ █  │  ← Visible grid boundaries
└────┴────┴────┴────┘

Implementation:
- TerrainBlock: SKSpriteNode per block
- Size: 48×48 pixels
- Each block has texture, color, physics body
- Materials are blocks with different textures
- Chunk-based loading (50 blocks high)
```

### New System (Continuous Terrain)
```
┌─────────────────────┐
│ ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈ │  ← Continuous geological layer (single large texture)
│ ≈≈≈[M]≈≈≈≈[M]≈≈≈≈≈ │  ← Materials as overlay nodes at grid positions
│ ≈≈≈≈≈≈≈[M]≈≈≈≈[M]≈ │  ← Invisible 64×64 grid for collision
└─────────────────────┘

Implementation:
- TerrainLayer: Single large texture per stratum
- Size: Full level width × stratum depth range
- Gradients, organic variations, flow patterns
- MaterialDeposit: Separate overlay nodes
- Grid: 64×64 invisible collision map
```

---

## 🔑 Key Design Changes

### 1. Block Size Change
**Current**: 48×48 pixels
**New**: 64×64 pixels
**Why**: Design system specifies 64×64 grid for material positioning
**Impact**: All positioning calculations, chunk sizes, screen calculations

### 2. Visual Layers
**Current**: Individual block sprites
**New**: Continuous terrain layers with embedded deposits

```swift
// Current
blocks["x,y"] = TerrainBlock(material, depth, hardness)

// New
terrainLayers[stratumIndex] = TerrainLayerTexture(stratum, size)
materialDeposits["x,y"] = MaterialDeposit(material, gridPosition)
```

### 3. Collision System
**Current**: Each block has SKPhysicsBody
**New**: Invisible grid-based collision detection

```swift
// Current
block.physicsBody = SKPhysicsBody(rectangleOf: size)

// New
collisionGrid[x][y] = hasMaterial ? .solid : .empty
// Check collision via grid lookup, not physics
```

### 4. Material Representation
**Current**: Materials are colored blocks
**New**: Materials are separate overlay nodes with glows

```swift
// Current: Material embedded in block texture
TerrainBlock(material: ironOre, depth: 100)

// New: Material as separate visual node
MaterialDeposit(
    material: ironOre,
    position: gridCenter,
    glowRadius: depositSize * 1.5,
    coreGradient: [#7a8a9a, #6a7a8a]
)
```

---

## 🏗️ Implementation Plan

### Phase 1: Foundation (2-3 days)

#### 1.1 Update Constants
- [ ] Change `TerrainBlock.size` from 48 to 64
- [ ] Update all size-dependent calculations
- [ ] Test that existing system still works at new size

#### 1.2 Create New Classes

**TerrainLayer.swift**
```swift
class TerrainLayer: SKNode {
    let stratumRange: ClosedRange<Double>  // Depth range (e.g., 0-160m)
    let terrainType: TerrainType  // Sand, Stone, Rock, Mars Rock
    private var baseTexture: SKTexture!
    private var variations: [SKNode] = []
    private var flowPattern: SKNode?

    init(stratum: Stratum, levelWidth: CGFloat) {
        // Create continuous texture for entire layer
        // Add organic variations
        // Add flow patterns
    }
}
```

**MaterialDeposit.swift**
```swift
class MaterialDeposit: SKNode {
    let material: Material
    let gridPosition: (x: Int, y: Int)
    private var glowNode: SKShapeNode!
    private var coreNode: SKSpriteNode!
    private var detailNodes: [SKShapeNode] = []

    init(material: Material, gridPosition: (Int, Int)) {
        // Create glow effect (1.5x size, blurred)
        // Create core with radial gradient
        // Add internal texture details
    }
}
```

**CollisionGrid.swift**
```swift
class CollisionGrid {
    private var grid: [[GridCell]]  // 2D array
    let gridSize: (width: Int, height: Int)

    enum GridCell {
        case empty
        case terrain
        case material(Material)
        case obstacle(BlockType)
    }

    func cellAt(x: Int, y: Int) -> GridCell
    func removeMaterial(at: (Int, Int)) -> Material?
    func isColliding(rect: CGRect) -> Bool
}
```

**TextureGeneratorExtension.swift**
```swift
extension TextureGenerator {
    // Continuous terrain textures
    func createVerticalGradientTexture(
        size: CGSize,
        colors: [UIColor]
    ) -> SKTexture

    func createRadialGradientTexture(
        radius: CGFloat,
        colors: [UIColor]
    ) -> SKTexture

    func createOrganicVariations(
        layerSize: CGSize,
        count: Int,
        baseColor: UIColor
    ) -> [SKNode]

    func createFlowPattern(
        layerSize: CGSize,
        angle: CGFloat
    ) -> SKNode
}
```

#### 1.3 Create TerrainType Enum
```swift
enum TerrainType {
    case sand
    case stone
    case rock
    case marsRock

    var gradientColors: [UIColor] {
        switch self {
        case .sand:
            return [
                UIColor(hex: "#c4a57b"),
                UIColor(hex: "#b89a70"),
                UIColor(hex: "#a89060"),
                UIColor(hex: "#9c8555")
            ]
        case .stone:
            return [
                UIColor(hex: "#6a7a8a"),
                UIColor(hex: "#5a6a7a")
            ]
        // ... etc
        }
    }

    var variationColor: UIColor { /* ... */ }
    var flowColor: UIColor { /* ... */ }
}
```

---

### Phase 2: Terrain Layer Generation (3-4 days)

#### 2.1 Implement Layer Rendering
- [ ] Vertical gradient texture generation
- [ ] Organic variation ellipses (80-130px, 10-18% opacity)
- [ ] Diagonal flow patterns (15-40° angles)
- [ ] Horizontal texture lines
- [ ] Layer caching system

#### 2.2 Update TerrainManager
```swift
class TerrainManager {
    // Replace blocks dictionary with:
    private var terrainLayers: [Int: TerrainLayer] = [:]
    private var materialDeposits: [String: MaterialDeposit] = [:]
    private var collisionGrid: CollisionGrid!

    // Change from loadChunk to:
    func loadStratumLayer(stratumIndex: Int)
    func generateMaterialDepositsForRange(yRange: Range<Int>)
    func updateVisibleMaterials(playerY: CGFloat)
}
```

#### 2.3 Layer-Based Chunk Loading
```swift
// Current: Load 50-block chunks
// New: Load entire stratum layers + visible materials

func updateChunks(playerY: CGFloat) {
    // 1. Determine which strata are near player
    let visibleStrata = getVisibleStrata(playerY)

    // 2. Load/unload terrain layers (cheap - just textures)
    for stratum in visibleStrata {
        if !terrainLayers.keys.contains(stratum) {
            loadStratumLayer(stratum)
        }
    }

    // 3. Load/unload material deposits in view range (expensive)
    let materialRange = getMaterialLoadRange(playerY)
    updateVisibleMaterials(in: materialRange)
}
```

---

### Phase 3: Material Deposit System (2-3 days)

#### 3.1 Material Rendering
- [ ] Radial gradient cores
- [ ] Outer glow with Gaussian blur
- [ ] Internal texture details (2-4 random spots)
- [ ] Size variation (small/medium/large)
- [ ] Contrast validation (30%+ from terrain)

#### 3.2 Material Positioning
```swift
// Convert vein position to grid center
func materialDepositPosition(gridX: Int, gridY: Int, surfaceY: CGFloat) -> CGPoint {
    let pixelX = CGFloat(gridX) * 64 + 32  // Grid center
    let pixelY = surfaceY - (CGFloat(gridY) * 64 + 32)
    return CGPoint(x: pixelX, y: pixelY)
}
```

#### 3.3 Glow System
```swift
// Apply Gaussian blur to glow nodes
let glowNode = SKShapeNode(circleOfRadius: glowRadius)
glowNode.fillColor = material.glowColor
glowNode.alpha = material.glowIntensity  // 0.4-0.9 based on rarity

if let filter = CIFilter(name: "CIGaussianBlur", parameters: [
    "inputRadius": 3.0 + (material.rarity * 2.0)
]) {
    glowNode.filter = filter
}
```

---

### Phase 4: Collision System Refactor (2 days)

#### 4.1 Grid-Based Collision
```swift
// Replace physics-based collision with grid lookup
func checkCollision(podRect: CGRect) -> CollisionResult {
    let gridBounds = rectToGridBounds(podRect)

    for y in gridBounds.minY...gridBounds.maxY {
        for x in gridBounds.minX...gridBounds.maxX {
            switch collisionGrid.cellAt(x: x, y: y) {
            case .empty:
                continue
            case .terrain, .obstacle:
                return .collision(type: .solid)
            case .material(let material):
                return .collision(type: .drillable(material))
            }
        }
    }
    return .none
}
```

#### 4.2 Drilling System Update
```swift
// Current: Remove block from scene
// New: Remove from collision grid + remove material deposit node

func drillBlock(at gridPos: (Int, Int)) -> Material? {
    // 1. Remove from collision grid
    guard let material = collisionGrid.removeMaterial(at: gridPos) else {
        return nil
    }

    // 2. Remove visual deposit node
    let key = "\(gridPos.0),\(gridPos.1)"
    if let deposit = materialDeposits[key] {
        deposit.removeFromParent()
        materialDeposits.removeValue(forKey: key)
    }

    // 3. Terrain layer remains visible (continuity!)

    return material
}
```

---

### Phase 5: Integration & Testing (2-3 days)

#### 5.1 Update GameScene
- [ ] Remove old TerrainBlock references
- [ ] Update drilling logic to use grid system
- [ ] Update collision detection to use CollisionGrid
- [ ] Test chunk loading/unloading
- [ ] Verify material collection works

#### 5.2 Performance Optimization
- [ ] Cache terrain layer textures
- [ ] Batch material deposit rendering
- [ ] Profile memory usage (should be lower)
- [ ] Profile frame rate (should be stable)
- [ ] Test on older devices

#### 5.3 Visual Quality Pass
- [ ] Verify gradient smoothness
- [ ] Check material contrast against terrain
- [ ] Adjust glow intensities
- [ ] Test organic variation appearance
- [ ] Validate flow pattern visibility

---

## 📋 Detailed Task Breakdown

### Week 1: Foundation & Layer System

**Day 1-2: Setup & Constants**
- [ ] Update `TerrainBlock.size` to 64
- [ ] Create `TerrainType` enum with colors
- [ ] Create `TerrainLayer` class skeleton
- [ ] Create `MaterialDeposit` class skeleton
- [ ] Create `CollisionGrid` class
- [ ] Test size change with existing system

**Day 3-4: Texture Generation**
- [ ] Implement `createVerticalGradientTexture`
- [ ] Implement `createRadialGradientTexture`
- [ ] Implement `createOrganicVariations`
- [ ] Implement `createFlowPattern`
- [ ] Test individual texture components

**Day 5: Layer Rendering**
- [ ] Complete `TerrainLayer` init
- [ ] Combine gradient + variations + flow
- [ ] Test single layer rendering
- [ ] Verify visual quality

### Week 2: Material System & Collision

**Day 6-7: Material Deposits**
- [ ] Complete `MaterialDeposit` rendering
- [ ] Implement glow system with blur
- [ ] Add internal texture details
- [ ] Test deposit visibility on terrain
- [ ] Adjust contrast if needed

**Day 8-9: Collision Grid**
- [ ] Implement grid collision detection
- [ ] Replace physics-based collision
- [ ] Update drilling to use grid
- [ ] Test pod collision with grid
- [ ] Verify material collection

**Day 10: Integration**
- [ ] Update `TerrainManager` to generate layers
- [ ] Update chunk loading for layer system
- [ ] Update material vein generation
- [ ] Test complete system in GameScene

### Week 3: Polish & Optimization

**Day 11-12: Performance**
- [ ] Profile frame rate
- [ ] Profile memory usage
- [ ] Optimize texture caching
- [ ] Batch material rendering
- [ ] Test on iPhone 8 (lowest target)

**Day 13-14: Visual Polish**
- [ ] Fine-tune gradient colors
- [ ] Adjust glow intensities
- [ ] Verify material contrast
- [ ] Test all material types
- [ ] Add size variations

**Day 15: Final Testing**
- [ ] Complete playthrough from 0-500m
- [ ] Verify drilling feels good
- [ ] Test prestige (terrain regeneration)
- [ ] Test save/load
- [ ] Bug fixes

---

## ⚠️ Key Challenges & Solutions

### Challenge 1: Performance
**Issue**: Single large textures for terrain layers could be expensive
**Solution**:
- Pre-render textures once per layer
- Cache textures across runs (same seed = same terrain)
- Use lower resolution textures on older devices
- Only render materials in viewport

### Challenge 2: Material Visibility
**Issue**: Materials must stand out against continuous terrain
**Solution**:
- Glow radius 1.5x deposit size
- Contrast validation (30%+ darker/lighter)
- Brighten glow for rare materials (70-90% opacity)
- Add pulsing animation for crystals

### Challenge 3: Collision Detection
**Issue**: No physics bodies = need custom collision
**Solution**:
- Maintain invisible 64×64 grid
- Check 9 grid cells around pod (pod is ~48px = <1 cell)
- Simple rect-to-grid conversion
- Cache grid lookups per frame

### Challenge 4: Drilling Feedback
**Issue**: Drilling continuous terrain needs to feel impactful
**Solution**:
- Spawn particles from material deposit when collected
- Flash the terrain layer where drilled
- Screen shake on collection
- Haptic feedback
- Sound effects

### Challenge 5: Memory Usage
**Issue**: Large textures could use more memory
**Solution**:
- Current system: ~500 individual 48×48 textures = 11.5MB per screen
- New system: 1 large 375×5000 texture per layer = ~1.8MB per layer
- Net result: ~50% memory reduction
- Unload far terrain layers (keep only ±2 strata visible)

---

## 🎯 Success Criteria

### Visual Quality
- [ ] Terrain appears continuous with no visible grid
- [ ] Organic variations span 3-5 blocks naturally
- [ ] Flow patterns visible but subtle
- [ ] Materials stand out clearly from terrain
- [ ] Glows are visible and attractive
- [ ] No hard edges or block boundaries

### Performance
- [ ] 60 FPS on iPhone 11 Pro
- [ ] 30+ FPS on iPhone 8
- [ ] <100MB memory usage
- [ ] Smooth scrolling while drilling
- [ ] No lag when loading new layers

### Gameplay
- [ ] Drilling feels precise (grid-based)
- [ ] Material collection works correctly
- [ ] Collision detection accurate
- [ ] Chunk loading seamless
- [ ] Save/load preserves drilled positions

### Code Quality
- [ ] Clean separation: visual vs. logic layers
- [ ] Reusable texture generation
- [ ] Efficient collision grid
- [ ] Maintainable codebase
- [ ] Well-documented

---

## 🔄 Migration Strategy

### Option A: Parallel Implementation (Recommended)
1. Create new classes alongside old ones
2. Feature flag to switch between systems
3. Test new system thoroughly
4. Remove old system once validated

```swift
enum TerrainRenderMode {
    case blockBased  // Current
    case continuous  // New
}

class TerrainManager {
    let renderMode: TerrainRenderMode = .continuous  // Switch here

    func loadChunk(_ chunkNumber: Int) {
        switch renderMode {
        case .blockBased:
            loadChunk_BlockBased(chunkNumber)
        case .continuous:
            loadChunk_Continuous(chunkNumber)
        }
    }
}
```

### Option B: Clean Break (Risky)
1. Create new branch
2. Delete old terrain system
3. Implement new system from scratch
4. Merge when complete

**Recommendation**: Use Option A for safety. Easy to rollback if issues arise.

---

## 📝 Files to Modify/Create

### New Files
- [ ] `TerrainLayer.swift` - Continuous terrain rendering
- [ ] `MaterialDeposit.swift` - Material overlay nodes
- [ ] `CollisionGrid.swift` - Grid-based collision system
- [ ] `TextureGeneratorExtension.swift` - New texture methods
- [ ] `TerrainType.swift` - Terrain type definitions

### Modified Files
- [ ] `TerrainManager.swift` - Layer-based generation
- [ ] `TerrainBlock.swift` - May be deprecated or minimal role
- [ ] `GameScene.swift` - Update collision & drilling
- [ ] `TextureGenerator.swift` - Add gradient methods
- [ ] `Material.swift` - Add glow properties

### Potentially Deprecated
- [ ] Current `TerrainBlock` texture methods (if not needed)

---

## 🎨 Visual Design Reference

### Terrain Gradients (from DESIGN_SYSTEM.md)

**Sand (0-640m)**
```swift
[
    "#c4a57b",  // Light sandy brown
    "#b89a70",
    "#a89060",
    "#9c8555"   // Dark sandy brown
]
```

**Stone (640-1280m)**
```swift
[
    "#6a7a8a",  // Light gray
    "#5a6a7a"   // Dark gray
]
```

**Rock (1280-1920m)**
```swift
[
    "#7a8090",  // Light rock gray
    "#6a7080"   // Dark rock gray
]
```

**Mars Rock (1920m+)**
```swift
[
    "#b85a40",  // Mars red-brown
    "#a04a30"   // Dark mars brown
]
```

### Material Deposit Sizes

```swift
enum DepositSize {
    case small   // 10-14px radius
    case medium  // 15-19px radius
    case large   // 20-24px radius

    var glowRadius: CGFloat {
        switch self {
        case .small: return 15-21
        case .medium: return 22.5-28.5
        case .large: return 30-36
        }
    }
}
```

---

## 🚀 Getting Started

### Step 1: Review Design Document
Read `DESIGN_SYSTEM.md` thoroughly, especially:
- Section: "🌊 Terrain-Material Interaction"
- Section: "🎨 Terrain Generation Patterns"
- Section: "🧱 Continuous Terrain Construction"
- Section: "🔧 Implementation Notes"

### Step 2: Create Feature Branch
```bash
git checkout -b feature/continuous-terrain
```

### Step 3: Start with Foundation
Begin with Phase 1 tasks:
1. Update block size constant
2. Create new class skeletons
3. Implement basic texture generation

### Step 4: Iterate and Test
- Implement one component at a time
- Test in simulator after each major change
- Use feature flag to keep old system working
- Commit frequently

---

## 📊 Progress Tracking

Use this checklist to track overall progress:

### Phase 1: Foundation ⬜️
- [ ] Update constants and sizes
- [ ] Create new class files
- [ ] Implement texture generation helpers

### Phase 2: Terrain Layers ⬜️
- [ ] Layer rendering with gradients
- [ ] Organic variations
- [ ] Flow patterns

### Phase 3: Material Deposits ⬜️
- [ ] Deposit rendering with glows
- [ ] Material positioning system
- [ ] Integration with terrain

### Phase 4: Collision System ⬜️
- [ ] Grid-based collision
- [ ] Drilling system update
- [ ] Material collection

### Phase 5: Integration ⬜️
- [ ] GameScene updates
- [ ] Performance optimization
- [ ] Visual quality pass
- [ ] Testing and bug fixes

---

**Total Estimated Time**: 2-3 weeks
**Priority**: High (major visual upgrade)
**Risk Level**: Medium (significant architectural change)
**Rollback Plan**: Feature flag allows reverting to old system

**Questions?** Review DESIGN_SYSTEM.md or ask for clarification on specific components.
