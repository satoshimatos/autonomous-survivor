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

### P1 - Replayability And Power Growth

- Add more challenge goals and meta-progression rewards after the first unlock pass.

### P1 - Enemies And Bosses

- Tune enemy spawn weights after short automated survival checks.

### P2 - Performance

- Tune active pressure caps after short automated survival checks.

### P2 - UI And Feedback

- #10 Improve upgrade cards with clearer synergy tags once the upgrade set grows.
