"""Deterministic spawn-pressure projection for tuning.

This intentionally mirrors the data shape in scripts/core/main.gd without
booting Godot's scene runtime, so it can be run quickly during balance passes:

    python tools/balance_check.py
"""

from __future__ import annotations

BASE_ACTIVE_ENEMY_CAP = 85
MAX_ACTIVE_ENEMY_CAP = 225
ACTIVE_ENEMY_CAP_GROWTH_PER_MINUTE = 8.0
SAMPLE_SECONDS = [0.0, 120.0, 300.0, 600.0, 900.0, 1200.0, 1500.0, 1800.0, 2100.0, 2400.0, 2700.0, 3000.0]

ENEMIES = [
    {"id": "scout", "unlock": 0.0, "weight": 100.0, "growth": -7.0, "min": 4.0, "max": 100.0, "hp": 12.0},
    {"id": "bruiser", "unlock": 120.0, "weight": 20.0, "growth": 1.8, "min": 0.0, "max": 34.0, "hp": 22.0},
    {"id": "runner", "unlock": 180.0, "weight": 20.0, "growth": 1.8, "min": 0.0, "max": 36.0, "hp": 10.0},
    {"id": "shield", "unlock": 240.0, "weight": 12.0, "growth": 1.6, "min": 0.0, "max": 30.0, "hp": 48.0},
    {"id": "zigzag", "unlock": 300.0, "weight": 18.0, "growth": 1.7, "min": 0.0, "max": 34.0, "hp": 20.0},
    {"id": "swarm", "unlock": 360.0, "weight": 26.0, "growth": 2.2, "min": 0.0, "max": 48.0, "hp": 8.0},
    {"id": "stalker", "unlock": 480.0, "weight": 18.0, "growth": 1.8, "min": 0.0, "max": 36.0, "hp": 34.0},
    {"id": "orbiter", "unlock": 600.0, "weight": 18.0, "growth": 2.0, "min": 0.0, "max": 38.0, "hp": 42.0},
    {"id": "tank", "unlock": 720.0, "weight": 10.0, "growth": 1.2, "min": 0.0, "max": 22.0, "hp": 86.0},
    {"id": "drifter", "unlock": 840.0, "weight": 18.0, "growth": 2.4, "min": 0.0, "max": 42.0, "hp": 54.0},
    {"id": "lancer", "unlock": 960.0, "weight": 16.0, "growth": 1.8, "min": 0.0, "max": 36.0, "hp": 46.0},
    {"id": "phalanx", "unlock": 1080.0, "weight": 12.0, "growth": 1.4, "min": 0.0, "max": 28.0, "hp": 128.0},
    {"id": "mirage", "unlock": 1200.0, "weight": 20.0, "growth": 2.1, "min": 0.0, "max": 42.0, "hp": 32.0},
    {"id": "reaper", "unlock": 1440.0, "weight": 14.0, "growth": 1.7, "min": 0.0, "max": 34.0, "hp": 92.0},
    {"id": "comet", "unlock": 1680.0, "weight": 18.0, "growth": 2.0, "min": 0.0, "max": 40.0, "hp": 72.0},
    {"id": "viper", "unlock": 1860.0, "weight": 16.0, "growth": 2.0, "min": 0.0, "max": 38.0, "hp": 68.0},
    {"id": "bulldozer", "unlock": 1980.0, "weight": 10.0, "growth": 1.2, "min": 0.0, "max": 26.0, "hp": 180.0},
    {"id": "specter", "unlock": 2100.0, "weight": 18.0, "growth": 2.2, "min": 0.0, "max": 42.0, "hp": 58.0},
    {"id": "sapper", "unlock": 2220.0, "weight": 14.0, "growth": 1.8, "min": 0.0, "max": 34.0, "hp": 76.0},
    {"id": "voidling", "unlock": 2340.0, "weight": 20.0, "growth": 2.4, "min": 0.0, "max": 44.0, "hp": 88.0},
]

BOSSES = [
    {"id": "charger", "unlock": 0.0, "weight": 100.0, "growth": -8.0, "min": 20.0, "max": 100.0},
    {"id": "bulwark", "unlock": 420.0, "weight": 55.0, "growth": 1.0, "min": 0.0, "max": 70.0},
    {"id": "sprinter", "unlock": 840.0, "weight": 55.0, "growth": 1.5, "min": 0.0, "max": 75.0},
    {"id": "crusher", "unlock": 1260.0, "weight": 62.0, "growth": 1.2, "min": 0.0, "max": 82.0},
    {"id": "wraith", "unlock": 1680.0, "weight": 70.0, "growth": 1.5, "min": 0.0, "max": 90.0},
    {"id": "monarch", "unlock": 1800.0, "weight": 64.0, "growth": 1.4, "min": 0.0, "max": 86.0},
    {"id": "tempest", "unlock": 2100.0, "weight": 68.0, "growth": 1.5, "min": 0.0, "max": 88.0},
    {"id": "bastion", "unlock": 2400.0, "weight": 72.0, "growth": 1.2, "min": 0.0, "max": 92.0},
    {"id": "overlord", "unlock": 2700.0, "weight": 76.0, "growth": 1.2, "min": 0.0, "max": 94.0},
    {"id": "singularity", "unlock": 3000.0, "weight": 80.0, "growth": 1.1, "min": 0.0, "max": 96.0},
]


def main() -> None:
    print("BALANCE_CHECK deterministic pressure projection")
    for sample_time in SAMPLE_SECONDS:
        enemy_entries = unlocked_entries(ENEMIES, sample_time)
        boss_entries = unlocked_entries(BOSSES, sample_time)
        print(
            "t={time:04d}s cap={cap:03d} enemy_weight={enemy_weight:.1f} "
            "avg_hp={avg_hp:.1f} top_enemy={top_enemy} enemy_mix={enemy_mix} "
            "boss_weight={boss_weight:.1f} top_boss={top_boss} boss_mix={boss_mix}".format(
                time=int(sample_time),
                cap=active_enemy_cap(sample_time),
                enemy_weight=total_weight(enemy_entries),
                avg_hp=average_hp(enemy_entries, sample_time),
                top_enemy=top_id(enemy_entries),
                enemy_mix=mix_summary(enemy_entries),
                boss_weight=total_weight(boss_entries),
                top_boss=top_id(boss_entries),
                boss_mix=mix_summary(boss_entries),
            )
        )


def unlocked_entries(catalog: list[dict], sample_time: float) -> list[dict]:
    entries = []
    for config in catalog:
        if sample_time < config["unlock"]:
            continue
        minutes_since_unlock = max((sample_time - config["unlock"]) / 60.0, 0.0)
        weight = config["weight"] + minutes_since_unlock * config.get("growth", 0.0)
        weight = min(max(weight, config.get("min", 0.0)), config.get("max", weight))
        if weight > 0.0:
            entries.append({"config": config, "weight": weight})
    return entries


def active_enemy_cap(sample_time: float) -> int:
    cap = BASE_ACTIVE_ENEMY_CAP + int((sample_time / 60.0) * ACTIVE_ENEMY_CAP_GROWTH_PER_MINUTE)
    return min(max(cap, BASE_ACTIVE_ENEMY_CAP), MAX_ACTIVE_ENEMY_CAP)


def projected_health_bonus(sample_time: float) -> float:
    elapsed = 0.0
    bonus_step = 0.0
    bonus_total = 0.0
    while elapsed + 30.0 <= sample_time:
        elapsed += 30.0
        bonus_step += 0.01
        bonus_total += bonus_step
    return bonus_total


def average_hp(entries: list[dict], sample_time: float) -> float:
    if not entries:
        return 0.0
    weight_sum = total_weight(entries)
    weighted_hp = sum(entry["config"].get("hp", 0.0) * entry["weight"] for entry in entries)
    return weighted_hp / max(weight_sum, 0.001) * (1.0 + projected_health_bonus(sample_time))


def total_weight(entries: list[dict]) -> float:
    return sum(entry["weight"] for entry in entries)


def top_id(entries: list[dict]) -> str:
    if not entries:
        return "none"
    return max(entries, key=lambda entry: entry["weight"])["config"]["id"]


def mix_summary(entries: list[dict]) -> str:
    weight_sum = total_weight(entries)
    if weight_sum <= 0.0:
        return "none"
    sorted_entries = sorted(entries, key=lambda entry: entry["weight"], reverse=True)[:3]
    return ",".join(
        f"{entry['config']['id']}:{entry['weight'] / weight_sum:.0%}" for entry in sorted_entries
    )


if __name__ == "__main__":
    main()
