# Autonomous Survivor Game Compendium

This document is the current open-book reference for the game. It describes the playable loop, tank starts, enemies, bosses, upgrades, abilities, evolutions, events, modifiers, unlocks, pickups, scaling, and performance limits implemented in the Godot project.

Note: the in-game Compendium is now the primary live reference because it reads the current Godot catalogs directly and shows sprite/icon cards with detail pages. This document remains a readable design reference and may lag behind the fastest content batches. Current implemented catalog counts are 100 upgrades, 40 powers, 22 tanks, 71 enemies, 31 bosses, and 11 maps.

## Menu

- [Core Loop](#core-loop)
- [Run Setup](#run-setup)
- [Maps](#maps)
- [Player Baseline](#player-baseline)
- [Tank Archetypes](#tank-archetypes)
- [Core Upgrades](#core-upgrades)
- [Abilities](#abilities)
- [Evolved Synergies](#evolved-synergies)
- [Enemies](#enemies)
- [Elite Affixes](#elite-affixes)
- [Bosses](#bosses)
- [Mid-Run Events](#mid-run-events)
- [Run Modifiers](#run-modifiers)
- [Unlocks And Meta Progression](#unlocks-and-meta-progression)
- [Pickups And Rewards](#pickups-and-rewards)
- [Scaling And Pressure](#scaling-and-pressure)
- [30-Minute Balance Evidence](#30-minute-balance-evidence)
- [Performance Budgets](#performance-budgets)
- [AI And Debug Helpers](#ai-and-debug-helpers)

## Core Loop

Autonomous Survivor is a top-down tank bullet-heaven prototype.

1. Pick a tank archetype from the main menu.
2. A new run rolls a seed and 2-3 unlocked run modifiers.
3. Enemies spawn around the player and gradually scale in speed, health, damage, variety, and elite chance.
4. Defeated enemies drop EXP crystals. EXP levels the player and opens upgrade choices.
5. Every fifth normal level-up queues an ability choice.
6. Supply boxes and mid-run events can grant bonus upgrade or ability choices.
7. Bosses arrive on a timer and use behavior profiles, phases, hazards, or minions.
8. The run ends when the player dies or when the player survives to 30:00. A 30:00 clear is a victory and records run telemetry, build highlights, events, unlocks, and challenge rewards.

## Run Setup

### Seeds

- Each run receives an 8-character seed using `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`.
- The seed initializes gameplay randomness in the main scene.
- Run modifiers and mid-run events are deterministic from the seed.

### Random Run Modifiers

- Each run rolls 2-3 modifiers from the currently unlocked modifier pool.
- Modifier selection uses a seeded random generator.
- Modifiers can affect spawn cadence, EXP value, enemy scaling, boss cadence, supply boxes, weapon tempo, and pickup drops.

### Mid-Run Event Schedule

- A seeded event schedule is built at run start.
- Up to 4 events are chosen without replacement from the event catalog.
- First event triggers around 150 seconds, offset by about +/-18 seconds.
- Later events are spaced about 135-175 seconds apart.

## Maps

### Dust Bowl

- Starter map.
- Open arena with no interior blockers.
- Available by default.

### Scrap Maze

- Unlock: win Dust Bowl by surviving to 30:00.
- Larger arena than Dust Bowl.
- Contains authored wreckage obstacles that block player movement and enemy movement.
- EXP crystals, wrench drops, dynamite drops, supply boxes, and enemy spawns resolve to nearby walkable space if their first position overlaps an obstacle.
- Harder pressure profile: regular spawns are faster, bosses arrive sooner, enemy speed/health/damage scaling is stronger, active enemy pressure cap is higher, and elite odds are increased.
- Map-specific enemy roster: Scrap Scout, Gear Runner, Slag Brute, Magnet Wraith, Crusher Drone, and Furnace Reaper enter the spawn table over time.
- Map-specific boss roster: Scrapyard Warden, Magnetar Colossus, and Foundry Overlord add heavier hazard rings, targeted hazards, and minion calls.
- Original Dust Bowl enemies and bosses can still appear, but their weights are reduced so Scrapborn enemies dominate this map.

### Crystal Expanse

- Unlock: win Scrap Maze by surviving to 30:00.
- Very wide crystalline arena with shard-lane obstacle groups and a higher active enemy cap than Scrap Maze.
- Gimmick: Crystal Storm. Roughly every 18 seconds, several small crystal hazards land around the player with a burst effect. The storm count increases over time.
- Pressure profile: faster regular spawns, faster bosses, stronger speed/health/damage growth, and higher elite odds than Scrap Maze.
- Map-specific enemy roster: Shardling, Prism Runner, Quartz Bulwark, Lens Wraith, and Crystal Juggernaut.
- Map-specific boss roster: Prism Regent and Crystal Hydra focus on fast targeted hazards, hazard rings, and minion pressure.
- Global Dust Bowl enemies can still appear at reduced weight, but Crystal enemies dominate the spawn table.

### Toxic Foundry

- Unlock: win Crystal Expanse by surviving to 30:00.
- Largest current arena, with furnace-wall and vent-stack obstacles that create long lanes.
- Gimmick: Toxic Vents. Roughly every 15 seconds, corrosive hazard pools erupt across random walkable positions.
- Pressure profile: very fast regular spawns, tankier enemies, high damage growth, a larger active enemy cap, and much higher elite odds.
- Map-specific enemy roster: Spore Tick, Acid Sprinter, Caustic Bloater, Fume Stalker, and Slag Titan.
- Map-specific boss roster: Toxlord and Furnace Queen emphasize large hazard rings, minion calls, and targeted corrosive strikes.
- Global enemies are heavily down-weighted, leaving foundry enemies as the main pressure identity.

### Void Crucible

- Unlock: win Toxic Foundry by surviving to 30:00.
- Compact endgame arena with central void-core and side-rib blockers, making positioning more dangerous despite the smaller size.
- Gimmick: Void Collapse. Roughly every 13 seconds, multiple void hazards appear near the player and can spawn extra Null Mites if enemy pressure has room.
- Pressure profile: fastest regular spawns, fastest boss cadence, strongest growth multipliers, highest active enemy cap, and highest elite odds.
- Map-specific enemy roster: Null Mite, Rift Lancer, Gravity Knight, Event Horizon, and Cosmic Devourer.
- Map-specific boss roster: Rift Seraph and Void Emperor create rapid target hazards, dense hazard rings, and large minion waves.
- Global enemy/boss weights are reduced the most on this map so the endgame roster dominates.

### Autonomous Content Wave Maps

| Map | Unlock | Size Identity | Pressure Identity | Gimmick | Bosses |
|---|---|---|---|---|---|
| Moonlit Graveyard | Win Void Crucible at 30:00 | Wide, dark arena with crypt walls and tomb rows. | Spectral pressure with high elite odds and low-visibility mood. | Ghost Surge: hazards form around the player and can spawn Grave Echo enemies if pressure has room. | Grave Bell, Crypt Marshal |
| Neon Grid | Win Moonlit Graveyard at 30:00 | Rectangular grid with horizontal lanes and vertical pillars. | Very fast enemies and high boss cadence. | Laser Lattice: repeated hazard nodes trace grid-like lanes across the arena. | Neon Executioner, Grid Overseer |
| Frozen Scar | Win Neon Grid at 30:00 | Long frozen battlefield with ridges and a center ice core. | Heavy health scaling and slower but tougher pressure. | Frost Lock: hazards form a loose ring around the player with icy burst feedback. | Frost Leviathan, Blizzard Matriarch |
| Ember Rift | Win Frozen Scar at 30:00 | Compact lava arena with side gates and a central ember core. | Brutal damage growth, extreme boss cadence, and funnel pressure. | Ember Eruption: random walkable eruptions detonate across the arena with camera shake. | Magma Tyrant, Cinder Prophet |
| Astral Engine | Win Ember Rift at 30:00 | Massive final arena with engine-wall blockers on all sides. | Highest pressure cap, extreme elite odds, and fastest boss cadence. | Astral Collapse: hazards and Astral Echo spawns converge near the player. | Astral Archon, Engine Heart |
| Singularity Garden | Win Astral Engine at 30:00 | Huge bioluminescent postgame arena with root walls, seed pods, and off-center root spires. | New highest pressure cap, extreme health/damage growth, and near-constant boss cadence. | Singularity Bloom: spiraling hazards bloom around the player and can spawn Bloom Echo enemies. | Bloom Crowned, Garden Singularity |

### Autonomous Content Wave Enemy Rosters

| Map | Regular Enemy Roster | Spawn Identity |
|---|---|---|
| Moonlit Graveyard | Grave Crawler, Moon Wisp, Tomb Guard, Bell Specter, Crypt Colossus | Starts with slow spectral crawlers, adds orbiting wisps, then ramps into slow high-health guards and late colossal blockers. |
| Neon Grid | Neon Bit, Grid Skater, Circuit Guard, Pulse Lancer, Firewall Titan | Starts fast and stays fast, mixing tiny bits, lane skaters, sprinting lancers, and large defensive titans. |
| Frozen Scar | Frost Tick, Ice Dasher, Rime Guard, Glacier Beast, Whiteout Wraith | Slower, tougher pressure with burst dashers and late whiteout orbiters layered on heavy blockers. |
| Ember Rift | Ember Imp, Lava Skimmer, Cinder Knight, Magma Brute, Ash Reaper | High-contact-damage roster with aggressive sprinters, armored knights, magma heavies, and late ash pursuit. |
| Astral Engine | Astral Mote, Engine Sentinel, Star Lancer, Gravity Bastion, Cosmic Apex | Final-map roster with high baseline speed, heavier rewards, orbiting bastions, and late apex elites. |
| Singularity Garden | Bloom Mote, Root Guardian, Spore Lancer, Garden Bastion, Singularity Apex | Postgame roster with fast orbiters, heavy root blockers, sprinting spores, and late singularity hunters. |

## Player Baseline

| Characteristic | Value |
|---|---:|
| Move speed | 115 |
| Max health | 10 |
| Fire interval | 1.0s |
| Attack damage | 10 |
| Rotation speed | 720 degrees/s |
| Invulnerability window | 0.75s |
| Starting level | 1 |

### Leveling

Required EXP is:

```text
ceil(12 + level * 5 + level^1.45 * 2.4 + max(level - 10, 0)^1.8 * 1.2)
```

Each level-up:

- Increases max health by 1.
- Heals 1, capped by max health.
- Queues one upgrade selection.
- Queues an ability selection if the level is divisible by 5.

## Tank Archetypes

| Tank | Unlock | Stats And Start | Role |
|---|---|---|---|
| Vanguard | Default | 1.0 speed, +0 health, 1.0 damage, 1.0 fire interval | Balanced baseline. |
| Scout | Default | 1.28 speed, -2 health, 0.92 damage, starts with Magnet 1 | Fast economy start. |
| Fortress | Survive 7:00 | 0.82 speed, +8 health, 1.08 damage, starts with Armor 2 | Slow durable tank. |
| Twin Cannon | Defeat 3 total bosses | 0.95 speed, 0.88 damage, starts with Cannon 1, 1.08 fire interval | Early multishot. |
| Engineer | Best enemies defeated >= 900 | 0.94 speed, +2 health, starts with Landmine 1 and Oil Slick 1 | Device specialist. |
| Collector | Reach level 12 | 1.05 speed, -1 health, 0.95 damage, starts with EXP 1 and Magnet 2 | Economy and pickup specialist. |
| Storm Chaser | Reach level 18 | 1.18 speed, -1 health, 0.96 damage, starts with Shock Field 1 and Chain Lightning 1 | Electric raider. |
| Pyroclast | Survive 15:00 | 0.94 speed, +2 health, 1.04 damage, starts with Splash 1 and Flame Wave 1 | Burn-and-blast specialist. |
| Medic | Defeat 8 total bosses | 0.98 speed, +4 health, starts with Regeneration 1, Repair Beacon 1, and Nanite Cloud 1 | Sustain support. |
| Singularity Rig | Survive 25:00 and reach level 22 | 0.86 speed, +5 health, 1.08 damage, starts with Gravity Well 1 and Capacitor Bank 1 | Crowd-control rig. |
| Glass Rail | Reach level 20 | 1.12 speed, -4 health, 1.18 damage, starts with Piercing 1, Targeting Array 1, and Ion Lance | Fragile precision cannon. |
| Bulldozer | Best enemies defeated >= 1400 | 0.78 speed, +12 health, starts with Armor 3, Barbed Wire 2, and Bulldozer Aura | Contact brawler. |
| Swarm Broker | Reach level 24 | 0.96 speed, +1 health, 0.88 damage, starts with Footsoldier 1, Drone Swarm 1, Drone Command, and Pulse Drone | Pet commander. |
| Sapper | Survive 20:00 | 0.9 speed, +3 health, starts with Landmine 2, Splash 1, Mine Dispenser, and Meteor Shell | Trap specialist. |
| Chrono Tank | Survive 25:00 and defeat 10 total bosses | 1.02 speed, -3 health, starts with Chrono Burst 1, Freeze Pulse 1, Field Amplifier, and Time Shock | Time-control caster. |
| Gold Engine | Reach level 26 | 1.0 speed, -2 health, 0.86 damage, starts with EXP 2, Magnet 1, Golden Reactor, and Supply Beacon | Greedy economy scaler. |
| Rift Skimmer | Win any map at 30:00 | 1.36 speed, -5 health, 0.9 damage, starts with Magnet 2, Gravity Well 1, and Phase Magnet | Fast risky controller. |
| Fortress Medic | Defeat 14 total bosses | 0.74 speed, +14 health, 0.9 damage, starts with Armor 2, Regeneration 2, Repair Beacon 1, Guardian Wall, and Repair Burst | Durable repair tank. |
| Meteor Twins | Reach level 28 | 0.94 speed, 0.96 damage, starts with Cannon 2, Splash 1, and Orbital Cannon | Explosive multishot. |
| Storm Foundry | Win any map and defeat 18 total bosses | 0.86 speed, +6 health, starts with Shock Field 1, Tesla Pylon 1, Capacitor Bank 1, and Storm Catalyst | Heavy electric factory. |
| Prism Sentinel | Win Crystal Expanse at 30:00 | 1.06 speed, -2 health, 1.08 damage, 1.06 fire interval, starts with Piercing 1, Targeting Array 1, Ricochet Rounds 1, Crystal Lens, Prism Rounds, and Critical Storm | Crystal crit and ricochet controller. |
| Void Anchor | Win Void Crucible and defeat 20 total bosses | 0.8 speed, +10 health, 1.12 damage, 1.14 fire interval, starts with Gravity Well 2, Armor 1, Barbed Wire 1, Gravity Anchor, Singularity Lens, Black Hole Mines, and Fortress Protocol | Heavy gravity-control bruiser. |

## Core Upgrades

Upgrade choices show 3 random options from the valid upgrade pool. Regeneration only appears while it can still improve the current regen state. Upgrade card metadata lives in `scripts/core/upgrade_catalog.gd`; `upgrade.gd` owns roll presentation, icons, rarity colors, and synergy display.

| Upgrade | Effect | Scaling | Synergy Hints |
|---|---|---|---|
| Speed | Multiplies current move speed by 1.2. | Stacks multiplicatively through `speed_level`. | Magnet, Oil Slick |
| Fire Rate | Multiplies fire interval by 0.885. Lower is faster. | Stacks multiplicatively through `fire_rate_level`. | Damage, Cannon, Footsoldier, Drone Swarm |
| Damage | Multiplies attack damage by 1.2925. | Stacks multiplicatively through `damage_level`. | Fire Rate, Splash, Piercing, Shock Field |
| Regeneration | Adds or improves passive healing. | Starts at 1 HP every 5s, then virtual interval improves by 0.333s per level down to 0.166s virtual minimum while displayed interval remains capped. | Armor, Barbed Wire |
| EXP | Adds +25% EXP value per level. | Used when picking up EXP orbs. | Magnet |
| Splash | Adds projectile explosion radius. | Radius is 10 + 5 per extra Splash level. Payload Rack and evolutions can add more. | Damage, Piercing, Artillery, Landmine |
| Piercing | Adds projectile hit capacity. | Projectile HP is Piercing + 1 before evolution bonuses. | Damage, Splash, Fire Rate |
| Barbed Wire | Damages nearby enemies every 0.5s. | Damage is attack damage * 0.33 * Barbed Wire level, modified by evolutions. | Armor, Regeneration, Shock Field |
| Armor | Reduces incoming hit damage. | +8% reduction per level, capped at 65%, plus evolution bonuses. | Barbed Wire, Regeneration, Circular Saw |
| Magnet | Pulls EXP orbs toward the player. | Pull radius is 86 + 38 per extra level. | EXP, Speed, Artillery |
| Cannon | Adds another shot to each volley. | Total shots are 1 + Cannon level, plus evolution bonuses. Spread is 12 degrees. | Damage, Fire Rate, Drone Swarm |

### Accessory Upgrades

Accessories are part of the normal 3-choice upgrade pool. They are lightweight stat or proc upgrades intended to widen build paths without adding new scenes.

| Accessory | Effect | Scaling | Synergy Hints |
|---|---|---|---|
| Targeting Array | Adds projectile critical hit chance. | +4% crit chance per level, capped at 75%. Crits deal 1.5x damage before evolution bonuses. | Damage, Fire Rate, Cannon |
| Accelerator | Increases projectile speed. | Projectile speed is 500 * (1 + 0.12 * Accelerator level). | Piercing, Splash, Payload Rack |
| Alloy Plating | Raises maximum health and repairs the tank immediately. | +2 max HP and +2 current HP per level, capped by max health. | Armor, Regeneration, Reactive Shield |
| Recycler | Defeated enemies can repair the tank. | +2.5% chance per level to heal 1 HP on normal enemy defeat, capped at 35%. Boss defeats heal 3 + Recycler level HP. | Magnet, EXP, Alloy Plating |
| Payload Rack | Adds baseline payload blast radius and splash damage. | +6px splash radius and +6% splash damage per level. Works even before Splash is picked. | Splash, Damage, Accelerator |
| Reactive Shield | Extends the post-hit invulnerability window. | +0.08s invulnerability per level. | Armor, Alloy Plating, Recycler |
| Gyro Stabilizer | Increases tank and cannon rotation speed. | Rotation speed multiplies by 1.12 per level. | Fire Rate, Cannon, Accelerator |
| Rapid Loader | Adds a second fire-rate branch. | Fire interval multiplies by 0.94 per level. | Fire Rate, Damage, Ammo Synth |
| High Caliber | Raises base damage and projectile size. | Attack damage multiplies by 1.12 per level; projectile scale gains +0.04 per level. | Damage, Targeting Array, Piercing |
| Nanobots | Improves all healing received. | Healing amount multiplies by 1 + 0.12 per level. | Regeneration, Recycler, Emergency Repairs |
| Kinetic Treads | Adds another movement branch. | Move speed multiplies by 1.1 per level. | Speed, Oil Slick, Magnet |
| Ammo Synthesizer | Adds extra shots to volleys. | +1 guaranteed shot every 2 levels; odd levels have a 50% chance to add one more shot. | Cannon, Rapid Loader, Damage |
| Shatter Rounds | Adds splash radius and splash damage. | +4px splash radius and +3% splash damage per level. | Splash, Payload Rack, Combustion Mix |
| Phase Core | Improves projectile speed and piercing. | +6% projectile speed per level; +1 pierce every 2 levels. | Piercing, Accelerator, High Caliber |
| Capacitor Bank | Amplifies weapon and power damage. | +5.5% power damage multiplier per level. | Damage, Overdrive Core, Chain Lightning |
| Salvage Magnet | Improves economy and pickup reach. | +8% EXP value and +24px EXP pull radius per level. | Magnet, EXP, Recycler |
| Emergency Repairs | Repairs while critically damaged. | At or below 42% health, heals Emergency Repairs level HP every 9s. | Armor, Nanobots, Reactive Shield |
| Combustion Mix | Improves area and contact damage. | Splash, Barbed Wire, and other area/contact damage gain +6.5% per level. | Splash, Barbed Wire, Landmine |
| Heat Sinks | Improves weapon tempo. | Fire interval multiplies by 0.965 per level. | Fire Rate, Overdrive Core, Railgun Orbiter |
| Overclocked Barrel | Improves damage and tempo together. | Attack damage multiplies by 1.07 and fire interval multiplies by 0.97 per level. | Damage, Rapid Loader, Heat Sinks |
| Rail Stabilizer | Improves precision builds and Railgun Orbiter. | +2.5% crit chance per level; Railgun Orbiter gains +1 effective level every 2 levels. | Targeting Array, Railgun Orbiter, Accelerator |
| Missile Guidance | Improves missile and splash builds. | +2px splash radius per level; Missile Pod gains effective levels from Missile Guidance plus Ordnance Bay. | Missile Pod, Payload Rack, Ordnance Bay |
| Ordnance Bay | Improves siege and splash builds. | +5px splash radius and +4.5% splash damage per level; Artillery gains +1 effective level every 2 levels; Missile Pod shares effective-level scaling with Missile Guidance. | Splash, Artillery, Missile Pod |
| Field Amplifier | Improves aura and field powers. | Shock Field, Flame Wave, Repair Beacon, and Gravity Well gain +1 effective level every 2 levels. | Shock Field, Flame Wave, Gravity Well |
| Volt Coils | Improves electric powers and power damage. | +3% power damage per level; Shock Field and Chain Lightning gain +1 effective level every 2 levels. | Chain Lightning, Shock Field, Capacitor Bank |
| Gravity Anchor | Improves control-area builds. | +4% area damage per level; Gravity Well shares effective-level scaling with Field Amplifier. | Gravity Well, Combustion Mix, Barbed Wire |
| Repair Drones | Improves sustain builds. | +8% healing received per level; Repair Beacon gains +1 effective level every 2 levels. | Repair Beacon, Nanobots, Recycler |
| Crystal Lens | Improves economy and crit builds. | +5% EXP value and +2% crit chance per level. | EXP, Salvage Magnet, Targeting Array |
| Munition Printer | Improves multishot builds. | +1 guaranteed shot every 3 levels; non-multiple levels have a 33% chance to add one extra shot. | Cannon, Ammo Synthesizer, Ordnance Bay |
| Stabilized Chassis | Improves defense and aiming control. | +2.5% armor reduction and *1.06 rotation speed per level. | Armor, Gyro Stabilizer, Reactive Shield |
| Vector Thrusters | Improves mobility and projectile delivery. | Move speed *1.07, rotation speed *1.04, and projectile speed +3.5% per level. | Speed, Accelerator, Kinetic Treads |
| Impact Fuse | Improves explosive consistency. | +3px splash radius and +3.5% splash damage per level. | Splash, Shatter Rounds, Ordnance Bay |
| Armor Piercers | Improves projectile damage and penetration. | +4.5% projectile damage per level and +1 pierce every 2 levels. | Piercing, Phase Core, Weakpoint Scanner |
| Weakpoint Scanner | Improves precision damage and rail beams. | +1.8% crit chance and +0.06 crit multiplier per level; Railgun Orbiter gains +1 effective level every 2 combined Rail Stabilizer/Weakpoint Scanner levels. | Targeting Array, Rail Stabilizer, Railgun Orbiter |
| Med Pump | Improves sustain uptime. | +7% healing received per level; Emergency Repairs interval is reduced by 0.35s per level to a 3s floor. | Nanobots, Repair Drones, Emergency Repairs |
| Orbit Gears | Improves orbit-contact builds. | +8% contact power damage per level; Guardian Satellite gains effective levels from Orbit Gears plus Drone Command. | Circular Saw, Guardian Satellite, Barbed Wire |
| Mine Dispenser | Improves mine cadence and damage. | Landmine interval is reduced by 0.18s per level; landmine damage gains +8% per level. | Landmine, Combustion Mix, Impact Fuse |
| Drone Command | Improves pet builds. | +7% pet damage per level; Drone Swarm gains +1 effective level every 2 levels and Guardian Satellite shares effective-level scaling with Orbit Gears. | Footsoldier, Drone Swarm, Guardian Satellite |
| Lucky Core | Adds replayable luck scaling. | +3% EXP value and +1% crit chance per level; each level adds 2.5% chance, capped at 25%, for one extra projectile per volley. | Crystal Lens, Targeting Array, Munition Printer |

## Abilities

Ability menus roll 3 weighted options from unlocked abilities. Weight increases for unowned abilities, for existing stacks, for late-game rare abilities, and for matching upgrade/ability synergies.

| Ability | Rarity | Tags | Unlock | Mechanics |
|---|---|---|---|---|
| Landmine | Common | device, area | Default | Places mines near the player. Base placement interval 5s, -0.5s per level, minimum 1s. Mine explosion radius 70, detonation delay 0.5s, damage = player damage * mine multiplier. Multiplier starts at 2.0 and grows by 1.35x per level after the first. |
| Circular Saw | Common | orbit, contact | Default | Adds orbiting saws. Each saw orbits at radius 100 and damages overlapping enemies every 0.35s for ceil(player damage / 3). |
| Footsoldier | Uncommon | pet, projectile | Default | Adds a follower that trails the player, seeks enemies within 400px, winds up, then fires 3 shots with 0.06s burst spacing. Soldier shot damage is floor(player damage * 0.3125). |
| Shock Field | Uncommon | aura, crowd-control | Default | Adds an electric aura. Radius is 78 + 14 per extra level. Every 0.45s it damages enemies for player damage * 0.22 * level and slows them for 0.8s at 58% speed. |
| Oil Slick | Common | device, crowd-control | Survive 7:00 | Drops slicks behind the player. Drop interval is 3.8s, -0.28s per level, minimum 1.35s. Each slick lasts 7s, radius 56 + 7 per extra level, damages every 0.55s for player damage * 0.16 * level, and slows enemies for 0.75s at 42% speed. Max active slicks: 4 + level * 2. |
| Drone Swarm | Uncommon | pet, projectile | Reach level 12 | Adds orbiting drones. Fire interval starts at 0.65s, -0.035s per level, minimum 0.22s. Drone count is min(2 + level, 10). Each shot deals player damage * 0.38 * 1.08^(level - 1). |
| Artillery | Rare | area, burst | Defeat 3 total bosses | Targets dense enemy clusters within 520px. Base interval 4s, -0.28s per level, minimum 1.4s. Telegraphs for 0.55s, then creates a splash radius 82 + 9 per extra level. Damage is player damage * 2.1 * 1.18^(level - 1). Gains late weight at player level 12. |
| Freeze Pulse | Rare | burst, crowd-control | Reach level 10 | Periodically bursts around the player. Base interval 6s, -0.42s per level, minimum 2s. Radius is 120 + 15 per extra level. Damage is player damage * 0.58 * 1.12^(level - 1). Slows for 1.25s + 0.08s per level at 16% speed. Gains late weight at player level 10. |
| Overdrive Core | Rare | buff, mobility | Reach level 12 | Adds a permanent power core. Damage multiplier starts at +8% and adds +3.5% per extra level. Move speed multiplier starts at +4% and adds +1.5% per extra level. |
| Flame Wave | Uncommon | area, burn | Survive 240s | Periodically emits a radial heat wave. Base interval 5.2s, -0.32s per level, minimum 1.8s. Radius is 112 + 14 per extra level. Damage is player damage * 0.72 * 1.13^(level - 1), scaled by area and power damage bonuses, and briefly slows enemies. |
| Repair Beacon | Uncommon | sustain, support | Survive 300s | Periodically pulses from the player. Base interval 6.5s, -0.28s per level, minimum 2.8s. Each pulse heals 1 HP, +1 per 3 levels, then lightly damages and slows enemies in 88 + 8 per extra level radius. |
| Missile Pod | Uncommon | area, projectile | Survive 480s | Fires splash missiles at nearby enemies. Base interval 4.4s, -0.24s per level, minimum 1.4s. Missile count is min(2 + level / 2, 8). Each missile creates a splash radius 42 + 3 per extra level and scales with area and power damage bonuses. |
| Chain Lightning | Rare | chain, crowd-control | Survive 600s | Every 4.8s, reduced by 0.25s per level to 1.8s minimum, strikes nearby enemies in a chain. Starts with 3 jumps, gains more jumps every 2 levels, deals player damage * 0.48 * 1.1^(level - 1), and briefly slows targets. |
| Gravity Well | Rare | crowd-control, area | Reach level 14 | Opens a pull field on dense enemy clusters within 540px. Base interval 6.2s, -0.3s per level, minimum 2.4s. The well lasts 1.8s plus small level scaling, pulls and slows enemies in 96 + 10 per extra level radius, and damages every 0.36s. |
| Guardian Satellite | Uncommon | orbit, defense | Survive 900s | Adds orbiting satellites that damage enemies on contact every 0.28s. Satellite count is min(1 + level, 8), orbit radius grows by 8px per level, and damage is player damage * 0.24 * 1.08^(level - 1). |
| Railgun Orbiter | Rare | pierce, projectile | Defeat 2 total bosses | Periodically fires a piercing beam through the nearest enemy. Base interval 3.8s, -0.2s per level, minimum 1.2s. Beam length is 720px, pierces 4 + level enemies, and damage is player damage * 1.05 * 1.12^(level - 1), scaled by power damage bonuses. |
| Tesla Pylon | Rare | electric, area | Survive 720s | Deploys a temporary pylon at dense enemy clusters within 560px. Base interval 5.8s, -0.28s per level, minimum 2.1s. The pylon lasts 2.4s plus small level scaling, zaps every 0.34s in 92 + 8 per extra level radius, damages for player damage * 0.36 * 1.09^(level - 1), and briefly slows enemies. |
| Nanite Cloud | Uncommon | sustain, aura | Reach level 16 | Maintains a player-centered cloud. Radius is 72 + 7 per extra level. Every 0.55s it damages and lightly slows nearby enemies; every 5.4s, reduced by 0.22s per level to 2s minimum, it heals the player for 1 HP plus 1 per 4 levels. |
| Ricochet Rounds | Rare | chain, projectile | Survive 1080s | Periodically fires bouncing damage through nearby enemies. Base interval 3.9s, -0.2s per level, minimum 1.25s. Range is 430 + 16 per extra level, starts at 4 bounces, gains more every 2 levels, and uses projectile damage multipliers. |
| Chrono Burst | Rare | crowd-control, burst | Survive 1320s | Periodically emits a heavy time-slow burst. Base interval 7s, -0.34s per level, minimum 2.4s. Radius is 132 + 13 per extra level. Damages for player damage * 0.42 * 1.1^(level - 1) and slows enemies for 1.45s + 0.08s per level at 24% speed. |

## Evolved Synergies

Evolutions are checked after upgrade and ability picks. Active evolutions appear in the upgrade inventory and defeat build summary. Evolution definitions live in `scripts/player/evolution_catalog.gd`; `player.gd` owns requirement checks, active effect reads, and runtime feedback.

| Evolution | Requirements | Effects |
|---|---|---|
| Shrapnel Core | Damage 4, Splash 3, Piercing 2 | Projectile damage *1.2, splash radius +18, piercing +2, projectile scale 1.22. |
| Storm Armor | Shock Field 3, Barbed Wire 3, Armor 3 | Shock Field effective level +2, Barbed Wire radius +30, Barbed Wire damage *1.35, armor reduction +8 percentage points. |
| Drone Foundry | Drone Swarm 2, Cannon 3, Fire Rate 4 | Drone Swarm effective level +2, cannon projectile bonus +1, projectile damage *1.1, projectile scale up to 1.12. |
| Critical Payload | Targeting Array 3, Payload Rack 3, Damage 4 | Crit chance +12 percentage points, crit multiplier +0.35, splash damage *1.2, projectile scale up to 1.1. |
| Repair Loop | Recycler 3, Alloy Plating 3, Reactive Shield 2 | Recycler heal chance +8 percentage points and armor reduction +5 percentage points. |
| Storm Grid | Chain Lightning 3, Shock Field 3, Freeze Pulse 2 | Chain Lightning effective level +2 and Shock Field effective level +1. |
| Guardian Protocol | Guardian Satellite 3, Overdrive Core 3, Armor 3 | Guardian Satellite effective level +2, Overdrive damage bonus +12 percentage points, and armor reduction +4 percentage points. |
| Siege Command | Missile Pod 3, Railgun Orbiter 3, Targeting Array 3 | Missile Pod and Railgun Orbiter effective levels +2, projectile damage *1.12. |
| Singularity Engine | Gravity Well 3, Flame Wave 3, Combustion Mix 2 | Gravity Well and Flame Wave effective levels +2, splash damage *1.12. |
| Field Medic | Repair Beacon 3, Nanobots 3, Armor 2 | Repair Beacon effective level +2, armor reduction +3 percentage points, and power damage +4 percentage points. |
| Coil Reactor | Volt Coils 3, Capacitor Bank 3, Chain Lightning 3 | Chain Lightning effective level +2, Shock Field effective level +1, and power damage +8 percentage points. |
| War Factory | Ordnance Bay 3, Missile Guidance 3, Munition Printer 3 | Missile Pod effective level +2, cannon projectile bonus +1, and splash damage *1.14. |
| Recovery Swarm | Repair Drones 3, Repair Beacon 3, Nanobots 3 | Repair Beacon effective level +2, healing received +18 percentage points, and armor reduction +3 percentage points. |
| Death Orbit | Orbit Gears 3, Circular Saw 3, Guardian Satellite 3 | Guardian Satellite effective level +2, Barbed Wire radius +18, and contact power damage +18 percentage points. |
| Breach Rounds | Armor Piercers 3, Weakpoint Scanner 3, Railgun Orbiter 2 | Railgun Orbiter effective level +2, projectile damage *1.16, and crit multiplier +0.25. |
| Time Cage | Chrono Burst 3, Gravity Well 3, Field Amplifier 3 | Chrono Burst effective level +2, Gravity Well effective level +1, and splash damage *1.1. |
| Storm Battery | Tesla Pylon 3, Volt Coils 3, Chain Lightning 3 | Tesla Pylon effective level +2, Chain Lightning effective level +1, and power damage +8 percentage points. |

Projectile damage multipliers from active evolutions multiply together. Projectile scale uses the largest active scale bonus.

## Enemies

Enemy variants unlock over time and use weighted spawn chances. Weight is:

```text
clamp(base_weight + minutes_since_unlock * growth_per_minute, min_weight, max_weight)
```

| Enemy | Unlock | Movement | Health | Speed | Damage | EXP Drops | Weight Profile |
|---|---:|---|---:|---:|---:|---|---|
| Scout | 0s | chase | 12 | 58 | 1 | 1 tier 1+ | 100 base, -7/min, min 4, max 100 |
| Bruiser | 120s | chase | 22 | 46 | 2 | 2 tier 1+ | 20 base, +1.8/min, max 34 |
| Runner | 180s | sprinter | 10 | 94 | 1 | 1 tier 1+ | 20 base, +1.8/min, max 36 |
| Shield | 240s | chase | 48 | 27 | 3 | 3 tier 2+ | 12 base, +1.6/min, max 30 |
| Zigzag | 300s | zigzag | 20 | 68 | 2 | 2 tier 1+ | 18 base, +1.7/min, max 34 |
| Swarm | 360s | weaver | 8 | 76 | 1 | 1 tier 1+ | 26 base, +2.2/min, max 48 |
| Stalker | 480s | stalker | 34 | 54 | 3 | 3 tier 2+ | 18 base, +1.8/min, max 36 |
| Orbiter | 600s | orbiter | 42 | 62 | 3 | 3 tier 2+ | 18 base, +2/min, max 38 |
| Tank | 720s | chase | 86 | 21 | 5 | 5 tier 3+ | 10 base, +1.2/min, max 22 |
| Drifter | 840s | drifter | 54 | 70 | 4 | 4 tier 3+ | 18 base, +2.4/min, max 42 |
| Lancer | 960s | sprinter | 46 | 104 | 5 | 4 tier 3+ | 16 base, +1.8/min, max 36 |
| Phalanx | 1080s | chase | 128 | 26 | 6 | 6 tier 3+ | 12 base, +1.4/min, max 28 |
| Mirage | 1200s | weaver | 32 | 90 | 4 | 3 tier 3+ | 20 base, +2.1/min, max 42 |
| Reaper | 1440s | stalker | 92 | 64 | 7 | 7 tier 4+ | 14 base, +1.7/min, max 34 |
| Comet | 1680s | drifter | 72 | 112 | 6 | 5 tier 4+ | 18 base, +2/min, max 40 |
| Viper | 1860s | zigzag | 68 | 118 | 7 | 5 tier 4+ | 16 base, +2/min, max 38 |
| Bulldozer | 1980s | chase | 180 | 24 | 9 | 8 tier 4+ | 10 base, +1.2/min, max 26 |
| Specter | 2100s | orbiter | 58 | 98 | 6 | 5 tier 4+ | 18 base, +2.2/min, max 42 |
| Sapper | 2220s | stalker | 76 | 74 | 8 | 6 tier 4+ | 14 base, +1.8/min, max 34 |
| Voidling | 2340s | weaver | 88 | 84 | 8 | 7 tier 4+ | 20 base, +2.4/min, max 44 |

### Map-Specific Enemies

These enemies only enter the spawn table on their listed map. The selected map's own enemies are weighted normally, while global enemies are down-weighted on maps 2-11 so each arena keeps its identity.

| Enemy | Map | Unlock | Movement | Health | Speed | Damage | EXP Drops | Weight Profile |
|---|---|---:|---|---:|---:|---:|---|---|
| Scrap Scout | Scrap Maze | 0s | zigzag | 16 | 74 | 1 | 1 tier 1+ | 88 base, -3.5/min, min 18 |
| Gear Runner | Scrap Maze | 90s | sprinter | 14 | 116 | 2 | 1 tier 1+ | 36 base, +2.4/min, max 58 |
| Slag Brute | Scrap Maze | 210s | chase | 42 | 48 | 4 | 3 tier 2+ | 24 base, +2/min, max 46 |
| Magnet Wraith | Scrap Maze | 360s | orbiter | 32 | 88 | 3 | 2 tier 2+ | 28 base, +2.8/min, max 54 |
| Crusher Drone | Scrap Maze | 540s | drifter | 76 | 36 | 5 | 4 tier 3+ | 18 base, +1.7/min, max 36 |
| Furnace Reaper | Scrap Maze | 840s | stalker | 108 | 72 | 8 | 7 tier 4+ | 16 base, +2.1/min, max 38 |
| Shardling | Crystal Expanse | 0s | zigzag | 24 | 92 | 2 | 1 tier 1+ | 92 base, -3/min, min 20 |
| Prism Runner | Crystal Expanse | 120s | sprinter | 20 | 132 | 3 | 2 tier 1+ | 34 base, +2.6/min, max 60 |
| Quartz Bulwark | Crystal Expanse | 300s | chase | 92 | 32 | 6 | 5 tier 3+ | 22 base, +1.8/min, max 42 |
| Lens Wraith | Crystal Expanse | 540s | orbiter | 54 | 98 | 5 | 4 tier 3+ | 28 base, +2.5/min, max 56 |
| Crystal Juggernaut | Crystal Expanse | 900s | drifter | 180 | 30 | 10 | 8 tier 4+ | 16 base, +1.6/min, max 34 |
| Spore Tick | Toxic Foundry | 0s | weaver | 34 | 82 | 3 | 2 tier 1+ | 96 base, -2.2/min, min 22 |
| Acid Sprinter | Toxic Foundry | 150s | sprinter | 32 | 126 | 4 | 2 tier 2+ | 36 base, +2.3/min, max 62 |
| Caustic Bloater | Toxic Foundry | 360s | chase | 140 | 38 | 8 | 6 tier 3+ | 28 base, +2.1/min, max 50 |
| Fume Stalker | Toxic Foundry | 600s | stalker | 72 | 88 | 7 | 5 tier 3+ | 30 base, +2.8/min, max 58 |
| Slag Titan | Toxic Foundry | 960s | chase | 260 | 26 | 13 | 10 tier 4+ | 18 base, +1.8/min, max 38 |
| Null Mite | Void Crucible | 0s | weaver | 44 | 118 | 4 | 2 tier 2+ | 110 base, -1.8/min, min 32 |
| Rift Lancer | Void Crucible | 100s | sprinter | 48 | 152 | 6 | 3 tier 2+ | 40 base, +3/min, max 72 |
| Gravity Knight | Void Crucible | 300s | orbiter | 150 | 46 | 10 | 7 tier 3+ | 28 base, +2.3/min, max 54 |
| Event Horizon | Void Crucible | 620s | stalker | 120 | 78 | 9 | 6 tier 4+ | 26 base, +2.7/min, max 58 |
| Cosmic Devourer | Void Crucible | 980s | drifter | 320 | 34 | 16 | 12 tier 4+ | 20 base, +2.2/min, max 46 |
| Grave Crawler | Moonlit Graveyard | 0s | weaver | 62 | 92 | 5 | 2 tier 2+ | 98 base, -2.4/min, min 28 |
| Moon Wisp | Moonlit Graveyard | 120s | orbiter | 48 | 136 | 5 | 2 tier 2+ | 38 base, +2.8/min, max 70 |
| Tomb Guard | Moonlit Graveyard | 300s | chase | 170 | 38 | 11 | 7 tier 3+ | 30 base, +2/min, max 54 |
| Bell Specter | Moonlit Graveyard | 620s | stalker | 96 | 106 | 9 | 5 tier 4+ | 30 base, +2.6/min, max 64 |
| Crypt Colossus | Moonlit Graveyard | 980s | drifter | 360 | 28 | 17 | 12 tier 4+ | 18 base, +2/min, max 44 |
| Neon Bit | Neon Grid | 0s | zigzag | 46 | 132 | 5 | 2 tier 2+ | 112 base, -2/min, min 36 |
| Grid Skater | Neon Grid | 90s | sprinter | 54 | 172 | 7 | 3 tier 2+ | 44 base, +3.4/min, max 82 |
| Circuit Guard | Neon Grid | 260s | chase | 150 | 52 | 11 | 6 tier 3+ | 30 base, +2.2/min, max 58 |
| Pulse Lancer | Neon Grid | 560s | sprinter | 86 | 150 | 10 | 5 tier 4+ | 32 base, +3/min, max 72 |
| Firewall Titan | Neon Grid | 940s | drifter | 320 | 40 | 18 | 12 tier 4+ | 20 base, +2.4/min, max 50 |
| Frost Tick | Frozen Scar | 0s | weaver | 70 | 82 | 6 | 3 tier 2+ | 104 base, -1.8/min, min 34 |
| Ice Dasher | Frozen Scar | 120s | drifter | 58 | 142 | 7 | 3 tier 2+ | 40 base, +2.8/min, max 76 |
| Rime Guard | Frozen Scar | 320s | chase | 220 | 30 | 13 | 8 tier 3+ | 34 base, +2.1/min, max 64 |
| Glacier Beast | Frozen Scar | 640s | stalker | 260 | 48 | 15 | 9 tier 4+ | 28 base, +2.2/min, max 58 |
| Whiteout Wraith | Frozen Scar | 1020s | orbiter | 130 | 124 | 12 | 7 tier 4+ | 24 base, +2.8/min, max 58 |
| Ember Imp | Ember Rift | 0s | weaver | 64 | 128 | 7 | 3 tier 2+ | 116 base, -1.4/min, min 40 |
| Lava Skimmer | Ember Rift | 90s | sprinter | 72 | 164 | 9 | 4 tier 3+ | 46 base, +3.3/min, max 86 |
| Cinder Knight | Ember Rift | 280s | chase | 210 | 46 | 15 | 8 tier 3+ | 34 base, +2.5/min, max 68 |
| Magma Brute | Ember Rift | 620s | stalker | 300 | 54 | 18 | 10 tier 4+ | 30 base, +2.5/min, max 62 |
| Ash Reaper | Ember Rift | 1000s | drifter | 150 | 132 | 14 | 8 tier 4+ | 24 base, +3/min, max 64 |
| Astral Mote | Astral Engine | 0s | weaver | 90 | 146 | 8 | 4 tier 3+ | 128 base, -1/min, min 48 |
| Engine Sentinel | Astral Engine | 160s | chase | 260 | 44 | 16 | 9 tier 4+ | 42 base, +2.8/min, max 78 |
| Star Lancer | Astral Engine | 360s | sprinter | 108 | 178 | 13 | 6 tier 4+ | 42 base, +3.5/min, max 88 |
| Gravity Bastion | Astral Engine | 720s | orbiter | 420 | 32 | 22 | 13 tier 4+ | 32 base, +2.8/min, max 70 |
| Cosmic Apex | Astral Engine | 1080s | stalker | 360 | 92 | 20 | 12 tier 4+ | 26 base, +3.2/min, max 72 |
| Bloom Mote | Singularity Garden | 0s | orbiter | 112 | 156 | 9 | 4 tier 3+ | 136 base, -0.8/min, min 54 |
| Root Guardian | Singularity Garden | 180s | chase | 340 | 38 | 18 | 10 tier 4+ | 44 base, +3/min, max 86 |
| Spore Lancer | Singularity Garden | 400s | sprinter | 128 | 188 | 15 | 7 tier 4+ | 44 base, +3.8/min, max 96 |
| Garden Bastion | Singularity Garden | 760s | drifter | 520 | 30 | 25 | 15 tier 4+ | 34 base, +3/min, max 78 |
| Singularity Apex | Singularity Garden | 1120s | stalker | 440 | 104 | 24 | 14 tier 4+ | 28 base, +3.6/min, max 82 |

### Enemy Movement Styles

| Style | Behavior |
|---|---|
| chase | Directly moves toward the player. |
| sprinter | Pulses speed with a sine wave for bursty pursuit. |
| zigzag | Rotates pursuit direction strongly from side to side. |
| weaver | Uses quicker, smaller lateral weaving. |
| stalker | Moves slower at range, then lunges faster inside 120px. |
| orbiter | Blends pursuit with an orbital angle around the player. |
| drifter | Uses a wide slow drift angle around pursuit direction. |

## Elite Affixes

Elites begin appearing after 90s and ramp to an 18% spawn chance by 900s. Split elites are prevented when active pressure is too high. Affixes are owned by `scripts/core/enemy_affix_catalog.gd` and use shared stat, reward, color, volatile-death, and split-death hooks.

| Affix | Unlock | Weight | Effects |
|---|---:|---:|---|
| Hasty | 90s | 28 | Speed *1.45, health *0.85. |
| Armored | 150s | 24 | Speed *0.82, health *1.85, scale *1.12. |
| Glass | 180s | 18 | Speed *1.28, health *0.55, damage *1.65, EXP drop count *1.25. |
| Rich | 210s | 18 | Health *1.2, EXP drop count *2.4, minimum EXP tier +1. |
| Bulwark | 270s | 14 | Speed *0.58, health *2.8, damage *1.2, scale *1.24, EXP drop count *1.35. |
| Volatile | 300s | 16 | Speed *1.18, health *0.9. On death, damages nearby enemies in a 92px radius for 34 damage. |
| Overcharged | 360s | 14 | Speed *1.22, health *1.1, damage *1.25. On death, damages nearby enemies in a 72px radius for 22 damage. |
| Splitting | 420s | 14 | Health *1.35. On death, splits into 2 small weaver children with 8 health, 82 speed, and 1 damage. |
| Brood | 540s | 10 | Health *1.1. On death, splits into 3 small weaver children with 6 health, 96 speed, and 1 damage. |
| Champion | 720s | 8 | Speed *1.08, health *2.2, damage *1.45, scale *1.18, EXP drop count *2.0, minimum EXP tier +1. |

## Bosses

Only one boss can be alive at a time. Bosses normally spawn every 180s, modified by run modifiers and map pressure. Boss spawns reserve 16 enemy-pressure slots.

| Boss | Unlock | Behavior | Health | Speed | Damage | EXP Drops | Weight Profile | Special Mechanics |
|---|---:|---|---:|---:|---:|---|---|---|
| Charger | 0s | charger | 950 | 25 | 5 | 30 tier 1+ | 100 base, -8/min, min 20 | Baseline pursuing boss. |
| Bulwark | 420s | bulwark | 1550 | 17 | 8 | 38 tier 2+ | 55 base, +1/min, max 70 | Rotates visually, phase at 55%, summons minions every 8s after 3.5s. Minion count 3 + 2 per phase, capped at 7. |
| Sprinter | 840s | sprinter | 1100 | 34 | 6 | 42 tier 2+ | 55 base, +1.5/min, max 75 | Pulses speed up to +75%. |
| Crusher | 1260s | crusher | 2200 | 15 | 11 | 52 tier 3+ | 62 base, +1.2/min, max 82 | Phases at 65% and 32%, creates hazard rings every 7.2s after 2.8s. |
| Wraith | 1680s | wraith | 1750 | 30 | 9 | 60 tier 4+ | 70 base, +1.5/min, max 90 | Phases at 50%, fades visually, targets player hazards every 5.6s and calls minions every 11s. |
| Monarch | 1800s | monarch | 2400 | 22 | 10 | 68 tier 4+ | 64 base, +1.4/min, max 86 | Phases at 66% and 33%, alternates larger minion calls with player-targeted hazards. |
| Tempest | 2100s | tempest | 2050 | 38 | 8 | 74 tier 4+ | 68 base, +1.5/min, max 88 | Phases at 72%, 44%, and 20%, rotates rapidly, pulses speed, and layers hazard rings with targeted strikes. |
| Bastion | 2400s | bastion | 3200 | 13 | 14 | 84 tier 4+ | 72 base, +1.2/min, max 92 | Phases at 75%, 50%, and 25%, uses large hazard rings and bounded support waves. |
| Overlord | 2700s | overlord | 3600 | 20 | 15 | 92 tier 4+ | 76 base, +1.2/min, max 94 | Phases at 78%, 55%, 32%, and 16%, combining minion calls, hazard rings, and targeted hazards. |
| Singularity | 3000s | singularity | 2950 | 32 | 13 | 100 tier 4+ | 80 base, +1.1/min, max 96 | Phases at 70%, 45%, and 22%, fades and pulses while layering rapid targeted hazards with dense rings. |

### Map-Specific Bosses

| Boss | Map | Unlock | Behavior | Health | Speed | Damage | EXP Drops | Weight Profile | Special Mechanics |
|---|---|---:|---|---:|---:|---:|---|---|---|
| Scrapyard Warden | Scrap Maze | 0s | crusher | 1850 | 24 | 9 | 48 tier 3+ | 120 base, -2/min, min 64 | Phases at 68% and 36%; hazard rings plus minion calls. |
| Magnetar Colossus | Scrap Maze | 420s | singularity | 2700 | 28 | 12 | 72 tier 4+ | 82 base, +1.8/min, max 108 | Three phases; targeted hazards plus dense rings. |
| Foundry Overlord | Scrap Maze | 900s | overlord | 3800 | 19 | 16 | 96 tier 4+ | 72 base, +2/min, max 112 | Four phases; minion waves, large rings, and targeted hazards. |
| Prism Regent | Crystal Expanse | 0s | tempest | 2450 | 34 | 11 | 62 tier 3+ | 112 base, -1.2/min, min 58 | Fast boss with targeted crystal strikes and hazard rings. |
| Crystal Hydra | Crystal Expanse | 540s | monarch | 3500 | 25 | 14 | 86 tier 4+ | 84 base, +1.9/min, max 112 | Four phases; minion calls and repeated player-targeted hazards. |
| Toxlord | Toxic Foundry | 0s | bastion | 4200 | 21 | 16 | 78 tier 4+ | 118 base, -0.8/min, min 68 | Large corrosive hazard rings and minion pressure. |
| Furnace Queen | Toxic Foundry | 600s | overlord | 5200 | 18 | 20 | 104 tier 4+ | 88 base, +2/min, max 118 | Four phases; heavy hazard rings, targeted strikes, and minion calls. |
| Rift Seraph | Void Crucible | 0s | wraith | 5600 | 36 | 18 | 90 tier 4+ | 120 base, -0.4/min, min 72 | Fast fading boss with rapid targeted hazards and minion waves. |
| Void Emperor | Void Crucible | 480s | singularity | 7200 | 28 | 24 | 128 tier 4+ | 96 base, +2.4/min, max 128 | Five phases; dense rings, targeted hazards, and large minion waves. |
| Grave Bell | Moonlit Graveyard | 0s | wraith | 6200 | 24 | 18 | 92 tier 4+ | 118 base, -0.6/min, min 70 | Three phases; targeted ghost hazards and escalating minion calls. |
| Crypt Marshal | Moonlit Graveyard | 480s | bastion | 8200 | 18 | 22 | 122 tier 4+ | 92 base, +2.2/min, max 128 | Four phases; wide rings and large support waves. |
| Neon Executioner | Neon Grid | 0s | tempest | 6500 | 42 | 19 | 98 tier 4+ | 120 base, -0.8/min, min 72 | Fast target strikes with ring pressure. |
| Grid Overseer | Neon Grid | 540s | overlord | 9000 | 28 | 23 | 130 tier 4+ | 90 base, +2.5/min, max 132 | Four phases; grid-like rings and targeted hazards. |
| Frost Leviathan | Frozen Scar | 0s | crusher | 9800 | 18 | 24 | 112 tier 4+ | 118 base, -0.4/min, min 74 | Slow, huge boss with heavy hazard rings. |
| Blizzard Matriarch | Frozen Scar | 600s | monarch | 8600 | 34 | 21 | 136 tier 4+ | 86 base, +2.4/min, max 130 | Three phases; minion calls plus player-targeted ice hazards. |
| Magma Tyrant | Ember Rift | 0s | overlord | 10400 | 30 | 28 | 126 tier 4+ | 122 base, -0.5/min, min 76 | Four phases; eruption-style targeted hazards and rings. |
| Cinder Prophet | Ember Rift | 520s | sprinter | 7800 | 46 | 22 | 142 tier 4+ | 92 base, +2.7/min, max 136 | Fast boss with frequent targeted hazards and minions. |
| Astral Archon | Astral Engine | 0s | singularity | 11200 | 38 | 30 | 150 tier 4+ | 124 base, -0.2/min, min 82 | Five phases; dense rings, targeted hazards, and minion calls. |
| Engine Heart | Astral Engine | 660s | bastion | 14800 | 20 | 34 | 180 tier 4+ | 96 base, +2.8/min, max 144 | Six phases; massive rings and large support waves. |
| Bloom Crowned | Singularity Garden | 0s | tempest | 13200 | 44 | 32 | 164 tier 4+ | 130 base, -0.1/min, min 88 | Four phases; fast target hazards, bloom rings, and support waves. |
| Garden Singularity | Singularity Garden | 620s | singularity | 17600 | 24 | 38 | 196 tier 4+ | 98 base, +3/min, max 152 | Six phases; heavy rings, target hazards, and large bloom calls. |

Boss phases increase base speed by 8%, add +1 contact damage, and trigger a burst effect.

## Mid-Run Events

Runs schedule up to 4 seeded events. Active or upcoming events appear in the HUD. Triggered events appear in the defeat summary.

| Event | Duration | Weight | Risk | Reward |
|---|---:|---:|---|---|
| Crystal Bloom | 48s | 28 | Enemy damage *1.12 while active. | EXP value *1.35 while active. |
| Supply Cache | Instant | 24 | None. | Spawns 2 green supply boxes and 1 blue supply box offscreen. |
| Elite Bounty | Instant | 22 | Spawns a bounded 5-enemy guaranteed elite wave respecting pressure caps. | Queues 1 bonus upgrade choice. |
| Overrun Gambit | 36s | 20 | Spawn interval *0.72 and enemy speed *1.1 while active. | Queues 1 bonus ability choice. |
| Repair Convoy | Instant | 18 | Spawns a bounded 3-enemy guaranteed elite wave. | Spawns 3 green supply boxes. |
| Blue Moon | Instant | 16 | None. | Spawns 1 blue supply box and queues 1 bonus ability choice. |
| Overclock Bloom | 42s | 17 | Spawn interval *0.82 and enemy speed *1.08 while active. | EXP value *1.18 while active and queues 1 bonus upgrade choice. |
| Siege Cache | Instant | 15 | Spawns a bounded 7-enemy guaranteed elite wave. | Spawns 1 green supply box and queues 1 bonus upgrade choice. |
| Salvage Comet | 40s | 16 | Enemy damage *1.08 while active. | EXP value *1.22 while active and spawns 1 blue supply box. |
| Blackout Rush | 32s | 14 | Spawn interval *0.64 and enemy speed *1.18 while active. | Spawns 1 green supply box and queues 1 bonus ability choice. |
| Magnet Storm | 34s | 15 | Enemy speed *1.16 while active and spawns a bounded 4-enemy guaranteed elite wave. | Spawns 2 green supply boxes. |
| Power Market | 38s | 13 | Enemy damage *1.1 and spawn interval *0.86 while active. | Spawns 1 blue supply box and queues 1 bonus ability choice. |
| Repair Jubilee | 44s | 14 | Enemy damage *1.06 while active. | Spawns 4 green supply boxes. |
| Critical Front | 46s | 12 | Spawn interval *0.78 while active and spawns a bounded 3-enemy guaranteed elite wave. | EXP value *1.16 while active and queues 1 bonus upgrade choice. |
| Boss Omen | Instant | 11 | Spawns a bounded 6-enemy guaranteed elite wave. | Spawns 1 green supply box and 1 blue supply box. |

## Run Modifiers

| Modifier | Unlock | Effects |
|---|---|---|
| Swarm Opening | Default | Spawn interval *0.72, enemy health growth *0.92. |
| Rich Crystals | Default | EXP value *1.28, enemy damage growth *1.2. |
| Supply Rain | Survive 7:00 | Supply interval *0.72, supply chance *2.4. |
| Boss Contract | Defeat 3 total bosses | Boss spawn interval *0.55, boss EXP *1.45. |
| Unstable Engine | Reach level 10 | Player fire interval *0.88, enemy speed growth *1.25. |
| Salvage Field | Best enemies defeated >= 900 | Wrench drops *1.75, dynamite drops *2.0, supply chance *0.65. |
| Overclock Cache | Complete Boss Breaker challenge | Player fire interval *0.9, supply chance *0.8. |
| Grave Moon | Win Void Crucible at 30:00 | EXP value *1.18, boss spawn interval *0.86, enemy health growth *1.16. |
| Neon Overdrive | Win Moonlit Graveyard at 30:00 | Player fire interval *0.84, spawn interval *0.82, enemy speed growth *1.28. |
| Frost Cache | Win Neon Grid at 30:00 | Enemy speed growth *0.92, enemy health growth *1.26, supply chance *1.55. |
| Ember Bounty | Win Frozen Scar at 30:00 | Boss EXP *1.58, dynamite drops *1.65, enemy damage growth *1.26. |
| Astral Lottery | Win Ember Rift at 30:00 | EXP value *1.36, boss EXP *1.32, supply chance *0.72, all enemy growth is sharper. |
| Singularity Seed | Win Singularity Garden at 30:00 | Spawn interval *0.76, boss spawn interval *0.78, EXP value *1.22, boss EXP *1.42, wrench drops *1.25, supply chance *0.62, enemy health growth *1.24, enemy damage growth *1.18. |

## Unlocks And Meta Progression

Progress is saved in `user://unlock_state.cfg`.

### Default Unlocks

- Tanks: Vanguard, Scout
- Abilities: Landmine, Circular Saw, Footsoldier, Shock Field
- Modifiers: Swarm Opening, Rich Crystals

### Stat-Based Unlocks

| Requirement | Unlocks |
|---|---|
| Best survival time >= 420s | Fortress tank, Oil Slick ability, Supply Rain modifier |
| Best level >= 12 | Collector tank, Drone Swarm ability, Overdrive Core ability |
| Total bosses defeated >= 3 | Twin Cannon tank, Artillery ability, Boss Contract modifier |
| Best enemies defeated >= 900 | Engineer tank, Salvage Field modifier |
| Best level >= 10 | Freeze Pulse ability, Unstable Engine modifier |
| Best survival time >= 240s | Flame Wave ability |
| Best survival time >= 300s | Repair Beacon ability |
| Best survival time >= 480s | Missile Pod ability |
| Best survival time >= 600s | Chain Lightning ability |
| Best survival time >= 720s | Tesla Pylon ability |
| Best level >= 14 | Gravity Well ability |
| Best survival time >= 900s | Guardian Satellite ability |
| Total bosses defeated >= 2 | Railgun Orbiter ability |
| Best level >= 16 | Nanite Cloud ability |
| Best survival time >= 1080s | Ricochet Rounds ability |
| Best survival time >= 1320s | Chrono Burst ability |
| Win Crystal Expanse at 30:00 | Prism Sentinel tank |
| Win Void Crucible and total bosses defeated >= 20 | Void Anchor tank |

### Map Unlocks

| Requirement | Unlock |
|---|---|
| Win Dust Bowl at 30:00 | Scrap Maze |
| Win Scrap Maze at 30:00 | Crystal Expanse |
| Win Crystal Expanse at 30:00 | Toxic Foundry |
| Win Toxic Foundry at 30:00 | Void Crucible |
| Win Void Crucible at 30:00 | Moonlit Graveyard |
| Win Moonlit Graveyard at 30:00 | Neon Grid |
| Win Neon Grid at 30:00 | Frozen Scar |
| Win Frozen Scar at 30:00 | Ember Rift |
| Win Ember Rift at 30:00 | Astral Engine |
| Win Astral Engine at 30:00 | Singularity Garden |
| Win Singularity Garden at 30:00 | Singularity Seed modifier |

### Challenge Goals

Completed challenge IDs persist separately and can grant meta rewards.

| Challenge | Requirement | Reward |
|---|---|---|
| Hold the Line | Survive 180s in a run | +1 starting Armor level |
| Boss Breaker | Defeat 1 boss in a run | Unlock Overclock Cache modifier |
| Elite Sweeper | Defeat 8 elites in a run | Wrench drop multiplier *1.15 |
| Heavy Build | Damage + Fire Rate + Cannon levels total at least 7 | +1 starting Damage level |
| Collector Build | Magnet + EXP levels total at least 5 | +1 starting EXP level |
| Storm Build | Volt Coils + Field Amplifier + Capacitor Bank levels total at least 4 | +1 starting Magnet level |
| Control Build | Gravity Anchor + Field Amplifier + Barbed Wire levels total at least 5 | +1 starting Health |
| Marathon Plate | Survive 30:00 in a run | +1 starting Health |
| Boss Harvester | Defeat 6 bosses in a run | Dynamite drop multiplier *1.25 |
| Elite Recycler | Defeat 20 elites in a run | Wrench drop multiplier *1.2 |
| Storm Mastery | Volt Coils + Field Amplifier + Capacitor Bank levels total at least 8 | +1 starting Damage level |
| Magnet Empire | Magnet + EXP levels total at least 9 | +1 starting Magnet and +1 starting EXP |
| Veteran Hull | Survive 15:00 in a run | +1 starting Armor level |
| Breaker Column | Defeat 3 bosses in a run | +1 starting Damage level |
| Elite Grinder | Defeat 35 elites in a run | Wrench drop multiplier *1.25 |
| Salvage Crown | Recycler + Salvage Magnet + Lucky Core levels total at least 7 | +1 starting Magnet level |
| Repair Doctrine | Nanobots + Repair Drones + Med Pump + Repair Beacon levels total at least 7 | +1 starting Health |
| Siege Engineer | Ordnance Bay + Munition Printer + Missile Guidance + Impact Fuse levels total at least 8 | Dynamite drop multiplier *1.2 |
| Precision Doctrine | Targeting Array + Weakpoint Scanner + Armor Piercers + Rail Stabilizer levels total at least 8 | +1 starting Damage level |
| Phase Collector | Phase Core + Vector Thrusters + Kinetic Treads + Gyro Stabilizer levels total at least 8 | +1 starting EXP level |

## Pickups And Rewards

| Pickup | Source | Effect |
|---|---|---|
| EXP Orb | Enemy and boss deaths | Adds EXP. Player EXP upgrade increases value by +25% per level. Run modifiers and events can multiply value before pickup. |
| Magnet Pickup | Spawns every 180s if inactive | Activates global EXP magnet for 5s. |
| Dynamite Pickup | Enemy/boss death chance, default 0.1% | Deals 9999 damage to normal enemies and 300 to bosses. |
| Wrench Pickup | Enemy/boss death chance, default 5% | Heals 1 HP if the player can heal. Max active wrench pickups: 10. |
| Green Supply Box | Timed supply spawn or events | Grants a bonus upgrade selection. |
| Blue Supply Box | Timed supply spawn or events | Grants a bonus ability selection. Normal supply boxes are blue 20% of the time. |

Supply boxes check every 15s with a base 5% spawn chance, modified by run modifiers.

## Scaling And Pressure

### Enemy Scaling

| System | Rate |
|---|---|
| Enemy speed scale | Every 10s, speed scale multiplies by 1 + 0.01 * enemy speed growth multiplier. |
| Enemy health bonus | Every 30s, health bonus step increases by 0.01 * enemy health growth multiplier, then total health bonus increases by that step. |
| Enemy damage multiplier | Every 60s, damage multiplier increases toward the configured 1.05 step, modified by enemy damage growth multiplier. |
| EXP tier upgrades | Purple orbs can appear after 300s, violet after 600s. |

### Active Enemy Pressure

Active enemy cap is:

```text
clamp(85 + floor(minutes * 8), 85, 225)
```

Additional pressure rules:

- Boss spawns reserve 16 pressure slots.
- Boss minions can spawn only below 92% of current pressure cap.
- Splitting elites can spawn children only below 96% of current pressure cap and below the split cap of 180.
- Skipped spawns are tracked and shown in the run report.

## 30-Minute Balance Evidence

The deterministic balance report lives in [30-Minute Balance Pass](BALANCE_30_MIN.md).

Current projection status: PASS.

At 30 minutes:

- Active enemy cap is 225.
- Average regular spawn HP is 853.0.
- Minimum spawn interval is 0.20s, or 5 regular spawns per second.
- A coherent high-synergy build projects about 31,764 direct weapon DPS and 37.2 regular kills per second before splash overlap, piercing, pets, fields, and crowd-control are credited.

This confirms the intended long-run shape: the director reaches maximum active pressure while focused upgrades and evolved synergies can still create a deliberately overpowered bullet-heaven build.

## Performance Budgets

| Budget | Value |
|---|---:|
| Active EXP orbs | 100 |
| Projectile pool limit | 220 |
| Particle burst pool limit | 48 |
| Active particle bursts | 36 |
| Damage numbers per frame | 18 |
| Active splash areas | 24 |
| Active boss hazards | 18 |
| EXP drops spawned per frame | 20 |

Runtime object pooling is used for projectiles and particle bursts. Visibility culling applies to enemies, pickups, landmines, projectiles, circular saws, and footsoldiers outside the camera view plus margin.

## AI And Debug Helpers

The project includes AI/debug helpers for autonomous testing:

- Auto movement.
- Enemy avoidance.
- EXP seeking.
- Wrench seeking.
- Powerup seeking.
- Supply box seeking.
- Automatic upgrade/ability picking.
- Time scale presets: 1x, 2x, 4x, 8x.

AI upgrade preference currently prioritizes:

1. Piercing if the player has none and it appears.
2. Damage, Fire Rate, or Splash when player DPS is low relative to average spawn HP.
3. Regeneration after sustained low health.
4. Otherwise a random displayed upgrade.
