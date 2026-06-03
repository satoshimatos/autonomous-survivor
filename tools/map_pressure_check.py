"""Fast map pressure projection for the five-map campaign.

This complements balance_check.py by focusing on map-level spawn pressure,
enemy cap ceilings, and boss cadence. It intentionally stays lightweight so
autonomous map-content passes can run it often.
"""

from __future__ import annotations

BASE_ACTIVE_ENEMY_CAP = 85
ACTIVE_ENEMY_CAP_GROWTH_PER_MINUTE = 8.0
BASE_SPAWN_INTERVAL = 1.5
MIN_SPAWN_INTERVAL = 0.2
SPAWN_INTERVAL_REDUCTION_PER_LEVEL = 0.05
BASE_BOSS_INTERVAL = 180.0

MAPS = [
    {
        "id": "map1",
        "name": "Dust Bowl",
        "spawn": 1.0,
        "boss": 1.0,
        "speed": 1.0,
        "health": 1.0,
        "damage": 1.0,
        "cap_bonus": 0,
        "cap_limit": 225,
        "elite": 1.0,
    },
    {
        "id": "map2",
        "name": "Scrap Maze",
        "spawn": 0.78,
        "boss": 0.82,
        "speed": 1.12,
        "health": 1.18,
        "damage": 1.1,
        "cap_bonus": 35,
        "cap_limit": 225,
        "elite": 1.25,
    },
    {
        "id": "map3",
        "name": "Crystal Expanse",
        "spawn": 0.68,
        "boss": 0.72,
        "speed": 1.26,
        "health": 1.28,
        "damage": 1.18,
        "cap_bonus": 65,
        "cap_limit": 260,
        "elite": 1.45,
    },
    {
        "id": "map4",
        "name": "Toxic Foundry",
        "spawn": 0.58,
        "boss": 0.64,
        "speed": 1.18,
        "health": 1.42,
        "damage": 1.28,
        "cap_bonus": 95,
        "cap_limit": 295,
        "elite": 1.7,
    },
    {
        "id": "map5",
        "name": "Void Crucible",
        "spawn": 0.5,
        "boss": 0.48,
        "speed": 1.38,
        "health": 1.55,
        "damage": 1.38,
        "cap_bonus": 125,
        "cap_limit": 340,
        "elite": 2.05,
    },
]


def active_cap(map_config: dict, minute: float) -> int:
    raw_cap = BASE_ACTIVE_ENEMY_CAP + map_config["cap_bonus"] + int(minute * ACTIVE_ENEMY_CAP_GROWTH_PER_MINUTE)
    return max(BASE_ACTIVE_ENEMY_CAP, min(raw_cap, map_config["cap_limit"]))


def spawn_interval(map_config: dict, minute: float) -> float:
    base = BASE_SPAWN_INTERVAL - minute * SPAWN_INTERVAL_REDUCTION_PER_LEVEL
    return max(MIN_SPAWN_INTERVAL, base * map_config["spawn"])


def main() -> None:
    print("Map pressure projection")
    print("map,cap@30,spawn_interval@30,spawns_per_second@30,boss_interval,elite_multiplier,growth")
    for map_config in MAPS:
        interval = spawn_interval(map_config, 30.0)
        print(
            "{name},{cap},{interval:.2f},{sps:.2f},{boss:.1f}s,{elite:.2f},speed {speed:.2f} health {health:.2f} damage {damage:.2f}".format(
                name=map_config["name"],
                cap=active_cap(map_config, 30.0),
                interval=interval,
                sps=1.0 / interval,
                boss=BASE_BOSS_INTERVAL * map_config["boss"],
                elite=map_config["elite"],
                speed=map_config["speed"],
                health=map_config["health"],
                damage=map_config["damage"],
            )
        )


if __name__ == "__main__":
    main()
