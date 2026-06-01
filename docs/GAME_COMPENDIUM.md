# Autonomous Survivor Game Compendium

This document is the current open-book reference for the game. It describes the playable loop, tank starts, enemies, bosses, upgrades, abilities, evolutions, events, modifiers, unlocks, pickups, scaling, and performance limits implemented in the Godot project.

## Menu

- [Core Loop](#core-loop)
- [Run Setup](#run-setup)
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
8. The run ends when the player dies, then the defeat report records run telemetry, build highlights, events, unlocks, and challenge rewards.

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
| Fortress | Survive 120s | 0.82 speed, +8 health, 1.08 damage, starts with Armor 2 | Slow durable tank. |
| Twin Cannon | Defeat 1 total boss | 0.95 speed, 0.88 damage, starts with Cannon 1, 1.08 fire interval | Early multishot. |
| Engineer | Best enemies defeated >= 250 | 0.94 speed, +2 health, starts with Landmine 1 and Oil Slick 1 | Device specialist. |
| Collector | Reach level 5 | 1.05 speed, -1 health, 0.95 damage, starts with EXP 1 and Magnet 2 | Economy and pickup specialist. |

## Core Upgrades

Upgrade choices show 3 random options from the valid upgrade pool. Regeneration only appears while it can still improve the current regen state.

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

## Abilities

Ability menus roll 3 weighted options from unlocked abilities. Weight increases for unowned abilities, for existing stacks, for late-game rare abilities, and for matching upgrade/ability synergies.

| Ability | Rarity | Tags | Unlock | Mechanics |
|---|---|---|---|---|
| Landmine | Common | device, area | Default | Places mines near the player. Base placement interval 5s, -0.5s per level, minimum 1s. Mine explosion radius 70, detonation delay 0.5s, damage = player damage * mine multiplier. Multiplier starts at 2.0 and grows by 1.35x per level after the first. |
| Circular Saw | Common | orbit, contact | Default | Adds orbiting saws. Each saw orbits at radius 100 and damages overlapping enemies every 0.35s for ceil(player damage / 3). |
| Footsoldier | Uncommon | pet, projectile | Default | Adds a follower that trails the player, seeks enemies within 400px, winds up, then fires 3 shots with 0.06s burst spacing. Soldier shot damage is floor(player damage * 0.3125). |
| Shock Field | Uncommon | aura, crowd-control | Default | Adds an electric aura. Radius is 78 + 14 per extra level. Every 0.45s it damages enemies for player damage * 0.22 * level and slows them for 0.8s at 58% speed. |
| Oil Slick | Common | device, crowd-control | Survive 120s | Drops slicks behind the player. Drop interval is 3.8s, -0.28s per level, minimum 1.35s. Each slick lasts 7s, radius 56 + 7 per extra level, damages every 0.55s for player damage * 0.16 * level, and slows enemies for 0.75s at 42% speed. Max active slicks: 4 + level * 2. |
| Drone Swarm | Uncommon | pet, projectile | Reach level 5 | Adds orbiting drones. Fire interval starts at 0.65s, -0.035s per level, minimum 0.22s. Drone count is min(2 + level, 10). Each shot deals player damage * 0.38 * 1.08^(level - 1). |
| Artillery | Rare | area, burst | Defeat 1 total boss | Targets dense enemy clusters within 520px. Base interval 4s, -0.28s per level, minimum 1.4s. Telegraphs for 0.55s, then creates a splash radius 82 + 9 per extra level. Damage is player damage * 2.1 * 1.18^(level - 1). Gains late weight at player level 12. |
| Freeze Pulse | Rare | burst, crowd-control | Reach level 10 | Periodically bursts around the player. Base interval 6s, -0.42s per level, minimum 2s. Radius is 120 + 15 per extra level. Damage is player damage * 0.58 * 1.12^(level - 1). Slows for 1.25s + 0.08s per level at 16% speed. Gains late weight at player level 10. |

## Evolved Synergies

Evolutions are checked after upgrade and ability picks. Active evolutions appear in the upgrade inventory and defeat build summary.

| Evolution | Requirements | Effects |
|---|---|---|
| Shrapnel Core | Damage 4, Splash 3, Piercing 2 | Projectile damage *1.2, splash radius +18, piercing +2, projectile scale 1.22. |
| Storm Armor | Shock Field 3, Barbed Wire 3, Armor 3 | Shock Field effective level +2, Barbed Wire radius +30, Barbed Wire damage *1.35, armor reduction +8 percentage points. |
| Drone Foundry | Drone Swarm 2, Cannon 3, Fire Rate 4 | Drone Swarm effective level +2, cannon projectile bonus +1, projectile damage *1.1, projectile scale up to 1.12. |
| Critical Payload | Targeting Array 3, Payload Rack 3, Damage 4 | Crit chance +12 percentage points, crit multiplier +0.35, splash damage *1.2, projectile scale up to 1.1. |
| Repair Loop | Recycler 3, Alloy Plating 3, Reactive Shield 2 | Recycler heal chance +8 percentage points and armor reduction +5 percentage points. |

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

Elites begin appearing after 90s and ramp to an 18% spawn chance by 900s. Split elites are prevented when active pressure is too high.

| Affix | Unlock | Weight | Effects |
|---|---:|---:|---|
| Hasty | 90s | 28 | Speed *1.45, health *0.85. |
| Armored | 150s | 24 | Speed *0.82, health *1.85, scale *1.12. |
| Rich | 210s | 18 | Health *1.2, EXP drop count *2.4, minimum EXP tier +1. |
| Volatile | 300s | 16 | Speed *1.18, health *0.9. On death, damages nearby enemies in a 92px radius for 34 damage. |
| Splitting | 420s | 14 | Health *1.35. On death, splits into 2 small weaver children with 8 health, 82 speed, and 1 damage. |

## Bosses

Only one boss can be alive at a time. Bosses normally spawn every 420s, modified by run modifiers. Boss spawns reserve 16 enemy-pressure slots.

| Boss | Unlock | Behavior | Health | Speed | Damage | EXP Drops | Weight Profile | Special Mechanics |
|---|---:|---|---:|---:|---:|---|---|---|
| Charger | 0s | charger | 950 | 25 | 5 | 30 tier 1+ | 100 base, -8/min, min 20 | Baseline pursuing boss. |
| Bulwark | 420s | bulwark | 1550 | 17 | 8 | 38 tier 2+ | 55 base, +1/min, max 70 | Rotates visually, phase at 55%, summons minions every 8s after 3.5s. Minion count 3 + 2 per phase, capped at 7. |
| Sprinter | 840s | sprinter | 1100 | 34 | 6 | 42 tier 2+ | 55 base, +1.5/min, max 75 | Pulses speed up to +75%. |
| Crusher | 1260s | crusher | 2200 | 15 | 11 | 52 tier 3+ | 62 base, +1.2/min, max 82 | Phases at 65% and 32%, creates hazard rings every 7.2s after 2.8s. |
| Wraith | 1680s | wraith | 1750 | 30 | 9 | 60 tier 4+ | 70 base, +1.5/min, max 90 | Phases at 50%, fades visually, targets player hazards every 5.6s and calls minions every 11s. |

Boss phases increase base speed by 8%, add +1 contact damage, and trigger a burst effect.

## Mid-Run Events

Runs schedule up to 4 seeded events. Active or upcoming events appear in the HUD. Triggered events appear in the defeat summary.

| Event | Duration | Weight | Risk | Reward |
|---|---:|---:|---|---|
| Crystal Bloom | 48s | 28 | Enemy damage *1.12 while active. | EXP value *1.35 while active. |
| Supply Cache | Instant | 24 | None. | Spawns 2 green supply boxes and 1 blue supply box offscreen. |
| Elite Bounty | Instant | 22 | Spawns a bounded 5-enemy guaranteed elite wave respecting pressure caps. | Queues 1 bonus upgrade choice. |
| Overrun Gambit | 36s | 20 | Spawn interval *0.72 and enemy speed *1.1 while active. | Queues 1 bonus ability choice. |

## Run Modifiers

| Modifier | Unlock | Effects |
|---|---|---|
| Swarm Opening | Default | Spawn interval *0.72, enemy health growth *0.92. |
| Rich Crystals | Default | EXP value *1.28, enemy damage growth *1.2. |
| Supply Rain | Survive 120s | Supply interval *0.72, supply chance *2.4. |
| Boss Contract | Defeat 1 total boss | Boss spawn interval *0.55, boss EXP *1.45. |
| Unstable Engine | Reach level 10 | Player fire interval *0.88, enemy speed growth *1.25. |
| Salvage Field | Best enemies defeated >= 250 | Wrench drops *1.75, dynamite drops *2.0, supply chance *0.65. |
| Overclock Cache | Complete Boss Breaker challenge | Player fire interval *0.9, supply chance *0.8. |

## Unlocks And Meta Progression

Progress is saved in `user://unlock_state.cfg`.

### Default Unlocks

- Tanks: Vanguard, Scout
- Abilities: Landmine, Circular Saw, Footsoldier, Shock Field
- Modifiers: Swarm Opening, Rich Crystals

### Stat-Based Unlocks

| Requirement | Unlocks |
|---|---|
| Best survival time >= 120s | Fortress tank, Oil Slick ability, Supply Rain modifier |
| Best level >= 5 | Collector tank, Drone Swarm ability |
| Total bosses defeated >= 1 | Twin Cannon tank, Artillery ability, Boss Contract modifier |
| Best enemies defeated >= 250 | Engineer tank, Salvage Field modifier |
| Best level >= 10 | Freeze Pulse ability, Unstable Engine modifier |

### Challenge Goals

Completed challenge IDs persist separately and can grant meta rewards.

| Challenge | Requirement | Reward |
|---|---|---|
| Hold the Line | Survive 180s in a run | +1 starting Armor level |
| Boss Breaker | Defeat 1 boss in a run | Unlock Overclock Cache modifier |
| Elite Sweeper | Defeat 8 elites in a run | Wrench drop multiplier *1.15 |
| Heavy Build | Damage + Fire Rate + Cannon levels total at least 7 | +1 starting Damage level |
| Collector Build | Magnet + EXP levels total at least 5 | +1 starting EXP level |

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
