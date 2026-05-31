extends Node

const SAVE_PATH: String = "user://unlock_state.cfg"

var unlocked_tanks: Array[String] = ["vanguard", "scout"]
var unlocked_abilities: Array[String] = ["landmine", "circular_saw", "footsoldier", "shock_field"]
var unlocked_modifiers: Array[String] = ["swarm_opening", "rich_crystals"]
var best_survival_seconds: int = 0
var best_level: int = 1
var best_enemies_defeated: int = 0
var total_bosses_defeated: int = 0


func _ready() -> void:
	load_unlocks()


func load_unlocks() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		save_unlocks()
		return
	
	unlocked_tanks = array_to_string_array(config.get_value("unlocks", "tanks", unlocked_tanks))
	unlocked_abilities = array_to_string_array(config.get_value("unlocks", "abilities", unlocked_abilities))
	unlocked_modifiers = array_to_string_array(config.get_value("unlocks", "modifiers", unlocked_modifiers))
	best_survival_seconds = int(config.get_value("stats", "best_survival_seconds", best_survival_seconds))
	best_level = int(config.get_value("stats", "best_level", best_level))
	best_enemies_defeated = int(config.get_value("stats", "best_enemies_defeated", best_enemies_defeated))
	total_bosses_defeated = int(config.get_value("stats", "total_bosses_defeated", total_bosses_defeated))
	ensure_default_unlocks()


func save_unlocks() -> void:
	var config := ConfigFile.new()
	config.set_value("unlocks", "tanks", unlocked_tanks)
	config.set_value("unlocks", "abilities", unlocked_abilities)
	config.set_value("unlocks", "modifiers", unlocked_modifiers)
	config.set_value("stats", "best_survival_seconds", best_survival_seconds)
	config.set_value("stats", "best_level", best_level)
	config.set_value("stats", "best_enemies_defeated", best_enemies_defeated)
	config.set_value("stats", "total_bosses_defeated", total_bosses_defeated)
	config.save(SAVE_PATH)


func ensure_default_unlocks() -> void:
	for tank_id in ["vanguard", "scout"]:
		unlock_id(unlocked_tanks, tank_id)
	for ability_id in ["landmine", "circular_saw", "footsoldier", "shock_field"]:
		unlock_id(unlocked_abilities, ability_id)
	for modifier_id in ["swarm_opening", "rich_crystals"]:
		unlock_id(unlocked_modifiers, modifier_id)


func record_run_result(result: Dictionary) -> Array[String]:
	best_survival_seconds = max(best_survival_seconds, int(result.get("survival_seconds", 0)))
	best_level = max(best_level, int(result.get("level", 1)))
	best_enemies_defeated = max(best_enemies_defeated, int(result.get("enemies_defeated", 0)))
	total_bosses_defeated += int(result.get("bosses_defeated", 0))
	
	var unlocked_messages: Array[String] = []
	add_unlocks_for_progress(unlocked_messages)
	save_unlocks()
	return unlocked_messages


func add_unlocks_for_progress(unlocked_messages: Array[String]) -> void:
	if best_survival_seconds >= 120:
		try_unlock("tank", "fortress", "Fortress tank", unlocked_messages)
		try_unlock("ability", "oil_slick", "Oil Slick ability", unlocked_messages)
		try_unlock("modifier", "supply_rain", "Supply Rain modifier", unlocked_messages)
	if best_level >= 5:
		try_unlock("tank", "collector", "Collector tank", unlocked_messages)
		try_unlock("ability", "drone_swarm", "Drone Swarm ability", unlocked_messages)
	if total_bosses_defeated >= 1:
		try_unlock("tank", "twin_cannon", "Twin Cannon tank", unlocked_messages)
		try_unlock("ability", "artillery", "Artillery ability", unlocked_messages)
		try_unlock("modifier", "boss_contract", "Boss Contract modifier", unlocked_messages)
	if best_enemies_defeated >= 250:
		try_unlock("tank", "engineer", "Engineer tank", unlocked_messages)
		try_unlock("modifier", "salvage_field", "Salvage Field modifier", unlocked_messages)
	if best_level >= 10:
		try_unlock("ability", "freeze_pulse", "Freeze Pulse ability", unlocked_messages)
		try_unlock("modifier", "unstable_engine", "Unstable Engine modifier", unlocked_messages)


func try_unlock(kind: String, id: String, display_name: String, unlocked_messages: Array[String]) -> void:
	match kind:
		"tank":
			if unlock_id(unlocked_tanks, id):
				unlocked_messages.append(display_name)
		"ability":
			if unlock_id(unlocked_abilities, id):
				unlocked_messages.append(display_name)
		"modifier":
			if unlock_id(unlocked_modifiers, id):
				unlocked_messages.append(display_name)


func unlock_id(list: Array[String], id: String) -> bool:
	if list.has(id):
		return false
	list.append(id)
	return true


func is_tank_unlocked(tank_id: String) -> bool:
	return unlocked_tanks.has(tank_id)


func is_ability_unlocked(ability_id: String) -> bool:
	return unlocked_abilities.has(ability_id)


func is_modifier_unlocked(modifier_id: String) -> bool:
	return unlocked_modifiers.has(modifier_id)


func array_to_string_array(value) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(String(item))
	return result
