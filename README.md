# Autonomous Survivor

Top-down tank survivor prototype built in Godot. The current design target is a replayable bullet-heaven loop: escalating enemy pressure, randomized upgrade choices, simple readable shapes, and strong upgrade synergies that can become intentionally overpowered when the player builds well.

GitHub issue tracker: https://github.com/satoshimatos/autonomous-survivor/issues

## Current Changelog

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

## Backlog

### Next

- Add run modifiers so each run starts with a random rule twist, such as richer elites, faster EXP, low visibility, or double bosses.
- Add ability rarity, synergy tags, or weighted choices so late-game ability rolls can bias toward build-defining combos.

### Content

- Add elite enemy affixes using lightweight modifiers instead of many duplicate scenes.
- Expand boss behaviors beyond stat profiles with minion calls, projectile rings, arena hazards, and phase changes.
- Add unlock goals for tanks, abilities, and run modifiers.

### Systems

- Keep enemy, boss, upgrade, and ability definitions data-driven so tuning does not require scene duplication.
- Add object pools for projectiles, ability effects, and common enemies as counts rise.
- Add deterministic run seeds and show the seed on the defeat screen.
- Add balancing telemetry for run time, chosen upgrades, enemy kills, boss kills, damage dealt, and damage taken.

### Testing

- Maintain Godot headless scene-load checks after each implementation slice.
- Add lightweight script-level tests for weighted spawn tables and upgrade math if the project gains a test harness.

## Scope Rules

- Favor simple shapes and clear silhouettes until the gameplay loop is stable.
- Prioritize performance and organization over visual polish.
- Prefer reusable data/config systems for enemies, bosses, upgrades, abilities, tanks, and run modifiers.
- Keep each autonomous run focused on the highest-value backlog item and record results here.
