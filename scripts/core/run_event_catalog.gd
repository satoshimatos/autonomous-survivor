extends RefCounted


static func get_entries() -> Array[Dictionary]:
	return [
		{"id": "crystal_bloom", "name": "Crystal Bloom", "summary": "Richer EXP while enemy damage spikes.", "duration": 48.0, "weight": 28.0, "effects": {"exp_value_multiplier": 1.35, "enemy_damage_multiplier": 1.12}},
		{"id": "supply_cache", "name": "Supply Cache", "summary": "A cache drops offscreen.", "duration": 0.0, "weight": 24.0, "rewards": {"green_supply": 2, "blue_supply": 1}},
		{"id": "elite_bounty", "name": "Elite Bounty", "summary": "An elite wave arrives with an upgrade reward.", "duration": 0.0, "weight": 22.0, "risks": {"elite_wave_count": 5}, "rewards": {"upgrade_choices": 1}},
		{"id": "overrun_gambit", "name": "Overrun Gambit", "summary": "Enemy pressure surges, then grants an ability choice.", "duration": 36.0, "weight": 20.0, "effects": {"spawn_interval_multiplier": 0.72, "enemy_speed_multiplier": 1.1}, "rewards": {"ability_choices": 1}},
		{"id": "repair_convoy", "name": "Repair Convoy", "summary": "A supply convoy arrives under elite escort.", "duration": 0.0, "weight": 18.0, "risks": {"elite_wave_count": 3}, "rewards": {"green_supply": 3}},
		{"id": "blue_moon", "name": "Blue Moon", "summary": "A rare ability cache breaks through the chaos.", "duration": 0.0, "weight": 16.0, "rewards": {"blue_supply": 1, "ability_choices": 1}},
		{"id": "overclock_bloom", "name": "Overclock Bloom", "summary": "Spawn tempo and EXP value rise together before an upgrade payout.", "duration": 42.0, "weight": 17.0, "effects": {"spawn_interval_multiplier": 0.82, "enemy_speed_multiplier": 1.08, "exp_value_multiplier": 1.18}, "rewards": {"upgrade_choices": 1}},
		{"id": "siege_cache", "name": "Siege Cache", "summary": "A dangerous elite squad guards a compact upgrade cache.", "duration": 0.0, "weight": 15.0, "risks": {"elite_wave_count": 7}, "rewards": {"green_supply": 1, "upgrade_choices": 1}},
		{"id": "salvage_comet", "name": "Salvage Comet", "summary": "EXP and incoming damage surge while a blue cache drops.", "duration": 40.0, "weight": 16.0, "effects": {"exp_value_multiplier": 1.22, "enemy_damage_multiplier": 1.08}, "rewards": {"blue_supply": 1}},
		{"id": "blackout_rush", "name": "Blackout Rush", "summary": "A brutal short rush grants a fresh ability choice.", "duration": 32.0, "weight": 14.0, "effects": {"spawn_interval_multiplier": 0.64, "enemy_speed_multiplier": 1.18}, "rewards": {"green_supply": 1, "ability_choices": 1}},
		{"id": "magnet_storm", "name": "Magnet Storm", "summary": "A fast elite surge blows open a supply lane.", "duration": 34.0, "weight": 15.0, "effects": {"enemy_speed_multiplier": 1.16}, "risks": {"elite_wave_count": 4}, "rewards": {"green_supply": 2}},
		{"id": "power_market", "name": "Power Market", "summary": "A rare power broker trades pressure for an ability and blue cache.", "duration": 38.0, "weight": 13.0, "effects": {"enemy_damage_multiplier": 1.1, "spawn_interval_multiplier": 0.86}, "rewards": {"blue_supply": 1, "ability_choices": 1}},
		{"id": "repair_jubilee", "name": "Repair Jubilee", "summary": "Repair crates arrive while enemies harden for a short window.", "duration": 44.0, "weight": 14.0, "effects": {"enemy_damage_multiplier": 1.06}, "rewards": {"green_supply": 4}},
		{"id": "critical_front", "name": "Critical Front", "summary": "Dense pressure buys an upgrade payout and richer crystals.", "duration": 46.0, "weight": 12.0, "effects": {"spawn_interval_multiplier": 0.78, "exp_value_multiplier": 1.16}, "risks": {"elite_wave_count": 3}, "rewards": {"upgrade_choices": 1}},
		{"id": "boss_omen", "name": "Boss Omen", "summary": "A champion escort marks the arena before dropping a mixed cache.", "duration": 0.0, "weight": 11.0, "risks": {"elite_wave_count": 6}, "rewards": {"green_supply": 1, "blue_supply": 1}},
	]
