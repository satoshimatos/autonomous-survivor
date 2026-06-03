# Autonomous Survivor Backlog

## Active Policy

Each autonomous run should:

1. Read this backlog and `README.md`.
2. Pick the highest-value task that preserves the original survivor/bullet-heaven scope.
3. Implement a small complete slice.
4. Run a Godot validation command.
5. Update `README.md` changelog and this backlog.

GitHub issues are now the primary task tracker: https://github.com/satoshimatos/autonomous-survivor/issues

Standing architecture rule:

- Keep folders and files cleanly organized; create subfolders when a feature family starts to grow.
- Prefer small purpose-built scripts/classes over long singleton-style catchalls.
- Use object-driven scene ownership plus event-driven communication through signals where practical.
- Avoid hard-coded node paths and manual cross-tree script lookups; exported references, typed dependencies, groups, signals, and local ownership should survive directory or scene-tree changes.
- Instantiate reusable scenes cleanly through focused factories/helpers or owner systems instead of scattering construction logic across unrelated scripts.

## Priority Queue

### P0 - Project Operations

- Create GitHub repo `satoshimatos/autonomous-survivor`, push the current project, and create GitHub issues from this backlog.
- Keep project organization data-driven, foldered by responsibility, and avoid one scene per minor variant unless the behavior truly needs unique nodes.

Completed setup:

- Repository: https://github.com/satoshimatos/autonomous-survivor
- Issue tracker initialized:
  - #1 Add tank archetype selection with unique starts
  - #2 Add random run modifiers and deterministic seed display
  - #3 Add unlock progression for tanks, abilities, and modifiers
  - #4 Add ability rarity, synergy tags, and weighted ability choices
  - #5 Add elite enemy affixes using lightweight modifiers
  - #6 Expand boss behaviors with phases and hazards
  - #7 Add object pools and effect budgets for performance
  - #8 Add run summary details and build telemetry
  - #9 Add spawn director caps based on active pressure
  - #10 Improve upgrade cards with clearer synergy tags
  - #11 Tune enemy and boss spawn weights with survival checks
  - #12 Add challenge goals and meta-progression rewards
  - #13 Add first evolved upgrade synergy rewards
  - #14 Add randomized mid-run events and gambit rewards
  - #15 Add accessory upgrade branch for build variety
  - #16 Add late-game enemy and boss variants toward long-run variety
  - #17 Add next power batch toward 20 powers
  - #18 Add final enemy and boss batch toward target counts
  - #19 Add upgrade branch batch toward 50 unique upgrades
  - #20 Add another power batch toward 20 powers
  - #21 Add another upgrade branch batch toward 50 unique upgrades
  - #22 Add final upgrade batch toward 50 unique upgrades
  - #23 Add final power batch toward 20 powers
  - #24 Run 30-minute progression balance pass
  - #25 Visual identity and juice pass
  - #26 Upgrade card UI, pickup precision, and gamepad flow
  - #27 Fix full upgrade pause and tighten upgrade visuals
  - #28 Add rarity-colored cards and prerequisite-gated rolls
  - #29 Progression communication, compendium, and juice polish pass
  - #30 Fix progression readability, pickups, bosses, and expand build content
  - #31 Refresh all project graphics with cleaner semi-real cartoon style
  - #32 Expand build pool to 100 upgrades and 40 powers with performance pass
  - #33 Performance and organization pass for high enemy counts
  - #34 Add 30-minute victory and unlockable obstacle map 2
  - #35 Make map 2 a harder distinct experience
  - #36 Add maps 3-5 with unlock chain, distinct pressure, gimmicks, and performance pass
  - #37 Add global gameplay and UI juice pass
  - #38 Add autonomous content wave: tanks, bosses, maps, backgrounds, and gimmicks
  - #39 Add late-map enemy rosters and sprites
  - #40 Extract late-map enemy catalog from main controller
  - #41 Extract late-map boss catalog from main controller
  - #42 Add late-chain victory run modifiers
  - #43 Extract autonomous tank and map catalogs
  - #44 Extract run modifier catalog
  - #45 Expand and extract challenge goal catalog
  - #46 Expand and extract run event catalog
  - #47 Expand and extract enemy affix catalog
  - #48 Expand permanent challenge goals
  - #49 Add Autonomous Survivor branding assets and extract ability catalog
  - #50 Extract player evolution catalog
  - #51 Extract upgrade metadata catalog
  - #52 Add late-campaign tank archetypes

Completed issues:

- #1 Add tank archetype selection with unique starts
- #2 Add random run modifiers and deterministic seed display
- #3 Add unlock progression for tanks, abilities, and modifiers
- #4 Add ability rarity, synergy tags, and weighted ability choices
- #5 Add elite enemy affixes using lightweight modifiers
- #6 Expand boss behaviors with phases and hazards
- #7 Add object pools and effect budgets for performance
- #8 Add run summary details and build telemetry
- #9 Add spawn director caps based on active pressure
- #10 Improve upgrade cards with clearer synergy tags
- #11 Tune enemy and boss spawn weights with survival checks
- #12 Add challenge goals and meta-progression rewards
- #13 Add first evolved upgrade synergy rewards
- #14 Add randomized mid-run events and gambit rewards
- #15 Add accessory upgrade branch for build variety
- #16 Add late-game enemy and boss variants toward long-run variety
- #17 Add next power batch toward 20 powers
- #18 Add final enemy and boss batch toward target counts
- #19 Add upgrade branch batch toward 50 unique upgrades
- #20 Add another power batch toward 20 powers
- #21 Add another upgrade branch batch toward 50 unique upgrades
- #22 Add final upgrade batch toward 50 unique upgrades
- #23 Add final power batch toward 20 powers
- #24 Run 30-minute progression balance pass
- #25 Visual identity and juice pass
- #26 Upgrade card UI, pickup precision, and gamepad flow
- #27 Fix full upgrade pause and tighten upgrade visuals
- #28 Add rarity-colored cards and prerequisite-gated rolls
- #29 Progression communication, compendium, and juice polish pass
- #30 Fix progression readability, pickups, bosses, and expand build content
- #31 Refresh all project graphics with cleaner semi-real cartoon style
- #32 Expand build pool to 100 upgrades and 40 powers with performance pass
- #33 Performance and organization pass for high enemy counts
- #34 Add 30-minute victory and unlockable obstacle map 2
- #35 Make map 2 a harder distinct experience
- #36 Add maps 3-5 with unlock chain, distinct pressure, gimmicks, and performance pass
- #37 Add global gameplay and UI juice pass
- #38 Add autonomous content wave: tanks, bosses, maps, backgrounds, and gimmicks
- #39 Add late-map enemy rosters and sprites
- #40 Extract late-map enemy catalog from main controller
- #41 Extract late-map boss catalog from main controller
- #42 Add late-chain victory run modifiers
- #43 Extract autonomous tank and map catalogs
- #44 Extract run modifier catalog
- #45 Expand and extract challenge goal catalog
- #46 Expand and extract run event catalog
- #47 Expand and extract enemy affix catalog
- #48 Expand permanent challenge goals
- #49 Add Autonomous Survivor branding assets and extract ability catalog
- #50 Extract player evolution catalog
- #51 Extract upgrade metadata catalog
- #52 Add late-campaign tank archetypes

### P1 - Replayability And Power Growth

- Content and progression targets are exceeded. Current counts: 100 unique upgrades, 40 powers, 22 tanks, 66 enemies, 29 bosses, 10 maps.
- The 30-minute balance projection passes with a documented strong-build clear-rate margin in `docs/BALANCE_30_MIN.md`.
- 30-minute survival now completes the run as a victory and unlocks the next map in the chain.
- Scrap Maze now has map-specific pressure scaling, six Scrapborn enemy variants, and three Scrap Maze bosses.
- Crystal Expanse, Toxic Foundry, and Void Crucible now add larger/different arenas, map gimmicks, 15 additional map-specific enemies, and 6 additional bosses.
- Moonlit Graveyard, Neon Grid, Frozen Scar, Ember Rift, and Astral Engine extend the victory chain with new backgrounds, obstacle groups, pressure profiles, gimmicks, 25 map-specific regular enemies, and 10 additional map-specific bosses.
- Late-chain victories now add five more run modifiers, bringing the modifier pool from 7 to 12 and making high-progression runs more varied.
- Challenge goals now have a focused catalog and 20 total goals, adding more late-run permanent rewards for survival, boss, elite, storm, economy, salvage, repair, siege, precision, and mobility builds.
- Run events now have a focused catalog and 10 total event variants, increasing seeded mid-run surprise variety without adding per-frame systems.
- Enemy affixes now have a focused catalog and 10 total variants, adding more late-run elite pressure patterns without new scenes.
- Late-campaign tank variety now includes Prism Sentinel and Void Anchor, adding crystal crit/ricochet and void gravity-control starts behind campaign-progress unlocks.

### P1 - Enemies And Bosses

- Enemy and boss count targets are met; future enemy/boss work should be balance or behavior depth, not raw count.

### P2 - Performance

- Active runtime registries now cover enemies, bosses, EXP orbs, projectiles, splash areas, boss hazards, and particle bursts so hot combat loops can avoid repeated whole-tree scans.
- Late-map enemy and boss data now live in focused catalog helpers instead of expanding the core gameplay controller, preserving behavior while improving editor readability.
- Autonomous tank and late-map config data now live in focused run-config catalog helpers, keeping `run_config.gd` smaller and easier to maintain.
- Run modifier data now lives in a focused catalog helper while `run_config.gd` keeps ownership of seed rolling, unlock filtering, and multiplier queries.
- Challenge goal data now lives in a focused catalog helper while `unlock_manager.gd` keeps ownership of save state, completion checks, and reward application.
- Run event data now lives in a focused catalog helper while `main.gd` keeps ownership of event scheduling, active multipliers, risk spawning, and rewards.
- Enemy affix data now lives in a focused catalog helper while `main.gd` keeps ownership of spawn rolling, pressure checks, stat application, and death payload execution.
- Ability selection data now lives in a focused catalog helper while `ability_menu.gd` keeps ownership of rolling, prerequisites, icons, and card presentation.
- Evolution data now lives in a focused player catalog helper while `player.gd` keeps ownership of requirement checks, active effect reads, and runtime feedback.
- Upgrade card metadata now lives in a focused catalog helper while `upgrade.gd` keeps ownership of valid choice rolling, rarity colors, icons, synergy display, and card presentation.
- Continue profiling dense late-game runs after challenge goals start pushing longer survival times.

### P2 - UI And Feedback

- Visual identity pass is complete enough for the current scope: generated arena/menu art, cartoon sprites, chunky UI, cloud shadows, player lighting, projectile trails, hit pops, and richer bursts are in-game.
- Project branding now includes a proper Autonomous Survivor app icon, boot splash logo, wordmark, and main-menu logo asset.
- Global juice pass added animated button press/hover feedback, brighter upgrade and ability celebration backgrounds, selection confetti bursts, projectile hit sparks, healing particles, splash reinforcement, and capped micro-shake on strong impacts.
- Continue improving individual power-specific animations after hands-on playtest feedback identifies weak effects.
- First in-game compendium and permanent unlock communication pass is complete; future work should refine content presentation and add more visual thumbnails where useful.
