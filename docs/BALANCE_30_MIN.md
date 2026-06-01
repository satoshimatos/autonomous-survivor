# 30-Minute Progression Balance Pass

This report records the current deterministic balance projection for the 30-minute survivor target. It is generated from `tools/balance_check.py`, which mirrors the enemy and boss catalogs from `scripts/core/main.gd` and models a coherent high-synergy player build using the formulas from `scripts/player/player.gd`.

The projection is not a substitute for a human playtest, but it is a fast regression check for the main design question: can enemy pressure keep escalating while a good build becomes overpowered enough to survive and clear the screen?

## Summary

Status: PASS

| Target | Result |
|---|---:|
| Enemy catalog | 20 / 20 |
| Boss catalog | 10 / 10 |
| Upgrade catalog | 50 / 50 |
| Ability / power catalog | 20 / 20 |
| 30-minute active enemy cap | 225 |
| 30-minute average regular spawn HP | 853.0 |
| 30-minute minimum spawn interval | 0.20s |
| Required regular clear rate at spawn cap | 5.0 kills/s |
| Projected strong-build direct clear rate | 37.2 kills/s |
| Projected strong-build direct DPS | 31,764 |

The 30-minute build has enough direct weapon output to exceed regular spawn pressure by about 7.4x before counting splash overlap, piercing value, mines, drones, fields, crowd-control uptime, or boss-focused power damage.

## Pressure Curve

| Time | Active Cap | Average HP | Top Enemy Mix | Top Boss Mix |
|---:|---:|---:|---|---|
| 0:00 | 85 | 12.0 | scout 100% | charger 100% |
| 5:00 | 125 | 27.5 | scout 45%, bruiser 17%, runner 16% | charger 100% |
| 10:00 | 165 | 67.5 | swarm 16%, bruiser 16%, runner 15% | bulwark 74%, charger 26% |
| 15:00 | 205 | 166.0 | swarm 17%, runner 13%, bruiser 12% | bulwark 45%, sprinter 41%, charger 14% |
| 20:00 | 225 | 336.1 | swarm 13%, orbiter 10%, runner 10% | bulwark 45%, sprinter 42%, charger 13% |
| 25:00 | 225 | 561.8 | swarm 11%, drifter 10%, orbiter 9% | sprinter 31%, bulwark 31%, crusher 29% |
| 30:00 | 225 | 853.0 | swarm 10%, drifter 9%, mirage 9% | sprinter 20%, wraith 19%, crusher 19% |

The pressure cap reaches its maximum at about 18 minutes and then difficulty continues through enemy health, damage, speed, elite affixes, enemy mix, boss mix, and boss ability complexity.

## Strong-Build Projection

This path assumes a player makes coherent damage, fire-rate, multishot, splash, precision, electric, and siege choices when offered. It intentionally represents a good run, not an average run.

| Time | Upgrade / Ability Picks | Avg HP | Direct DPS | Clear Rate | Required Rate | Projectile State | Status |
|---:|---:|---:|---:|---:|---:|---|---|
| 0:00 | 0 / 0 | 12.0 | 10 | 0.8/s | 0.7/s | 1 shot, 1 pierce, 0px splash | PASS |
| 5:00 | 11 / 2 | 27.5 | 93 | 3.4/s | 1.1/s | 3 shots, 2 pierce, 10px splash | PASS |
| 10:00 | 21 / 4 | 67.5 | 425 | 6.3/s | 2.2/s | 5 shots, 5 pierce, 44px splash | PASS |
| 15:00 | 31 / 6 | 166.0 | 1,604 | 9.7/s | 5.0/s | 7 shots, 5 pierce, 65px splash | PASS |
| 20:00 | 40 / 8 | 336.1 | 4,271 | 12.7/s | 5.0/s | 8 shots, 8 pierce, 76px splash | PASS |
| 25:00 | 48 / 10 | 561.8 | 11,612 | 20.7/s | 5.0/s | 10 shots, 8 pierce, 92px splash | PASS |
| 30:00 | 56 / 12 | 853.0 | 31,764 | 37.2/s | 5.0/s | 11 shots, 9 pierce, 94px splash | PASS |

## Synergy Notes

The modeled 30-minute build activates these major damage evolutions:

- Shrapnel Core
- Drone Foundry
- Critical Payload
- Siege Command
- Coil Reactor
- War Factory
- Breach Rounds
- Storm Battery

The table only credits direct projectile damage. The real run should be stronger because the following systems add additional clear and safety:

- Piercing lets each volley damage multiple enemies.
- Splash overlaps dense packs and scales with area multipliers.
- Drone Swarm, Missile Pod, Railgun Orbiter, Tesla Pylon, Chain Lightning, Gravity Well, and Chrono Burst keep damaging independently.
- Shock Field, Flame Wave, Tesla Pylon, Gravity Well, and Chrono Burst add slows or crowd-control.
- Guardian Satellite, Nanite Cloud, Repair Beacon, armor, and healing upgrades support longer survival.

## Tuning Decision

No gameplay constants were changed in this pass. The current enemy health curve is steep, but the 30-minute strong-build projection has large enough headroom to support the intended bullet-heaven fantasy while still punishing unfocused or underpowered builds.

Future tuning should focus on real-play feel:

- If average runs die too early, reduce early boss cadence or lower enemy damage growth.
- If strong runs become unreadable before 30 minutes, reduce active enemy cap or visual effect budgets before reducing build power.
- If strong runs still feel too hard at 25-30 minutes, reduce `ENEMY_HEALTH_BONUS_STEP` rather than lowering enemy variety.
