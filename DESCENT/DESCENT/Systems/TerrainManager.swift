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
    private let soulCrystalBonus: Double  // Soul Crystal earnings multiplier

    // Storage
    private var blocks: [String: TerrainBlock] = [:]  // Key: "x,y"
    private var loadedChunks: Set<Int> = []  // Chunk numbers that are loaded
    private var veinMap: [String: Material] = [:]  // Key: "x,y", stores material at each vein position
    private var obstacleMap: [String: TerrainBlock.BlockType] = [:]  // Key: "x,y", stores obstacle type at each position
    private var drilledPositions: Set<String> = []  // Key: "x,y", positions that have been drilled (永久 removed)

    // Core chamber
    private var coreCrystalSpawned: Bool = false

    // MARK: - Initialization

    init(scene: SKScene, planet: Planet, soulCrystalBonus: Double = 1.0, seed: Int? = nil) {
        self.scene = scene
        self.planet = planet
        self.soulCrystalBonus = soulCrystalBonus

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
        print("   - Soul Crystal bonus: \(soulCrystalBonus)x")
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
        // Process each Y level in this chunk
        for y in startY..<endY {
            let depth = Double(y)

            // Get the strata layer for this depth
            guard let layer = planetConfig.strata.first(where: { $0.contains(depth: depth) }) else {
                continue
            }

            // Generate obstacles for each type defined in this layer
            for (obstacleIndex, obstacle) in layer.obstacles.enumerated() {
                // Skip if no coverage
                guard obstacle.coverage > 0 else { continue }

                // Map obstacle type string to BlockType enum
                let blockType: TerrainBlock.BlockType
                switch obstacle.type {
                case "bedrock":
                    blockType = .bedrock
                case "hardCrystal":
                    blockType = .hardCrystal
                case "reinforcedRock":
                    blockType = .reinforcedRock
                default:
                    print("⚠️ Unknown obstacle type: \(obstacle.type)")
                    continue
                }

                // Convert FormationSize structs to tuples
                let formationSizes: [(width: Int, height: Int)] = obstacle.formationSizes.map {
                    ($0.width, $0.height)
                }

                // Use unique offset base for each obstacle type to ensure different patterns
                let offsetBase = 10000 * (obstacleIndex + 1)

                generateObstacleType(
                    blockType,
                    coverage: obstacle.coverage,
                    y: y,
                    formationSizes: formationSizes,
                    offsetBase: offsetBase
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
        // Calculate average formation size to adjust seed rate
        let avgFormationSize = formationSizes.reduce(0.0) { sum, size in
            sum + Double(size.width * size.height)
        } / Double(formationSizes.count)

        // Adjust coverage to account for formation size
        // If coverage = 8% and avg formation = 16 blocks, we need far fewer seeds
        // Seed rate = coverage / (avg formation area / row width)
        let adjustedCoverage = coverage / (avgFormationSize / Double(width))

        // Randomly decide if this row should have any obstacles at all
        // Use the adjusted coverage as probability
        let rowSeed = generateSeed(x: offsetBase, y: y, offset: y * 73)
        let rowRandom = Double((rowSeed & 0xFFFF)) / Double(0xFFFF)

        // Only place obstacles on some rows based on adjusted coverage
        guard rowRandom < adjustedCoverage else { return }

        // Place 1 seed on this row (since formations are large)
        // Use offsetBase + y as offset to add more variation for horizontal distribution
        let positionSeed = generateSeed(x: y, y: offsetBase, offset: offsetBase + y)
        let seedX = seededRandom(min: 0, max: width - 1, seed: positionSeed)
        let seedKey = "\(seedX),\(y)"

        // Skip if position already has an obstacle
        guard obstacleMap[seedKey] == nil else { return }

        // Choose formation size
        let sizeSeed = generateSeed(x: seedX, y: y, offset: offsetBase * 2 + seedX)
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

        // Calculate depth in meters (1 tile = 1 meter)
        let depth = Double(y)  // Each tile is 1 meter deep

        // Skip blocks inside core chamber (10×10 open area at 490-500m)
        if isInCoreChamber(x: x, y: y) {
            // Spawn Dark Matter crystal once when core chamber is first loaded
            if !coreCrystalSpawned && depth >= planetConfig.coreDepth {
                spawnCoreCrystal(surfaceY: surfaceY)
            }
            return
        }

        // Calculate position
        let blockX = scene.frame.minX + CGFloat(x) * TerrainBlock.size + TerrainBlock.size / 2
        let blockY = surfaceY - CGFloat(y) * TerrainBlock.size - TerrainBlock.size / 2

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

    // MARK: - Core Chamber

    /// Check if a position is inside the core chamber
    private func isInCoreChamber(x: Int, y: Int) -> Bool {
        let depth = Double(y)

        // Core chamber is at 490-500m depth
        guard depth >= planetConfig.coreDepth && depth < planetConfig.totalDepth else {
            return false
        }

        // Calculate center X position (middle of terrain width)
        let centerX = width / 2

        // Core chamber is 10×10 tiles centered horizontally
        let chamberRadius = 5  // 5 tiles on each side of center
        let xDistance = abs(x - centerX)

        return xDistance <= chamberRadius
    }

    /// Spawn the Dark Matter crystal at the center of the core chamber
    private func spawnCoreCrystal(surfaceY: CGFloat) {
        guard let scene = scene else { return }
        guard !coreCrystalSpawned else { return }

        // Calculate center position of core chamber
        let centerX = width / 2
        let centerY = Int(planetConfig.coreDepth) + 5  // Middle of 10-tile vertical chamber

        // World position
        let blockX = scene.frame.minX + CGFloat(centerX) * TerrainBlock.size + TerrainBlock.size / 2
        let blockY = surfaceY - CGFloat(centerY) * TerrainBlock.size - TerrainBlock.size / 2

        // Create Dark Matter crystal block
        let darkMatter = Material(type: .darkMatter, planetMultiplier: planetConfig.valueMultiplier, soulCrystalBonus: soulCrystalBonus)
        let strataHardness = planetConfig.strata.first(where: { $0.contains(depth: Double(centerY)) })?.hardness ?? 5.0

        let crystalBlock = TerrainBlock(material: darkMatter, depth: Double(centerY), strataHardness: strataHardness, blockType: .normal)
        crystalBlock.position = CGPoint(x: blockX, y: blockY)
        crystalBlock.zPosition = 1
        crystalBlock.name = "\(centerX),\(centerY)"

        scene.addChild(crystalBlock)
        blocks["\(centerX),\(centerY)"] = crystalBlock

        coreCrystalSpawned = true

        print("💎 Dark Matter core crystal spawned at (\(centerX), \(centerY)) - depth \(centerY)m")
    }

    // MARK: - Material Creation

    /// Create a Material instance from a ResourceConfig
    private func createMaterial(from config: ResourceConfig) -> Material? {
        // Map resource type string to MaterialType enum
        guard let materialType = Material.MaterialType(rawValue: config.type) else {
            print("⚠️ Unknown material type: \(config.type)")
            return nil
        }

        return Material(type: materialType, planetMultiplier: planetConfig.valueMultiplier, soulCrystalBonus: soulCrystalBonus)
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
        coreCrystalSpawned = false

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

    /// Clear a 3×3 area around a position (for bomb)
    /// Returns array of materials collected from destroyed blocks
    func clearBombArea(at position: CGPoint) -> [Material] {
        guard let centerGrid = worldToGrid(position) else { return [] }

        var collectedMaterials: [Material] = []

        // Clear 3×3 grid centered on position
        for dy in -1...1 {
            for dx in -1...1 {
                let x = centerGrid.x + dx
                let y = centerGrid.y + dy

                // Remove block and collect material
                if let material = removeBlock(x: x, y: y) {
                    collectedMaterials.append(material)
                }
            }
        }

        print("💣 Bomb cleared \(collectedMaterials.count) blocks")
        return collectedMaterials
    }
}
