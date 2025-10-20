#!/bin/bash

# Generic Material SVG to PNG Converter
# Processes all *-svg.svg files in the Materials directory
# Creates corresponding imagesets in Assets.xcassets/Materials/

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ASSETS_DIR="$SCRIPT_DIR/../../Assets.xcassets/Materials"

echo "🎨 Material Asset Converter"
echo "=========================="
echo ""

# Find all SVG files matching the pattern *-svg.svg
SVG_FILES=("$SCRIPT_DIR"/*-svg.svg)

if [ ${#SVG_FILES[@]} -eq 0 ] || [ ! -f "${SVG_FILES[0]}" ]; then
    echo "❌ No SVG files found matching pattern *-svg.svg"
    exit 1
fi

# Create a temporary Swift script
TEMP_SCRIPT=$(mktemp).swift

cat > "$TEMP_SCRIPT" << 'SWIFT_EOF'
import Foundation
import AppKit

let args = CommandLine.arguments
if args.count < 4 {
    print("Usage: script <svg_path> <output_dir> <material_name>")
    exit(1)
}

let svgPath = args[1]
let outputDir = args[2]
let materialName = args[3]

print("🔄 Converting \(materialName) SVG to PNG...")
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

    let outputPath = outputDir + "/\(materialName)_\(scale).png"
    do {
        try pngData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Created \(materialName)_\(scale).png (\(size)×\(size))")
    } catch {
        print("❌ Failed to write: \(error)")
    }
}

print("✅ \(materialName) conversion complete!")
SWIFT_EOF

# Counter for processed files
PROCESSED=0
FAILED=0

# Process each SVG file
for SVG_FILE in "${SVG_FILES[@]}"; do
    if [ ! -f "$SVG_FILE" ]; then
        continue
    fi

    # Extract material name from filename
    # coal-ore-svg.svg -> coal-ore -> coal
    BASENAME=$(basename "$SVG_FILE" -svg.svg)
    MATERIAL_NAME="${BASENAME%-ore}"

    # Handle special cases (silicon-crystal, dark-matter-crystal, etc.)
    if [[ "$BASENAME" == *-crystal ]]; then
        MATERIAL_NAME="${BASENAME%-crystal}"
    fi

    # Convert to lowercase and replace hyphens with underscores for asset names
    ASSET_NAME=$(echo "$MATERIAL_NAME" | tr '[:upper:]' '[:lower:]' | tr '-' '_')

    echo ""
    echo "📦 Processing: $BASENAME"
    echo "   Material: $ASSET_NAME"

    # Create output directory
    OUTPUT_DIR="$ASSETS_DIR/$ASSET_NAME.imageset"
    mkdir -p "$OUTPUT_DIR"

    # Run the Swift script
    if swift "$TEMP_SCRIPT" "$SVG_FILE" "$OUTPUT_DIR" "$ASSET_NAME"; then
        ((PROCESSED++))

        # Create Contents.json if it doesn't exist
        if [ ! -f "$OUTPUT_DIR/Contents.json" ]; then
            cat > "$OUTPUT_DIR/Contents.json" << JSON_EOF
{
  "images" : [
    {
      "filename" : "${ASSET_NAME}_1x.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "${ASSET_NAME}_2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "filename" : "${ASSET_NAME}_3x.png",
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
JSON_EOF
            echo "   ✅ Created Contents.json"
        fi
    else
        echo "   ❌ Failed to convert $BASENAME"
        ((FAILED++))
    fi
done

# Clean up
rm "$TEMP_SCRIPT"

echo ""
echo "=========================="
echo "📊 Summary:"
echo "   Processed: $PROCESSED materials"
if [ $FAILED -gt 0 ]; then
    echo "   Failed: $FAILED materials"
fi
echo ""
echo "Next steps:"
echo "  1. Rebuild the app to see the updated material graphics"
echo "  2. Or run: xcodebuild -project DESCENT.xcodeproj -scheme DESCENT build"
echo ""
