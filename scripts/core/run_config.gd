extends Node

var selected_tank_id: String = "vanguard"
var selected_map_id: String = "map1"
var run_seed_text: String = ""
var active_run_modifiers: Array[Dictionary] = []

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
	{
		"id": "storm_chaser",
		"name": "Storm Chaser",
		"summary": "A fast electric raider that starts with Shock Field and Chain Lightning pressure.",
		"speed_multiplier": 1.18,
		"health_bonus": -1,
		"damage_multiplier": 0.96,
		"shock_field_level": 1,
		"chain_lightning_level": 1,
		"color": Color(0.25, 0.88, 1.0, 1.0),
	},
	{
		"id": "pyroclast",
		"name": "Pyroclast",
		"summary": "Burn-and-blast tank that opens with Flame Wave and stronger splash scaling.",
		"speed_multiplier": 0.94,
		"health_bonus": 2,
		"damage_multiplier": 1.04,
		"splash_level": 1,
		"flame_wave_level": 1,
		"color": Color(1.0, 0.38, 0.12, 1.0),
	},
	{
		"id": "medic",
		"name": "Medic",
		"summary": "Support tank with stronger sustain, repair tools, and gentler early survival.",
		"speed_multiplier": 0.98,
		"health_bonus": 4,
		"regeneration_level": 1,
		"repair_beacon_level": 1,
		"nanite_cloud_level": 1,
		"color": Color(0.55, 1.0, 0.72, 1.0),
	},
	{
		"id": "singularity_rig",
		"name": "Singularity Rig",
		"summary": "Late-game control tank that starts slow but bends crowds with Gravity Well.",
		"speed_multiplier": 0.86,
		"health_bonus": 5,
		"damage_multiplier": 1.08,
		"gravity_well_level": 1,
		"capacitor_bank_level": 1,
		"color": Color(0.78, 0.46, 1.0, 1.0),
	},
]

var map_catalog: Array[Dictionary] = [
	{
		"id": "map1",
		"name": "Dust Bowl",
		"summary": "Open starter arena with no interior blockers.",
	},
	{
		"id": "map2",
		"name": "Scrap Maze",
		"summary": "Larger arena with wreckage lanes that block tanks and enemies.",
	},
]

var run_modifier_catalog: Array[Dictionary] = [
	{
		"id": "swarm_opening",
		"name": "Swarm Opening",
		"summary": "More early pressure, but weaker small enemies.",
		"spawn_interval_multiplier": 0.72,
		"enemy_health_growth_multiplier": 0.92,
	},
	{
		"id": "rich_crystals",
		"name": "Rich Crystals",
		"summary": "More EXP value, but enemy damage ramps harder.",
		"exp_value_multiplier": 1.28,
		"enemy_damage_growth_multiplier": 1.2,
	},
	{
		"id": "supply_rain",
		"name": "Supply Rain",
		"summary": "Supply boxes are more common during the run.",
		"supply_box_interval_multiplier": 0.72,
		"supply_box_chance_multiplier": 2.4,
	},
	{
		"id": "boss_contract",
		"name": "Boss Contract",
		"summary": "Bosses arrive far more often and drop richer rewards.",
		"boss_spawn_interval_multiplier": 0.55,
		"boss_exp_multiplier": 1.45,
	},
	{
		"id": "unstable_engine",
		"name": "Unstable Engine",
		"summary": "Faster weapon tempo, faster enemy speed scaling.",
		"player_fire_interval_multiplier": 0.88,
		"enemy_speed_growth_multiplier": 1.25,
	},
	{
		"id": "salvage_field",
		"name": "Salvage Field",
		"summary": "More wrench and dynamite drops, but less supply support.",
		"wrench_drop_multiplier": 1.75,
		"dynamite_drop_multiplier": 2.0,
		"supply_box_chance_multiplier": 0.65,
	},
	{
		"id": "overclock_cache",
		"name": "Overclock Cache",
		"summary": "A challenge reward modifier with faster weapons and lower pickup support.",
		"player_fire_interval_multiplier": 0.9,
		"supply_box_chance_multiplier": 0.8,
	},
]


func get_selected_tank() -> Dictionary:
	if not get_unlock_manager().is_tank_unlocked(selected_tank_id):
		selected_tank_id = get_first_unlocked_tank_id()
	return get_tank_by_id(selected_tank_id)


func get_tank_by_id(tank_id: String) -> Dictionary:
	for tank in tank_archetypes:
		if String(tank.id) == tank_id:
			return tank
	return tank_archetypes[0]


func set_selected_tank(tank_id: String) -> void:
	if get_unlock_manager().is_tank_unlocked(tank_id):
		selected_tank_id = get_tank_by_id(tank_id).id


func can_start_selected_tank() -> bool:
	return get_unlock_manager().is_tank_unlocked(selected_tank_id)


func get_selected_map() -> Dictionary:
	if not get_unlock_manager().is_map_unlocked(selected_map_id):
		selected_map_id = "map1"
	return get_map_by_id(selected_map_id)


func get_map_by_id(map_id: String) -> Dictionary:
	for map_config in map_catalog:
		if String(map_config.id) == map_id:
			return map_config
	return map_catalog[0]


func set_selected_map(map_id: String) -> void:
	if get_unlock_manager().is_map_unlocked(map_id):
		selected_map_id = get_map_by_id(map_id).id


func can_start_selected_map() -> bool:
	return get_unlock_manager().is_map_unlocked(selected_map_id)


func start_new_run() -> void:
	run_seed_text = generate_run_seed()
	active_run_modifiers = roll_run_modifiers(run_seed_text)


func ensure_run_ready() -> void:
	if run_seed_text == "":
		start_new_run()


func generate_run_seed() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var alphabet := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var seed_parts: Array[String] = []
	for i in range(8):
		seed_parts.append(alphabet[rng.randi_range(0, alphabet.length() - 1)])
	return "".join(seed_parts)


func roll_run_modifiers(seed_text: String) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seed_text)
	var available_modifiers := get_unlocked_run_modifiers()
	var modifier_count := rng.randi_range(2, 3)
	var modifiers: Array[Dictionary] = []
	for i in range(modifier_count):
		if available_modifiers.is_empty():
			break
		var index := rng.randi_range(0, available_modifiers.size() - 1)
		modifiers.append(available_modifiers[index])
		available_modifiers.remove_at(index)
	return modifiers


func get_active_modifier_names() -> Array[String]:
	var names: Array[String] = []
	for modifier in active_run_modifiers:
		names.append(String(modifier.name))
	return names


func get_active_modifier_summary() -> String:
	var names := get_active_modifier_names()
	if names.is_empty():
		return "None"
	return ", ".join(names)


func get_modifier_multiplier(key: String, default_value: float = 1.0) -> float:
	var multiplier := default_value
	for modifier in active_run_modifiers:
		multiplier *= float(modifier.get(key, 1.0))
	return multiplier


func get_meta_reward_bonus(reward_key: String) -> int:
	var unlock_manager = get_unlock_manager()
	if unlock_manager.has_method("get_meta_reward_bonus"):
		return int(unlock_manager.get_meta_reward_bonus(reward_key))
	return 0


func get_meta_reward_multiplier(reward_key: String, default_value: float = 1.0) -> float:
	var unlock_manager = get_unlock_manager()
	if unlock_manager.has_method("get_meta_reward_multiplier"):
		return float(unlock_manager.get_meta_reward_multiplier(reward_key, default_value))
	return default_value


func get_unlocked_run_modifiers() -> Array[Dictionary]:
	var unlocked: Array[Dictionary] = []
	var unlock_manager = get_unlock_manager()
	for modifier in run_modifier_catalog:
		if unlock_manager.is_modifier_unlocked(String(modifier.id)):
			unlocked.append(modifier)
	return unlocked


func get_first_unlocked_tank_id() -> String:
	var unlock_manager = get_unlock_manager()
	for tank in tank_archetypes:
		if unlock_manager.is_tank_unlocked(String(tank.id)):
			return String(tank.id)
	return "vanguard"


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")
