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
            }
        }
    }

    // MARK: - Block Generation

    private func generateBlock(x: Int, y: Int, surfaceY: CGFloat) {
        guard let scene = scene else { return }

        let key = "\(x),\(y)"
        guard blocks[key] == nil else { return }  // Already exists

        // Calculate position
        let blockX = scene.frame.minX + CGFloat(x) * TerrainBlock.size + TerrainBlock.size / 2
        let blockY = surfaceY - CGFloat(y) * TerrainBlock.size - TerrainBlock.size / 2

        // Calculate depth in meters (1 tile = 1 meter)
        let depth = Double(y)  // Each tile is 1 meter deep

        // Determine if this block contains a material
        let material = getMaterialForBlock(x: x, y: y, depth: depth)

        // Create block
        let block = TerrainBlock(material: material, depth: depth)
        block.position = CGPoint(x: blockX, y: blockY)
        block.zPosition = 1
        block.name = key  // Store coordinates as name for easy lookup

        scene.addChild(block)
        blocks[key] = block
    }

    // MARK: - Material Distribution

    private func getMaterialForBlock(x: Int, y: Int, depth: Double) -> Material? {
        // Use seeded random for consistent terrain (includes terrain seed for uniqueness per run)
        let seed = (x * 73856093 ^ y * 19349663) ^ terrainSeed

        // Get the strata layer for this depth
        guard let layer = planetConfig.strata.first(where: { $0.contains(depth: depth) }) else {
            return nil
        }

        // Check if this block should have a material (per-block spawn check)
        // Use a different random seed for material selection
        let materialSeed = seed ^ 12345
        let materialRandom = Double((materialSeed & 0xFFFF)) / Double(0xFFFF)

        // Calculate total spawn rate for this layer
        let totalSpawnRate = layer.resources.reduce(0.0) { $0 + $1.spawnRate }

        guard materialRandom < totalSpawnRate else { return nil }

        // Select which resource to spawn based on weighted probabilities
        var accumulated: Double = 0.0
        for resource in layer.resources {
            accumulated += resource.spawnRate
            if materialRandom < accumulated {
                // Found the material to spawn
                return createMaterial(from: resource)
            }
        }

        return nil
    }

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

        print("🗑️ Cleared all terrain - blocks: 0, chunks: 0")
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
