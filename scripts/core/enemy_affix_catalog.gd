extends RefCounted


static func get_entries() -> Array[Dictionary]:
	return [
		{"id": "hasty", "name": "Hasty", "unlock_seconds": 90.0, "weight": 28.0, "speed_multiplier": 1.45, "health_multiplier": 0.85, "color": Color(1.0, 0.95, 0.16, 1.0)},
		{"id": "armored", "name": "Armored", "unlock_seconds": 150.0, "weight": 24.0, "speed_multiplier": 0.82, "health_multiplier": 1.85, "scale_multiplier": 1.12, "color": Color(0.62, 0.72, 0.84, 1.0)},
		{"id": "glass", "name": "Glass", "unlock_seconds": 180.0, "weight": 18.0, "speed_multiplier": 1.28, "health_multiplier": 0.55, "damage_multiplier": 1.65, "exp_drop_multiplier": 1.25, "color": Color(0.72, 0.95, 1.0, 1.0)},
		{"id": "rich", "name": "Rich", "unlock_seconds": 210.0, "weight": 18.0, "health_multiplier": 1.2, "exp_drop_multiplier": 2.4, "exp_drop_min_tier_bonus": 1, "color": Color(0.46, 1.0, 0.35, 1.0)},
		{"id": "bulwark", "name": "Bulwark", "unlock_seconds": 270.0, "weight": 14.0, "speed_multiplier": 0.58, "health_multiplier": 2.8, "damage_multiplier": 1.2, "scale_multiplier": 1.24, "exp_drop_multiplier": 1.35, "color": Color(0.38, 0.48, 0.58, 1.0)},
		{"id": "volatile", "name": "Volatile", "unlock_seconds": 300.0, "weight": 16.0, "speed_multiplier": 1.18, "health_multiplier": 0.9, "death_effect": "volatile", "death_radius": 92.0, "death_damage": 34.0, "color": Color(1.0, 0.18, 0.08, 1.0)},
		{"id": "overcharged", "name": "Overcharged", "unlock_seconds": 360.0, "weight": 14.0, "speed_multiplier": 1.22, "health_multiplier": 1.1, "damage_multiplier": 1.25, "death_effect": "volatile", "death_radius": 72.0, "death_damage": 22.0, "color": Color(0.2, 0.9, 1.0, 1.0)},
		{"id": "splitting", "name": "Splitting", "unlock_seconds": 420.0, "weight": 14.0, "health_multiplier": 1.35, "death_effect": "split", "split_count": 2, "split_health": 8, "split_speed": 82.0, "color": Color(0.95, 0.36, 1.0, 1.0)},
		{"id": "brood", "name": "Brood", "unlock_seconds": 540.0, "weight": 10.0, "health_multiplier": 1.1, "death_effect": "split", "split_count": 3, "split_health": 6, "split_speed": 96.0, "color": Color(0.9, 0.32, 0.72, 1.0)},
		{"id": "champion", "name": "Champion", "unlock_seconds": 720.0, "weight": 8.0, "speed_multiplier": 1.08, "health_multiplier": 2.2, "damage_multiplier": 1.45, "scale_multiplier": 1.18, "exp_drop_multiplier": 2.0, "exp_drop_min_tier_bonus": 1, "color": Color(1.0, 0.72, 0.18, 1.0)},
	]
