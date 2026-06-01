# Autonomous Survivor

Top-down tank survivor prototype built in Godot. The current design target is a replayable bullet-heaven loop: escalating enemy pressure, randomized upgrade choices, simple readable shapes, and strong upgrade synergies that can become intentionally overpowered when the player builds well.

GitHub issue tracker: https://github.com/satoshimatos/autonomous-survivor/issues

## Navigation

- [Game Compendium](docs/GAME_COMPENDIUM.md): open-book reference for mechanics, tanks, enemies, bosses, upgrades, abilities, evolutions, events, modifiers, unlocks, pickups, scaling, and budgets.
- [Backlog](BACKLOG.md): autonomous task queue and completed issue history.
- [Current Changelog](#current-changelog): latest implementation notes.

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

## Backlog

### Next

- Add the next power/ability batch toward 20 powers and stronger late-game build explosions.

### Content

- Add the next power/ability batch toward 20 powers and stronger late-game build explosions.

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
- Keep each autonomous run focused on the highest-value backlog item and record results here.
