---
tags: [descent, design-system, art]
updated: 2026-06-21
---

# Design System

The canonical art reference for DESCENT (v1.0, October 2025). The aesthetic is **modern sci-fi**: smooth gradients, atmospheric glows, layered transparency. The signature move is **continuous geological terrain with embedded resource deposits** — the level reads as flowing strata, not a brick wall, while gameplay stays on an invisible grid. Pairs with [[Drill Animation and VFX]] (which reuses this palette) and serves the goals in [[Game Design]].

> [!warning]
> This palette, type scale, and component spec are **defined here but not yet applied in code** — there is no `Theme` constant centralizing these values, so colors and spacing are currently scattered/hardcoded. Tracked in [[Code Review]].

## Core Principles

1. **Continuous over Discrete** — terrain flows as unified geological layers, not individual blocks.
2. **Embedded Resources** — materials appear as natural deposits within terrain, not separate blocks.
3. **Depth through Layers** — build complexity with semi-transparent overlays spanning multiple blocks.
4. **Organic Flow** — large-scale color variations and diagonal stratification.
5. **Clear Contrast** — materials stand out through glow and color differentiation.
6. **Atmospheric Effects** — glows, halos, soft shadows for depth.
7. **Consistent Lighting** — single light source from the top-left for all elements.
8. **Grid-Based Gameplay** — visual continuity never sacrifices gameplay precision.

The intent: *excavating natural resources from geological formations* rather than *breaking colored tiles*. Visual layer is continuous; game-logic layer is a discrete invisible 64×64 grid. Terrain renders at `z = 0`, materials at `z = 10+`.

## Color Palette

### Space / UI

```
Deep Space Blue     #2a7fbf
Bright Blue         #4db8ff
Light Blue          #6dd5ff
Cyan Highlight      #9ef4ff
```

### Background

```
Deep Space Dark     #0a0e27
Space Medium        #1a1f3a
Space Dark          #0f1123
Ocean Deep          #1a3d5c
```

### Accent

```
White Highlight     #ffffff (30-80% opacity)
Pure White          #ffffff (100% for text)
```

### Material — Common

```
Rock Gray           #5a6a7a
Rock Dark           #3a4a5a
Rock Mid            #4a5a6a
Stone Blue-Gray     #4a5a6a
```

### Material — Metallic

```
Iron Light          #7a8a9a
Iron Dark           #6a7a8a
Steel Gray          #8a9aaa
Metal Shine         #9aaaba
```

### Material — Crystal / Rare

```
Crystal Bright      #6dd5ff
Crystal Core        #4db8ff
Crystal Glow        #2a7fbf
Gem Shine           #ffffff (50% opacity)
```

### Planetary Surface

```
Mars Red            #e85d3a
Mars Orange         #c44228
Mars Brown          #a03520
Mars Dark           #8a2a18
Crater Shadow       #6a1a10
```

### Energy / Effects

```
Thruster Yellow     #ffdd57
Flame Orange        #ff9d3a
Fire Red            #ff6b35
Energy White        #ffffff (60% opacity)
```

## Terrain Color Ramp

Terrain forms continuous geological layers spanning the full level width and a depth band. **Each strata has two states** — surface (lighter) and excavated (darker). Mining reveals the deeper, compacted version of the *same* material, never a different one. Depth bands and strata gameplay are detailed in [[Terrain and Strata]]; material values live in [[Materials and Economy]].

### Sand
```
Surface Colors:   #c4a57b → #b89a70 → #a89060 (light tan, warm)
Excavated Colors: #8c7545 → #7c6535 → #6c5525 (darker tan, compacted)
Contrast:         ~35% darker
Variations:       Large ellipses (80-120px), 10-15% opacity
Flow Pattern:     Diagonal (15-30°), subtle color shifts
Texture:          Horizontal organic lines, 8% opacity
Mining Reveals:   Darker, compacted sand underneath
Depth Range:      0-640m
```

### Stone
```
Surface Colors:   #6a7a8a → #5a6a7a (medium gray)
Excavated Colors: #4a5a6a → #3a4a5a (dark gray, dense)
Contrast:         ~40% darker
Variations:       Medium ellipses (60-90px), 12-18% opacity
Flow Pattern:     Diagonal (20-35°), more angular than sand
Texture:          Horizontal stratification lines, 10% opacity
Mining Reveals:   Deep, dense stone layer
Depth Range:      640-1280m
```

### Rock
```
Surface Colors:   #7a8090 → #6a7080 (gray-blue)
Excavated Colors: #5a6070 → #4a5060 (deep gray-blue)
Contrast:         ~35% darker
Variations:       Large irregular shapes (70-110px), 15-20% opacity
Flow Pattern:     Mixed angles (15-40°), varied stratification
Texture:          Cracked texture patterns, 12% opacity
Mining Reveals:   Ancient, compressed rock formations
Depth Range:      1280-1920m
```

### Mars Rock
```
Surface Colors:   #b85a40 → #a04a30 (rust red)
Excavated Colors: #8a3a20 → #6a2a10 (deep rust, almost black)
Contrast:         ~45% darker (approaching void)
Variations:       Large organic shapes (90-130px), 12-18% opacity
Flow Pattern:     Wavy, geological upheaval patterns
Texture:          Crater-like depressions, dust patterns, 10% opacity
Mining Reveals:   Deep, ancient Martian bedrock
Depth Range:      1920m+
```

### Contrast requirements

- **Surface vs. excavated:** Sand ~35%, Stone ~40%, Rock ~35%, Mars Rock ~45% darker.
- **Material vs. terrain:** Common ≥ 30% contrast; Rare ≥ 50% contrast. Glow must read against both surface and excavated terrain.

## Material Deposits

Discrete deposits embedded at grid centers (`x*64+32`, `y*64+32`). Outer glow extends 1.5× deposit size; core stays full opacity; 2–4 internal detail spots add texture.

### Coal (Common)
```
Deposit Size:    10-22px radius
Core Colors:     #3a3a3a → #2a2a2a → #1a1a1a
Glow:            30-40% opacity, #3a3a3a, subtle
Internal Detail: Dark spots (#2a2a2a, #1a1a1a), 60-70% opacity
Grid Frequency:  50-70% of blocks
Value:           10 credits/unit
```

### Iron Ore (Uncommon)
```
Deposit Size:    12-20px radius
Core Colors:     #9aaaba → #7a8a9a → #6a7a8a
Glow:            40-50% opacity, #9aaaba, metallic sheen
Internal Detail: Bright metallic spots (#9aaaba, #b4c4d4), 70-80% opacity
Grid Frequency:  20-30% of blocks
Value:           25 credits/unit
```

### Copper Ore (Uncommon)
```
Deposit Size:    13-21px radius
Core Colors:     #d4956e → #c4754e → #b4653e
Glow:            50-60% opacity, #d4956e, warm glow
Internal Detail: Orange-copper spots (#d4956e, #e4a57e), 70-90% opacity
Grid Frequency:  15-25% of blocks
Value:           30 credits/unit
```

### Crystal / Diamond (Rare)
```
Deposit Size:    16-24px radius
Core Colors:     #6dd5ff → #4db8ff → #2a7fbf
Glow:            70-90% opacity, multi-layer (#6dd5ff, #4db8ff), intense
Internal Detail: Faceted highlights, bright white core (#ffffff, 70% opacity)
Special:         Animated pulse (0.9-1.1 scale, 2s cycle)
Grid Frequency:  3-8% of blocks
Value:           100 credits/unit
```

### Gold Ore (Rare)
```
Deposit Size:    14-20px radius
Core Colors:     #ffd700 → #f4c430 → #daa520
Glow:            60-80% opacity, #ffd700, golden radiance
Internal Detail: Metallic shine spots (#ffd700, #ffed4e), 80-90% opacity
Special:         Subtle shimmer effect
Grid Frequency:  5-10% of blocks
Value:           150 credits/unit
```

## Visual Techniques

### Gradients
Replace all solid fills with gradients. Linear gradients for lighting (vertical) and volume (horizontal/diagonal); radial gradients for glows and energy. Example terrain ramps live in the [[#Terrain Color Ramp]] above.

### Glow intensity by material type
- **Common:** 10-20% opacity, small blur (stdDeviation 2-3)
- **Uncommon:** 30-40% opacity, medium blur (stdDeviation 3-4)
- **Rare:** 50-80% opacity, large blur (stdDeviation 4-6)
- **Energy:** 70-90% opacity, intense blur (stdDeviation 5-8)

### Layering & depth
Build each element from 3–5 layers:
```
Layer 5: Outer Glow      (20-40% opacity, radial fade)
Layer 4: Edge Lighting   (thin lines, 50% opacity)
Layer 3: Highlight       (30-50% opacity, top-left)
Layer 2: Main Body       (100% opacity, gradient fill)
Layer 1: Shadow Base     (dark, 100% opacity)
```

## Planetary Surfaces

### Mars-like Planet
```
Base:       #c44228 → #a03520
Craters:    #8a2a18 ellipses, 50% opacity
Highlights: #e85d3a ridges, 30% opacity
Atmosphere: #e85d3a glow, 20% opacity, large radius
Details:    Random dark spots (#6a1a10, 40% opacity)
```

### Rocky Moon
```
Base:       #4a5a6a → #3a4a5a
Craters:    Many, various sizes, #2a3a4a
Highlights: Minimal, #5a6a7a edges
Atmosphere: None
Details:    High contrast shadows
```

### Crystalline World
```
Base:       #2a7fbf → #4db8ff with transparency
Craters:    Faceted depressions, bright
Highlights: Intense, #6dd5ff, 70% opacity
Atmosphere: Bright glow, #4db8ff, 60% opacity
Details:    Crystalline formations, geometric
```

## UI Components

### Pod / Player
```
Body:          #2a7fbf → #4db8ff → #2a7fbf (horizontal)
Highlights:    #6dd5ff, 50% opacity, top-left
Window:        #1a3d5c, 90% opacity
Window Shine:  #4db8ff, 60% opacity, small circle
Thrusters:     #ffdd57 → #ff9d3a → #ff6b35
Thruster Glow: Intense, animated
Edge:          Soft glow, #4db8ff, 40% opacity
```

### HUD Elements
```
Background:    #0a0e27, 80% opacity
Border:        #4db8ff, 2px, 60% opacity
Text:          #6dd5ff for values, white for labels
Icons:         #4db8ff with glow
Progress Bars: #2a7fbf → #6dd5ff gradient
Buttons:       #1a3d5c bg, #4db8ff border
```

### Particles & Effects
```
Thruster:   Yellow-orange gradient, fading
Collision:  White flash, rapid fade
Collection: Material color, spiral upward
Landing:    Dust cloud, gray with blue tint
Explosion:  Orange-red, expanding ring
```

## Sizing & Spacing

### Block sizes
```
Standard Block: 48x48 points
Large Block:    64x64 points
Small Block:    32x32 points
Particle:       4-12 points
```

### Spacing
```
Block Gap:      2-4 points
UI Padding:     16 points
Element Margin: 8 points
Text Line:      1.2x font size
```

### Corner radius
```
Small (< 32pt):  3-4 points
Medium (32-64):  6-8 points
Large (> 64):    10-15 points
Buttons:         8-12 points
Containers:      12-16 points
```

## Lighting Model

Single light source at the **top-left (45° angle)**.

### Surface lighting
```
Top Face:    Base color + 20% brightness
Left Face:   Base color + 10% brightness
Center:      Base color (100%)
Right Face:  Base color - 10% brightness
Bottom Face: Base color - 20% brightness
```

### Shadows
```
Position: Below and right of object
Shape:    Ellipse, 80% of object width
Color:    Black or very dark base color
Opacity:  15-25%
Blur:     Soft edge, 2-4 point blur
```

### Specular highlights
```
Position: Top-left corner
Shape:    Small ellipse or circle
Color:    White
Opacity:  30-60% (higher for shiny materials)
Size:     10-20% of object size
```

## Animation Guidelines

### Material idle states
```
Common:   None or very subtle drift
Uncommon: Gentle pulse (0.95-1.05, 3s)
Rare:     Noticeable pulse (0.9-1.1, 2s)
Crystal:  Rotate glow (360°, 4s)
Energy:   Flicker (opacity 0.8-1.0, 0.3-0.6s random)
```

### Collection
```
Duration: 0.5-0.8s
Path:     Curve toward player
Scale:    1.0 → 1.2 → 0
Opacity:  1.0 → 0
Effect:   Trailing particles
```

### Destruction
```
Duration: 0.3-0.5s
Effect:   Break into 4-6 pieces, outward explosion, random spin
Opacity:  1.0 → 0
Scale:    1.0 → 0.5 → 0
```

### UI motion
```
Button Press:      0.1s press / 0.2s release; scale 1.0 → 0.95 → 1.0; glow +20% on press
Value Change:      0.3-0.5s; pulse scale 1.0 → 1.15 → 1.0; flash bright then fade
Screen Transition: 0.4-0.6s; fade with slight scale (opacity 0 / scale 0.95 → opacity 1 / scale 1.0)
```

## Platform & Accessibility

- Support Dark Mode (already a dark theme), respect Dynamic Type, use SF Symbols where appropriate.
- **Touch targets ≥ 44×44pt**, respect Safe Area on all devices.
- Color contrast ≥ 4.5:1; honor Reduce Motion (disable pulse/rotation); VoiceOver labels on all interactive elements; haptics for important actions.

## Asset Export

- **Resolutions:** @1x (legacy), @2x (standard, 1170×2532 for iPhone 14 Pro Max), @3x (recommended for new assets).
- **Formats:** UI/icons → PDF (vector) or PNG @3x; terrain textures → PNG @2x w/ alpha; backgrounds → PNG @2x optimized; particles → PNG @1x.
- **Naming:** `terrain_rock_common@2x.png`, `terrain_crystal_rare@3x.png`, `ui_button_primary@3x.png`, `icon_material_iron.pdf`, `particle_dust.png`.

## Related

[[Drill Animation and VFX]] · [[Game Design]] · [[Terrain and Strata]] · [[Materials and Economy]] · [[Code Review]]
