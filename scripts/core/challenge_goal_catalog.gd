extends RefCounted


static func get_entries() -> Array[Dictionary]:
	return [
		{"id": "hold_the_line", "name": "Hold the Line", "metric": "survival_seconds", "threshold": 180, "reward_text": "+1 starting armor", "rewards": {"starting_armor_level": 1}},
		{"id": "boss_breaker", "name": "Boss Breaker", "metric": "bosses_defeated", "threshold": 1, "reward_text": "Overclock Cache modifier", "rewards": {"unlock_modifier": "overclock_cache"}},
		{"id": "elite_sweeper", "name": "Elite Sweeper", "metric": "elites_defeated", "threshold": 8, "reward_text": "+15% wrench drops", "rewards": {"wrench_drop_multiplier": 1.15}},
		{"id": "heavy_build", "name": "Heavy Build", "metric": "build_sum", "build_keys": ["damage", "fire_rate", "cannon"], "threshold": 7, "reward_text": "+1 starting damage", "rewards": {"starting_damage_level": 1}},
		{"id": "collector_build", "name": "Collector Build", "metric": "build_sum", "build_keys": ["magnet", "exp"], "threshold": 5, "reward_text": "+1 starting EXP", "rewards": {"starting_exp_level": 1}},
		{"id": "storm_build", "name": "Storm Build", "metric": "build_sum", "build_keys": ["volt_coils", "field_amplifier", "capacitor_bank"], "threshold": 4, "reward_text": "+1 starting magnet", "rewards": {"starting_magnet_level": 1}},
		{"id": "control_build", "name": "Control Build", "metric": "build_sum", "build_keys": ["gravity_anchor", "field_amplifier", "barbed_wire"], "threshold": 5, "reward_text": "+1 starting health", "rewards": {"starting_health_bonus": 1}},
		{"id": "marathon_plate", "name": "Marathon Plate", "metric": "survival_seconds", "threshold": 1800, "reward_text": "+1 starting health", "rewards": {"starting_health_bonus": 1}},
		{"id": "boss_harvester", "name": "Boss Harvester", "metric": "bosses_defeated", "threshold": 6, "reward_text": "+25% dynamite drops", "rewards": {"dynamite_drop_multiplier": 1.25}},
		{"id": "elite_recycler", "name": "Elite Recycler", "metric": "elites_defeated", "threshold": 20, "reward_text": "+20% wrench drops", "rewards": {"wrench_drop_multiplier": 1.2}},
		{"id": "storm_mastery", "name": "Storm Mastery", "metric": "build_sum", "build_keys": ["volt_coils", "field_amplifier", "capacitor_bank"], "threshold": 8, "reward_text": "+1 starting damage", "rewards": {"starting_damage_level": 1}},
		{"id": "magnet_empire", "name": "Magnet Empire", "metric": "build_sum", "build_keys": ["magnet", "exp"], "threshold": 9, "reward_text": "+1 starting magnet and +1 starting EXP", "rewards": {"starting_magnet_level": 1, "starting_exp_level": 1}},
	]
