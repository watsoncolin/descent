# DESCENT - Complete Design Document

## Game Overview

**Title**: DESCENT  
**Genre**: Mining Action / Incremental Progression  
**Platform**: iOS  
**Engine**: Swift + SpriteKit

A Motherload-inspired mining game where you pilot a drilling pod through planets to extract their cores. Features a dual-currency prestige system inspired by Egg Inc, where each planet offers progressively more valuable materials but requires better upgrades and skills to conquer.

**Tagline**: _"How deep will you go?"_

---

## Core Gameplay Loop

1. **Select a planet** from globe view
2. **Drill downward** through terrain layers to collect minerals
3. **Manage fuel** carefully - running out = game over
4. **Return to surface** to sell minerals and refuel
5. **Buy upgrades** with Credits (cash) to improve your pod
6. **Extract the planet's core** to trigger prestige
7. **Gain Soul Crystals** for permanent earning bonuses
8. **Move to harder planets** for higher multipliers

---

## Core Mechanics

### Movement

- **Left/Right**: Horizontal movement (consumes fuel)
- **Down**: Drill through terrain (consumes fuel)
- **Up**: Fly upward (consumes fuel, cannot drill upward)
- **Gravity**: Pulls you down when not thrusting

### Fuel Management

- Fuel depletes with all movement
- Running out of fuel = game over (crash to surface)
- Must balance depth exploration vs return trip fuel

### Cargo System (Volume-Based)

- Each mineral takes up cargo space based on size/density
- Starting capacity: 50 units
- Creates strategic decisions: "Drop coal for diamonds?"

### Terrain Destruction

- Different rock types require better drill levels
- Harder terrain = slower drilling speed
- Some materials impossible without drill upgrades

### Hazards

- Gas pockets (damage hull)
- Lava flows (damage hull)
- Extreme temperatures (require resistance upgrades)
- Environmental hazards specific to each planet

---

## Resource Economy

### Philosophy

Resources progress from familiar real-world elements to exotic fictional materials, creating a sense of discovery and sci-fi escalation as you explore deeper and harder planets.

### Tier 1: Common Elements (Mars, Luna)

_Real elements, educational, familiar_

- **Carbon** (Coal): 5 units, $10 each - Black chunks, very common
- **Iron (Fe)**: 3 units, $25 each - Reddish-brown ore veins
- **Copper (Cu)**: 3 units, $30 each - Orange-brown metallic veins
- **Silicon (Si)**: 2 units, $50 each - Gray crystalline formations
- **Aluminum (Al)**: 2 units, $60 each - Silver-white metallic deposits

### Tier 2: Precious Real Elements (Luna, Io)

_Valuable metals and gems_

- **Silver (Ag)**: 2 units, $75 each - Shiny metallic veins
- **Gold (Au)**: 2 units, $150 each - Yellow metallic veins
- **Platinum (Pt)**: 2 units, $250 each - Silver-white, very shiny
- **Titanium (Ti)**: 1.5 units, $200 each - Dark gray metallic

### Tier 3: Rare Earth & Gems (Io, Europa, Titan)

_Real but exotic materials_

- **Neodymium (Nd)**: 1.5 units, $300 each - Purple-silver magnetic crystals
- **Palladium (Pd)**: 1 unit, $400 each - Silvery-white metallic
- **Ruby**: 0.5 units, $500 each - Deep red crystalline gem
- **Emerald**: 0.5 units, $600 each - Green crystalline gem
- **Diamond**: 0.5 units, $800 each - Clear/white brilliant crystal
- **Rhodium (Rh)**: 1 unit, $900 each - Silver-white, ultra-reflective

### Tier 4: Exotic Fictional Materials (Venus, Mercury)

_Sci-fi elements discovered on extreme planets_

- **Pyronium**: 1 unit, $1,500 each
  - Glowing orange-red crystal that pulses with heat
  - Found in Venus volcanic zones (depth 400m+)
  - Visual: Orange glow with heat shimmer effect
- **Cryonite**: 1 unit, $1,500 each
  - Bright blue ice crystal that radiates cold
  - Found in Europa deep ice layers (depth 500m+)
  - Visual: Blue glow with frost particles
- **Voltium**: 0.8 units, $2,000 each
  - Electric yellow crystal with lightning inside
  - Found in Mercury magnetic storm zones
  - Visual: Yellow/white with electrical arcs
- **Gravitite**: 0.5 units, $2,500 each
  - Purple-black floating crystal that defies gravity
  - Found in Titan deep hydrocarbon zones
  - Visual: Slowly floats/bobs, purple aura
  - Gameplay: Actually floats upward when released
- **Neutronium**: 0.3 units, $3,500 each
  - Ultra-dense silver sphere, impossibly heavy-looking
  - Found near Mercury core (depth 800m+)
  - Visual: Silver-white with gravitational distortion effect
  - Gameplay: Slows movement slightly when carrying

### Tier 5: Alien/Endgame Materials (Mercury, Enceladus)

_The rarest, most valuable discoveries_

- **Xenite**: 0.5 units, $4,000 each
  - Iridescent crystal that shifts colors
  - Found in all deep cores (depth 700m+), rare
  - Visual: Rainbow shifting holographic effect
  - Lore: "Evidence of alien engineering?"
- **Chronite**: 0.4 units, $5,000 each
  - Transparent crystal with swirling time distortion inside
  - Found in Enceladus alien structures
  - Visual: Clear with slow-motion particle effects inside
  - Gameplay: Time appears to slow near it (visual effect)
- **Quantum Foam**: 0.3 units, $6,000 each
  - Shimmering, impossible geometry
  - Found in Enceladus subsurface ocean (depth 900m+)
  - Visual: Glitchy, phases in/out of visibility
- **Dark Matter**: 0.1 units, $10,000 each
  - Black void crystal that absorbs light
  - Found: Planet cores exclusively (guaranteed one per core)
  - Visual: Black hole effect, bends light around it
- **Stellarium**: 0.05 units, $25,000 each
  - Miniature star contained in crystal
  - Found: Enceladus core only, extremely rare (1-3 per run)
  - Visual: Brilliant white-gold with lens flare effects
  - Ultimate chase item

### Depth Distribution

- **0-50m**: Coal, Iron, Copper
- **50-150m**: Silver starts appearing, Gold becomes possible
- **150-300m**: Gold common, Platinum appears, occasional gems
- **300-500m**: Gems more common, Titanium veins
- **500m+**: Heavy gem concentration, radioactive materials
- **Core zone**: Alien artifacts, dark matter

---

## Planet System

Each planet has progressively more valuable minerals but requires specific upgrades to access.

### Planet Progression

1. **Mars** (Tutorial) - Base value: 1x - No requirements
2. **Luna** (Earth's Moon) - Base value: 2x - No requirements
3. **Io** (Jupiter's moon) - Base value: 5x - _Requires Heat Resistance Level 1_
4. **Europa** (Ice moon) - Base value: 8x - _Requires Cold Resistance Level 1_
5. **Titan** (Saturn's moon) - Base value: 15x - _Requires Cold Resistance Level 2_
6. **Venus** (Extreme heat) - Base value: 25x - _Requires Heat Resistance Level 2_
7. **Mercury** (Ultra heat) - Base value: 50x - _Requires Heat Resistance Level 3_
8. **Enceladus** (Cryogenic) - Base value: 100x - _Requires Cold Resistance Level 3_

### Planet Value Multiplier

Same minerals exist on every planet, but worth MORE on harder planets:

- Iron on Mars = $25
- Iron on Venus = $625 (25x multiplier)
- Diamond on Mars = $800
- Diamond on Venus = $20,000

This creates natural progression: grind early planets to unlock later ones.

---

## Currency Systems

### 1. Credits (Cash) - Temporary Currency

- Earned by selling minerals at surface
- Used to buy Common Upgrades (planet-specific)
- Resets when you prestige (extract planet core)
- Primary currency for moment-to-moment progression

### 2. Soul Crystals - Permanent Progression

- Earned when you prestige (extract a planet's core)
- Amount based on total career earnings before prestige
- Each Soul Crystal gives **+10% to ALL mineral values** permanently
- Never lost, compounds across all future runs
- Formula: `Soul Crystals = √(Total Career Earnings / 1000)`

### 3. Golden Gems - Premium Currency

- Used to buy Epic Upgrades (permanent unlocks)
- Earned through:
  - Special drones that fly by (shoot them down)
  - Finding rare "Golden Nuggets" while mining
  - Daily login bonuses
  - Watching ads (optional)
  - Completing challenges
  - In-app purchases (optional)

---

## The Prestige System

### When You Extract a Planet's Core:

**What You Lose:**

- All Credits (cash)
- All Common Upgrades (fuel, cargo, drill, hull, speed, dampeners)
- Your current planet progress

**What You Keep:**

- Soul Crystals (earning bonus)
- Epic Upgrades (permanent unlocks)
- Golden Gems (premium currency)
- Planet unlocks (can return to any unlocked planet)

**What You Gain:**

- Soul Crystals based on total earnings
- Access to next planet tier (if requirements met)

### Earnings Bonus (EB)

Your total multiplicative effect from Soul Crystals:

- 5 Soul Crystals = 50% bonus (1.5x multiplier)
- 20 Soul Crystals = 200% bonus (3x multiplier)
- 100 Soul Crystals = 1000% bonus (11x multiplier)

This bonus applies to ALL mineral values on ALL planets permanently.

---

## Upgrade Systems

### Common Upgrades (Reset on Prestige)

Bought with Credits, specific to current planet run.

#### Starting Pod Stats

- **Fuel**: 100 units (~2 minutes of active movement)
- **Hull**: 50 HP
- **Cargo**: 50 units
- **Drill**: Level 1 (soft terrain only)
- **Speed**: 100% base
- **Impact Resistance**: 0 (any fast fall = damage)

#### 1. Fuel Tank

_Enables longer expeditions without surface returns_

- Level 1: 100 fuel - $0 (starting)
- Level 2: 150 fuel - $500
- Level 3: 200 fuel - $1,200
- Level 4: 300 fuel - $2,500
- Level 5: 400 fuel - $5,000
- Level 6: 500 fuel - $10,000 (max)

#### 2. Drill Strength

_Gates access to terrain types and deeper layers_

- Level 1: Dirt, soft rock, coal veins - $0 (starting)
- Level 2: Iron ore, copper, silver veins - $800
- Level 3: Hard rock, gold, granite - $2,000
- Level 4: Platinum veins, crystalline formations, titanium - $4,500
- Level 5: Any terrain, gem veins, alien materials - $10,000 (max)

#### 3. Cargo Capacity

_More minerals per trip = more profit_

- Level 1: 50 units - $0 (starting)
- Level 2: 75 units - $400
- Level 3: 100 units - $900
- Level 4: 150 units - $2,000
- Level 5: 200 units - $4,500
- Level 6: 250 units - $9,000 (max)

#### 4. Hull Armor

_Survive hazards and impacts_

- Level 1: 50 HP - $0 (starting)
- Level 2: 75 HP - $600
- Level 3: 100 HP - $1,400
- Level 4: 150 HP - $3,000
- Level 5: 200 HP - $6,500 (max)

#### 5. Engine Speed

_Faster navigation and hazard avoidance_

- Level 1: 100% speed - $0 (starting)
- Level 2: 120% speed - $700
- Level 3: 140% speed - $1,600
- Level 4: 170% speed - $3,500
- Level 5: 200% speed - $7,500 (max)

#### 6. Impact Dampeners

_Enables aggressive free-fall playstyle_

- Level 0: Fall damage threshold = low speed - $0 (starting)
- Level 1: Survive moderate falls - $1,000
- Level 2: Survive high-speed falls - $3,000
- Level 3: Survive terminal velocity - $8,000 (max)

#### Consumables (Single-Use)

- **Repair Kit**: Restore 50 HP - $150
- **Fuel Cell**: Restore 100 fuel - $200
- **Mining Bomb**: Destroy 5x5 area of terrain - $400
- **Emergency Teleporter**: Instant return to surface with cargo - $800
- **Shield Generator**: Invincibility for 10 seconds - $600

**Total cost to max all Common Upgrades**: ~$60,000

---

### Epic Upgrades (Permanent, Never Reset)

Bought with Golden Gems, persist across ALL planets and prestiges.

#### Earnings Multipliers

- **Soul Crystal Amplifier**: Each Soul Crystal gives +12% instead of +10%
  - 5 levels, costs 5,000→10,000→20,000→35,000→50,000 gems
- **Mineral Value Boost**: All minerals worth +25% more
  - 5 levels, costs 3,000→6,000→12,000→24,000→30,000 gems

#### Quality of Life

- **Auto-Refuel**: Automatically refuels between runs - 2,000 gems
- **Auto-Repair**: Automatically repairs hull - 2,500 gems
- **Advanced Scanner**: Shows minerals through terrain - 3,000 gems
- **Ejection Pod**: Survive death once per run - 5,000 gems
- **Cargo Insurance**: Keep 50% of cargo on death - 8,000 gems
- **Advanced HUD**: Shows depth, nearest hazards, fuel efficiency - 1,500 gems

#### Planet Unlock Gates

- **Heat Resistance Level 1**: Survive warm planets - 2,500 gems
- **Heat Resistance Level 2**: Survive hot planets - 5,000 gems
- **Heat Resistance Level 3**: Survive volcanic planets - 12,000 gems
- **Cold Resistance Level 1**: Survive cold planets - 2,500 gems
- **Cold Resistance Level 2**: Survive frozen planets - 5,000 gems
- **Cold Resistance Level 3**: Survive cryogenic planets - 12,000 gems

#### Discount Upgrades

- **Cheaper Upgrades**: All common upgrades cost 20% less
  - 5 levels, costs 2,000→4,000→8,000→16,000→25,000 gems
- **Faster Drilling**: Drill speed +20% permanently
  - 3 levels, costs 3,000→7,000→15,000 gems

**Total cost for all Epic Upgrades**: ~300,000 Golden Gems

---

## Planet-Specific Design

Each planet has unique visual identity, hazards, and resource distribution to create distinct gameplay experiences.

### 1. Mars (Tutorial Planet)

**Base Multiplier**: 1x  
**Requirements**: None  
**Core Depth**: 500m

**Visual Identity**

- Red/orange terrain with dusty atmosphere effect
- Rocky, cratered surface with iron-rich rust-colored veins

**Unique Hazards**

- **Dust Storms** (depth 200m+): Reduce visibility, harder to spot minerals
- **Unstable Rock**: Occasional cave-ins drop rocks (10 HP damage)
- **Small Gas Pockets**: Minor hazard, 5 HP damage

**Terrain Composition**

- 60% soft rock (easy drilling)
- 30% medium rock
- 10% hard rock (near core)

**Special Features**

- Tutorial messages appear here
- Easiest planet for learning mechanics
- Most forgiving hazard damage
- Clear progression of difficulty with depth

---

### 2. Luna (Earth's Moon)

**Base Multiplier**: 2x  
**Requirements**: None  
**Core Depth**: 400m

**Visual Identity**

- Gray/white dusty terrain with no atmosphere
- Stars visible from surface, Earth visible in background sky
- Smooth regolith layers

**Unique Hazards**

- **Low Gravity**: Movement feels floatier, harder to control precisely
- **Sharp Rocks**: Hidden jagged formations (15 HP damage)
- **Vacuum Pockets**: Sudden zero-resistance areas causing faster falls

**Terrain Composition**

- 70% soft regolith (very easy drilling)
- 20% medium rock
- 10% titanium deposits (harder)

**Special Features**

- Low Gravity Modifier: Jump physics feel different
- Faster drilling overall due to loose terrain
- Good for practicing precise movement control

---

### 3. Io (Volcanic Moon)

**Base Multiplier**: 5x  
**Requirements**: Heat Resistance Level 1  
**Core Depth**: 600m

**Visual Identity**

- Yellow/sulfur-colored terrain with red lava flows
- Volcanic vents releasing steam, orange glow from below

**Unique Hazards**

- **Lava Rivers** (depth 100m+): Horizontal flowing lava, 20 HP/sec
- **Volcanic Vents**: Randomly shoot upward, push and damage (25 HP)
- **Sulfur Gas Clouds**: Persistent damage zones, 10 HP/sec
- **Crumbling Terrain**: Some blocks break and release lava after drilling

**Terrain Composition**

- 40% volcanic rock (medium-hard)
- 30% sulfur deposits (soft but toxic)
- 20% hard basalt
- 10% obsidian (very hard, near core)

**Special Features**

- Heat Damage: Without resistance, 5 HP/sec ambient damage below 300m
- High risk, high reward with valuable minerals
- Visual warnings for lava flows (orange glow through terrain)
- First exotic material: Pyronium

---

### 4. Europa (Ice Moon)

**Base Multiplier**: 8x  
**Requirements**: Cold Resistance Level 1  
**Core Depth**: 700m

**Visual Identity**

- White/blue ice terrain with cracks revealing liquid water
- Crystalline ice formations
- Blue bioluminescent organisms in deep water

**Unique Hazards**

- **Ice Spikes**: Sharp formations, 20 HP damage on contact
- **Subglacial Ocean** (depth 300m+): Large water pockets slow movement
- **Freezing Water**: Water contact = 15 HP/sec without resistance
- **Pressure Cracks**: Drilling too fast shatters ice around you

**Terrain Composition**

- 50% solid ice (medium difficulty)
- 30% crystalline ice (harder, more gems)
- 15% liquid water pockets
- 5% alien organisms (unique collectible)

**Special Features**

- Cold Damage: 5 HP/sec below 200m without resistance
- Buoyancy Zones: Water pockets reverse gravity, push upward
- Unique "frozen" sound effects and visuals
- Discover alien life (bonus rewards)
- First appearance of Cryonite and Xenite

---

### 5. Titan (Saturn's Moon)

**Base Multiplier**: 15x  
**Requirements**: Cold Resistance Level 2  
**Core Depth**: 800m

**Visual Identity**

- Orange/brown methane atmosphere with thick hazy visibility
- Dark hydrocarbon terrain
- Methane lakes at surface and underground

**Unique Hazards**

- **Methane Lakes**: Large liquid methane zones, 25 HP/sec damage
- **Nitrogen Geysers**: Explosive vents launch you upward (30 HP)
- **Hydrocarbon Rain**: Periodic "rain" damages hull (5 HP/sec when active)
- **Thick Atmosphere**: Reduced visibility, scanner less effective

**Terrain Composition**

- 40% hydrocarbon-rich rock (oily, slippery)
- 30% frozen methane (medium-hard)
- 20% ice
- 10% exotic organic materials (valuable)

**Special Features**

- Slippery Physics: Movement has momentum, harder to stop precisely
- Atmosphere Pressure: Deeper = more pressure, slower movement
- Orange fog obscures long-distance vision
- Unique "splashing" effects in methane
- First appearance of Gravitite

---

### 6. Venus (Hellscape)

**Base Multiplier**: 25x  
**Requirements**: Heat Resistance Level 2  
**Core Depth**: 900m

**Visual Identity**

- Yellow/green toxic atmosphere
- Bright orange molten terrain with acid rain effects
- Intense heat distortion visual effects

**Unique Hazards**

- **Sulfuric Acid Rain**: Constant environmental damage (10 HP/sec), worse near surface
- **Extreme Heat**: 15 HP/sec ambient damage without Level 2 resistance
- **Lava Pools**: Large molten zones (30 HP/sec)
- **Volcanic Eruptions**: Random explosions damage large areas (50 HP)
- **Corrosive Gas**: Depletes fuel 2x faster in certain zones

**Terrain Composition**

- 50% volcanic rock (very hard)
- 30% molten zones (undrillable, must avoid)
- 15% crystallized minerals (platinum, gems)
- 5% diamond veins (extremely valuable)

**Special Features**

- Pressure Atmosphere: Surface pressure slows movement significantly
- Most dangerous planet before endgame
- Highest concentration of valuable gems before Enceladus
- Visual heat waves and distortion effects
- Hull damage accumulates quickly
- First appearance of Voltium, Neutronium, and Chronite

---

### 7. Mercury (Solar Furnace)

**Base Multiplier**: 50x  
**Requirements**: Heat Resistance Level 3  
**Core Depth**: 1000m

**Visual Identity**

- Charred black and gray terrain
- Intense sunlight from surface
- Metal-rich silvery veins, solar flares visible in sky

**Unique Hazards**

- **Solar Radiation**: Surface damage (20 HP/sec), decreases with depth
- **Extreme Temperature Swings**: Alternate hot/cold zones
- **Magnetic Storms**: Random electrical discharges (40 HP)
- **Iron Core Interference**: Scanner doesn't work well here
- **Meteor Impacts**: Random falling meteors near surface (60 HP)

**Terrain Composition**

- 60% iron/nickel rock (very hard)
- 25% metal ore veins (platinum, titanium)
- 10% radioactive materials
- 5% alien artifacts

**Special Features**

- No Atmosphere: Extreme temperature zones
- Day/Night Cycle: Surface conditions change if you return
- Richest metal deposits in the game
- Requires perfect execution to reach core
- Drill struggles with metal-rich terrain
- First appearance of Quantum Foam

---

### 8. Enceladus (Cryogenic Hell)

**Base Multiplier**: 100x  
**Requirements**: Cold Resistance Level 3  
**Core Depth**: 1200m

**Visual Identity**

- Pure white ice surface with blue crystalline structures
- Subsurface ocean with bioluminescence
- Ice geysers erupting, Saturn visible in sky

**Unique Hazards**

- **Cryogenic Jets**: Massive ice geysers shooting upward (50 HP)
- **Deep Ocean** (depth 500m+): Must navigate through liquid water
- **Extreme Cold**: 20 HP/sec ambient damage without Level 3 resistance
- **Ice Quakes**: Terrain shifts and crushes (70 HP instant damage)
- **Alien Guardians**: Rare hostile creatures near core (80 HP)

**Terrain Composition**

- 40% ultra-hard ice (slow drilling)
- 30% subsurface ocean (navigable but dangerous)
- 20% crystalline formations (gems everywhere)
- 10% core access tunnels (narrow, precise navigation required)

**Special Features**

- Final Challenge: Hardest planet in the game
- Highest gem concentration
- Ocean Layer: Mid-depth entirely liquid, must swim through
- Alien Presence: Evidence of alien structures near core
- Dark Matter guaranteed at core
- Only source of Stellarium (ultimate chase item)
- Requires mastery of all mechanics

---

## Planet Progression Strategy

**Planets 1-2 (Mars, Luna)**: Learn mechanics, build Soul Crystals  
**Planets 3-4 (Io, Europa)**: Unlock resistances, face environmental challenges, discover exotic materials  
**Planets 5-6 (Titan, Venus)**: Master advanced hazards, high stakes, rare exotics appear  
**Planets 7-8 (Mercury, Enceladus)**: Endgame content, perfect execution required, alien materials

---

## Collection Meta-Game & Discovery

### Material Compendium

- Each exotic material first discovery = 500 Golden Gems bonus
- Unlocks lore entry in compendium/encyclopedia
- Visual gallery of all discovered materials
- Stats tracking: total collected, rarest find, highest value haul

### Example Lore Entries

**Pyronium**  
_"First discovered in the volcanic depths of Io, Pyronium maintains a stable temperature of 2000°C. Scientists theorize it's the key to unlimited fusion energy. Mining corporations have sparked a new gold rush across the solar system."_

**Cryonite**  
_"This crystalline structure exists at absolute zero yet remains stable at any temperature. Discovered on Europa, it defies thermodynamic laws. Applications in quantum computing are revolutionary."_

**Gravitite**  
_"Found only in Titan's hydrocarbon depths, Gravitite exhibits negative mass properties. It literally falls upward. The physics community is divided on whether this should even be possible."_

**Xenite**  
_"Unknown elemental structure, not on any periodic table. Its iridescent properties suggest artificial origin. Evidence of alien engineering? Every government and corporation wants answers."_

**Stellarium**  
_"Fragments of stellar matter, somehow stabilized into crystalline form. Its existence violates known physics. The alien structures on Enceladus suggest this material was manufactured, not naturally occurring. What civilization had the technology to bottle stars?"_

### Achievements

- **Element Hunter**: Discover all Tier 1-3 real elements
- **Exotic Collector**: Discover all Tier 4 exotic materials
- **Alien Archivist**: Discover all Tier 5 alien materials
- **Stellarium Seeker**: Collect 100 Stellarium (dozens of runs)
- **Dark Matter Baron**: Extract 50 planet cores
- **Material Master**: Collect at least one of every material in the game

### Visual Identity Guidelines

**Real Elements (Tiers 1-3)**

- Realistic textures (metallic sheens, crystal facets)
- Earth-tone colors
- Familiar geological shapes

**Exotic Materials (Tier 4)**

- Particle effects (glow, shimmer, sparks)
- Unnatural colors (bright electric blue, plasma orange)
- Animated textures (pulsing, flowing)

**Alien Materials (Tier 5)**

- Reality-bending effects (lens distortion, glitches)
- Impossible geometries
- Multiple visual layers
- Screen shake or visual feedback when collected
- Post-processing effects (bloom, chromatic aberration)

---

## Progression Examples

1. **Run 1**: Mine basics, earn ~$300 → Buy Fuel Level 2
2. **Run 2-3**: Earn ~$800 → Buy Cargo Level 2 + Drill Level 2
3. **Run 4-6**: Reach depth 150m, earning $2,000+ → Hull + Speed upgrades
4. **Run 7-10**: Access gold/platinum, $5,000+ runs → Save for Drill Level 3
5. **Run 11-15**: Attempt Mars core at 500m → Extract core, earn 50 Soul Crystals
6. **Result**: All minerals now worth 50% more permanently

### Mid Game (Runs 16-50, Multiple Planets)

1. Prestige on Mars multiple times until ~100 Soul Crystals (1000% bonus)
2. Save Golden Gems to unlock Luna (2x base multiplier)
3. With Soul Crystal bonus, Luna minerals worth 22x Mars original values
4. Grind Luna for Heat Resistance Level 1
5. Unlock Io (5x multiplier) and Europa (8x multiplier)
6. Each planet takes 10-15 runs to master
7. Building up to thousands of Soul Crystals

### Late Game (Runs 51-100+, Extreme Planets)

1. Unlock Level 3 resistances for Mercury/Enceladus
2. Minerals worth 100x base value PLUS massive Soul Crystal bonus
3. Single runs can earn millions of Credits
4. Prestiging gives thousands of Soul Crystals per run
5. Maxing out Epic Upgrades
6. Perfect execution runs on hardest planets

---

## Strategic Build Paths

Players can optimize different playstyles:

**Speed Runner Build**

- Max engine + impact dampeners early
- Fast, risky runs with free-falling
- High fuel efficiency through speed

**Tank Build**

- Max hull + drill first
- Survive anything, slower but safer
- Can push deeper into dangerous zones

**Efficiency Build**

- Balanced fuel + cargo upgrades
- Maximize profit per run
- Consistent, reliable progression

**Explorer Build**

- Unlock scanner + resistances early
- Access rare planets sooner
- Focus on Golden Gem collection

---

## UI Considerations

### Main Screen (Mining View)

- Fuel gauge (visual bar + number)
- Hull HP (visual bar + number)
- Cargo capacity: "45/50 units" + "$1,250 value"
- Current depth meter
- Minimap (if scanner unlocked)

### Surface/Upgrade Screen

- Current Credits balance
- Upgrade shop with clear level indicators
- "Prestige Available" indicator when at core
- Soul Crystal counter with EB percentage

### Planet Selection Screen

- Globe view with clickable planets
- Planet stats (multiplier, requirements)
- Locked planets show requirements
- Current Soul Crystal bonus displayed

---

## Why This Design Works

1. **Always Progressing**: Even failed runs contribute to Soul Crystals
2. **Fresh Challenges**: Each planet feels new despite same mechanics
3. **"One More Run" Factor**: Always close to next milestone
4. **Strategic Depth**: When to prestige? Which planet? Which upgrades?
5. **Long-term Goals**: Epic Upgrades take 50-100 runs
6. **Skill + Persistence**: Good players progress faster, everyone can max out
7. **Clear Milestones**: Each Soul Crystal threshold feels significant
8. **Variety**: 8 unique planets with different challenges

---

## iOS Touch Controls

### Control Scheme

Simple, intuitive direct-touch controls:

**Primary Control - Touch and Drag**

- **Touch and hold anywhere on screen** to move the pod
- Pod moves toward your finger position
- The further from the pod, the faster it moves
- Automatically drills through terrain when touching it
- Release to stop moving (gravity takes over)

**Automatic Drilling**

- No separate drill button needed
- Terrain automatically breaks when pod touches it while moving
- Visual feedback: Cracks appear, particles fly
- Audio feedback: Drilling sound based on material hardness
- Haptic feedback on successful drill

**Item Buttons (Bottom of Screen)**

- **Bomb**: Destroys 5x5 area of terrain
- **Teleporter**: Instant return to surface with cargo
- **Repair Kit**: Restore 50 HP
- **Fuel Cell**: Restore 100 fuel
- **Shield**: Invincibility for 10 seconds
- Buttons show quantity owned and are grayed out when unavailable

**Top UI Bar (Always Visible)**

- Fuel gauge (horizontal bar with percentage)
- Hull HP (horizontal bar with percentage)
- Cargo capacity (volume used/max + current value)
- Current depth meter
- Cash/Credits counter

**Additional UI**

- **Return to Surface Button**: Large button appears when near surface (top 50m)
- **Pause Button** (top-right): Opens pause menu
  - Resume
  - Return to Surface (keeps cargo)
  - Abandon Run (lose cargo)
  - Settings (sound, haptics, control sensitivity)

### Control Feel & Feedback

- **Haptic Feedback**:
  - Light tap when drilling soft terrain
  - Medium pulse when drilling hard terrain
  - Strong pulse when collecting valuable materials
  - Continuous vibration when taking damage
- **Visual Feedback**:
  - Thrust particles from pod pointing toward finger
  - Terrain cracks before breaking
  - Screen shake on hard impacts
  - Glow/flash when collecting gems and exotic materials
  - Damage indicators (screen edges flash red)
  - Trail effect showing pod movement path
- **Audio Cues**:
  - Different drilling sounds per material type
  - Satisfying "ping" when collecting minerals
  - Warning beeps for low fuel/hull
  - Ominous sounds near hazards

### Why This Control Scheme Works

- **Intuitive**: Touch where you want to go
- **One-handed play**: Can play with just thumb
- **No occlusion**: Finger doesn't block view since pod moves toward it
- **Precise**: Direct control for navigating tight spaces
- **Automatic drilling**: No need to think about separate actions
- **Simple**: Easy to learn, hard to master

### Accessibility Options

- Adjustable movement sensitivity (how fast pod moves toward finger)
- Visual indicators for touch position (optional circle/crosshair)
- Haptic feedback intensity (off/low/medium/high)
- Button size scaling (small/medium/large)
- Colorblind modes for mineral identification
- Optional "safe mode" warning before entering dangerous areas

---

## UI/UX Design & Screen Layouts

### Screen Flow Diagram

```
App Launch
    ↓
Main Menu
    ↓
Planet Selection
    ↓
Mining View ←→ Pause Menu
    ↓            ↓
Surface/Shop    Abandon Run
    ↓               ↓
Mining View    Planet Selection
    ↓
Prestige Screen
    ↓
Surface/Shop
```

---

### Screen 1: Main Menu / Title Screen

**Layout:**
```
┌─────────────────────────┐
│                         │
│      [DESCENT Logo]     │
│   "How deep will you    │
│        go?"             │
│                         │
│     [Start Game]        │
│     [Continue]          │ (if save exists)
│     [Settings]          │
│     [Compendium]        │ (locked until first exotic found)
│                         │
│   [Golden Gems: 1,250]  │
└─────────────────────────┘
```

**Elements:**
- Logo: Large pixel art title with subtle glow animation
- Tagline: Fades in below logo
- Buttons: Centered, stacked vertically with icons
- Golden Gems counter: Bottom right corner
- Background: Animated starfield or Mars surface parallax

**Transitions:**
- Fade in from black on app launch
- Button press: Scale animation + haptic feedback
- Start Game → Fade to Planet Selection (or Mining if continuing)

---

### Screen 2: Planet Selection (Globe View)

**Layout:**
```
┌─────────────────────────┐
│  [Back]    PLANETS [💎1,250]│
│                         │
│     🌍 ← Rotatable      │
│    Globe                │
│   (Swipe to rotate,     │
│    Tap planet           │
│    to select)           │
│                         │
│  ┌─────────────────┐    │
│  │ 🔴 MARS (1x)    │    │
│  │ Unlocked        │    │
│  │ Core: 500m      │    │
│  │                 │    │
│  │ Your Best:      │    │
│  │ • Deepest: 487m │    │
│  │ • Best: $5,200  │    │
│  │ • Prestiges: 12 │    │
│  │                 │    │
│  │   [SELECT]      │    │
│  └─────────────────┘    │
└─────────────────────────┘
```

**Locked Planet Card:**
```
┌─────────────────────┐
│ 🔒 IO (LOCKED)      │
│ Multiplier: 5x      │
│                     │
│ Requires:           │
│ Heat Resist Lvl 1   │
│ Cost: 2,500 💎      │
│                     │
│ 💎 Have: 1,850      │
│ [████░░] 74%        │
│                     │
│ Hazards: Lava 🔥    │
│ Rewards: 5x value!  │
│                     │
│  [UNLOCK] (grayed)  │
└─────────────────────┘
```

**Features:**
- Rotatable 3D globe (swipe left/right)
- Planets pulse/glow when unlocked
- Locked planets show lock icon + silhouette
- Tapping planet slides card up from bottom
- Shows Soul Crystal bonus: "EB: +250%" at top
- Quick stats overlay on swipe up

**Transitions:**
- Slide up from Main Menu
- Planet select → Zoom to planet, fade to Mining View

---

### Screen 3: Mining View (Main Gameplay)

**Layout:**
```
┌─────────────────────────┐
│ ⛽[████░░] 67%  Credits  │ ← Top HUD
│ ❤️ [██████] 90%  12,450 │
│ 📦 34/50  💰$2,450      │
│ 📏 Depth: 245m     [≡]  │
├─────────────────────────┤
│                         │
│                         │
│    [Your Pod] ← 🔦      │
│                         │
│   ▓▓▓▓ Terrain ▓▓▓▓     │ ← Scrolling
│   ▓💎▓▓▓▓▓▓▓▓▓▓         │   game area
│   ▓▓▓▓⚡▓▓▓▓▓▓          │   (camera
│   ▓▓▓▓▓▓▓🔥▓▓▓          │    follows pod)
│                         │
│                         │
├─────────────────────────┤
│ [💣] [📡] [🔧] [⛽] [🛡]  │ ← Item buttons
│  3    1    2    1    0  │   (with counts)
└─────────────────────────┘
```

**HUD Elements (Always Visible):**

**Top Bar:**
- **Fuel Gauge**: Horizontal bar, color-coded (green→yellow→red)
  - Shows percentage and visual bar
  - Pulses red when <20%
- **Hull HP**: Horizontal bar, color-coded
  - Shows percentage and visual bar
  - Screen edges flash red when taking damage
- **Cargo Display**: "34/50 units" + current value "$2,450"
  - Visual bar showing capacity
  - Glows gold when near full
- **Depth Meter**: "245m" with down arrow icon
  - Updates in real-time
- **Credits Counter**: Shows current cash
- **Pause Button** (☰): Top right corner

**Bottom Bar (Semi-transparent):**
- 5 consumable item buttons with icons
- Shows quantity owned below each
- Grayed out when quantity = 0
- Tap to use (confirmation for Teleporter)

**Visual Feedback:**
- Touch position: Optional crosshair/circle (accessibility)
- Pod thrust: Particle trail pointing toward finger
- Drilling: Cracks appear, debris particles fly
- Collection: Material floats up with value popup
- Damage: Screen shake + red flash at edges
- Low fuel warning: Fuel bar pulses + warning beep

**Dynamic HUD Modes:**
- **Standard**: All elements visible (90% opacity)
- **Minimal**: Auto-hide when pod deep (depth >300m), only show critical warnings
- **Critical**: Low fuel (<30%) or hull (<30%) - warnings prominent

**Transitions:**
- Fade in from Planet Selection at surface altitude
- Camera follows pod smoothly
- Return to surface → Slide right to Shop

---

### Screen 4: Surface / Upgrade Shop

**Layout:**
```
┌─────────────────────────┐
│    SURFACE - MARS       │
│  [Change Planet] [⚙️]   │
├─────────────────────────┤
│  CARGO HOLD             │
│  ┌─────────────────┐    │
│  │ Gold x5    $750 │    │
│  │ Diamond x2 $1600│    │
│  │ Iron x8    $200 │    │
│  │ ─────────────── │    │
│  │ TOTAL: $2,550   │    │
│  │   [SELL ALL]    │    │
│  └─────────────────┘    │
├─────────────────────────┤
│  💰 Credits: 12,450     │
│  💎 Soul Crystals: 45   │
│  ⭐ Earnings Bonus: 450%│
├─────────────────────────┤
│  [COMMON] [✨EPIC✨]    │ ← Tabs
├─────────────────────────┤
│  ┌─────────────────┐    │
│  │ ⛽ FUEL TANK    │    │
│  │ Level 2 → 3     │    │
│  │                 │    │
│  │ Current: 150    │    │
│  │ Next: 200 (+33%)│    │
│  │                 │    │
│  │ 💡 "Reach 300m" │    │
│  │                 │    │
│  │ Cost: 1,200 Cr  │    │
│  │ [████░░] 100%   │    │
│  │                 │    │
│  │   [UPGRADE]     │    │
│  └─────────────────┘    │
│  (Scroll for more...)   │
├─────────────────────────┤
│    [🚀 LAUNCH]          │
└─────────────────────────┘
```

**Epic Upgrades Tab:**
```
┌─────────────────────────┐
│  [COMMON] [✨EPIC✨]    │
├─────────────────────────┤
│ 💎 Golden Gems: 1,850   │
├─────────────────────────┤
│ ┌─────────────────┐     │
│ │ 🔥 HEAT RESIST 1│     │
│ │ PERMANENT       │     │
│ │                 │     │
│ │ Unlocks Io      │     │
│ │ (5x multiplier!)│     │
│ │                 │     │
│ │ Cost: 2,500 💎  │     │
│ │ [████░░] 74%    │     │
│ │                 │     │
│ │  [NOT YET]      │     │
│ └─────────────────┘     │
│                         │
│ ┌─────────────────┐     │
│ │ 📡 SCANNER      │     │
│ │ ✅ OWNED        │     │
│ │                 │     │
│ │ Shows minerals  │     │
│ │ through terrain │     │
│ └─────────────────┘     │
└─────────────────────────┘
```

**Features:**
- **Cargo auto-sells** on arrival (or manual SELL button)
- **Upgrade cards** scroll vertically
- Each card shows:
  - Icon + name
  - Current level → Next level
  - Stat comparison (150 → 200)
  - Benefit hint ("Reach depth 300m")
  - Cost with affordability bar
  - Buy button (green when affordable)
- **Smart recommendations**:
  - "Recommended!" badge if died from that issue
  - Highlight fuel if died from fuel depletion
- **Prestige indicator**:
  - "PRESTIGE AVAILABLE" glowing button if core extracted
- **Epic tab**:
  - Premium gold/purple theme
  - Shows owned upgrades with checkmark
  - Progress bars for "almost there" motivation

**Transitions:**
- Slide from right when returning from mining
- Launch → Slide left, fade to mining at surface
- Prestige button → Popup overlay

---

### Screen 5: Run Summary Screen

**Appears immediately after returning to surface:**

```
┌─────────────────────────┐
│     RUN COMPLETE! ✨    │
│                         │
│  Depth: 340m            │
│  🏆 NEW RECORD! (+15m)  │
│                         │
│  Cargo Value: $2,850    │
│  Time: 4m 32s           │
│  Fuel Efficiency: 87%   │
│                         │
│  Best Find:             │
│  💎 Diamond x2          │
│                         │
│  [Continue to Shop]     │
└─────────────────────────┘
```

**Features:**
- Shows key stats from run
- Highlights new records with celebration
- Shows most valuable material found
- Quick swipe down to dismiss
- Auto-dismisses after 5 seconds

**Transitions:**
- Popup overlay with blur background
- Celebration confetti if new record
- Tap anywhere or wait → Continues to Shop

---

### Screen 6: Prestige Confirmation Screen

**Layout:**
```
┌─────────────────────────┐
│   CORE EXTRACTED! ✨    │
│                         │
│   ┌───────────────┐     │
│   │  [Dark Matter]│     │ ← Animated
│   │   Collected!  │     │   glow + spin
│   └───────────────┘     │
│                         │
│  PRESTIGE AVAILABLE     │
│                         │
│  Calculating...         │
│  💰 Total: $89,450      │ ← Counts up
│                         │
│  You will gain:         │
│  ✨ +23 Soul Crystals   │
│                         │
│  You will lose:         │
│  • All Credits          │
│    ($12,450)            │
│  • All Common Upgrades  │
│                         │
│  You will keep:         │
│  • 45 + 23 = 68 Crystals│
│  • Epic Upgrades        │
│  • Planet Unlocks       │
│  • Golden Gems (1,850)  │
│                         │
│  Earnings Bonus:        │
│  450% → 680%            │
│                         │
│   [✨ PRESTIGE ✨]      │
│   [Cancel]              │
└─────────────────────────┘
```

**Prestige Animation Sequence:**
1. Core extraction in gameplay
2. Screen shakes violently
3. White flash
4. "CORE EXTRACTED!" with particle explosion
5. Fade to prestige screen
6. Numbers count up dramatically
7. Show before/after comparison
8. Confirm or cancel
9. If confirmed: Sparkle transition, reset to surface

**Transitions:**
- Popup overlay with blur background
- Particle effects (stars, sparkles)
- Haptic burst on prestige
- Fade to Surface/Shop after confirmation

---

### Screen 7: Pause Menu

**Layout:**
```
┌─────────────────────────┐
│       ⏸ PAUSED          │
│                         │
│     [▶ Resume]          │
│     [⚙️ Settings]       │
│     [🏠 Return to       │
│         Surface]        │
│     [❌ Abandon Run]    │
│                         │
│  (Return to Surface     │
│   keeps cargo)          │
│                         │
│  (Abandon Run           │
│   loses everything)     │
└─────────────────────────┘
```

**Features:**
- Blur + darken background
- Game fully paused
- Clear explanations for each option
- Confirmation dialog for destructive actions

**Transitions:**
- Slide down from top
- Blur animation on background
- Resume → Fade out, unpause
- Return to Surface → Slide transition

---

### Screen 8: Material Compendium

**Layout:**
```
┌─────────────────────────┐
│  [← Back]  COMPENDIUM   │
├─────────────────────────┤
│  [All] [Tier 1] [Tier 2]│ ← Filter tabs
│  [Tier 3] [Exotic] [???]│
├─────────────────────────┤
│  ┌──┐  PYRONIUM ⭐      │
│  │🔥│  First Discovery!  │
│  └──┘                   │
│  Collected: 47          │
│  Value: $1,500 each     │
│  Found: Venus (400m+)   │
│                         │
│  "First discovered in   │
│  the volcanic depths of │
│  Io, Pyronium maintains │
│  a stable temperature..." │
├─────────────────────────┤
│  ┌──┐  CHRONITE         │
│  │⏰│  Rare!             │
│  └──┘                   │
│  Collected: 3           │
│  Value: $5,000 each     │
│  "Transparent crystal..." │
├─────────────────────────┤
│  ┌──┐  ??? LOCKED       │
│  │❓│  Not discovered   │
│  └──┘  "???"            │
└─────────────────────────┘
```

**Features:**
- List or grid view toggle
- Filter by tier/type
- Shows lore for discovered materials
- Locked entries show silhouette + "???"
- First discovery shows +500 Golden Gems reward
- Stats: Total collected, where to find

**Transitions:**
- Slide from bottom
- Entry tap → Expands for full lore

---

### Screen 9: Settings

**Layout:**
```
┌─────────────────────────┐
│  [← Back]   SETTINGS    │
├─────────────────────────┤
│  AUDIO                  │
│  Music:     [█████░] 80%│
│  SFX:       [██████] 100%│
│                         │
│  CONTROLS               │
│  Sensitivity:[███░░] 60%│
│  Haptics:    [ON] / OFF │
│  Show Touch: ON / [OFF] │
│                         │
│  VISUAL                 │
│  Colorblind: [Standard▼]│
│   • Protanopia          │
│   • Deuteranopia        │
│   • Tritanopia          │
│  Material Labels: [ON]  │
│  Button Size:  [Medium▼]│
│  Particle FX:  [ON]     │
│  Reduced Motion: [OFF]  │
│                         │
│  GAMEPLAY               │
│  Auto-Pause on Call: ON │
│  Confirm Teleport: [ON] │
│                         │
│  DATA                   │
│  [Cloud Save: ✅ ON]    │
│  [Reset Progress]       │
│  [Restore Purchases]    │
└─────────────────────────┘
```

**Features:**
- Sliders for audio levels
- Dropdown menus for options
- Toggle switches for binary settings
- Warning dialog for Reset Progress
- Cloud save status indicator

---

### Transition Styles & Timing

**Screen Transitions:**
- **Fast** (0.2s): Tab switches, button presses
- **Medium** (0.4s): Screen changes (menu to planet)
- **Slow** (0.8s): Prestige celebration, major events

**Animation Types:**
- Fade: Black transitions between major scenes
- Slide: UI panels (shop from right, pause from top)
- Scale: Button presses (scale down on press, up on release)
- Blur: Pause menu, popups
- Particles: Prestige, rare material collection

**In-Game Feedback:**
- Material collection: Float up + fade (0.5s)
- Damage: Screen flash red (0.1s) + shake
- Low fuel: Pulse animation (continuous)
- Item use: Button scale + particle burst

---

### Mobile-Specific Considerations

**Safe Areas:**
- Top: Notch/Dynamic Island safe area (44pt)
- Bottom: Home indicator safe area (34pt)
- HUD elements respect safe areas

**Thumb Zones:**
- Critical actions in bottom 1/3 (easy reach)
- Info display in top 1/3 (read-only)
- Item buttons in thumb zone

**Screen Sizes:**
- Design for iPhone SE (smallest) first
- Scale up for iPhone 15 Pro Max
- Adjust layouts dynamically using Auto Layout principles in SpriteKit

**Interruptions:**
- Auto-pause on:
  - Phone call
  - Notification
  - App backgrounding
- Auto-save every 30 seconds
- Resume exactly where left off

---

## Visual Art Style

### Modern Pixel Art with HD Effects

**Core Foundation:**
- **Tile Size**: 32x32 pixels for terrain blocks
- **Pod**: 48x48 pixels with smooth 8-direction rotation
- **Aesthetic**: Crisp, clean pixel art with modern color palettes (not overly retro)

**Visual Hierarchy by Material Tier:**

**Tier 1-2 Materials (Common/Precious):**
- Pure pixel art with simple animations
- Realistic textures (metallic sheens, crystal facets)
- Earth-tone colors

**Tier 3 Materials (Rare Gems):**
- Pixel art + subtle glow effects
- Crystalline facets with light refraction

**Tier 4 Materials (Exotic):**
- Pixel art + animated shaders + particles
- Pyronium: Fire particle trails + heat shimmer
- Cryonite: Ice crystal particles + frost effect
- Voltium: Electrical arcs animation
- Gravitite: Floating animation + purple aura shader
- Neutronium: Gravitational distortion effect

**Tier 5 Materials (Alien):**
- Pixel art + advanced effects
- Stellarium: Lens flares, bloom, star particles
- Dark Matter: Distortion shader, void effect, light bending
- Quantum Foam: Glitch shader, phase in/out
- Chronite: Slow-motion particle effects

**Environmental Effects:**
- Dynamic lighting: Pod headlight, material glows
- Per-planet color grading filters
- Background parallax layers (pixel art)
- Weather effects: Dust storms (Mars), acid rain (Venus), ice geysers (Enceladus)
- Screen effects: Heat distortion, frost overlay, electrical interference

**UI Style:**
- Clean vector graphics for menus and buttons
- Pixel-art icons for materials in inventory
- Modern typography (SF Pro for iOS native feel)
- Smooth transitions and animations

**Technical Implementation:**
- SpriteKit particle system for drilling/collection effects
- Shader support for exotic material effects
- Built-in lighting system
- Texture atlases for performance
- Estimated ~50-75 terrain sprites, ~25 material sprites

**Color Palette Strategy:**
- Mars: Reds, oranges, rust browns
- Luna: Grays, whites, deep blacks
- Io: Yellows, sulfur, volcanic oranges
- Europa: Blues, whites, cyan
- Titan: Oranges, browns, hazy amber
- Venus: Yellow-greens, acid greens, bright oranges
- Mercury: Charcoal blacks, silvers, stark whites
- Enceladus: Pure whites, ice blues, deep ocean blues
- Materials maintain color consistency across all planets

---

## MVP Development Plan

### Phased Approach (8-10 weeks to Soft Launch)

**Phase 1: Core Mechanics Prototype (Week 1-2)**
- Goal: Prove the core gameplay loop is fun
- Mars only, basic terrain (3 block types)
- Touch controls + drilling
- Fuel system (depletes, game over when empty)
- 5 materials (Coal, Iron, Copper, Silver, Gold)
- Simple HUD (fuel, cargo, depth)
- Return to surface + sell mechanic
- **Success Metric**: Can you mine, return, sell, and repeat?

**Phase 2: Progression Loop (Week 3-4)**
- Goal: Make the grind satisfying
- Upgrade shop (6 types, 3-5 levels each)
- Hull HP system + damage
- Cargo volume system (visual inventory)
- 5 more materials (Platinum, Ruby, Emerald, Diamond, Titanium)
- 3 basic hazards (gas pockets, falling damage, cave-ins)
- Save/load system
- Better UI (upgrade screen, cargo value display)
- **Result**: Complete single-planet game loop

**Phase 3: Prestige System (Week 5)**
- Goal: Add the long-term hook
- Planet core + extraction mechanic
- Soul Crystal calculation + storage
- Earnings Bonus (EB) display
- Prestige confirmation screen with animation
- Reset logic (keep Soul Crystals, lose upgrades)
- **Result**: Repeatable progression system works

**Phase 4: Visual Polish (Week 6)**
- Goal: Make it feel good
- Particle effects (drilling, collecting, explosions)
- Screen shake on impacts
- Haptic feedback implementation
- Material glow effects
- Sound effects and simple background music
- Animated UI transitions
- Polish pass on pixel art
- **Result**: Game feels juicy and satisfying

**Phase 5: Second Planet (Week 7-8)**
- Goal: Prove planet variety works
- Planet selection screen (globe view, basic)
- Luna (2x multiplier, low gravity mechanic)
- Luna-specific hazards
- 3 exotic materials (Pyronium, Cryonite, Xenite for endgame taste)
- Golden Gems currency (basic implementation)
- 2-3 Epic Upgrades (Auto-Refuel, Scanner, Heat Resistance 1)
- **Result**: Multi-planet system validated

**Soft Launch MVP Scope:**
- 3 planets (Mars, Luna, Io)
- 15 materials (all Tier 1-2 + Pyronium as exotic teaser)
- All 6 Common Upgrade types (5 levels each)
- 5 Epic Upgrades (Auto-Refuel, Scanner, Heat Resistance 1, Mineral Value Boost, Soul Crystal Amplifier)
- Full prestige system with Soul Crystals
- Golden Gems (from Golden Nuggets while mining)
- Tutorial system (first 3 runs on Mars)
- Polish: particles, haptics, sound, smooth UI
- Planet-specific hazards for each
- **Progression**: ~10 runs to max Mars, ~15 for Luna, ~20 for Io = 15-20 hours gameplay

**Post-Launch Content Pipeline:**
- Add 1 planet per month (Europa → Titan → Venus → Mercury → Enceladus)
- Add exotic/alien materials with each planet
- Expand Epic Upgrade tree
- Add achievements and challenges
- Material compendium/encyclopedia
- Additional consumables

**Key Metrics to Track:**
- Session length: Target 5-10 minutes per run
- Retention: Day 1 (40%+), Day 7 (20%+)
- Progression: Players reaching prestige within first hour
- Red flags: Quitting before first upgrade, no prestiges, sessions <2min or >20min

---

## Next Steps for Development

1. Design unique hazards/mechanics for each planet
2. Prototype core drilling mechanics in Swift/SpriteKit
3. Create mineral spawn algorithms
4. Design UI/UX for touch controls
5. Balance economy and progression curve
6. Add achievements and challenges
7. Polish visual feedback and juice

---

## Technical Considerations (iOS/Swift)

- **Game Engine**: SpriteKit (2D, built into iOS)
- **Physics**: Use SpriteKit physics for gravity/collisions
- **Procedural Generation**: Algorithm for terrain/mineral placement
- **Save System**: UserDefaults for simple data, FileManager for complex
- **Monetization**: Optional ads for Golden Gems, IAP for gem packs
- **Performance**: Optimize for older devices, chunk-based terrain loading
