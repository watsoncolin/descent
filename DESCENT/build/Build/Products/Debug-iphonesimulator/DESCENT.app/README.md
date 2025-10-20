# Material Assets

This directory contains SVG source files for all material types in the game, along with a conversion script to generate PNG assets for Xcode.

## Directory Structure

```
Materials/
├── README.md                      # This file
├── convert_all_materials.sh       # Automated conversion script
├── convert_coal.sh                # Legacy script (kept for reference)
├── coal-ore-svg.svg              # Coal ore SVG source
├── iron-ore-svg.svg              # Iron ore SVG source
├── copper-ore-svg.svg            # Copper ore SVG source
├── gold-ore-svg.svg              # Gold ore SVG source
├── silicon-crystal-svg.svg       # Silicon crystal SVG source
└── dark-matter-crystal-svg.svg   # Dark matter crystal SVG source
```

## Material Naming Convention

SVG files should follow the pattern: `{material-name}-{type}-svg.svg`

Examples:
- `coal-ore-svg.svg` → Generates `coal.imageset`
- `iron-ore-svg.svg` → Generates `iron.imageset`
- `silicon-crystal-svg.svg` → Generates `silicon.imageset`

The script automatically:
- Removes `-ore` and `-crystal` suffixes
- Converts hyphens to underscores for asset names
- Creates 1x, 2x, and 3x PNG variants

## Adding New Materials

1. **Create the SVG file** in this directory following the naming convention:
   ```
   {material-name}-ore-svg.svg
   ```
   or
   ```
   {material-name}-crystal-svg.svg
   ```

2. **Run the conversion script**:
   ```bash
   ./convert_all_materials.sh
   ```

3. **Rebuild the app** to see the new material graphics:
   ```bash
   cd ../../..
   xcodebuild -project DESCENT.xcodeproj -scheme DESCENT build
   ```

## Conversion Script

The `convert_all_materials.sh` script automatically:
- Finds all `*-svg.svg` files in this directory
- Converts each to PNG at 3 resolutions (48px, 96px, 144px)
- Creates the corresponding `.imageset` directory in `Assets.xcassets/Materials/`
- Generates the `Contents.json` file for Xcode
- Provides a summary of processed materials

### Usage

```bash
# Convert all materials
./convert_all_materials.sh

# Make script executable (if needed)
chmod +x convert_all_materials.sh
```

### Output

For each material SVG, the script creates:
```
Assets.xcassets/Materials/{material}.imageset/
├── Contents.json
├── {material}_1x.png  (48×48)
├── {material}_2x.png  (96×96)
└── {material}_3x.png  (144×144)
```

## Technical Details

- **SVG Source Resolution**: Vector (scalable)
- **PNG Output Sizes**: 48px (1x), 96px (2x), 144px (3x)
- **Conversion Method**: Swift + AppKit (NSImage)
- **Output Format**: PNG with alpha channel
- **Color Space**: Device RGB

## Material Types

Currently supported materials:
- **Coal** (`coal-ore-svg.svg`)
- **Iron** (`iron-ore-svg.svg`)
- **Copper** (`copper-ore-svg.svg`)
- **Gold** (`gold-ore-svg.svg`)
- **Silicon** (`silicon-crystal-svg.svg`)
- **Dark Matter** (`dark-matter-crystal-svg.svg`)

## Troubleshooting

**Script fails to run:**
```bash
chmod +x convert_all_materials.sh
```

**Missing output files:**
- Check that the SVG file exists and follows the naming convention
- Verify the Assets.xcassets/Materials directory exists
- Run the script with verbose output to see errors

**Assets not appearing in Xcode:**
- Rebuild the project
- Clean build folder (Cmd+Shift+K)
- Restart Xcode if needed

## Notes

- Keep SVG source files in version control
- Generated PNG files are also committed to ensure consistent builds
- The conversion script is idempotent (safe to run multiple times)
- Existing PNG files will be overwritten on each run
