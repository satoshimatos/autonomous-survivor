"""Deterministic 30-minute progression projection for tuning.

This intentionally mirrors the data shape in scripts/core/main.gd without
booting Godot's scene runtime, so it can be run quickly during balance passes:

    python tools/balance_check.py

The output is not a replacement for playtesting. It is a conservative
spreadsheet-style pass that checks whether the spawn-pressure curve and a
coherent synergistic build can coexist through the 30-minute target.
"""

from __future__ import annotations

BASE_ACTIVE_ENEMY_CAP = 85
MAX_ACTIVE_ENEMY_CAP = 225
ACTIVE_ENEMY_CAP_GROWTH_PER_MINUTE = 8.0
BASE_SPAWN_INTERVAL = 1.5
MIN_SPAWN_INTERVAL = 0.2
SPAWN_INTERVAL_REDUCTION_PER_LEVEL = 0.05
SAMPLE_SECONDS = [
    0.0,
    120.0,
    300.0,
    600.0,
    900.0,
    1200.0,
    1500.0,
    1800.0,
    2100.0,
    2400.0,
    2700.0,
    3000.0,
]
BUILD_SAMPLE_SECONDS = [0.0, 300.0, 600.0, 900.0, 1200.0, 1500.0, 1800.0]

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

STRONG_BUILD_SNAPSHOTS = {
    0: {
        "upgrade_picks": 0,
        "ability_picks": 0,
        "damage": 0,
        "fire_rate": 0,
        "high_caliber": 0,
        "overclocked_barrel": 0,
        "rapid_loader": 0,
        "heat_sinks": 0,
        "cannon": 0,
        "ammo_synthesizer": 0,
        "munition_printer": 0,
        "splash": 0,
        "piercing": 0,
        "payload_rack": 0,
        "shatter_rounds": 0,
        "phase_core": 0,
        "armor_piercers": 0,
        "targeting_array": 0,
        "rail_stabilizer": 0,
        "weakpoint_scanner": 0,
        "capacitor_bank": 0,
        "volt_coils": 0,
        "field_amplifier": 0,
        "ordnance_bay": 0,
        "missile_guidance": 0,
        "combustion_mix": 0,
        "gravity_anchor": 0,
        "orbit_gears": 0,
        "drone_command": 0,
        "abilities": {},
    },
    300: {
        "upgrade_picks": 11,
        "ability_picks": 2,
        "damage": 3,
        "fire_rate": 3,
        "high_caliber": 0,
        "overclocked_barrel": 0,
        "rapid_loader": 0,
        "heat_sinks": 0,
        "cannon": 2,
        "ammo_synthesizer": 0,
        "munition_printer": 0,
        "splash": 1,
        "piercing": 1,
        "payload_rack": 0,
        "shatter_rounds": 0,
        "phase_core": 0,
        "armor_piercers": 0,
        "targeting_array": 0,
        "rail_stabilizer": 0,
        "weakpoint_scanner": 0,
        "capacitor_bank": 0,
        "volt_coils": 0,
        "field_amplifier": 0,
        "ordnance_bay": 0,
        "missile_guidance": 0,
        "combustion_mix": 0,
        "gravity_anchor": 0,
        "orbit_gears": 0,
        "drone_command": 0,
        "abilities": {"drone_swarm": 1, "shock_field": 1},
    },
    600: {
        "upgrade_picks": 21,
        "ability_picks": 4,
        "damage": 4,
        "fire_rate": 4,
        "high_caliber": 1,
        "overclocked_barrel": 1,
        "rapid_loader": 1,
        "heat_sinks": 0,
        "cannon": 3,
        "ammo_synthesizer": 1,
        "munition_printer": 0,
        "splash": 3,
        "piercing": 2,
        "payload_rack": 1,
        "shatter_rounds": 0,
        "phase_core": 0,
        "armor_piercers": 0,
        "targeting_array": 1,
        "rail_stabilizer": 0,
        "weakpoint_scanner": 0,
        "capacitor_bank": 1,
        "volt_coils": 0,
        "field_amplifier": 0,
        "ordnance_bay": 0,
        "missile_guidance": 0,
        "combustion_mix": 1,
        "gravity_anchor": 0,
        "orbit_gears": 0,
        "drone_command": 1,
        "abilities": {"drone_swarm": 2, "shock_field": 2, "landmine": 1, "flame_wave": 1},
    },
    900: {
        "upgrade_picks": 31,
        "ability_picks": 6,
        "damage": 5,
        "fire_rate": 5,
        "high_caliber": 2,
        "overclocked_barrel": 2,
        "rapid_loader": 2,
        "heat_sinks": 1,
        "cannon": 4,
        "ammo_synthesizer": 2,
        "munition_printer": 1,
        "splash": 3,
        "piercing": 2,
        "payload_rack": 3,
        "shatter_rounds": 1,
        "phase_core": 1,
        "armor_piercers": 1,
        "targeting_array": 3,
        "rail_stabilizer": 1,
        "weakpoint_scanner": 0,
        "capacitor_bank": 2,
        "volt_coils": 1,
        "field_amplifier": 1,
        "ordnance_bay": 1,
        "missile_guidance": 0,
        "combustion_mix": 2,
        "gravity_anchor": 0,
        "orbit_gears": 0,
        "drone_command": 2,
        "abilities": {
            "drone_swarm": 2,
            "shock_field": 2,
            "landmine": 1,
            "flame_wave": 1,
            "chain_lightning": 1,
            "missile_pod": 1,
        },
    },
    1200: {
        "upgrade_picks": 40,
        "ability_picks": 8,
        "damage": 6,
        "fire_rate": 6,
        "high_caliber": 3,
        "overclocked_barrel": 3,
        "rapid_loader": 3,
        "heat_sinks": 2,
        "cannon": 5,
        "ammo_synthesizer": 3,
        "munition_printer": 2,
        "splash": 3,
        "piercing": 3,
        "payload_rack": 3,
        "shatter_rounds": 2,
        "phase_core": 2,
        "armor_piercers": 2,
        "targeting_array": 3,
        "rail_stabilizer": 2,
        "weakpoint_scanner": 1,
        "capacitor_bank": 3,
        "volt_coils": 2,
        "field_amplifier": 2,
        "ordnance_bay": 2,
        "missile_guidance": 1,
        "combustion_mix": 2,
        "gravity_anchor": 1,
        "orbit_gears": 1,
        "drone_command": 2,
        "abilities": {
            "drone_swarm": 3,
            "shock_field": 3,
            "landmine": 1,
            "flame_wave": 2,
            "chain_lightning": 2,
            "missile_pod": 2,
            "railgun_orbiter": 1,
            "tesla_pylon": 1,
        },
    },
    1500: {
        "upgrade_picks": 48,
        "ability_picks": 10,
        "damage": 7,
        "fire_rate": 7,
        "high_caliber": 4,
        "overclocked_barrel": 3,
        "rapid_loader": 4,
        "heat_sinks": 3,
        "cannon": 5,
        "ammo_synthesizer": 4,
        "munition_printer": 3,
        "splash": 4,
        "piercing": 3,
        "payload_rack": 3,
        "shatter_rounds": 3,
        "phase_core": 2,
        "armor_piercers": 3,
        "targeting_array": 3,
        "rail_stabilizer": 3,
        "weakpoint_scanner": 2,
        "capacitor_bank": 3,
        "volt_coils": 3,
        "field_amplifier": 3,
        "ordnance_bay": 3,
        "missile_guidance": 2,
        "combustion_mix": 3,
        "gravity_anchor": 2,
        "orbit_gears": 2,
        "drone_command": 3,
        "abilities": {
            "drone_swarm": 3,
            "shock_field": 3,
            "landmine": 1,
            "flame_wave": 3,
            "chain_lightning": 3,
            "missile_pod": 3,
            "railgun_orbiter": 2,
            "tesla_pylon": 2,
            "gravity_well": 1,
            "chrono_burst": 1,
        },
    },
    1800: {
        "upgrade_picks": 56,
        "ability_picks": 12,
        "damage": 8,
        "fire_rate": 8,
        "high_caliber": 4,
        "overclocked_barrel": 4,
        "rapid_loader": 4,
        "heat_sinks": 4,
        "cannon": 5,
        "ammo_synthesizer": 4,
        "munition_printer": 3,
        "splash": 4,
        "piercing": 4,
        "payload_rack": 3,
        "shatter_rounds": 3,
        "phase_core": 3,
        "armor_piercers": 3,
        "targeting_array": 3,
        "rail_stabilizer": 3,
        "weakpoint_scanner": 3,
        "capacitor_bank": 4,
        "volt_coils": 3,
        "field_amplifier": 3,
        "ordnance_bay": 3,
        "missile_guidance": 3,
        "combustion_mix": 3,
        "gravity_anchor": 3,
        "orbit_gears": 3,
        "drone_command": 3,
        "abilities": {
            "drone_swarm": 3,
            "shock_field": 3,
            "landmine": 1,
            "flame_wave": 3,
            "chain_lightning": 3,
            "missile_pod": 3,
            "railgun_orbiter": 3,
            "tesla_pylon": 3,
            "gravity_well": 2,
            "chrono_burst": 2,
            "guardian_satellite": 1,
            "nanite_cloud": 1,
        },
    },
}

EVOLUTIONS = [
    ("shrapnel_core", {"damage": 4, "splash": 3, "piercing": 2}),
    ("drone_foundry", {"drone_swarm": 2, "cannon": 3, "fire_rate": 4}),
    ("critical_payload", {"targeting_array": 3, "payload_rack": 3, "damage": 4}),
    ("storm_grid", {"chain_lightning": 3, "shock_field": 3, "freeze_pulse": 2}),
    ("siege_command", {"missile_pod": 3, "railgun_orbiter": 3, "targeting_array": 3}),
    ("singularity_engine", {"gravity_well": 3, "flame_wave": 3, "combustion_mix": 2}),
    ("coil_reactor", {"volt_coils": 3, "capacitor_bank": 3, "chain_lightning": 3}),
    ("war_factory", {"ordnance_bay": 3, "missile_guidance": 3, "munition_printer": 3}),
    ("death_orbit", {"orbit_gears": 3, "circular_saw": 3, "guardian_satellite": 3}),
    ("breach_rounds", {"armor_piercers": 3, "weakpoint_scanner": 3, "railgun_orbiter": 2}),
    ("time_cage", {"chrono_burst": 3, "gravity_well": 3, "field_amplifier": 3}),
    ("storm_battery", {"tesla_pylon": 3, "volt_coils": 3, "chain_lightning": 3}),
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
    print()
    print("BALANCE_CHECK 30-minute synergistic-build projection")
    build_checks = []
    for sample_time in BUILD_SAMPLE_SECONDS:
        snapshot = STRONG_BUILD_SNAPSHOTS[int(sample_time)]
        metrics = build_metrics(snapshot)
        avg_hp = average_hp(unlocked_entries(ENEMIES, sample_time), sample_time)
        spawn_interval = projected_spawn_interval(snapshot["upgrade_picks"])
        required_kills_per_second = 1.0 / spawn_interval
        projected_kills_per_second = metrics["direct_dps"] / max(avg_hp, 1.0)
        build_checks.append(projected_kills_per_second >= required_kills_per_second * 1.25)
        print(
            "t={time:04d}s picks={picks:02d}/{abilities:02d} spawn={spawn:.2f}s "
            "avg_hp={avg_hp:.1f} shot={shot:.1f} volley={volley:.0f} "
            "direct_dps={dps:.0f} kps={kps:.1f}/{required_kps:.1f} "
            "projectiles={projectiles} pierce={pierce} splash={splash:.0f}px "
            "crit={crit:.0%} evolutions={evolutions} status={status}".format(
                time=int(sample_time),
                picks=int(snapshot["upgrade_picks"]),
                abilities=int(snapshot["ability_picks"]),
                spawn=spawn_interval,
                avg_hp=avg_hp,
                shot=metrics["projectile_damage"],
                volley=metrics["volley_damage"],
                dps=metrics["direct_dps"],
                kps=projected_kills_per_second,
                required_kps=required_kills_per_second,
                projectiles=metrics["projectile_count"],
                pierce=metrics["pierce"],
                splash=metrics["splash_radius"],
                crit=metrics["expected_crit_bonus"] - 1.0,
                evolutions=metrics["evolution_summary"],
                status="PASS" if build_checks[-1] else "REVIEW",
            )
        )

    print()
    print("BALANCE_CHECK summary")
    print(f"content enemies={len(ENEMIES)}/20 bosses={len(BOSSES)}/10")
    print(
        "progression_30m={status} final_direct_dps={dps:.0f} final_avg_hp={hp:.1f} "
        "final_kps={kps:.1f} required_spawn_kps={required:.1f}".format(
            status="PASS" if all(build_checks[-4:]) else "REVIEW",
            dps=build_metrics(STRONG_BUILD_SNAPSHOTS[1800])["direct_dps"],
            hp=average_hp(unlocked_entries(ENEMIES, 1800.0), 1800.0),
            kps=build_metrics(STRONG_BUILD_SNAPSHOTS[1800])["direct_dps"]
            / max(average_hp(unlocked_entries(ENEMIES, 1800.0), 1800.0), 1.0),
            required=1.0 / projected_spawn_interval(STRONG_BUILD_SNAPSHOTS[1800]["upgrade_picks"]),
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


def projected_spawn_interval(upgrade_picks: int) -> float:
    return max(
        BASE_SPAWN_INTERVAL - float(upgrade_picks) * SPAWN_INTERVAL_REDUCTION_PER_LEVEL,
        MIN_SPAWN_INTERVAL,
    )


def build_metrics(snapshot: dict) -> dict:
    attack_damage = (
        10.0
        * pow(1.2925, snapshot["damage"])
        * pow(1.12, snapshot["high_caliber"])
        * pow(1.07, snapshot["overclocked_barrel"])
    )
    fire_interval = (
        1.0
        * pow(0.885, snapshot["fire_rate"])
        * pow(0.94, snapshot["rapid_loader"])
        * pow(0.965, snapshot["heat_sinks"])
        * pow(0.97, snapshot["overclocked_barrel"])
    )
    projectile_count = (
        1
        + snapshot["cannon"]
        + snapshot["ammo_synthesizer"] // 2
        + snapshot["munition_printer"] // 3
    )
    pierce = (
        snapshot["piercing"]
        + 1
        + snapshot["phase_core"] // 2
        + snapshot["armor_piercers"] // 2
    )
    splash_radius = (
        (10.0 + max(snapshot["splash"] - 1, 0) * 5.0 if snapshot["splash"] > 0 else 0.0)
        + snapshot["payload_rack"] * 6.0
        + snapshot["shatter_rounds"] * 4.0
        + snapshot["ordnance_bay"] * 5.0
        + snapshot["missile_guidance"] * 2.0
    )
    area_multiplier = (
        1.0 + snapshot["combustion_mix"] * 0.065 + snapshot["gravity_anchor"] * 0.04
    )
    power_multiplier = (
        1.0 + snapshot["capacitor_bank"] * 0.055 + snapshot["volt_coils"] * 0.03
    )
    projectile_multiplier = power_multiplier * (1.0 + snapshot["armor_piercers"] * 0.045)
    crit_chance = min(
        snapshot["targeting_array"] * 0.04
        + snapshot["rail_stabilizer"] * 0.025
        + snapshot["weakpoint_scanner"] * 0.018,
        0.75,
    )
    crit_multiplier = 1.5 + snapshot["weakpoint_scanner"] * 0.06 if snapshot["targeting_array"] > 0 else 1.0
    evolution_ids = active_evolutions(snapshot)
    if "shrapnel_core" in evolution_ids:
        projectile_multiplier *= 1.2
        pierce += 2
        splash_radius += 18.0
    if "drone_foundry" in evolution_ids:
        projectile_multiplier *= 1.1
        projectile_count += 1
    if "critical_payload" in evolution_ids:
        crit_chance = min(crit_chance + 0.12, 0.75)
        crit_multiplier += 0.35
        area_multiplier *= 1.2
    if "siege_command" in evolution_ids:
        projectile_multiplier *= 1.12
    if "war_factory" in evolution_ids:
        projectile_count += 1
        area_multiplier *= 1.14
    if "breach_rounds" in evolution_ids:
        projectile_multiplier *= 1.16
        crit_multiplier += 0.25
    if "singularity_engine" in evolution_ids:
        area_multiplier *= 1.12
    if "time_cage" in evolution_ids:
        area_multiplier *= 1.1
    if "coil_reactor" in evolution_ids or "storm_battery" in evolution_ids:
        power_multiplier += 0.08
        projectile_multiplier *= 1.08

    expected_crit_bonus = 1.0 + crit_chance * max(crit_multiplier - 1.0, 0.0)
    projectile_damage = attack_damage * projectile_multiplier * expected_crit_bonus
    volley_damage = projectile_damage * projectile_count
    direct_dps = volley_damage / max(fire_interval, 0.05)
    control_score = control_power_score(snapshot, evolution_ids)
    sustain_score = sustain_power_score(snapshot)
    return {
        "attack_damage": attack_damage,
        "fire_interval": fire_interval,
        "projectile_count": projectile_count,
        "pierce": pierce,
        "splash_radius": splash_radius,
        "area_multiplier": area_multiplier,
        "power_multiplier": power_multiplier,
        "expected_crit_bonus": expected_crit_bonus,
        "projectile_damage": projectile_damage,
        "volley_damage": volley_damage,
        "direct_dps": direct_dps,
        "control_score": control_score,
        "sustain_score": sustain_score,
        "evolution_summary": ",".join(evolution_ids[:4]) if evolution_ids else "none",
    }


def active_evolutions(snapshot: dict) -> list[str]:
    active = []
    for evolution_id, requirements in EVOLUTIONS:
        if all(build_level(snapshot, key) >= value for key, value in requirements.items()):
            active.append(evolution_id)
    return active


def build_level(snapshot: dict, key: str) -> int:
    if key in snapshot:
        return int(snapshot[key])
    return int(snapshot.get("abilities", {}).get(key, 0))


def control_power_score(snapshot: dict, evolution_ids: list[str]) -> int:
    abilities = snapshot.get("abilities", {})
    score = (
        abilities.get("shock_field", 0)
        + abilities.get("flame_wave", 0)
        + abilities.get("chain_lightning", 0)
        + abilities.get("gravity_well", 0) * 2
        + abilities.get("tesla_pylon", 0)
        + abilities.get("chrono_burst", 0) * 2
    )
    if "storm_grid" in evolution_ids or "time_cage" in evolution_ids:
        score += 3
    return int(score)


def sustain_power_score(snapshot: dict) -> int:
    abilities = snapshot.get("abilities", {})
    return int(
        snapshot.get("armor", 0)
        + snapshot.get("alloy_plating", 0)
        + snapshot.get("repair_drones", 0)
        + abilities.get("repair_beacon", 0) * 2
        + abilities.get("nanite_cloud", 0) * 2
    )


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
