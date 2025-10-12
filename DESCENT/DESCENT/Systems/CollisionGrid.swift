//
//  CollisionGrid.swift
//  DESCENT
//
//  Grid-based collision system for continuous terrain
//  Maintains invisible 64×64 grid for gameplay precision
//

import CoreGraphics

class CollisionGrid {

    // MARK: - Properties

    let gridSize: (width: Int, height: Int)
    private let cellSize: CGFloat = 64  // Matches TerrainBlock.size

    // 2D grid storing cell contents
    private var grid: [[GridCell]]

    // MARK: - Cell Type

    enum GridCell {
        case empty
        case terrain
        case material(Material)
        case obstacle(TerrainBlock.BlockType)
    }

    // MARK: - Initialization

    init(gridSize: (width: Int, height: Int)) {
        self.gridSize = gridSize

        // Initialize grid with empty cells
        self.grid = Array(
            repeating: Array(repeating: .empty, count: gridSize.width),
            count: gridSize.height
        )

        print("🔲 CollisionGrid initialized: \(gridSize.width)×\(gridSize.height) cells")
    }

    // MARK: - Grid Access

    /// Get cell at grid position (x, y)
    func cellAt(x: Int, y: Int) -> GridCell? {
        guard isValidPosition(x: x, y: y) else { return nil }
        return grid[y][x]
    }

    /// Set cell at grid position (x, y)
    func setCell(x: Int, y: Int, to cell: GridCell) {
        guard isValidPosition(x: x, y: y) else { return }
        grid[y][x] = cell
    }

    /// Check if grid position is valid
    func isValidPosition(x: Int, y: Int) -> Bool {
        return x >= 0 && x < gridSize.width && y >= 0 && y < gridSize.height
    }

    // MARK: - Material Management

    /// Remove material from grid position and return it
    func removeMaterial(at position: (x: Int, y: Int)) -> Material? {
        guard isValidPosition(x: position.x, y: position.y) else { return nil }

        if case .material(let material) = grid[position.y][position.x] {
            grid[position.y][position.x] = .empty
            return material
        }

        return nil
    }

    /// Check if position contains drillable material
    func hasMaterial(at position: (x: Int, y: Int)) -> Bool {
        guard let cell = cellAt(x: position.x, y: position.y) else { return false }
        if case .material = cell {
            return true
        }
        return false
    }

    // MARK: - Collision Detection

    /// Check if a rect collides with any solid cells
    /// Returns the cell type if collision occurs
    func checkCollision(rect: CGRect, surfaceY: CGFloat) -> GridCell? {
        // Convert rect to grid bounds
        let gridBounds = rectToGridBounds(rect: rect, surfaceY: surfaceY)

        // Check all cells in the bounding box
        for y in gridBounds.minY...gridBounds.maxY {
            for x in gridBounds.minX...gridBounds.maxX {
                if let cell = cellAt(x: x, y: y) {
                    switch cell {
                    case .empty:
                        continue
                    case .terrain, .obstacle, .material:
                        return cell
                    }
                }
            }
        }

        return nil
    }

    /// Convert world rect to grid bounds
    private func rectToGridBounds(rect: CGRect, surfaceY: CGFloat) -> (minX: Int, maxX: Int, minY: Int, maxY: Int) {
        // Convert world coordinates to grid coordinates
        let minX = Int(floor(rect.minX / cellSize))
        let maxX = Int(floor(rect.maxX / cellSize))

        // Y coordinates: depth increases downward from surface
        let depthMin = surfaceY - rect.maxY
        let depthMax = surfaceY - rect.minY
        let minY = Int(floor(depthMin / cellSize))
        let maxY = Int(floor(depthMax / cellSize))

        return (
            minX: max(0, minX),
            maxX: min(gridSize.width - 1, maxX),
            minY: max(0, minY),
            maxY: min(gridSize.height - 1, maxY)
        )
    }

    // MARK: - Coordinate Conversion

    /// Convert world position to grid position
    func worldToGrid(position: CGPoint, surfaceY: CGFloat) -> (x: Int, y: Int) {
        let x = Int(floor(position.x / cellSize))
        let depth = surfaceY - position.y
        let y = Int(floor(depth / cellSize))
        return (x, y)
    }

    /// Convert grid position to world position (center of cell)
    func gridToWorld(gridX: Int, gridY: Int, surfaceY: CGFloat) -> CGPoint {
        let x = CGFloat(gridX) * cellSize + cellSize / 2  // Center of cell
        let y = surfaceY - (CGFloat(gridY) * cellSize + cellSize / 2)
        return CGPoint(x: x, y: y)
    }

    // MARK: - Debug

    /// Get grid statistics
    func getStatistics() -> (empty: Int, terrain: Int, materials: Int, obstacles: Int) {
        var empty = 0, terrain = 0, materials = 0, obstacles = 0

        for row in grid {
            for cell in row {
                switch cell {
                case .empty: empty += 1
                case .terrain: terrain += 1
                case .material: materials += 1
                case .obstacle: obstacles += 1
                }
            }
        }

        return (empty: empty, terrain: terrain, materials: materials, obstacles: obstacles)
    }
}
