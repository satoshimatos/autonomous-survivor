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

### P1 - Replayability And Power Growth

- Content and progression targets are exceeded. Current counts: 100 unique upgrades, 40 powers, 26 enemies, 13 bosses.
- The 30-minute balance projection passes with a documented strong-build clear-rate margin in `docs/BALANCE_30_MIN.md`.
- 30-minute survival now completes the run as a victory and unlocks Scrap Maze, the second map.
- Scrap Maze now has map-specific pressure scaling, six Scrapborn enemy variants, and three Scrap Maze bosses.

### P1 - Enemies And Bosses

- Enemy and boss count targets are met; future enemy/boss work should be balance or behavior depth, not raw count.

### P2 - Performance

- Active runtime registries now cover enemies, bosses, EXP orbs, projectiles, splash areas, boss hazards, and particle bursts so hot combat loops can avoid repeated whole-tree scans.
- Continue profiling dense late-game runs after challenge goals start pushing longer survival times.

### P2 - UI And Feedback

- Visual identity pass is complete enough for the current scope: generated arena/menu art, cartoon sprites, chunky UI, cloud shadows, player lighting, projectile trails, hit pops, and richer bursts are in-game.
- Continue improving individual power-specific animations after hands-on playtest feedback identifies weak effects.
- First in-game compendium and permanent unlock communication pass is complete; future work should refine content presentation and add more visual thumbnails where useful.
