#!/bin/bash

# Coal SVG to PNG Converter
# Run this script after updating coal-ore-svg.svg to regenerate PNG assets

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SVG_FILE="$SCRIPT_DIR/coal-ore-svg.svg"
OUTPUT_DIR="$SCRIPT_DIR/../../Assets.xcassets/Materials/coal.imageset"

# Create a temporary Swift script
TEMP_SCRIPT=$(mktemp).swift

cat > "$TEMP_SCRIPT" << 'SWIFT_EOF'
import Foundation
import AppKit

let args = CommandLine.arguments
if args.count < 3 {
    print("Usage: script <svg_path> <output_dir>")
    exit(1)
}

let svgPath = args[1]
let outputDir = args[2]

print("🔄 Converting coal SVG to PNG...")
print("   Source: \(svgPath)")
print("   Output: \(outputDir)")

guard let svgData = try? Data(contentsOf: URL(fileURLWithPath: svgPath)) else {
    print("❌ Failed to read SVG file")
    exit(1)
}

guard let svgImage = NSImage(data: svgData) else {
    print("❌ Failed to create image from SVG")
    exit(1)
}

let sizes: [(Int, String)] = [(48, "1x"), (96, "2x"), (144, "3x")]

for (size, scale) in sizes {
    let targetSize = NSSize(width: size, height: size)
    let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    bitmapRep.size = targetSize
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
    svgImage.draw(in: NSRect(origin: .zero, size: targetSize))
    NSGraphicsContext.restoreGraphicsState()
    
    guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("❌ Failed to create PNG for \(scale)")
        continue
    }
    
    let outputPath = outputDir + "/coal_\(scale).png"
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Created coal_\(scale).png (\(size)×\(size))")
    } catch {
        print("❌ Failed to write: \(error)")
    }
}

print("✅ SVG conversion complete!")
SWIFT_EOF

# Run the Swift script
swift "$TEMP_SCRIPT" "$SVG_FILE" "$OUTPUT_DIR"

# Clean up
rm "$TEMP_SCRIPT"

echo ""
echo "Next steps:"
echo "  1. Rebuild the app to see the updated coal graphics"
echo "  2. Or run: xcodebuild -project DESCENT.xcodeproj -scheme DESCENT build"
