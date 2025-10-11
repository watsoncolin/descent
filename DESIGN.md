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

### What is a "Run"?

A **run** is a single mining expedition from surface to core (or back to surface). Each run follows this cycle:

**1. Launch Phase**

- Select a planet from the planet selection screen
- Your pod launches from the surface station
- All stats start at current upgrade levels (fuel full, hull full, cargo empty)

**2. Descent Phase**

- Drill downward through terrain layers
- Collect minerals to fill cargo
- Manage fuel consumption
- Avoid/survive hazards
- Make risk/reward decisions: "Go deeper for better minerals, or return now?"

**3. Return Decision**

- **Option A - Return Early**: Fly back to surface before reaching core
  - Keep all collected minerals
  - Sell minerals for Credits (temporary currency)
  - No prestige - can immediately start another run
  - Safe but lower rewards
- **Option B - Reach Core**: Extract the planet's core
  - Keep all collected minerals
  - Earn Dark Matter (guaranteed valuable drop)
  - Triggers prestige option
  - Higher risk, maximum rewards

**4. Surface Phase**

- Sell all minerals for Credits
- Spend Credits on Common Upgrades (fuel, cargo, drill, hull, speed, dampeners)
- Use Golden Gems (if any) on Epic Upgrades (permanent unlocks)
- View run statistics (depth reached, minerals collected, earnings)
- **Planet regenerates** - all drilled terrain respawns with fresh resources

**5. Next Run Decision**

- **Start another run**: Same planet, with your new upgrades, but terrain is fresh
- **Prestige** (if core was extracted): Reset planet, gain Soul Crystals
- **Switch planets**: Choose different planet (if unlocked)
- **Quit to main menu**: Save progress
- **Two options when returning to surface:**

**Option A - Bank & Continue:**

- Sell all minerals immediately for Credits
- Credits are banked (safe, can't lose them)
- Cargo empties
- Pod refuels to max automatically
- Hull repairs to max automatically
- Can immediately descend again for another trip
- Repeat as many times as fuel/skill allows
- Run continues until you choose "End Run"

**Option B - End Run:**

- Sell all minerals for Credits
- Credits are banked
- Run ends, proceed to upgrade shop
- View run statistics
- Purchase upgrades with accumulated Credits

**Strategic Depth:**

- Multiple trips per run maximize earnings
- Risk management: Continue for more or end while safe?
- High fuel capacity enables 3-5 trips per run
- Each trip deeper can collect better minerals

**5. After Ending Run**

- Spend Credits on Common Upgrades (fuel, cargo, drill, hull, speed, dampeners)
- Use Golden Gems (if any) on Epic Upgrades (permanent unlocks)
- View detailed run statistics (total earned, trips made, depth reached)
- **Planet regenerates** - all drilled terrain respawns with fresh resources
- **Start another run**: Same planet, with your new upgrades, but terrain is fresh
- **Prestige** (if core was extracted): Reset planet, gain Soul Crystals
- **Switch planets**: Choose different planet (if unlocked)
- **Quit to main menu**: Save progress

### Planet Reset Behavior

**Between Runs:**

- All terrain regenerates when you return to surface
- Resource positions redistribute (same spawn rates and formulas, different locations)
- Hazards respawn in new positions
- Core chamber remains in same location (always at maximum depth)
- Your upgrades and stats persist, but the planet itself resets

**Why Planets Reset:**

- Keeps each run fresh and unpredictable
- Prevents "strip mining" strategies
- Can't memorize exact mineral locations
- Maintains challenge across multiple runs
- Balances economy and progression
- Each run tests your skills, not your memory

**Procedural Generation:**

- Planets use seeded random generation
- Same planet type always feels similar (Mars feels like Mars)
- But specific mineral positions vary each run
- Ensures replayability while maintaining planet identity

**Visual/Lore Explanation:**

> "The planet's crust regenerates between expeditions due to the corporation's quantum mining technology. Each run phases matter temporarily - when you return to base, geological forces rapidly restore the drilled sections. This sustainable approach prevents permanent planetary damage."

### Run Duration

**Typical Run Length:**

- **Quick surface run**: 2-3 minutes (grab surface minerals, return)
- **Mid-depth run**: 5-7 minutes (reach 300m, good minerals)
- **Core run**: 8-15 minutes depending on upgrades and skill
- **Failed run**: Variable (ran out of fuel, died to hazards)

**Mobile-Friendly Sessions:**

- Perfect for short play sessions (one quick run)
- Or longer sessions (multiple runs, progression visible)
- Can pause mid-run, resume later

### Run Failure States

A run can end prematurely if:

**Out of Fuel:**

- Pod automatically returns to surface (emergency thrust)
- Lose 50% of collected minerals (cargo insurance can reduce this)
- No Credits earned from lost minerals
- Hull remains at current HP

**Hull Destroyed (0 HP):**

- Pod explodes, emergency ejection
- Lose all collected minerals (unless Ejection Pod upgrade is active)
- No Credits earned
- Respawn at surface for new run

**Manual Abandon:**

- Can choose "Abandon Run" from pause menu
- Lose all collected minerals
- Counts as failed run
- Use this to escape impossible situations

### Example Run Scenarios

**Scenario 1: Conservative Early Game**

1. Launch on Mars with basic upgrades
2. Drill to 150m collecting Iron, Copper, Silver
3. Cargo at 45/50, fuel at 40/100
4. Return to surface (safe play)
5. Sell minerals for $2,000 Credits
6. Buy Cargo Level 2 upgrade
7. Start next run immediately

**Scenario 2: Risky Deep Push**

1. Launch with Drill Level 3, Fuel Level 4
2. Drill deep to 450m, collecting Platinum and Diamonds
3. Cargo full (50/50), fuel at 25/300
4. Spot Ruby vein, drop some Platinum to collect Rubies
5. Risk the return trip with low fuel
6. Barely make it back with $8,000 worth of cargo
7. Major upgrade purchased

**Scenario 3: Core Extraction**

1. Launch with max upgrades for Mars
2. Efficient drilling to 500m core
3. Extract Dark Matter
4. Return to surface with full cargo + Dark Matter
5. Sell everything for $22,000 Credits
6. Prestige screen appears
7. Choose to prestige: Gain 50 Soul Crystals
8. All Credits and upgrades reset
9. All minerals now worth 50% more permanently
10. Start fresh run on Mars (or unlock Luna)

**Scenario 4: Failed Run**

1. Launch and drill to 300m
2. Hit gas pocket, lose 20 HP
3. Cave-in, lose another 20 HP (40 HP remaining)
4. Panic, drill too fast, another cave-in
5. Hull destroyed at 0 HP
6. Lose all collected minerals
7. Respawn at surface, start new run more carefully

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

### 1. Bocks (Cash) - Temporary Currency

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

- All Bocks (cash)
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

Bought with Bocks, specific to current planet run.

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
3. Single runs can earn millions of Bocks
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

- Current Bocks balance
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
- Cash/Bocks counter

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
