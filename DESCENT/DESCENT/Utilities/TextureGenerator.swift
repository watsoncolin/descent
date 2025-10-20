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
    // NOTE: Material textures removed - materials now use PNG assets via MaterialDeposit system

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

    // MARK: - Terrain Textures

    private func generateTerrainTexture(depth: Double) -> SKTexture {
        let size = CGSize(width: 64, height: 64)  // Full block size for smooth rendering

        // Use scale of 1.0 to prevent renderer from multiplying dimensions by screen scale
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let image = renderer.image { context in
            let ctx = context.cgContext

            // Determine base colors based on depth (smooth gradients, not pixel-art)
            let topColor: UIColor
            let bottomColor: UIColor

            if depth < 100 {
                // Shallow dirt - light brown gradient
                topColor = UIColor(red: 0.60, green: 0.50, blue: 0.40, alpha: 1.0)
                bottomColor = UIColor(red: 0.50, green: 0.40, blue: 0.30, alpha: 1.0)
            } else if depth < 300 {
                // Deep dirt - darker brown gradient
                topColor = UIColor(red: 0.50, green: 0.40, blue: 0.30, alpha: 1.0)
                bottomColor = UIColor(red: 0.40, green: 0.30, blue: 0.20, alpha: 1.0)
            } else {
                // Stone - gray gradient
                topColor = UIColor(red: 0.35, green: 0.35, blue: 0.35, alpha: 1.0)
                bottomColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
            }

            // Create smooth vertical gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) else {
                return
            }

            let startPoint = CGPoint(x: size.width / 2, y: 0)
            let endPoint = CGPoint(x: size.width / 2, y: size.height)
            ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])

            // Add subtle noise texture (fewer, larger dots for smooth look)
            let noiseColor = UIColor(white: 0.0, alpha: 0.15)
            ctx.setFillColor(noiseColor.cgColor)

            // Add 15-25 random noise dots for subtle texture
            let dotCount = Int.random(in: 15...25)
            for _ in 0..<dotCount {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let radius = CGFloat.random(in: 1.5...3.0)
                ctx.fillEllipse(in: CGRect(x: x - radius/2, y: y - radius/2, width: radius, height: radius))
            }
        }

        return SKTexture(image: image)
    }

    // MARK: - Obstacle Block Textures

    private func generateBedrockTexture() -> SKTexture {
        let size = CGSize(width: 64, height: 64)  // Full block size for smooth rendering

        // Use scale of 1.0 to prevent renderer from multiplying dimensions by screen scale
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let image = renderer.image { context in
            let ctx = context.cgContext

            // Very dark purple gradient (#2a1a3a → #1a0a2a)
            let topColor = UIColor(red: 0x2a / 255.0, green: 0x1a / 255.0, blue: 0x3a / 255.0, alpha: 1.0)
            let bottomColor = UIColor(red: 0x1a / 255.0, green: 0x0a / 255.0, blue: 0x2a / 255.0, alpha: 1.0)

            // Create vertical gradient
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) else {
                return
            }

            let startPoint = CGPoint(x: size.width / 2, y: 0)
            let endPoint = CGPoint(x: size.width / 2, y: size.height)
            ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])

            // Add subtle noise for texture
            let lighter = UIColor(red: 0x35 / 255.0, green: 0x25 / 255.0, blue: 0x45 / 255.0, alpha: 0.15)
            lighter.setFill()

            for _ in 0..<30 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let radius = CGFloat.random(in: 1...3)
                ctx.fillEllipse(in: CGRect(x: x, y: y, width: radius, height: radius))
            }
        }

        return SKTexture(image: image)
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

        // Medium purple reinforced rock (#5a3a6a)
        let reinforced = UIColor(red: 0x5a / 255.0, green: 0x3a / 255.0, blue: 0x6a / 255.0, alpha: 1.0)
        let dark = UIColor(red: 0x45 / 255.0, green: 0x25 / 255.0, blue: 0x55 / 255.0, alpha: 1.0)
        let light = UIColor(red: 0x70 / 255.0, green: 0x50 / 255.0, blue: 0x80 / 255.0, alpha: 1.0)
        let metallic = UIColor(red: 0x90 / 255.0, green: 0x70 / 255.0, blue: 0xa0 / 255.0, alpha: 1.0)

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

// MARK: - Continuous Terrain Texture Generation

extension TextureGenerator {

    /// Create vertical gradient texture for continuous terrain layers
    func createVerticalGradientTexture(size: CGSize, colors: [UIColor]) -> SKTexture {
        // Metal texture size limit: 8192 pixels max (conservative limit for safety)
        let maxDimension: CGFloat = 4096.0

        if size.width > maxDimension || size.height > maxDimension {
            print("⚠️ ERROR: Attempted to create texture larger than Metal limit!")
            print("   Requested: \(size.width)x\(size.height)")
            print("   Maximum: \(maxDimension)x\(maxDimension)")

            // Clamp to maximum size
            let clampedSize = CGSize(
                width: min(size.width, maxDimension),
                height: min(size.height, maxDimension)
            )
            print("   Clamping to: \(clampedSize.width)x\(clampedSize.height)")

            return createVerticalGradientTexture(size: clampedSize, colors: colors)
        }

        // Use scale of 1.0 to prevent renderer from multiplying dimensions by screen scale
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let image = renderer.image { context in
            // Create evenly spaced locations for gradient stops
            let locations: [CGFloat] = (0..<colors.count).map { CGFloat($0) / CGFloat(colors.count - 1) }

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: locations
            ) else { return }

            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: 0, y: size.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }

    /// Create radial gradient texture (for material deposits and glows)
    func createRadialGradientTexture(radius: CGFloat, colors: [UIColor]) -> SKTexture {
        // Metal texture size limit: 8192 pixels max (conservative limit for safety)
        let maxDimension: CGFloat = 4096.0
        let size = CGSize(width: radius * 2, height: radius * 2)

        if size.width > maxDimension || size.height > maxDimension {
            print("⚠️ ERROR: Attempted to create radial texture larger than Metal limit!")
            print("   Requested radius: \(radius) (size: \(size.width)x\(size.height))")
            print("   Maximum: \(maxDimension)x\(maxDimension)")

            // Clamp to maximum size
            let clampedRadius = maxDimension / 2
            print("   Clamping radius to: \(clampedRadius)")

            return createRadialGradientTexture(radius: clampedRadius, colors: colors)
        }

        // Use scale of 1.0 to prevent renderer from multiplying dimensions by screen scale
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let image = renderer.image { context in
            // Create evenly spaced locations for gradient stops
            let locations: [CGFloat] = (0..<colors.count).map { CGFloat($0) / CGFloat(colors.count - 1) }

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: locations
            ) else { return }

            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: radius, y: radius),
                startRadius: 0,
                endCenter: CGPoint(x: radius, y: radius),
                endRadius: radius,
                options: []
            )
        }
        return SKTexture(image: image)
    }

    /// Create diagonal gradient texture for flow patterns
    func createDiagonalGradientTexture(size: CGSize, colors: [UIColor], angle: CGFloat) -> SKTexture {
        // Metal texture size limit: 8192 pixels max (conservative limit for safety)
        let maxDimension: CGFloat = 4096.0

        if size.width > maxDimension || size.height > maxDimension {
            print("⚠️ ERROR: Attempted to create diagonal texture larger than Metal limit!")
            print("   Requested: \(size.width)x\(size.height)")
            print("   Maximum: \(maxDimension)x\(maxDimension)")

            // Clamp to maximum size
            let clampedSize = CGSize(
                width: min(size.width, maxDimension),
                height: min(size.height, maxDimension)
            )
            print("   Clamping to: \(clampedSize.width)x\(clampedSize.height)")

            return createDiagonalGradientTexture(size: clampedSize, colors: colors, angle: angle)
        }

        // Use scale of 1.0 to prevent renderer from multiplying dimensions by screen scale
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let image = renderer.image { context in
            // Create evenly spaced locations for gradient stops
            let locations: [CGFloat] = (0..<colors.count).map { CGFloat($0) / CGFloat(colors.count - 1) }

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: locations
            ) else { return }

            // Convert angle to radians
            let angleRad = angle * .pi / 180.0

            // Calculate gradient endpoints based on angle
            let endX = cos(angleRad) * size.width
            let endY = sin(angleRad) * size.height

            context.cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: endX, y: endY),
                options: []
            )
        }
        return SKTexture(image: image)
    }
}
