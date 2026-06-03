# Autonomous Survivor

Top-down tank survivor prototype built in Godot. The current design target is a replayable bullet-heaven loop: escalating enemy pressure, randomized upgrade choices, simple readable shapes, and strong upgrade synergies that can become intentionally overpowered when the player builds well.

GitHub issue tracker: https://github.com/satoshimatos/autonomous-survivor/issues

## Navigation

- [Game Compendium](docs/GAME_COMPENDIUM.md): open-book reference for mechanics, tanks, enemies, bosses, upgrades, abilities, evolutions, events, modifiers, unlocks, pickups, scaling, and budgets.
- [30-Minute Balance Pass](docs/BALANCE_30_MIN.md): deterministic long-run pressure and strong-build projection for the 30-minute target.
- [Visual Identity](docs/VISUAL_IDENTITY.md): current art direction, generated asset families, and juice hooks.
- [Backlog](BACKLOG.md): autonomous task queue and completed issue history.
- [Current Changelog](#current-changelog): latest implementation notes.

## Current Changelog

### 2026-06-03

- Added a global juice pass across gameplay and selection UI:
  - Upgrade and ability cards now punch, tilt, and settle on hover/focus/press so mouse, keyboard, and gamepad actions feel acknowledged.
  - Upgrade and ability selection screens now render richer moving celebration layers with rotating rays, soft bubbles, drifting confetti, and a burst at the selected card before the run resumes.
  - Player projectile impacts now emit capped spark bursts, with stronger orange bursts for splash hits and light shake for final splash impacts.
  - Repairs now spawn green healing particles in addition to the heal popup.
  - Large splash detonations add an extra burst and mass-splash camera shake while still respecting the existing particle and splash budgets.
- Added GitHub issue #37 for this polish slice and updated the backlog with the completed global juice pass.
- Added autonomous content wave #38:
  - Added 10 new tank starts: Glass Rail, Bulldozer, Swarm Broker, Sapper, Chrono Tank, Gold Engine, Rift Skimmer, Fortress Medic, Meteor Twins, and Storm Foundry.
  - Added 5 more unlock-chain maps: Moonlit Graveyard, Neon Grid, Frozen Scar, Ember Rift, and Astral Engine.
  - Added 5 new generated map background textures and scene-authored obstacle groups for the new maps.
  - Added 5 map gimmicks: ghost surges, laser lattice strikes, frost locks, ember eruptions, and astral collapse waves.
  - Added 10 map-specific bosses with phase thresholds and combinations of minion calls, hazard rings, targeted hazards, and high-pressure stat profiles.
- Added autonomous content wave #39:
  - Added 25 map-specific regular enemy variants for Moonlit Graveyard, Neon Grid, Frozen Scar, Ember Rift, and Astral Engine.
  - Added generated sprites and Godot import metadata for each new late-map enemy under `assets/visual/enemies/map6` through `assets/visual/enemies/map10`.
  - Updated the compendium and backlog so late maps document both their boss identity and their normal spawn-table identity.
- Added organization pass #40:
  - Extracted the late-map enemy roster from `scripts/core/main.gd` into `scripts/core/late_map_enemy_catalog.gd`.
  - Kept the existing registration hook and spawn behavior unchanged while reducing core controller catalog bulk.
  - Revalidated scene catalog and direct gameplay/menu startup after the extraction.
- Added organization pass #41:
  - Extracted the late-map boss roster from `scripts/core/main.gd` into `scripts/core/late_map_boss_catalog.gd`.
  - Kept boss registration, phase thresholds, ability modules, map gates, and spawn behavior unchanged.
  - Revalidated scene catalog and direct gameplay/menu startup after the extraction.
- Added replayability wave #42:
  - Added 5 late-chain run modifiers: Grave Moon, Neon Overdrive, Frost Cache, Ember Bounty, and Astral Lottery.
  - Late map victories now unlock these modifiers alongside the next map, and existing saves backfill them from already unlocked maps.
  - The new modifiers use existing run-scaling systems for EXP, boss rewards, spawn tempo, supplies, explosives, and enemy growth.
- Added organization pass #43:
  - Extracted the autonomous tank starts into `scripts/core/autonomous_tank_catalog.gd`.
  - Extracted the autonomous late-map configs into `scripts/core/autonomous_map_catalog.gd`.
  - Kept `run_config.gd` responsible for registering content and selecting runs, while the new catalog helpers own the large data batches.
- Added organization pass #44:
  - Extracted the full run modifier pool into `scripts/core/run_modifier_catalog.gd`.
  - Kept run seeding, unlock filtering, modifier rolling, and multiplier lookup in `run_config.gd`.
  - Revalidated scene catalog and direct gameplay/menu startup after the extraction.
- Added meta-progression wave #45:
  - Extracted challenge goals into `scripts/core/challenge_goal_catalog.gd`.
  - Added 5 late-run challenge goals: Marathon Plate, Boss Harvester, Elite Recycler, Storm Mastery, and Magnet Empire.
  - New rewards use existing permanent bonus hooks for starting health, damage, magnet, EXP, wrench drops, and dynamite drops.

### 2026-05-30

- Added a data-driven enemy variant catalog with 10 enemy types that unlock over time and enter the spawn table with weighted chances.
- Added enemy movement personalities: chase, sprinter, zigzag, weaver, stalker, orbiter, and drifter.
- Added a data-driven boss catalog with 5 boss variants that unlock over longer run times and differ by health, speed, damage, rewards, size, color, and behavior profile.
- Added three stacking player upgrades:
  - Armor reduces incoming hit damage up to a cap.
  - Magnet pulls nearby EXP orbs toward the tank.
  - Cannon adds extra spread shots per volley.
- Updated HUD stats and upgrade inventory to show cannon count, armor, magnet, and cannon upgrade levels.
- Created this README as the durable changelog and project overview for autonomous runs.
- Added two new ability choices:
  - Shock Field adds a scaling electric aura that damages and slows nearby enemies.
  - Artillery Beacon periodically targets dense enemy clusters near the player and calls in delayed splash strikes.
- Expanded the ability menu from 3 to 5 options and updated the ability inventory readout.
- Added headless validation coverage for the new ability scenes.
- Added three more ability choices:
  - Drone Swarm orbits the player and fires autonomous close-support shots.
  - Oil Slick drops lingering puddles that damage and heavily slow enemies.
  - Freeze Pulse periodically bursts around the player, damaging and nearly stopping enemies in a wide radius.
- Changed ability selection into a randomized 3-choice roll from the full ability catalog so ability rewards vary more between runs.
- Expanded headless validation to cover the randomized ability menu and all ability scenes.
- Created the GitHub repository and initialized GitHub issues from the backlog.
- Added tank archetype selection on the main menu:
  - Vanguard, Scout, Fortress, Twin Cannon, Engineer, and Collector.
  - Archetypes modify starting stats, upgrades, abilities, tank tint, HUD stats, and defeat summary.
- Added deterministic run seeds and randomized run modifiers:
  - Each run rolls a seed and 2-3 modifiers from a reusable modifier catalog.
  - Modifiers affect spawn pressure, EXP value, boss cadence/rewards, supply drops, enemy scaling, weapon tempo, and salvage drops.
  - Defeat summary now shows the seed and active modifier names.
- Added rarity, synergy tags, and weighted ability choices:
  - Ability rolls now consider rarity, current ability stacks, late-game level boosts, existing upgrade synergies, and existing ability synergies.
  - Ability buttons show rarity and a primary tag while still presenting a 3-choice menu.
- Added persistent unlock progression:
  - Unlock state is saved in `user://unlock_state.cfg` and updates from survival time, best level, enemy defeats, and boss defeats.
  - Tanks, ability choices, and run modifiers are now filtered by unlocked content, with locked tanks shown on the main menu.
  - Defeat summaries now report newly unlocked content so progression rewards are visible after each run.
- Added elite enemy affixes:
  - Regular enemy spawns can gradually roll Hasty, Armored, Rich, Volatile, or Splitting affixes as run time advances.
  - Affixes are data-driven and modify stats, colors, scale, rewards, and death effects without creating duplicate scenes.
  - Volatile elites damage nearby enemies on death, while Splitting elites spawn bounded child enemies to keep pressure high without unbounded growth.
- Expanded boss behaviors:
  - Boss configs can now declare timed ability modules and health-based phase thresholds.
  - Bulwark can summon bounded minion waves, Crusher can create warning telegraph hazard rings, and Wraith can target the player with hazards while calling support.
  - Boss phase transitions increase pressure and trigger a simple burst effect without replacing the shared state-machine movement.
- Added performance pooling and effect budgets:
  - Tank and footsoldier shots now use a reusable projectile pool instead of constant projectile allocation/free churn.
  - Particle bursts now recycle through a pool and respect an active burst budget.
  - Damage numbers, splash areas, particle bursts, and boss hazards now have explicit runtime budgets to keep dense fights bounded.
- Added run summary telemetry:
  - Runtime now tracks total damage dealt, damage taken, elite kills, boss kills, and top build choices.
  - The defeat screen now shows a compact run report with tank, level, seed, modifiers, survival time, kill counts, damage totals, DPS, build highlights, and unlocks.
  - The defeat report layout was widened and tightened so the extra tuning data remains readable.
- Added spawn director pressure caps:
  - Regular enemy spawns now respect a time-scaling active enemy cap instead of growing unbounded.
  - Boss spawns reserve pressure space, while boss minion waves and splitting elites use pressure-scaled caps.
  - The HUD and defeat report now show active pressure and skipped spawn counts for tuning.
- Improved upgrade choice cards:
  - Upgrade options now show role tags, short mechanical hints, and synergy notes.
  - Synergy hints react to currently active upgrades and abilities so build choices are easier to evaluate.
  - Upgrade option copy is driven by a compact data catalog instead of scattered match-only labels.

### 2026-05-31

- Added repeatable spawn-balance projection:
  - `tools/balance_check.py` now projects active pressure caps, enemy mix, boss mix, and average spawn health at key run times.
  - Enemy weights now rotate away from starter scouts into swarm, mobility, and durable variants as survival time increases.
  - Boss weights now decay the starter charger and raise later bosses so longer runs see more varied boss pressure.
  - Active enemy cap growth was tightened from 240 max pressure to 225 to leave more room for readable late-game fights.
- Added challenge goals and meta-progression rewards:
  - Unlock state now persists completed challenge goal IDs alongside tanks, abilities, modifiers, and run stats.
  - Added data-driven challenges for survival time, boss defeats, elite defeats, and build-style milestones.
  - Challenge rewards can grant starting stat bonuses, drop-rate multipliers, and modifier unlocks without duplicating scenes.
  - Added the Overclock Cache run modifier as a boss-challenge reward.
  - Defeat summaries now include newly completed challenge rewards in the unlock list.
- Added evolved upgrade synergies:
  - Added a data-driven evolution catalog on the player that checks upgrade and ability level requirements after picks.
  - Shrapnel Core combines damage, splash, and piercing into larger, harder-hitting projectiles with extra penetration.
  - Storm Armor combines Shock Field, Barbed Wire, and Armor into stronger aura/contact defense and extra damage reduction.
  - Drone Foundry combines Drone Swarm, Cannon, and Fire Rate into extra multishot pressure and stronger drone levels.
  - Active evolutions now appear in the upgrade inventory and defeat build summary.
- Added randomized mid-run events:
  - Runs now build a deterministic event schedule from the run seed, so the same seed repeats the same timed event sequence.
  - Added Crystal Bloom, Supply Cache, Elite Bounty, and Overrun Gambit event definitions with bounded risk/reward effects.
  - Active events can temporarily modify spawn pressure, enemy speed, enemy damage, or EXP value.
  - Event rewards can spawn supply caches, trigger bonus upgrade/ability choices, or call in elite waves while respecting pressure caps.
  - The HUD now shows active or upcoming events, and the defeat summary records triggered events.
- Added a navigable game compendium:
  - `docs/GAME_COMPENDIUM.md` documents current mechanics, tanks, upgrades, abilities, evolutions, enemies, bosses, events, modifiers, unlocks, pickups, scaling, and performance budgets.
  - README now links to the compendium from the top navigation section.
- Fixed boss variant and projectile cleanup issues:
  - Boss phase thresholds and ability modules now convert incoming config data into typed arrays before assignment.
  - Pooled player projectiles now launch after being placed, and recycled shots are hidden, disabled, and moved out of play before returning to the pool.
- Added accessory upgrade branch for build variety:
  - Added Targeting Array, Accelerator, Alloy Plating, Recycler, Payload Rack, and Reactive Shield to the normal upgrade pool.
  - Accessories add crits, projectile speed, max health, kill-based repairs, payload splash scaling, and longer post-hit safety windows.
  - Added Critical Payload and Repair Loop evolutions so accessory-heavy builds can cross into stronger late-game synergies.
  - HUD stats, upgrade inventory, run summary build tracking, and the game compendium now include accessory upgrades.
- Expanded late-game enemy and boss variety:
  - Added Lancer, Phalanx, Mirage, Reaper, and Comet enemy variants, bringing the enemy catalog to 15 weighted types.
  - Added Monarch, Tempest, and Bastion boss variants, bringing the boss catalog to 8 weighted types.
  - New variants unlock from 16 to 40 minutes to support longer 30-minute progression and keep late runs from repeating the same pressure mix.
  - Updated the balance projection tool and compendium with the new weighted entries.
- Added the next power batch:
  - Added Chain Lightning, Guardian Satellite, and Overdrive Core, bringing the ability/power catalog to 11 powers.
  - Chain Lightning provides chaining damage and brief slows, Guardian Satellite adds orbiting defensive contact damage, and Overdrive Core buffs damage and mobility.
  - Added Storm Grid and Guardian Protocol evolutions for late-game synergy spikes.
  - New powers are unlockable through level and survival progression and are surfaced in ability rolls, inventory, build summaries, unlocks, and the compendium.
- Reached the requested enemy and boss catalog counts:
  - Added Viper, Bulldozer, Specter, Sapper, and Voidling, bringing the enemy catalog to 20 weighted types.
  - Added Overlord and Singularity, bringing the boss catalog to 10 weighted types.
  - New entries extend the weighted progression through 50 minutes while preserving shared scenes and lightweight config-driven behavior.
  - Updated the compendium and balance projection data for the full 20 enemy / 10 boss catalog.
- Added a large upgrade branch batch:
  - Added Gyro Stabilizer, Rapid Loader, High Caliber, Nanobots, Kinetic Treads, Ammo Synthesizer, Shatter Rounds, Phase Core, Capacitor Bank, Salvage Magnet, Emergency Repairs, and Combustion Mix.
  - New upgrades feed existing projectile, splash, piercing, healing, economy, movement, rotation, power-damage, and low-health sustain systems.
  - Upgrade cards, HUD stats, inventory, run summaries, ability synergies, and the compendium now include the new upgrade IDs.
- Added another power batch:
  - Added Flame Wave, Repair Beacon, Missile Pod, Gravity Well, and Railgun Orbiter, bringing the ability/power catalog to 16 powers.
  - New powers add radial burn waves, sustain pulses, splash missile targeting, enemy-cluster pull fields, and piercing beam damage.
  - Added Siege Command, Singularity Engine, and Field Medic evolutions to push late-game build synergies higher.
  - New powers are wired into unlock progression, weighted ability rolls, inventory, run summaries, scene validation, and the compendium.
- Added another upgrade branch batch:
  - Added Heat Sinks, Overclocked Barrel, Rail Stabilizer, Missile Guidance, Ordnance Bay, Field Amplifier, Volt Coils, Gravity Anchor, Repair Drones, Crystal Lens, Munition Printer, and Stabilized Chassis.
  - The unique upgrade catalog is now 41/50, with new branches for tempo, precision, missile/siege scaling, field/aura scaling, electric power damage, control-area damage, healing, economy/crit, multishot, and defensive control.
  - Added Coil Reactor, War Factory, and Recovery Swarm evolutions to connect the new upgrades into late-game synergy spikes.
- Reached the requested unique-upgrade count:
  - Added Vector Thrusters, Impact Fuse, Armor Piercers, Weakpoint Scanner, Med Pump, Orbit Gears, Mine Dispenser, Drone Command, and Lucky Core.
  - The unique upgrade catalog is now 50/50, covering mobility, area damage, pierce, crit, sustain, orbit/contact damage, mines, pets, and luck-driven replayability.
  - Added Death Orbit and Breach Rounds evolutions to deepen orbit and precision late-game builds.
- Reached the requested power count:
  - Added Tesla Pylon, Nanite Cloud, Ricochet Rounds, and Chrono Burst, bringing the ability/power catalog to 20/20 powers.
  - New powers add stationary electric area denial, sustain aura damage, projectile ricochet chains, and heavy crowd-control bursts.
  - Added Time Cage and Storm Battery evolutions for late-game control and electric synergy spikes.
- Completed the 30-minute progression balance pass:
  - Expanded `tools/balance_check.py` from enemy-pressure-only output into a long-run progression projection that also models a coherent high-synergy player build.
  - Verified the current catalog meets the requested 20 enemies, 10 bosses, 50 upgrades, and 20 powers.
  - Projected the 30-minute pressure point at 225 active enemies, 853 average regular spawn HP, and a 0.20s minimum spawn interval.
  - Projected a strong 30-minute build at about 31,764 direct DPS and 37.2 regular kills/s against the 5.0 kills/s spawn cadence before splash overlap, piercing, pets, fields, or crowd-control are credited.
  - Added `docs/BALANCE_30_MIN.md` as the readable balance report linked from the README.

### 2026-06-02

- Expanded build variety and performance headroom:
  - Added 20 fully wired upgrades, bringing the upgrade pool to 100 total.
  - Added 5 fully wired powers, bringing the power pool to 40 total.
  - Generated matching semi-real cartoon icons for every new upgrade and power through `tools/generate_semireal_assets.ps1`.
  - Cached aggregate extra-upgrade and passive-power effects on the player so large build pools do not rescan every catalog on each stat query.
  - Replaced per-frame enemy and boss overlap polling with body enter/exit contact tracking to reduce physics query pressure at high enemy counts.

### 2026-06-01

- Added a cartoony black-outline visual identity pass:
  - Generated and integrated a vivid top-down wasteland arena/background and menu backdrop.
  - Added project-local cartoon sprite assets for the player tank, cannon, regular enemies, shielded enemies, bruisers, bosses, projectiles, EXP crystals, pickups, ability items, UI panels, cloud shadows, and player light texture.
  - Replaced primitive enemy/boss mesh placeholders with modulated sprite visuals so the existing data-driven variants keep their colors while gaining silhouettes and inked details.
  - Added moving cloud-shadow parallax and player-centered warm 2D lighting over a cooler world tint.
  - Skinned the main menu, upgrade menu, and ability menu with chunky outlined button styles and generated panel art while keeping Godot's default font.
  - Added projectile trails, enemy/boss hit pops, extra impact bursts, richer explosion rings, boss defeat flashes, player damage screen modulation, and juicier EXP pickup particles.
  - Added `tools/generate_visual_identity_assets.ps1` so this visual identity asset set can be regenerated from the source background image.
- Improved upgrade readability and controller play:
  - Rescaled EXP orb tiers so crystal collision radius matches visible size, with green crystals reduced from oversized sprites to tighter pickups.
  - Converted upgrade selection into horizontal icon cards with a focused description field for mouse, keyboard, and gamepad highlighting.
  - Regenerated all 50 upgrade icons with a standardized black-outline style, category colors, recurring motifs, and a shared green plus badge language.
  - Added runtime gamepad mappings for movement, UI navigation, tank selection cycling, pause/resume, and defeat-screen restart.
  - Upgrade and ability choices continue to fully pause gameplay; AI upgrade picking uses pause-safe timers so it can choose while the background stays stopped.
- Tightened the upgrade and scale pass after playtest feedback:
  - Moved paused input handling into a focused always-processing router so the main gameplay tree remains pausable during upgrade selection.
  - Shrank the upgrade panel and replaced stretched button icons with owned card labels/icons/tags plus one dedicated description field.
  - Removed upgrade hover tooltip content so descriptions are not duplicated.
  - Preserved authored enemy sprite scale when applying data-driven variant scales, reducing oversized enemy visuals and improving collision readability.
  - Zoomed the camera out modestly and expanded the arena/bounds to keep the map from feeling cramped.
- Added rarity-colored choice cards and prerequisite-gated rolls:
  - Upgrade cards now color their container by rarity instead of relying only on text tags.
  - Ability choices now use the same horizontal card layout as upgrades, with blue-themed rarity colors and generated icons for all 20 powers.
  - Upgrade rolls now filter out dependent modifiers until the player owns the relevant build piece, such as pets before pet damage, powers before power amplifiers, and splash/area tools before splash boosters.
  - Ability rolls now gate advanced powers behind existing build prerequisites while leaving starter powers available.
  - Added `tools/generate_ability_icons.ps1` for regenerating the standardized ability icon set.
- Expanded permanent progression communication and menu reference tools:
  - Added Storm Chaser, Pyroclast, Medic, and Singularity Rig tanks with distinct starting stat and power identities.
  - Tank selection now lets locked tanks be inspected and shows the exact unlock requirement while preventing locked starts.
  - Added a main-menu compendium scene for tanks, upgrades, abilities, enemies, bosses, run modifiers, and unlock goals with detailed stats, weights, timings, synergies, and unlock status.
  - Reworked the defeat screen into a detailed run report with combat stats, build summary, evolutions, new unlocks, permanent progress, and next goals.
  - Hid debug buttons and the on-screen stat/inventory readouts from the player-facing HUD.
  - Replaced the repeated oval cloud shadows with a full-screen drifting shader overlay.
  - Added confetti and moving color bands to upgrade and ability choices, plus stronger camera shake for boss defeats, volatile elite bursts, and dynamite.
- Expanded and corrected build content after playtest feedback:
  - Added 30 new unique upgrades, bringing the upgrade pool to 80 total.
  - Added 15 new powers, bringing the power pool to 35 total.
  - Rewrote confusing early upgrade descriptions and rebalanced upgrade/power rarity assignments around gameplay value.
  - Fixed healing scaling so Nanobots and related sustain upgrades noticeably increase wrench, beacon, cloud, and recycler repairs.
  - Increased recycler kill-repair chance so the enemy-kill repair upgrade is visible in normal play.
  - Rebuilt the end-run report as a scrollable panel instead of a cramped raw text block.
  - Bosses now spawn every 3 minutes, roll from the full boss pool, and avoid repeating the previous boss when alternatives exist.
  - Added variant enemy sprites and catalog texture hooks so later enemy types stop looking like only recolored starter enemies.
  - Enlarged supply boxes, widened wrench collision, and made wrench pickup range benefit from the player's pickup radius.
  - Zoomed the camera out for a wider field of view and made camera visibility math respect zoom.
  - Reworked the in-game compendium into sprite/icon cards that open detail pages with a back button.
  - Tightened tank unlock requirements so most tanks should take multiple runs or stronger play to unlock.
- Replaced the sketchier cartoon asset set with a cleaner semi-real cartoon pass:
  - Regenerated upgrade icons, power icons, enemy/boss sprites, pickups, projectiles, player tank pieces, effects, UI panels, cloud shadows, and both background images with cleaner bevels, stronger silhouettes, and less rough sketch texture.
  - Preserved existing PNG paths and dimensions so scene references, import metadata, and compendium icon lookups remain stable.
  - Added `tools/generate_semireal_assets.ps1` as the repeatable source for the current asset direction and updated `docs/VISUAL_IDENTITY.md` to make the new style target explicit.
- Ran a performance and organization pass:
  - Added active runtime registries in the main scene for enemies, bosses, EXP orbs, projectiles, splash areas, boss hazards, and particle bursts.
  - Replaced repeated tree-wide enemy/EXP scans in projectiles, player systems, AI movement, and combat powers with cached runtime queries that fall back to groups outside gameplay.
  - Routed shared lookup behavior through `RuntimeQuery` so ability scripts stay focused on their own effects instead of duplicating scene traversal logic.
  - Tightened pooled particle bursts so recycled effects stop processing while inactive.
  - Cached per-frame player references for cloud shadows, wrench pickup radius checks, and pickup indicators.
- Added a 30-minute victory target and unlockable second map:
  - Surviving to 30:00 now ends the run as a victory instead of continuing forever.
  - Victories are recorded in permanent progress and unlock the Scrap Maze map.
  - The main menu now lets unlocked maps be selected and shows locked map requirements.
  - Scrap Maze is a larger arena with authored obstacle nodes that block the player and enemies.
  - Enemy spawns, EXP drops, wrench/dynamite drops, and supply pickups now resolve to nearby walkable positions when an obstacle would overlap them.
- Made Scrap Maze a harder second-map experience:
  - Scrap Maze now applies faster regular spawns, faster boss cadence, stronger enemy scaling, a higher active enemy cap, and more elite pressure.
  - Added six Scrapborn regular enemies that enter the map 2 spawn pool over time and down-weight the original Dust Bowl roster.
  - Added three Scrap Maze bosses with heavier hazard/minion patterns and distinct reward profiles.
  - Generated distinct Scrap Maze enemy and boss sprites under `assets/visual/enemies/map2`.
- Expanded the campaign to five maps:
  - Map unlocks now form a victory chain: Dust Bowl -> Scrap Maze -> Crystal Expanse -> Toxic Foundry -> Void Crucible, with each new map unlocked by a 30:00 victory on the previous map.
  - Added Crystal Expanse, a wide shard-lane arena with faster flanking enemies, a higher pressure cap, and periodic crystal storm hazards.
  - Added Toxic Foundry, a huge corrosive basin with furnace blockers, toxic vent hazard pulses, heavier elites, and tankier enemy pressure.
  - Added Void Crucible, a compact endgame arena with central/rib blockers, void collapse pulses, extra unstable swarm spawns, and the fastest boss cadence.
  - Added 15 new map-specific regular enemies and 6 new map-specific bosses across maps 3-5.
  - Generated and imported distinct enemy and boss sprites under `assets/visual/enemies/map3`, `assets/visual/enemies/map4`, and `assets/visual/enemies/map5`.
  - Extended scene validation so every map layout is switched and checked for obstacle cache coverage.

## Backlog

### Next

- Continue with focused playtest feedback, bug fixes, and individual power animation polish as new issues are identified.

### Content

- Requested content and 30-minute progression targets are exceeded: 100 upgrades, 40 powers, 20 tanks, 66 enemies, 29 bosses, and 10 maps.
- Surviving 30:00 is now a victory condition and unlocks the next map when the current map is cleared.
- Maps 2-5 have their own enemy/boss rosters and pressure modifiers, so future map work should continue using map-specific catalog data instead of duplicating the main scene.

### Systems

- Keep enemy, boss, upgrade, and ability definitions data-driven so tuning does not require scene duplication.
- Add deterministic run seeds and show the seed on the defeat screen.

### Testing

- Maintain Godot headless scene-load checks after each implementation slice.
- Add lightweight script-level tests for weighted spawn tables and upgrade math if the project gains a test harness.

## Scope Rules

- Favor simple shapes and clear silhouettes until the gameplay loop is stable.
- Prioritize performance and organization over visual polish.
- Prefer reusable data/config systems for enemies, bosses, upgrades, abilities, tanks, and run modifiers.
- Keep folders and files neat; split growing systems into clear subfolders and focused scripts/classes.
- Avoid long singleton-style scripts when behavior can be delegated to owned objects, helper classes, focused managers, or reusable scenes.
- Prefer object-driven ownership and event-driven communication with signals; avoid brittle hard-coded node paths and direct cross-tree script lookups.
- Instantiate reusable scenes through clear owner systems, factories, or exported references so scene tree and directory changes stay low-risk.
- Keep each autonomous run focused on the highest-value backlog item and record results here.
