extends Node

var selected_tank_id: String = "vanguard"

var tank_archetypes: Array[Dictionary] = [
	{
		"id": "vanguard",
		"name": "Vanguard",
		"summary": "Balanced starter tank with no extremes.",
		"speed_multiplier": 1.0,
		"health_bonus": 0,
		"damage_multiplier": 1.0,
		"fire_interval_multiplier": 1.0,
		"color": Color(1.0, 1.0, 1.0, 1.0),
	},
	{
		"id": "scout",
		"name": "Scout",
		"summary": "Fast and fragile with better pickup reach.",
		"speed_multiplier": 1.28,
		"health_bonus": -2,
		"damage_multiplier": 0.92,
		"magnet_level": 1,
		"color": Color(0.42, 0.9, 1.0, 1.0),
	},
	{
		"id": "fortress",
		"name": "Fortress",
		"summary": "Slow, tanky, and armored.",
		"speed_multiplier": 0.82,
		"health_bonus": 8,
		"armor_level": 2,
		"damage_multiplier": 1.08,
		"color": Color(0.62, 0.7, 0.72, 1.0),
	},
	{
		"id": "twin_cannon",
		"name": "Twin Cannon",
		"summary": "Starts with an extra barrel and lower base damage.",
		"speed_multiplier": 0.95,
		"damage_multiplier": 0.88,
		"cannon_level": 1,
		"fire_interval_multiplier": 1.08,
		"color": Color(1.0, 0.72, 0.28, 1.0),
	},
	{
		"id": "engineer",
		"name": "Engineer",
		"summary": "Device specialist with mines and oil slicks.",
		"speed_multiplier": 0.94,
		"health_bonus": 2,
		"landmine_level": 1,
		"oil_slick_level": 1,
		"color": Color(0.58, 1.0, 0.5, 1.0),
	},
	{
		"id": "collector",
		"name": "Collector",
		"summary": "Economy tank that levels quickly and vacuums EXP.",
		"speed_multiplier": 1.05,
		"health_bonus": -1,
		"exp_bonus_level": 1,
		"magnet_level": 2,
		"damage_multiplier": 0.95,
		"color": Color(0.92, 0.62, 1.0, 1.0),
	},
]


func get_selected_tank() -> Dictionary:
	return get_tank_by_id(selected_tank_id)


func get_tank_by_id(tank_id: String) -> Dictionary:
	for tank in tank_archetypes:
		if String(tank.id) == tank_id:
			return tank
	return tank_archetypes[0]


func set_selected_tank(tank_id: String) -> void:
	selected_tank_id = get_tank_by_id(tank_id).id
