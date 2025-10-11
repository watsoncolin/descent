//
//  TextureGenerator.swift
//  DESCENT
//
//  Procedural pixel art texture generator for minerals
//

import SpriteKit

class TextureGenerator {

    // MARK: - Shared Instance
    static let shared = TextureGenerator()

    // Texture cache to avoid regenerating
    private var textureCache: [String: SKTexture] = [:]

    // MARK: - Public API

    /// Get or generate a texture for a material type
    func texture(for materialType: Material.MaterialType) -> SKTexture {
        let cacheKey = materialType.rawValue

        if let cached = textureCache[cacheKey] {
            return cached
        }

        let texture = generateTexture(for: materialType)
        textureCache[cacheKey] = texture
        return texture
    }

    /// Get or generate a texture for terrain (dirt/stone) at a given depth
    func terrainTexture(depth: Double) -> SKTexture {
        let cacheKey = "terrain_\(Int(depth / 50))" // Cache by 50m intervals

        if let cached = textureCache[cacheKey] {
            return cached
        }

        let texture = generateTerrainTexture(depth: depth)
        textureCache[cacheKey] = texture
        return texture
    }

    /// Generate a unique crack texture based on damage level (1 = light cracks, 2 = medium, 3 = heavy)
    /// Always generates a new random crack pattern - NOT cached
    func crackTexture(level: Int) -> SKTexture {
        return generateCrackTexture(level: level)
    }

    /// Get or generate texture for Bedrock obstacle
    func bedrockTexture() -> SKTexture {
        let cacheKey = "bedrock"
        if let cached = textureCache[cacheKey] {
            return cached
        }
        let texture = generateBedrockTexture()
        textureCache[cacheKey] = texture
        return texture
    }

    /// Get or generate texture for Hard Crystal obstacle
    func hardCrystalTexture() -> SKTexture {
        let cacheKey = "hardCrystal"
        if let cached = textureCache[cacheKey] {
            return cached
        }
        let texture = generateHardCrystalTexture()
        textureCache[cacheKey] = texture
        return texture
    }

    /// Get or generate texture for Reinforced Rock obstacle
    func reinforcedRockTexture() -> SKTexture {
        let cacheKey = "reinforcedRock"
        if let cached = textureCache[cacheKey] {
            return cached
        }
        let texture = generateReinforcedRockTexture()
        textureCache[cacheKey] = texture
        return texture
    }

    // MARK: - Material Textures

    private func generateTexture(for materialType: Material.MaterialType) -> SKTexture {
        let size = 24 // 24x24 pixel art
        let scale: CGFloat = 3.0 // Use 3x for retina displays

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        switch materialType {
        // Tier 1 - Common
        case .carbon, .coal:
            drawCoalTexture(context: context, size: size)
        case .iron:
            drawIronTexture(context: context, size: size)
        case .copper:
            drawCopperTexture(context: context, size: size)
        case .silicon:
            drawSiliconTexture(context: context, size: size)
        case .aluminum:
            drawAluminumTexture(context: context, size: size)

        // Tier 2 - Uncommon
        case .silver:
            drawSilverTexture(context: context, size: size)
        case .gold:
            drawGoldTexture(context: context, size: size)

        // Tier 3 - Rare
        case .platinum:
            drawPlatinumTexture(context: context, size: size)
        case .ruby:
            drawGemTexture(context: context, size: size, color: UIColor(red: 0.88, green: 0.07, blue: 0.37, alpha: 1.0))
        case .emerald:
            drawGemTexture(context: context, size: size, color: UIColor(red: 0.31, green: 0.78, blue: 0.47, alpha: 1.0))
        case .diamond:
            drawGemTexture(context: context, size: size, color: UIColor(red: 0.73, green: 0.95, blue: 1.0, alpha: 1.0))
        case .titanium:
            drawTitaniumTexture(context: context, size: size)
        case .neodymium:
            drawNeodymiumTexture(context: context, size: size)
        case .rhodium:
            drawRhodiumTexture(context: context, size: size)

        // Tier 4 - Core
        case .darkMatter:
            drawDarkMatterTexture(context: context, size: size)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    // MARK: - Crack Textures

    private func generateCrackTexture(level: Int) -> SKTexture {
        let size = 24
        let scale: CGFloat = 3.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        // Start with transparent background
        context.clear(CGRect(x: 0, y: 0, width: size, height: size))

        // Draw cracks in dark brown-gray to blend with terrain (more transparent)
        let crackColor = UIColor(red: 0.15, green: 0.12, blue: 0.10, alpha: 0.5)
        crackColor.setStroke()

        context.setLineWidth(1.0)
        context.setLineCap(.round)

        switch level {
        case 1: // Light cracks - single thin crack
            drawLightCracks(context: context, size: size)
        case 2: // Medium cracks - branching cracks
            drawMediumCracks(context: context, size: size)
        case 3: // Heavy cracks - spiderweb pattern
            drawHeavyCracks(context: context, size: size)
        default:
            break
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    private func drawLightCracks(context: CGContext, size: Int) {
        // Single crack from top center (drill impact point) downward
        let drillImpact = CGPoint(x: CGFloat(size/2) + CGFloat.random(in: -2...2), y: 2)

        // First crack goes mostly downward with some randomness
        let endX = CGFloat(size/2) + CGFloat.random(in: -6...6)
        let endY = CGFloat(size - 2)
        let end = CGPoint(x: endX, y: endY)

        // Create smooth crack with Bezier curves
        let segments = Int.random(in: 3...4)
        var points: [CGPoint] = [drillImpact]

        // Generate control points along the path
        for i in 1..<segments {
            let progress = CGFloat(i) / CGFloat(segments)
            let baseX = drillImpact.x + (end.x - drillImpact.x) * progress
            let baseY = drillImpact.y + (end.y - drillImpact.y) * progress

            // Add organic noise (smaller jitter near impact, larger further away)
            let jitterScale = progress * 0.5 + 0.5  // 0.5 to 1.0
            let jitterX = CGFloat.random(in: -4...4) * jitterScale
            let jitterY = CGFloat.random(in: -2...2) * jitterScale

            points.append(CGPoint(x: baseX + jitterX, y: baseY + jitterY))
        }
        points.append(end)

        // Draw crack with variable width (thicker at top, thinner at bottom)
        drawOrganicCrack(context: context, points: points, startWidth: 1.2, endWidth: 0.6)

        // Add tiny micro-cracks near the main crack (10-20% of the time)
        if Double.random(in: 0...1) < 0.15 {
            let microStart = points[Int.random(in: 1..<points.count-1)]
            let microEnd = CGPoint(
                x: microStart.x + CGFloat.random(in: -4...4),
                y: microStart.y + CGFloat.random(in: 3...6)
            )
            drawOrganicCrack(context: context, points: [microStart, microEnd], startWidth: 0.7, endWidth: 0.4)
        }
    }

    private func drawMediumCracks(context: CGContext, size: Int) {
        // Main crack from top center, plus 1-2 additional branching cracks
        let drillImpact = CGPoint(x: CGFloat(size/2) + CGFloat.random(in: -2...2), y: 2)

        // Draw main crack downward with more segments for organic look
        let mainEndX = CGFloat(size/2) + CGFloat.random(in: -8...8)
        let mainEnd = CGPoint(x: mainEndX, y: CGFloat(size - 2))

        let segments = Int.random(in: 4...5)
        var mainCrackPoints: [CGPoint] = [drillImpact]

        for i in 1..<segments {
            let progress = CGFloat(i) / CGFloat(segments)
            let baseX = drillImpact.x + (mainEnd.x - drillImpact.x) * progress
            let baseY = drillImpact.y + (mainEnd.y - drillImpact.y) * progress

            let jitterScale = progress * 0.6 + 0.4
            let jitterX = CGFloat.random(in: -5...5) * jitterScale
            let jitterY = CGFloat.random(in: -3...3) * jitterScale

            mainCrackPoints.append(CGPoint(x: baseX + jitterX, y: baseY + jitterY))
        }
        mainCrackPoints.append(mainEnd)

        // Draw main crack with variable width
        drawOrganicCrack(context: context, points: mainCrackPoints, startWidth: 1.3, endWidth: 0.7)

        // Add 1-2 branching cracks from points along the main crack
        let branchCount = Int.random(in: 1...2)
        for _ in 0..<branchCount {
            // Pick a random point along the main crack (not at the ends)
            let branchStartIndex = Int.random(in: 1..<mainCrackPoints.count-1)
            let branchStart = mainCrackPoints[branchStartIndex]

            // Branch to the side
            let branchDirection: CGFloat = Bool.random() ? -1 : 1
            let branchAngle = CGFloat.random(in: .pi/3 ... 2 * .pi/3)

            var branchPoints: [CGPoint] = [branchStart]
            let branchSegments = Int.random(in: 2...3)

            for i in 1...branchSegments {
                let progress = CGFloat(i) / CGFloat(branchSegments)
                let length = CGFloat(size) * 0.4 * progress

                let baseX = branchStart.x + cos(branchAngle) * length * branchDirection
                let baseY = branchStart.y + sin(branchAngle) * length

                let jitter = CGFloat.random(in: -3...3)
                branchPoints.append(CGPoint(x: baseX + jitter, y: baseY + jitter))
            }

            drawOrganicCrack(context: context, points: branchPoints, startWidth: 1.0, endWidth: 0.5)
        }

        // Add micro-cracks (2-3 small ones)
        for _ in 0...Int.random(in: 1...2) {
            let microStart = mainCrackPoints[Int.random(in: 1..<mainCrackPoints.count-1)]
            let microEnd = CGPoint(
                x: microStart.x + CGFloat.random(in: -5...5),
                y: microStart.y + CGFloat.random(in: 2...6)
            )
            drawOrganicCrack(context: context, points: [microStart, microEnd], startWidth: 0.6, endWidth: 0.3)
        }
    }

    private func drawHeavyCracks(context: CGContext, size: Int) {
        // Heavy damage: multiple cracks radiating from top center drill impact
        let drillImpact = CGPoint(x: CGFloat(size/2) + CGFloat.random(in: -2...2), y: 2)

        // 3-5 major cracks radiating outward from impact point
        let crackCount = Int.random(in: 4...6)
        for i in 0..<crackCount {
            // Angle from top (0 radians) spreading outward
            // Concentrate cracks in downward hemisphere (0 to π radians)
            let baseAngle = (CGFloat(i) / CGFloat(crackCount)) * .pi + CGFloat.random(in: -0.25...0.25)
            let angle = baseAngle + .pi/2 // Offset to spread from top

            var crackPoints: [CGPoint] = [drillImpact]

            // Create organic crack radiating outward
            let segments = Int.random(in: 4...6)
            for segment in 1...segments {
                let progress = CGFloat(segment) / CGFloat(segments)
                let length = CGFloat(size) * 0.7 * progress

                let baseX = drillImpact.x + cos(angle) * length
                let baseY = drillImpact.y + sin(angle) * length

                // Add perpendicular jitter for organic appearance
                let jitterScale = progress * 0.7 + 0.3
                let perpAngle = angle + .pi / 2
                let jitter = CGFloat.random(in: -4...4) * jitterScale

                let x = baseX + cos(perpAngle) * jitter
                let y = baseY + sin(perpAngle) * jitter

                crackPoints.append(CGPoint(x: x, y: y))
            }

            drawOrganicCrack(context: context, points: crackPoints, startWidth: 1.4, endWidth: 0.5)

            // Add small branches from some major cracks (50% chance)
            if Bool.random() && crackPoints.count > 2 {
                let branchStart = crackPoints[Int.random(in: 2..<crackPoints.count-1)]
                let branchAngle = angle + CGFloat.random(in: -.pi/3 ... .pi/3)
                let branchLength = CGFloat.random(in: 4...8)

                var branchPoints: [CGPoint] = [branchStart]
                for j in 1...2 {
                    let progress = CGFloat(j) / 2.0
                    let x = branchStart.x + cos(branchAngle) * branchLength * progress + CGFloat.random(in: -2...2)
                    let y = branchStart.y + sin(branchAngle) * branchLength * progress + CGFloat.random(in: -2...2)
                    branchPoints.append(CGPoint(x: x, y: y))
                }
                drawOrganicCrack(context: context, points: branchPoints, startWidth: 0.8, endWidth: 0.4)
            }
        }

        // Add many micro-cracks scattered across the damaged area (4-6 tiny cracks)
        for _ in 0...Int.random(in: 3...5) {
            let startX = CGFloat(size/2) + CGFloat.random(in: -10...10)
            let startY = CGFloat.random(in: 6...18)
            let start = CGPoint(x: startX, y: startY)

            let angle = CGFloat.random(in: .pi/4 ... 3 * .pi/4) // Downward angles
            let length = CGFloat.random(in: 3...6)

            let endX = startX + cos(angle) * length + CGFloat.random(in: -2...2)
            let endY = startY + sin(angle) * length + CGFloat.random(in: -2...2)
            let end = CGPoint(x: endX, y: endY)

            drawOrganicCrack(context: context, points: [start, end], startWidth: 0.5, endWidth: 0.3)
        }
    }

    /// Draw an organic-looking crack using smooth Bezier curves with variable width
    private func drawOrganicCrack(context: CGContext, points: [CGPoint], startWidth: CGFloat, endWidth: CGFloat) {
        guard points.count >= 2 else { return }

        // Save the current graphics state
        context.saveGState()

        if points.count == 2 {
            // Simple line for 2-point cracks
            context.setLineWidth(startWidth)
            context.beginPath()
            context.move(to: points[0])
            context.addLine(to: points[1])
            context.strokePath()
            context.restoreGState()
            return
        }

        // Draw crack as a smooth curve using quadratic Bezier curves
        // Use blend mode for better integration with underlying texture
        context.setBlendMode(.multiply)

        // Draw center crack darker
        context.setLineWidth(startWidth)
        context.beginPath()
        context.move(to: points[0])

        // Draw smooth curve through all points using quadratic Bezier
        for i in 1..<points.count {
            if i < points.count - 1 {
                // Use quadratic curve to current point with next point influencing curvature
                let current = points[i]
                let next = points[i + 1]

                // Control point is slightly offset toward next point for smooth flow
                let controlX = current.x + (next.x - current.x) * 0.3
                let controlY = current.y + (next.y - current.y) * 0.3
                let control = CGPoint(x: controlX, y: controlY)

                context.addQuadCurve(to: current, control: control)
            } else {
                // Last point - just draw line
                context.addLine(to: points[i])
            }
        }

        context.strokePath()

        // Draw softer outer edges for anti-aliasing effect
        let softerColor = UIColor(red: 0.2, green: 0.17, blue: 0.15, alpha: 0.3)
        softerColor.setStroke()
        context.setLineWidth(startWidth + 0.5)

        context.beginPath()
        context.move(to: points[0])

        for i in 1..<points.count {
            if i < points.count - 1 {
                let current = points[i]
                let next = points[i + 1]
                let controlX = current.x + (next.x - current.x) * 0.3
                let controlY = current.y + (next.y - current.y) * 0.3
                let control = CGPoint(x: controlX, y: controlY)
                context.addQuadCurve(to: current, control: control)
            } else {
                context.addLine(to: points[i])
            }
        }

        context.strokePath()

        // Restore graphics state
        context.restoreGState()
    }

    // Helper to get random point on edge of texture
    private func randomEdgePoint(edge: Int, size: Int) -> CGPoint {
        let margin = 2
        switch edge {
        case 0: // Top
            return CGPoint(x: Int.random(in: margin...(size-margin)), y: margin)
        case 1: // Right
            return CGPoint(x: size-margin, y: Int.random(in: margin...(size-margin)))
        case 2: // Bottom
            return CGPoint(x: Int.random(in: margin...(size-margin)), y: size-margin)
        case 3: // Left
            return CGPoint(x: margin, y: Int.random(in: margin...(size-margin)))
        default:
            return CGPoint(x: size/2, y: size/2)
        }
    }

    // MARK: - Terrain Textures

    private func generateTerrainTexture(depth: Double) -> SKTexture {
        let size = 24
        let scale: CGFloat = 3.0 // Use 3x for retina displays

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        // Base color based on depth
        let baseColor: UIColor
        if depth < 100 {
            baseColor = UIColor(red: 0.55, green: 0.45, blue: 0.35, alpha: 1.0) // Light brown dirt
        } else if depth < 300 {
            baseColor = UIColor(red: 0.45, green: 0.35, blue: 0.25, alpha: 1.0) // Darker dirt
        } else {
            baseColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0) // Stone
        }

        // Fill with base color
        baseColor.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Add noise/texture with darker pixels
        let darkColor = baseColor.darker(by: 0.2)
        let lightColor = baseColor.lighter(by: 0.1)

        for y in 0..<size {
            for x in 0..<size {
                let random = Double.random(in: 0...1)
                if random < 0.15 {
                    darkColor.setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                } else if random > 0.85 {
                    lightColor.setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    // MARK: - Obstacle Block Textures

    private func generateBedrockTexture() -> SKTexture {
        let size = 24
        let scale: CGFloat = 3.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        // Very dark gray/black base (#1a1a1a)
        let bedrock = UIColor(red: 0x1a / 255.0, green: 0x1a / 255.0, blue: 0x1a / 255.0, alpha: 1.0)
        let darker = UIColor(red: 0x10 / 255.0, green: 0x10 / 255.0, blue: 0x10 / 255.0, alpha: 1.0)
        let lighter = UIColor(red: 0x25 / 255.0, green: 0x25 / 255.0, blue: 0x25 / 255.0, alpha: 1.0)

        // Fill with base color
        bedrock.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Add rough stone-like texture with blocky pattern
        for y in stride(from: 0, to: size, by: 4) {
            for x in stride(from: 0, to: size, by: 4) {
                if Bool.random() {
                    darker.setFill()
                } else {
                    lighter.setFill()
                }
                let blockSize = Int.random(in: 2...4)
                context.fill(CGRect(x: x, y: y, width: blockSize, height: blockSize))
            }
        }

        // Add some random pixels for grit
        for _ in 0..<20 {
            let x = Int.random(in: 0..<size)
            let y = Int.random(in: 0..<size)
            if Bool.random() {
                darker.setFill()
            } else {
                lighter.setFill()
            }
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    private func generateHardCrystalTexture() -> SKTexture {
        let size = 24
        let scale: CGFloat = 3.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        // Bright purple crystal (#8B00FF)
        let crystal = UIColor(red: 0x8B / 255.0, green: 0x00 / 255.0, blue: 0xFF / 255.0, alpha: 1.0)
        let dark = UIColor(red: 0x60 / 255.0, green: 0x00 / 255.0, blue: 0xB0 / 255.0, alpha: 1.0)
        let bright = UIColor(red: 0xB0 / 255.0, green: 0x40 / 255.0, blue: 0xFF / 255.0, alpha: 1.0)

        // Fill with base color
        crystal.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Draw crystalline facets
        let center = size / 2

        // Dark facets (shadow side)
        dark.setFill()
        context.fill(CGRect(x: 0, y: 0, width: center, height: center))
        context.fill(CGRect(x: center, y: center, width: center, height: center))

        // Bright facets (light side)
        bright.setFill()
        context.fill(CGRect(x: center, y: 0, width: center, height: center))
        context.fill(CGRect(x: 0, y: center, width: center, height: center))

        // Add diagonal crystal lines
        bright.setFill()
        for i in stride(from: -size, to: size * 2, by: 6) {
            context.fill(CGRect(x: i, y: 0, width: 1, height: size))
            // Diagonal line
            let path = CGMutablePath()
            path.move(to: CGPoint(x: i, y: 0))
            path.addLine(to: CGPoint(x: i + size, y: size))
            context.addPath(path)
            context.setLineWidth(1)
            context.strokePath()
        }

        // Sparkle highlights
        bright.setFill()
        context.fill(CGRect(x: center - 1, y: center - 1, width: 2, height: 2))
        context.fill(CGRect(x: size - 4, y: 3, width: 2, height: 2))
        context.fill(CGRect(x: 3, y: size - 4, width: 2, height: 2))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    private func generateReinforcedRockTexture() -> SKTexture {
        let size = 24
        let scale: CGFloat = 3.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }

        // Medium gray reinforced rock (#4a4a4a)
        let reinforced = UIColor(red: 0x4a / 255.0, green: 0x4a / 255.0, blue: 0x4a / 255.0, alpha: 1.0)
        let dark = UIColor(red: 0x35 / 255.0, green: 0x35 / 255.0, blue: 0x35 / 255.0, alpha: 1.0)
        let light = UIColor(red: 0x60 / 255.0, green: 0x60 / 255.0, blue: 0x60 / 255.0, alpha: 1.0)
        let metallic = UIColor(red: 0x80 / 255.0, green: 0x80 / 255.0, blue: 0x80 / 255.0, alpha: 1.0)

        // Fill with base color
        reinforced.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Add stone texture
        for y in 0..<size {
            for x in 0..<size {
                let random = Double.random(in: 0...1)
                if random < 0.2 {
                    dark.setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                } else if random > 0.85 {
                    light.setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }

        // Add metallic reinforcement lines (grid pattern)
        metallic.setFill()
        // Horizontal reinforcement bars
        context.fill(CGRect(x: 0, y: size / 3, width: size, height: 1))
        context.fill(CGRect(x: 0, y: 2 * size / 3, width: size, height: 1))
        // Vertical reinforcement bars
        context.fill(CGRect(x: size / 3, y: 0, width: 1, height: size))
        context.fill(CGRect(x: 2 * size / 3, y: 0, width: 1, height: size))

        // Add rivets at intersections
        dark.setFill()
        context.fill(CGRect(x: size/3 - 1, y: size/3 - 1, width: 2, height: 2))
        context.fill(CGRect(x: 2*size/3 - 1, y: size/3 - 1, width: 2, height: 2))
        context.fill(CGRect(x: size/3 - 1, y: 2*size/3 - 1, width: 2, height: 2))
        context.fill(CGRect(x: 2*size/3 - 1, y: 2*size/3 - 1, width: 2, height: 2))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return SKTexture(image: image ?? UIImage())
    }

    // MARK: - Individual Material Patterns

    private func drawCoalTexture(context: CGContext, size: Int) {
        // Black coal with dark gray chunks
        let black = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        let darkGray = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)

        black.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Add chunky pattern
        drawChunkyPattern(context: context, size: size, color: darkGray, density: 0.3)
    }

    private func drawIronTexture(context: CGContext, size: Int) {
        // Rusty brown iron ore
        let rust = UIColor(red: 0.72, green: 0.45, blue: 0.20, alpha: 1.0)
        let darkRust = UIColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1.0)
        let lightRust = UIColor(red: 0.85, green: 0.55, blue: 0.30, alpha: 1.0)

        rust.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Streaky pattern
        drawStreakyPattern(context: context, size: size, darkColor: darkRust, lightColor: lightRust)
    }

    private func drawCopperTexture(context: CGContext, size: Int) {
        // Orange-brown copper ore
        let copper = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
        let darkCopper = UIColor(red: 0.6, green: 0.35, blue: 0.1, alpha: 1.0)
        let brightCopper = UIColor(red: 0.9, green: 0.6, blue: 0.3, alpha: 1.0)

        copper.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Metallic flecks
        drawMetallicFlecks(context: context, size: size, darkColor: darkCopper, brightColor: brightCopper)
    }

    private func drawSiliconTexture(context: CGContext, size: Int) {
        // Gray silicon with crystalline structure
        let gray = UIColor(red: 0.55, green: 0.55, blue: 0.55, alpha: 1.0)
        let darkGray = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        let lightGray = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)

        gray.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Crystalline pattern
        drawCrystallinePattern(context: context, size: size, darkColor: darkGray, lightColor: lightGray)
    }

    private func drawAluminumTexture(context: CGContext, size: Int) {
        // Light gray aluminum with metallic sheen
        let aluminum = UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1.0)
        let dark = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        let bright = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)

        aluminum.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Metallic bands
        drawMetallicBands(context: context, size: size, darkColor: dark, brightColor: bright)
    }

    private func drawSilverTexture(context: CGContext, size: Int) {
        // Shiny silver with highlights
        let silver = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        let dark = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        let bright = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

        silver.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Shiny highlights
        drawShinyHighlights(context: context, size: size, darkColor: dark, brightColor: bright)
    }

    private func drawGoldTexture(context: CGContext, size: Int) {
        // Bright golden with glints
        let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        let darkGold = UIColor(red: 0.8, green: 0.65, blue: 0.0, alpha: 1.0)
        let brightGold = UIColor(red: 1.0, green: 0.95, blue: 0.4, alpha: 1.0)

        gold.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Golden glints
        drawGoldenGlints(context: context, size: size, darkColor: darkGold, brightColor: brightGold)
    }

    private func drawPlatinumTexture(context: CGContext, size: Int) {
        // Platinum white with subtle shimmer
        let platinum = UIColor(red: 0.9, green: 0.89, blue: 0.88, alpha: 1.0)
        let dark = UIColor(red: 0.75, green: 0.74, blue: 0.73, alpha: 1.0)
        let bright = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        platinum.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        drawShinyHighlights(context: context, size: size, darkColor: dark, brightColor: bright)
    }

    private func drawGemTexture(context: CGContext, size: Int, color: UIColor) {
        // Faceted gem with sparkles
        let dark = color.darker(by: 0.3)
        let bright = color.lighter(by: 0.3)

        color.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        // Draw facets
        drawGemFacets(context: context, size: size, baseColor: color, darkColor: dark, brightColor: bright)
    }

    private func drawTitaniumTexture(context: CGContext, size: Int) {
        // Dark silver titanium
        let titanium = UIColor(red: 0.53, green: 0.53, blue: 0.51, alpha: 1.0)
        let dark = UIColor(red: 0.4, green: 0.4, blue: 0.38, alpha: 1.0)
        let bright = UIColor(red: 0.65, green: 0.65, blue: 0.63, alpha: 1.0)

        titanium.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        drawMetallicBands(context: context, size: size, darkColor: dark, brightColor: bright)
    }

    private func drawNeodymiumTexture(context: CGContext, size: Int) {
        // Purple-silver magnetic material
        let neodymium = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)
        let dark = UIColor(red: 0.45, green: 0.3, blue: 0.6, alpha: 1.0)
        let bright = UIColor(red: 0.75, green: 0.55, blue: 0.95, alpha: 1.0)

        neodymium.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        drawMagneticPattern(context: context, size: size, darkColor: dark, brightColor: bright)
    }

    private func drawRhodiumTexture(context: CGContext, size: Int) {
        // Ultra-reflective silver
        let rhodium = UIColor(red: 1.0, green: 0.98, blue: 0.98, alpha: 1.0)
        let dark = UIColor(red: 0.8, green: 0.78, blue: 0.78, alpha: 1.0)
        let bright = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        rhodium.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        drawMirrorSheen(context: context, size: size, darkColor: dark, brightColor: bright)
    }

    private func drawDarkMatterTexture(context: CGContext, size: Int) {
        // Dark purple with mysterious glow
        let darkMatter = UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1.0)
        let purple = UIColor(red: 0.3, green: 0.2, blue: 0.5, alpha: 1.0)
        let glow = UIColor(red: 0.5, green: 0.3, blue: 0.8, alpha: 1.0)

        darkMatter.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size, height: size))

        drawVoidPattern(context: context, size: size, purple: purple, glow: glow)
    }

    // MARK: - Pattern Helpers

    private func drawChunkyPattern(context: CGContext, size: Int, color: UIColor, density: Double) {
        color.setFill()
        for y in 0..<size {
            for x in 0..<size {
                if Double.random(in: 0...1) < density {
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }

    private func drawStreakyPattern(context: CGContext, size: Int, darkColor: UIColor, lightColor: UIColor) {
        for y in stride(from: 0, to: size, by: 3) {
            if Bool.random() {
                darkColor.setFill()
            } else {
                lightColor.setFill()
            }
            context.fill(CGRect(x: 0, y: y, width: size, height: 2))
        }
    }

    private func drawMetallicFlecks(context: CGContext, size: Int, darkColor: UIColor, brightColor: UIColor) {
        for _ in 0..<8 {
            let x = Int.random(in: 0..<size)
            let y = Int.random(in: 0..<size)
            brightColor.setFill()
            context.fill(CGRect(x: x, y: y, width: 2, height: 2))
        }
        for _ in 0..<6 {
            let x = Int.random(in: 0..<size)
            let y = Int.random(in: 0..<size)
            darkColor.setFill()
            context.fill(CGRect(x: x, y: y, width: 2, height: 2))
        }
    }

    private func drawCrystallinePattern(context: CGContext, size: Int, darkColor: UIColor, lightColor: UIColor) {
        // Diagonal stripes for crystal structure
        for i in stride(from: -size, to: size * 2, by: 4) {
            lightColor.setFill()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: i, y: 0))
            path.addLine(to: CGPoint(x: i + 2, y: 0))
            path.addLine(to: CGPoint(x: i + 2 + size, y: size))
            path.addLine(to: CGPoint(x: i + size, y: size))
            path.closeSubpath()
            context.addPath(path)
            context.fillPath()
        }
    }

    private func drawMetallicBands(context: CGContext, size: Int, darkColor: UIColor, brightColor: UIColor) {
        for x in stride(from: 0, to: size, by: 4) {
            brightColor.setFill()
            context.fill(CGRect(x: x, y: 0, width: 1, height: size))
            darkColor.setFill()
            context.fill(CGRect(x: x + 2, y: 0, width: 1, height: size))
        }
    }

    private func drawShinyHighlights(context: CGContext, size: Int, darkColor: UIColor, brightColor: UIColor) {
        // Diagonal highlights
        brightColor.setFill()
        context.fill(CGRect(x: size/2, y: size/4, width: size/3, height: size/8))
        context.fill(CGRect(x: size/4, y: size*2/3, width: size/4, height: size/10))

        darkColor.setFill()
        context.fill(CGRect(x: 0, y: 0, width: size/3, height: size/4))
    }

    private func drawGoldenGlints(context: CGContext, size: Int, darkColor: UIColor, brightColor: UIColor) {
        // Random bright spots
        for _ in 0..<12 {
            let x = Int.random(in: 0..<size)
            let y = Int.random(in: 0..<size)
            brightColor.setFill()
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
        // Dark veins
        darkColor.setFill()
        for i in stride(from: 0, to: size, by: 6) {
            context.fill(CGRect(x: i, y: 0, width: 1, height: size))
        }
    }

    private func drawGemFacets(context: CGContext, size: Int, baseColor: UIColor, darkColor: UIColor, brightColor: UIColor) {
        // Draw faceted gem appearance
        let center = size / 2

        // Dark facets
        darkColor.setFill()
        context.fill(CGRect(x: 0, y: 0, width: center, height: center))
        context.fill(CGRect(x: center, y: center, width: center, height: center))

        // Bright facets
        brightColor.setFill()
        context.fill(CGRect(x: center, y: 0, width: center, height: center))
        context.fill(CGRect(x: 0, y: center, width: center, height: center))

        // Sparkle points
        brightColor.setFill()
        context.fill(CGRect(x: center - 1, y: center - 1, width: 2, height: 2))
        context.fill(CGRect(x: size - 3, y: 2, width: 2, height: 2))
        context.fill(CGRect(x: 2, y: size - 3, width: 2, height: 2))
    }

    private func drawMagneticPattern(context: CGContext, size: Int, darkColor: UIColor, brightColor: UIColor) {
        // Wavy magnetic field lines
        for y in stride(from: 0, to: size, by: 4) {
            for x in 0..<size {
                if (x + y/2) % 4 == 0 {
                    brightColor.setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }

    private func drawMirrorSheen(context: CGContext, size: Int, darkColor: UIColor, brightColor: UIColor) {
        // Ultra-reflective diagonal gradient
        for y in 0..<size {
            for x in 0..<size {
                if (x + y) < size {
                    brightColor.setFill()
                } else {
                    darkColor.setFill()
                }
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }

    private func drawVoidPattern(context: CGContext, size: Int, purple: UIColor, glow: UIColor) {
        // Swirling void effect
        for y in 0..<size {
            for x in 0..<size {
                let distance = sqrt(pow(Double(x - size/2), 2) + pow(Double(y - size/2), 2))
                if distance < Double(size/3) && Int(distance) % 3 == 0 {
                    glow.setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                } else if Int.random(in: 0...20) == 0 {
                    purple.setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }
}

// MARK: - UIColor Extensions

extension UIColor {
    func darker(by percentage: CGFloat = 0.3) -> UIColor {
        return self.adjust(by: -abs(percentage))
    }

    func lighter(by percentage: CGFloat = 0.3) -> UIColor {
        return self.adjust(by: abs(percentage))
    }

    func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(
            red: min(red + percentage, 1.0),
            green: min(green + percentage, 1.0),
            blue: min(blue + percentage, 1.0),
            alpha: alpha
        )
    }
}
