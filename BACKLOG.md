# Autonomous Survivor Backlog

## Active Policy

Each autonomous run should:

1. Read this backlog and `README.md`.
2. Pick the highest-value task that preserves the original survivor/bullet-heaven scope.
3. Implement a small complete slice.
4. Run a Godot validation command.
5. Update `README.md` changelog and this backlog.

## Priority Queue

### P0 - Project Operations

- Create GitHub repo `satoshimatos/autonomous-survivor`, push the current project, and create GitHub issues from this backlog.
- Keep project organization data-driven and avoid one scene per minor variant unless the behavior truly needs unique nodes.

### P1 - Replayability And Power Growth

- Add tank archetype selection with at least 5 starts.
- Add random run modifiers and deterministic run seed display.
- Add unlock progression for tanks, abilities, modifiers, and challenge goals.
- Add ability rarity, synergy tags, or weighted choices so late-game ability rolls can bias toward build-defining combos.

### P1 - Enemies And Bosses

- Expand boss behavior scripts with minion spawning, hazard drops, projectile rings, and phase transitions.
- Add elite affixes that can be applied to existing enemy variants at spawn time.
- Tune enemy spawn weights after short automated survival checks.

### P2 - Performance

- Pool projectiles and frequently spawned enemies.
- Add effect budgets for damage numbers, splash visuals, and particle bursts.
- Add spawn director caps based on active enemy count and frame pressure.

### P2 - UI And Feedback

- Add run summary details: build, seed, time survived, bosses defeated, damage dealt, and favorite upgrade.
- Improve upgrade cards with clearer synergy tags once the upgrade set grows.
