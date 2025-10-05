//
//  TerrainManager.swift
//  DESCENT
//
//  Manages procedural terrain generation and chunk loading
//

import SpriteKit

class TerrainManager {

    // MARK: - Properties
    private weak var scene: SKScene?
    private let planet: Planet
    private let width: Int  // Blocks wide (calculated based on screen width)
    private let chunkHeight: Int = 50  // Blocks per chunk
    private let planetConfig: PlanetConfig
    private var terrainSeed: Int  // Unique seed for this terrain generation

    // Storage
    private var blocks: [String: TerrainBlock] = [:]  // Key: "x,y"
    private var loadedChunks: Set<Int> = []  // Chunk numbers that are loaded
    private var veinMap: [String: Material] = [:]  // Key: "x,y", stores material at each vein position
    private var obstacleMap: [String: TerrainBlock.BlockType] = [:]  // Key: "x,y", stores obstacle type at each position
    private var drilledPositions: Set<String> = []  // Key: "x,y", positions that have been drilled (永久 removed)

    // MARK: - Initialization

    init(scene: SKScene, planet: Planet, seed: Int? = nil) {
        self.scene = scene
        self.planet = planet

        // Use provided seed or generate new one based on timestamp
        self.terrainSeed = seed ?? Int(Date().timeIntervalSince1970 * 1000) + Int.random(in: 0...9999)

        // Load planet configuration
        let planetName = planet.rawValue.lowercased()
        guard let config = LevelConfigLoader.shared.loadPlanet(planetName) else {
            fatalError("Failed to load planet config for \(planetName)")
        }
        self.planetConfig = config

        // Calculate terrain width based on screen width
        let screenWidth = scene.frame.width
        let blockSize = TerrainBlock.size
        self.width = Int(ceil(screenWidth / blockSize)) + 2  // +2 for buffer on edges

        print("🌍 TerrainManager initialized for \(config.name)")
        print("   - Seed: \(terrainSeed)")
        print("   - Total depth: \(config.totalDepth)m")
        print("   - Strata layers: \(config.strata.count)")
    }

    // MARK: - Chunk Management

    /// Load terrain chunks near the player
    func updateChunks(playerY: CGFloat) {
        guard let scene = scene else { return }

        // Convert Y position to chunk number (negative Y = deeper)
        let playerDepth = (scene.frame.maxY - 100 - playerY) / TerrainBlock.size
        let currentChunk = Int(playerDepth) / chunkHeight

        // Load chunks within range (current chunk + 1 above and 2 below)
        let chunksToLoad = [currentChunk - 1, currentChunk, currentChunk + 1, currentChunk + 2]

        for chunkNumber in chunksToLoad {
            if chunkNumber >= 0 && !loadedChunks.contains(chunkNumber) {
                loadChunk(chunkNumber)
                loadedChunks.insert(chunkNumber)
            }
        }

        // Unload far away chunks to save memory
        let chunksToUnload = loadedChunks.filter { abs($0 - currentChunk) > 3 }
        for chunkNumber in chunksToUnload {
            unloadChunk(chunkNumber)
            loadedChunks.remove(chunkNumber)
        }
    }

    // MARK: - Chunk Loading

    private func loadChunk(_ chunkNumber: Int) {
        guard let scene = scene else { return }

        let surfaceY = scene.frame.maxY - 100
        let startY = chunkNumber * chunkHeight
        let endY = startY + chunkHeight

        // Step 1: Generate obstacles for this chunk (before veins)
        generateObstaclesForChunk(chunkNumber: chunkNumber, startY: startY, endY: endY)

        // Step 2: Generate veins for this chunk
        generateVeinsForChunk(chunkNumber: chunkNumber, startY: startY, endY: endY)

        // Step 3: Create blocks (checking obstacleMap and veinMap)
        for y in startY..<endY {
            for x in 0..<width {
                generateBlock(x: x, y: y, surfaceY: surfaceY)
            }
        }
    }

    private func unloadChunk(_ chunkNumber: Int) {
        let startY = chunkNumber * chunkHeight
        let endY = startY + chunkHeight

        for y in startY..<endY {
            for x in 0..<width {
                let key = "\(x),\(y)"
                if let block = blocks[key] {
                    block.removeFromParent()
                    blocks.removeValue(forKey: key)
                }
                // Also remove from vein map and obstacle map
                veinMap.removeValue(forKey: key)
                obstacleMap.removeValue(forKey: key)
            }
        }
    }

    // MARK: - Obstacle Generation

    private func generateObstaclesForChunk(chunkNumber: Int, startY: Int, endY: Int) {
        // Define obstacle coverage by depth ranges
        // Based on Mars level design: [Depth Range: (Bedrock%, HardCrystal%, ReinforcedRock%)]
        let obstacleRules: [(depthRange: ClosedRange<Double>, bedrock: Double, hardCrystal: Double, reinforcedRock: Double)] = [
            (0...30, 0.0, 0.0, 0.0),      // Layer 1: Surface
            (30...80, 0.03, 0.0, 0.0),    // Layer 2: First bedrock
            (80...150, 0.08, 0.02, 0.0),  // Layer 3: Bedrock + crystals
            (150...220, 0.10, 0.03, 0.0), // Layer 4
            (220...300, 0.12, 0.04, 0.0), // Layer 5
            (300...380, 0.15, 0.05, 0.03), // Layer 6: Reinforced rock appears
            (380...450, 0.18, 0.08, 0.05), // Layer 7
            (450...490, 0.20, 0.06, 0.08)  // Layer 8: Deep zone
        ]

        // Process each Y level in this chunk
        for y in startY..<endY {
            let depth = Double(y)

            // Find which obstacle rule applies to this depth
            guard let rule = obstacleRules.first(where: { $0.depthRange.contains(depth) }) else {
                continue
            }

            // Generate bedrock obstacles
            if rule.bedrock > 0 {
                generateObstacleType(
                    .bedrock,
                    coverage: rule.bedrock,
                    y: y,
                    formationSizes: [(2, 2), (3, 3), (4, 4)],
                    offsetBase: 10000
                )
            }

            // Generate hard crystal obstacles
            if rule.hardCrystal > 0 {
                generateObstacleType(
                    .hardCrystal,
                    coverage: rule.hardCrystal,
                    y: y,
                    formationSizes: [(2, 2), (3, 3)],
                    offsetBase: 20000
                )
            }

            // Generate reinforced rock obstacles
            if rule.reinforcedRock > 0 {
                generateObstacleType(
                    .reinforcedRock,
                    coverage: rule.reinforcedRock,
                    y: y,
                    formationSizes: [(2, 2), (3, 3)],
                    offsetBase: 30000
                )
            }
        }
    }

    /// Generate obstacles of a specific type for a row
    private func generateObstacleType(
        _ blockType: TerrainBlock.BlockType,
        coverage: Double,
        y: Int,
        formationSizes: [(width: Int, height: Int)],
        offsetBase: Int
    ) {
        // Calculate number of obstacle seeds for this row
        let numSeeds = Int(floor(Double(width) * coverage))

        // Place obstacle seeds
        for seedIndex in 0..<numSeeds {
            // Use deterministic seed based on position and type
            let positionSeed = generateSeed(x: y, y: offsetBase, offset: seedIndex)
            let seedX = seededRandom(min: 0, max: width - 1, seed: positionSeed)
            let seedKey = "\(seedX),\(y)"

            // Skip if position already has an obstacle
            guard obstacleMap[seedKey] == nil else { continue }

            // Choose formation size
            let sizeSeed = generateSeed(x: seedX, y: y, offset: offsetBase + seedIndex)
            let sizeIndex = seededRandom(min: 0, max: formationSizes.count - 1, seed: sizeSeed)
            let formationSize = formationSizes[sizeIndex]

            // Create formation around seed
            placeObstacleFormation(
                blockType: blockType,
                centerX: seedX,
                centerY: y,
                width: formationSize.width,
                height: formationSize.height
            )
        }
    }

    /// Place an obstacle formation (rectangular pattern)
    private func placeObstacleFormation(
        blockType: TerrainBlock.BlockType,
        centerX: Int,
        centerY: Int,
        width: Int,
        height: Int
    ) {
        let halfWidth = width / 2
        let halfHeight = height / 2

        for dy in -halfHeight...halfHeight {
            for dx in -halfWidth...halfWidth {
                let x = centerX + dx
                let y = centerY + dy

                // Keep within terrain bounds
                guard x >= 0 && x < self.width && y >= 0 else { continue }

                let key = "\(x),\(y)"

                // Skip if already has obstacle
                guard obstacleMap[key] == nil else { continue }

                // Place obstacle
                obstacleMap[key] = blockType
            }
        }
    }

    // MARK: - Vein Generation

    private func generateVeinsForChunk(chunkNumber: Int, startY: Int, endY: Int) {
        // Process each Y level in this chunk
        for y in startY..<endY {
            let depth = Double(y)

            // Get the strata layer for this depth
            guard let layer = planetConfig.strata.first(where: { $0.contains(depth: depth) }) else {
                continue
            }

            // Apply depth bonus (+20% at max depth)
            let depthBonus = (depth / planetConfig.totalDepth) * 0.2

            // Generate veins for each resource type in this layer
            for (resourceIndex, resource) in layer.resources.enumerated() {
                let adjustedSeedRate = resource.seedRate * (1.0 + depthBonus)
                let totalTilesInRow = width
                let numSeeds = Int(floor(Double(totalTilesInRow) * adjustedSeedRate))

                // Place vein seeds for this row
                for seedIndex in 0..<numSeeds {
                    // Use deterministic seed based on position and resource type
                    let positionSeed = generateSeed(x: y, y: resourceIndex, offset: seedIndex)
                    let seedX = seededRandom(min: 0, max: width - 1, seed: positionSeed)
                    let seedKey = "\(seedX),\(y)"

                    // Skip if position already has a vein
                    guard veinMap[seedKey] == nil else { continue }

                    // Create material for this vein
                    guard let material = createMaterial(from: resource) else { continue }

                    // Grow vein from seed - use seeded random for vein size
                    let sizeSeed = generateSeed(x: seedX, y: y, offset: 1000 + seedIndex)
                    let veinSize = seededRandom(min: resource.veinSizeMin, max: resource.veinSizeMax, seed: sizeSeed)
                    growVein(startX: seedX, startY: y, material: material, remainingSize: veinSize, baseSeed: positionSeed)
                }
            }
        }
    }

    /// Grow a vein from a seed position using 8-direction adjacent tile growth
    private func growVein(startX: Int, startY: Int, material: Material, remainingSize: Int, baseSeed: Int) {
        var currentX = startX
        var currentY = startY

        // Place first tile
        let key = "\(currentX),\(currentY)"
        veinMap[key] = material

        // Grow remaining tiles
        for growthStep in 1..<remainingSize {
            // Get valid adjacent positions (8 directions)
            let adjacentPositions = getAdjacentPositions(x: currentX, y: currentY)

            // Filter out occupied positions
            let availablePositions = adjacentPositions.filter { pos in
                let posKey = "\(pos.x),\(pos.y)"
                return veinMap[posKey] == nil
            }

            // If no available positions, vein cannot grow further
            guard !availablePositions.isEmpty else { break }

            // Choose deterministic adjacent position based on growth step
            let directionSeed = generateSeed(x: currentX, y: currentY, offset: baseSeed + growthStep)
            let choiceIndex = seededRandom(min: 0, max: availablePositions.count - 1, seed: directionSeed)
            let nextPos = availablePositions[choiceIndex]
            currentX = nextPos.x
            currentY = nextPos.y

            // Place tile
            let nextKey = "\(currentX),\(currentY)"
            veinMap[nextKey] = material
        }
    }

    /// Get all 8 adjacent positions (N, S, E, W, NE, NW, SE, SW)
    private func getAdjacentPositions(x: Int, y: Int) -> [(x: Int, y: Int)] {
        var positions: [(x: Int, y: Int)] = []

        let offsets = [
            (-1, -1), (0, -1), (1, -1),  // NW, N, NE
            (-1,  0),          (1,  0),  // W,     E
            (-1,  1), (0,  1), (1,  1)   // SW, S, SE
        ]

        for offset in offsets {
            let newX = x + offset.0
            let newY = y + offset.1

            // Keep within terrain bounds
            if newX >= 0 && newX < width && newY >= 0 && newY < Int(planetConfig.totalDepth) {
                positions.append((x: newX, y: newY))
            }
        }

        return positions
    }

    /// Generate a seed for random number generation
    private func generateSeed(x: Int, y: Int, offset: Int) -> Int {
        return (x * 73856093 ^ y * 19349663 ^ offset) ^ terrainSeed
    }

    /// Seeded random number in a range
    private func seededRandom(min: Int, max: Int, seed: Int) -> Int {
        let random = Double((seed & 0xFFFF)) / Double(0xFFFF)
        return min + Int(random * Double(max - min + 1))
    }

    // MARK: - Block Generation

    private func generateBlock(x: Int, y: Int, surfaceY: CGFloat) {
        guard let scene = scene else { return }

        let key = "\(x),\(y)"
        guard blocks[key] == nil else { return }  // Already exists

        // Skip positions that have been drilled - keep the shaft open!
        guard !drilledPositions.contains(key) else { return }

        // Calculate position
        let blockX = scene.frame.minX + CGFloat(x) * TerrainBlock.size + TerrainBlock.size / 2
        let blockY = surfaceY - CGFloat(y) * TerrainBlock.size - TerrainBlock.size / 2

        // Calculate depth in meters (1 tile = 1 meter)
        let depth = Double(y)  // Each tile is 1 meter deep

        // Check if this block has an obstacle type (takes priority over materials)
        let blockType = obstacleMap[key] ?? .normal

        // Check if this block has a material from vein generation (only for normal blocks)
        let material = blockType == .normal ? veinMap[key] : nil

        // Get the strata layer for this depth to determine hardness
        let strataHardness = planetConfig.strata.first(where: { $0.contains(depth: depth) })?.hardness ?? 1.0

        // Create block
        let block = TerrainBlock(material: material, depth: depth, strataHardness: strataHardness, blockType: blockType)
        block.position = CGPoint(x: blockX, y: blockY)
        block.zPosition = 1
        block.name = key  // Store coordinates as name for easy lookup

        scene.addChild(block)
        blocks[key] = block
    }

    // MARK: - Material Creation

    /// Create a Material instance from a ResourceConfig
    private func createMaterial(from config: ResourceConfig) -> Material? {
        // Map resource type string to MaterialType enum
        guard let materialType = Material.MaterialType(rawValue: config.type) else {
            print("⚠️ Unknown material type: \(config.type)")
            return nil
        }

        return Material(type: materialType, planetMultiplier: planetConfig.valueMultiplier)
    }

    // MARK: - Block Access

    /// Get block at grid coordinates
    func getBlock(x: Int, y: Int) -> TerrainBlock? {
        let key = "\(x),\(y)"
        return blocks[key]
    }

    /// Remove a block (when drilled)
    func removeBlock(x: Int, y: Int) -> Material? {
        let key = "\(x),\(y)"
        guard let block = blocks[key] else { return nil }

        let material = block.material
        block.removeFromParent()
        blocks.removeValue(forKey: key)

        // Mark this position as drilled so it stays open when chunk reloads
        drilledPositions.insert(key)

        return material
    }

    /// Remove all terrain (for game over / reset)
    func removeAllTerrain() {
        // Remove all block nodes from scene
        for block in blocks.values {
            block.removeFromParent()
        }

        // Clear storage
        blocks.removeAll()
        loadedChunks.removeAll()
        veinMap.removeAll()
        obstacleMap.removeAll()
        drilledPositions.removeAll()

        print("🗑️ Cleared all terrain - blocks: 0, chunks: 0, veins: 0, obstacles: 0, drilled: 0")
    }

    /// Convert world position to grid coordinates
    func worldToGrid(_ position: CGPoint) -> (x: Int, y: Int)? {
        guard let scene = scene else { return nil }

        let surfaceY = scene.frame.maxY - 100
        let x = Int((position.x - scene.frame.minX) / TerrainBlock.size)
        let y = Int((surfaceY - position.y) / TerrainBlock.size)

        return (x, y)
    }
}
