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
    private let width: Int  // Grid cells wide (calculated based on screen width)
    private let chunkHeight: Int = 50  // Grid cells per chunk
    private let planetConfig: PlanetConfig
    private var terrainSeed: Int  // Unique seed for this terrain generation
    private let soulCrystalBonus: Double  // Soul Crystal earnings multiplier

    // Continuous terrain system
    private var terrainLayers: [Int: TerrainLayer] = [:]  // Key: stratum index (first chunk only)
    private var allTerrainLayers: [(layer: TerrainLayer, depthRange: ClosedRange<Double>)] = []  // All layers with their depth ranges
    private var materialDeposits: [String: MaterialDeposit] = [:]  // Key: "x,y"
    private var physicsBlocks: [String: SKNode] = [:]  // Key: "x,y" - Invisible physics bodies
    private var collisionGrid: CollisionGrid!
    private var loadedStratumIndices: Set<Int> = []  // Which strata are loaded
    private var loadedChunks: Set<Int> = []  // Chunk numbers that are loaded

    // Vein and obstacle generation data
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

        // Initialize collision grid
        let gridHeight = Int(ceil(config.totalDepth))
        self.collisionGrid = CollisionGrid(gridSize: (width: width, height: gridHeight))

        print("🌍 TerrainManager initialized for \(config.name)")
        print("   - Seed: \(terrainSeed)")
        print("   - Total depth: \(config.totalDepth)m")
        print("   - Strata layers: \(config.strata.count)")
        print("   - Grid size: \(width)×\(gridHeight)")
        print("   - Soul Crystal bonus: \(soulCrystalBonus)x")

        // Load all terrain layers immediately (not lazy loading)
        loadAllTerrainLayers()
    }

    // MARK: - Terrain Layer Loading

    /// Load all terrain layers immediately at initialization
    private func loadAllTerrainLayers() {
        guard let scene = scene else { return }

        let surfaceY = scene.frame.maxY - 100

        print("🏔️ Loading all terrain layers immediately...")

        // Load each stratum (same logic as Level Explorer)
        for (stratumIndex, stratum) in planetConfig.strata.enumerated() {
            loadStratumLayer(stratumIndex: stratumIndex, surfaceY: surfaceY)
            loadedStratumIndices.insert(stratumIndex)
        }

        print("✅ All \(planetConfig.strata.count) terrain layers loaded")
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

        // Note: Terrain layers are already loaded at initialization
        // This method now only generates obstacles and materials for this chunk

        // Generate obstacles and materials for this chunk
        generateObstaclesForChunk(chunkNumber: chunkNumber, startY: startY, endY: endY)
        generateVeinsForChunk(chunkNumber: chunkNumber, startY: startY, endY: endY)

        // Populate collision grid, create material deposits, and physics bodies
        for y in startY..<endY {
            for x in 0..<width {
                // Skip positions that have been drilled
                let key = "\(x),\(y)"
                if drilledPositions.contains(key) {
                    collisionGrid.setCell(x: x, y: y, to: .empty)
                    continue
                }

                // Skip core chamber
                if isInCoreChamber(x: x, y: y) {
                    collisionGrid.setCell(x: x, y: y, to: .empty)

                    // Spawn Dark Matter crystal once
                    let depth = Double(y)
                    if !coreCrystalSpawned && depth >= planetConfig.coreDepth {
                        spawnCoreCrystal(surfaceY: surfaceY)
                    }
                    continue
                }

                // Check for obstacle
                if let obstacleType = obstacleMap[key] {
                    collisionGrid.setCell(x: x, y: y, to: .obstacle(obstacleType))
                    createPhysicsBody(x: x, y: y, surfaceY: surfaceY)
                }
                // Check for material
                else if let material = veinMap[key] {
                    collisionGrid.setCell(x: x, y: y, to: .material(material))
                    createMaterialDeposit(x: x, y: y, material: material, surfaceY: surfaceY)
                    createPhysicsBody(x: x, y: y, surfaceY: surfaceY)
                }
                // Normal terrain
                else {
                    collisionGrid.setCell(x: x, y: y, to: .terrain)
                    createPhysicsBody(x: x, y: y, surfaceY: surfaceY)
                }
            }
        }
    }

    /// Load a continuous terrain layer for an entire stratum
    private func loadStratumLayer(stratumIndex: Int, surfaceY: CGFloat) {
        guard let scene = scene else { return }

        let stratum = planetConfig.strata[stratumIndex]

        // Use canonical stratum name to TerrainType mapping
        let terrainType = TerrainType.fromStratumName(stratum.name)

        let levelWidth = CGFloat(width) * TerrainBlock.size

        // Create single layer for entire stratum
        let layer = TerrainLayer(
            stratumRange: stratum.depthMin...stratum.depthMax,
            terrainType: terrainType,
            levelWidth: levelWidth,
            surfaceColors: stratum.surfaceGradient,
            excavatedColors: stratum.excavatedGradient
        )

        // Deeper strata need higher z-positions so their excavated layers render in front
        // This prevents lower strata from showing through upper strata when drilling
        layer.zPosition = CGFloat(stratumIndex)
        layer.positionInWorld(surfaceY: surfaceY, sceneMinX: scene.frame.minX)
        scene.addChild(layer)
        terrainLayers[stratumIndex] = layer
        allTerrainLayers.append((layer: layer, depthRange: stratum.depthMin...stratum.depthMax))

        print("🏔️ Created stratum layer \(stratumIndex): \(stratum.name)")
        print("   - Depth range: \(stratum.depthMin)...\(stratum.depthMax)m")
        print("   - Size: \(layer.layerSize)")
        print("   - TerrainType: \(terrainType)")
        print("   - Surface colors from mars.json: \(stratum.surfaceGradient.map { $0.toHex() })")
        print("   - Excavated colors from mars.json: \(stratum.excavatedGradient.map { $0.toHex() })")
        print("   - Layer zPosition: \(layer.zPosition)")
    }

    /// Create a material deposit node at grid position
    private func createMaterialDeposit(x: Int, y: Int, material: Material, surfaceY: CGFloat) {
        guard let scene = scene else { return }

        let key = "\(x),\(y)"
        guard materialDeposits[key] == nil else { return }  // Already exists

        // Calculate world position (center of grid cell)
        let worldX = scene.frame.minX + (CGFloat(x) + 0.5) * TerrainBlock.size
        let worldY = surfaceY - (CGFloat(y) + 0.5) * TerrainBlock.size

        let deposit = MaterialDeposit(material: material, gridPosition: (x, y))
        deposit.position = CGPoint(x: worldX, y: worldY)
        deposit.zPosition = 10  // Above terrain layers

        scene.addChild(deposit)
        materialDeposits[key] = deposit
    }

    /// Create invisible physics body at grid position for collision
    private func createPhysicsBody(x: Int, y: Int, surfaceY: CGFloat) {
        guard let scene = scene else { return }

        let key = "\(x),\(y)"
        guard physicsBlocks[key] == nil else { return }  // Already exists

        // Calculate world position (center of grid cell)
        let worldX = scene.frame.minX + (CGFloat(x) + 0.5) * TerrainBlock.size
        let worldY = surfaceY - (CGFloat(y) + 0.5) * TerrainBlock.size

        // Create invisible node with physics body
        let physicsNode = SKNode()
        physicsNode.position = CGPoint(x: worldX, y: worldY)
        physicsNode.name = key  // Store coordinates for lookup

        // Setup physics body (same as old TerrainBlock)
        let blockSize = CGSize(width: TerrainBlock.size, height: TerrainBlock.size)
        physicsNode.physicsBody = SKPhysicsBody(rectangleOf: blockSize)
        physicsNode.physicsBody?.isDynamic = false  // Static terrain
        physicsNode.physicsBody?.categoryBitMask = 2  // Terrain category
        physicsNode.physicsBody?.contactTestBitMask = 1  // Player
        physicsNode.physicsBody?.collisionBitMask = 1  // Player

        scene.addChild(physicsNode)
        physicsBlocks[key] = physicsNode
    }

    private func unloadChunk(_ chunkNumber: Int) {
        let startY = chunkNumber * chunkHeight
        let endY = startY + chunkHeight

        for y in startY..<endY {
            for x in 0..<width {
                let key = "\(x),\(y)"

                // Remove material deposit if exists
                if let deposit = materialDeposits[key] {
                    deposit.removeFromParent()
                    materialDeposits.removeValue(forKey: key)
                }

                // Remove physics body if exists
                if let physicsBlock = physicsBlocks[key] {
                    physicsBlock.removeFromParent()
                    physicsBlocks.removeValue(forKey: key)
                }

                // Clear collision grid cell
                collisionGrid.setCell(x: x, y: y, to: .empty)

                // Remove from vein map and obstacle map
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
        // Generate materials using clustering system
        // Divide the chunk into 4×4 block regions for cluster generation
        // (Adjusted from 16×16 to account for 64px blocks instead of 16px blocks)
        let clusterRegionSize = 4

        // Calculate which cluster regions overlap this chunk
        let startRegionY = startY / clusterRegionSize
        let endRegionY = (endY - 1) / clusterRegionSize + 1
        let numRegionsX = (width - 1) / clusterRegionSize + 1

        // Process each cluster region
        for regionY in startRegionY..<endRegionY {
            for regionX in 0..<numRegionsX {
                let regionCenterX = regionX * clusterRegionSize + clusterRegionSize / 2
                let regionCenterY = regionY * clusterRegionSize + clusterRegionSize / 2
                let depth = Double(regionCenterY)

                // Get the strata layer for this depth
                guard let layer = planetConfig.strata.first(where: { $0.contains(depth: depth) }) else {
                    continue
                }

                // Generate clusters for each resource type in this layer
                for (resourceIndex, resource) in layer.resources.enumerated() {
                    // All resources must have clustering parameters defined
                    guard let clusterRadiusMin = resource.clusterRadiusMin,
                          let clusterRadiusMax = resource.clusterRadiusMax,
                          let clusterSizeMin = resource.clusterSizeMin,
                          let clusterSizeMax = resource.clusterSizeMax else {
                        print("⚠️ Resource \(resource.type) missing clustering parameters")
                        continue
                    }

                    generateClustersInRegion(
                        regionX: regionX,
                        regionY: regionY,
                        regionSize: clusterRegionSize,
                        resource: resource,
                        resourceIndex: resourceIndex,
                        clusterRadiusMin: clusterRadiusMin,
                        clusterRadiusMax: clusterRadiusMax,
                        clusterSizeMin: clusterSizeMin,
                        clusterSizeMax: clusterSizeMax
                    )
                }
            }
        }
    }

    /// Generate material clusters in a region using the clustering system
    private func generateClustersInRegion(
        regionX: Int,
        regionY: Int,
        regionSize: Int,
        resource: ResourceConfig,
        resourceIndex: Int,
        clusterRadiusMin: Int,
        clusterRadiusMax: Int,
        clusterSizeMin: Int,
        clusterSizeMax: Int
    ) {
        // Determine if this region should have a cluster
        let regionSeed = generateSeed(x: regionX, y: regionY, offset: resourceIndex * 10000)
        let spawnChance = Double((regionSeed & 0xFFFF)) / Double(0xFFFF)

        // Use seedRate as cluster spawn probability
        guard spawnChance < resource.seedRate else { return }

        // Choose cluster center within the region
        let centerSeed = generateSeed(x: regionX, y: regionY, offset: resourceIndex * 10000 + 1)
        let clusterCenterX = regionX * regionSize + seededRandom(min: 0, max: regionSize - 1, seed: centerSeed)
        let clusterCenterY = regionY * regionSize + seededRandom(min: 0, max: regionSize - 1, seed: centerSeed + 1)

        // Keep within bounds
        guard clusterCenterX >= 0 && clusterCenterX < width && clusterCenterY >= 0 else { return }

        // Choose cluster radius
        let radiusSeed = generateSeed(x: clusterCenterX, y: clusterCenterY, offset: resourceIndex * 10000 + 2)
        let clusterRadius = seededRandom(min: clusterRadiusMin, max: clusterRadiusMax, seed: radiusSeed)

        // Choose number of veins in cluster
        let sizeSeed = generateSeed(x: clusterCenterX, y: clusterCenterY, offset: resourceIndex * 10000 + 3)
        let numVeins = seededRandom(min: clusterSizeMin, max: clusterSizeMax, seed: sizeSeed)

        // Create material for this cluster
        guard let material = createMaterial(from: resource) else { return }

        // Place veins within cluster radius
        for veinIndex in 0..<numVeins {
            // Choose position within cluster radius using polar coordinates
            let angleSeed = generateSeed(x: clusterCenterX, y: clusterCenterY, offset: resourceIndex * 10000 + 100 + veinIndex * 2)
            let distanceSeed = generateSeed(x: clusterCenterX, y: clusterCenterY, offset: resourceIndex * 10000 + 101 + veinIndex * 2)

            let angle = Double(angleSeed & 0xFFFF) / Double(0xFFFF) * 2.0 * .pi
            let distance = sqrt(Double(distanceSeed & 0xFFFF) / Double(0xFFFF)) * Double(clusterRadius)

            let veinX = clusterCenterX + Int(cos(angle) * distance)
            let veinY = clusterCenterY + Int(sin(angle) * distance)

            // Keep within bounds
            guard veinX >= 0 && veinX < width && veinY >= 0 else { continue }

            let veinKey = "\(veinX),\(veinY)"
            guard veinMap[veinKey] == nil else { continue }

            // Grow vein from this position
            let veinSizeSeed = generateSeed(x: veinX, y: veinY, offset: resourceIndex * 10000 + 1000 + veinIndex)
            let veinSize = seededRandom(min: resource.veinSizeMin, max: resource.veinSizeMax, seed: veinSizeSeed)
            growVein(startX: veinX, startY: veinY, material: material, remainingSize: veinSize, baseSeed: veinSizeSeed)
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
        guard !coreCrystalSpawned else { return }

        // Calculate center position of core chamber
        let centerX = width / 2
        let centerY = Int(planetConfig.coreDepth) + 5  // Middle of 10-tile vertical chamber

        // Create Dark Matter material
        let darkMatter = Material(type: .darkMatter, planetMultiplier: planetConfig.valueMultiplier, soulCrystalBonus: soulCrystalBonus)

        // Add to grid and create deposit
        collisionGrid.setCell(x: centerX, y: centerY, to: .material(darkMatter))
        createMaterialDeposit(x: centerX, y: centerY, material: darkMatter, surfaceY: surfaceY)

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

    // MARK: - Grid Access

    /// Get cell type at grid coordinates
    func getCell(x: Int, y: Int) -> CollisionGrid.GridCell? {
        return collisionGrid.cellAt(x: x, y: y)
    }

    /// Get stratum hardness at a specific depth
    func getHardnessAtDepth(_ depth: Double) -> Double? {
        return planetConfig.strata.first(where: { $0.contains(depth: depth) })?.hardness
    }

    /// Update circular consumption visual for a block being drilled
    func updateConsumptionMask(x: Int, y: Int, progress: CGFloat) {
        // Convert grid Y (blocks) to depth in meters
        let depth = Double(y) * Double(TerrainBlock.metersPerBlock)

        // Find which terrain layer contains this depth
        for entry in allTerrainLayers {
            if entry.depthRange.contains(depth) {
                entry.layer.updateConsumptionMask(
                    gridX: x,
                    gridY: y,
                    progress: progress,
                    blockSize: TerrainBlock.size
                )
                return
            }
        }
    }

    /// Remove a block completely (called when drilling animation completes)
    func removeBlock(x: Int, y: Int) -> Material? {
        let key = "\(x),\(y)"

        // Check if block exists
        guard let cell = collisionGrid.cellAt(x: x, y: y) else { return nil }

        // Skip empty cells
        if case .empty = cell {
            return nil
        }

        var material: Material?

        // Extract material if present
        if case .material(let mat) = cell {
            material = mat

            // Remove material deposit visual
            if let deposit = materialDeposits[key] {
                deposit.removeWithAnimation { }
                materialDeposits.removeValue(forKey: key)
            } else {
                print("📦 ⚠️ No MaterialDeposit visual found in dictionary for (\(x),\(y))!")
            }
        }

        // Mark as fully empty
        collisionGrid.setCell(x: x, y: y, to: .empty)

        // Remove physics body
        if let physicsBlock = physicsBlocks[key] {
            physicsBlock.removeFromParent()
            physicsBlocks.removeValue(forKey: key)
        }

        // Cut surface layer to reveal excavated terrain
        cutSurfaceLayer(x: x, y: y)

        // Mark as drilled
        drilledPositions.insert(key)

        return material
    }

    /// Cut the surface layer at the given grid position to reveal excavated terrain
    private func cutSurfaceLayer(x: Int, y: Int) {
        // Call cutSurfaceAt on all layers - each layer will check if the block is within its range
        // This ensures that layers at boundaries properly cut their surfaces (e.g., when drilling
        // at the top of the stone layer, the sand layer's bottom surface also gets cut)
        for entry in allTerrainLayers {
            entry.layer.cutSurfaceAt(gridX: x, gridY: y, blockSize: TerrainBlock.size)
        }
    }

    /// Remove all terrain (for game over / reset)
    func removeAllTerrain() {
        // Remove all terrain layers (includes chunks)
        for entry in allTerrainLayers {
            entry.layer.removeFromParent()
        }
        terrainLayers.removeAll()
        allTerrainLayers.removeAll()

        // Remove material deposits
        for deposit in materialDeposits.values {
            deposit.removeFromParent()
        }
        materialDeposits.removeAll()

        // Remove physics bodies
        for physicsBlock in physicsBlocks.values {
            physicsBlock.removeFromParent()
        }
        physicsBlocks.removeAll()

        // Reinitialize collision grid
        let gridHeight = Int(planetConfig.totalDepth)
        collisionGrid = CollisionGrid(gridSize: (width: width, height: gridHeight))

        // Clear all data
        loadedStratumIndices.removeAll()
        loadedChunks.removeAll()
        veinMap.removeAll()
        obstacleMap.removeAll()
        drilledPositions.removeAll()
        coreCrystalSpawned = false

        print("🗑️ Cleared all terrain")
    }

    /// Convert world position to grid coordinates
    func worldToGrid(_ position: CGPoint) -> (x: Int, y: Int)? {
        guard let scene = scene else { return nil }

        let surfaceY = scene.frame.maxY - 100
        let x = Int((position.x - scene.frame.minX) / TerrainBlock.size)
        let y = Int((surfaceY - position.y) / TerrainBlock.size)

        return (x, y)
    }

    /// Clear a circular area around a position (for bomb)
    /// Returns array of materials collected from destroyed blocks
    func clearBombArea(at position: CGPoint) -> [Material] {
        guard let centerGrid = worldToGrid(position) else {
            print("💣 ❌ Bomb failed: invalid grid position")
            return []
        }

        print("💣 Bomb activated at grid (\(centerGrid.x), \(centerGrid.y))")
        var collectedMaterials: [Material] = []
        var blocksChecked = 0
        var blocksDestroyed = 0

        // Blast radius: 2.5 blocks = 160 pixels (reasonable for 64px blocks)
        let blastRadiusInBlocks = 2.5
        let blastRadiusSquared = blastRadiusInBlocks * blastRadiusInBlocks

        // Calculate bounds to check (3 blocks in each direction to cover 2.5 radius)
        let searchRadius = Int(ceil(blastRadiusInBlocks))

        // Find all blocks within circular blast radius
        for dy in -searchRadius...searchRadius {
            for dx in -searchRadius...searchRadius {
                // Check if this block is within circular radius
                let distanceSquared = Double(dx * dx + dy * dy)
                if distanceSquared <= blastRadiusSquared {
                    let x = centerGrid.x + dx
                    let y = centerGrid.y + dy
                    blocksChecked += 1

                    print("💣 Checking block (\(x),\(y)) - distance: \(sqrt(distanceSquared))")

                    // Remove block instantly and collect material
                    if let material = removeBlock(x: x, y: y) {
                        collectedMaterials.append(material)
                        blocksDestroyed += 1
                        print("💣 ✅ Destroyed block (\(x),\(y)) - got \(material.type)")
                    } else {
                        print("💣 ⚠️ Block (\(x),\(y)) returned nil (empty or already removed)")
                    }
                }
            }
        }

        print("💣 Bomb complete: checked \(blocksChecked) blocks, destroyed \(blocksDestroyed), collected \(collectedMaterials.count) materials")
        return collectedMaterials
    }
}
