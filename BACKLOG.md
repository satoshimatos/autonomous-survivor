# Autonomous Survivor Backlog

## Active Policy

Each autonomous run should:

1. Read this backlog and `README.md`.
2. Pick the highest-value task that preserves the original survivor/bullet-heaven scope.
3. Implement a small complete slice.
4. Run a Godot validation command.
5. Update `README.md` changelog and this backlog.

GitHub issues are now the primary task tracker: https://github.com/satoshimatos/autonomous-survivor/issues

## Priority Queue

### P0 - Project Operations

- Create GitHub repo `satoshimatos/autonomous-survivor`, push the current project, and create GitHub issues from this backlog.
- Keep project organization data-driven and avoid one scene per minor variant unless the behavior truly needs unique nodes.

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

### P1 - Replayability And Power Growth

- #22 Add final upgrade batch toward 50 unique upgrades.
- Add more upgrade and power branches until the project reaches at least 50 unique upgrades and 20 powers. Current counts: 41/50 unique upgrades, 16/20 powers.

### P1 - Enemies And Bosses

- Enemy and boss count targets are met; future enemy/boss work should be balance or behavior depth, not raw count.

### P2 - Performance

- Profile dense late-game runs after challenge goals start pushing longer survival times.

### P2 - UI And Feedback

- Continue improving upgrade and ability card readability as the build system grows.
