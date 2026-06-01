extends Node

const SAVE_PATH: String = "user://unlock_state.cfg"

var unlocked_tanks: Array[String] = ["vanguard", "scout"]
var unlocked_abilities: Array[String] = ["landmine", "circular_saw", "footsoldier", "shock_field"]
var unlocked_modifiers: Array[String] = ["swarm_opening", "rich_crystals"]
var completed_challenge_goals: Array[String] = []
var best_survival_seconds: int = 0
var best_level: int = 1
var best_enemies_defeated: int = 0
var total_bosses_defeated: int = 0

var challenge_goal_catalog: Array[Dictionary] = [
	{"id": "hold_the_line", "name": "Hold the Line", "metric": "survival_seconds", "threshold": 180, "reward_text": "+1 starting armor", "rewards": {"starting_armor_level": 1}},
	{"id": "boss_breaker", "name": "Boss Breaker", "metric": "bosses_defeated", "threshold": 1, "reward_text": "Overclock Cache modifier", "rewards": {"unlock_modifier": "overclock_cache"}},
	{"id": "elite_sweeper", "name": "Elite Sweeper", "metric": "elites_defeated", "threshold": 8, "reward_text": "+15% wrench drops", "rewards": {"wrench_drop_multiplier": 1.15}},
	{"id": "heavy_build", "name": "Heavy Build", "metric": "build_sum", "build_keys": ["damage", "fire_rate", "cannon"], "threshold": 7, "reward_text": "+1 starting damage", "rewards": {"starting_damage_level": 1}},
	{"id": "collector_build", "name": "Collector Build", "metric": "build_sum", "build_keys": ["magnet", "exp"], "threshold": 5, "reward_text": "+1 starting EXP", "rewards": {"starting_exp_level": 1}},
]


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
	completed_challenge_goals = array_to_string_array(config.get_value("unlocks", "completed_challenge_goals", completed_challenge_goals))
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
	config.set_value("unlocks", "completed_challenge_goals", completed_challenge_goals)
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
	add_challenge_rewards_for_result(result, unlocked_messages)
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
	if best_level >= 12:
		try_unlock("ability", "overdrive_core", "Overdrive Core ability", unlocked_messages)
	if best_survival_seconds >= 600:
		try_unlock("ability", "chain_lightning", "Chain Lightning ability", unlocked_messages)
	if best_survival_seconds >= 900:
		try_unlock("ability", "guardian_satellite", "Guardian Satellite ability", unlocked_messages)


func add_challenge_rewards_for_result(result: Dictionary, unlocked_messages: Array[String]) -> void:
	for goal in challenge_goal_catalog:
		var goal_id := String(goal.id)
		if completed_challenge_goals.has(goal_id):
			continue
		if not is_challenge_goal_completed(goal, result):
			continue
		
		completed_challenge_goals.append(goal_id)
		apply_challenge_unlock_rewards(goal, unlocked_messages)
		unlocked_messages.append("Challenge: %s (%s)" % [String(goal.name), String(goal.reward_text)])


func is_challenge_goal_completed(goal: Dictionary, result: Dictionary) -> bool:
	var metric := String(goal.get("metric", ""))
	var threshold := int(goal.get("threshold", 0))
	match metric:
		"survival_seconds", "bosses_defeated", "elites_defeated":
			return int(result.get(metric, 0)) >= threshold
		"build_sum":
			return get_build_goal_sum(goal, result) >= threshold
	return false


func get_build_goal_sum(goal: Dictionary, result: Dictionary) -> int:
	var build_levels: Dictionary = result.get("build_levels", {}) as Dictionary
	var total := 0
	for key in goal.get("build_keys", []):
		total += int(build_levels.get(String(key), 0))
	return total


func apply_challenge_unlock_rewards(goal: Dictionary, unlocked_messages: Array[String]) -> void:
	var rewards: Dictionary = goal.get("rewards", {}) as Dictionary
	if rewards.has("unlock_modifier"):
		try_unlock("modifier", String(rewards.unlock_modifier), "%s modifier" % get_modifier_reward_name(String(rewards.unlock_modifier)), unlocked_messages)


func get_modifier_reward_name(modifier_id: String) -> String:
	match modifier_id:
		"overclock_cache":
			return "Overclock Cache"
	return modifier_id.capitalize()


func get_meta_reward_bonus(reward_key: String) -> int:
	var total := 0
	for goal in get_completed_challenge_goal_configs():
		var rewards: Dictionary = goal.get("rewards", {}) as Dictionary
		total += int(rewards.get(reward_key, 0))
	return total


func get_meta_reward_multiplier(reward_key: String, default_value: float = 1.0) -> float:
	var multiplier := default_value
	for goal in get_completed_challenge_goal_configs():
		var rewards: Dictionary = goal.get("rewards", {}) as Dictionary
		if rewards.has(reward_key):
			multiplier *= float(rewards.get(reward_key, 1.0))
	return multiplier


func get_completed_challenge_goal_configs() -> Array[Dictionary]:
	var goals: Array[Dictionary] = []
	for goal in challenge_goal_catalog:
		if completed_challenge_goals.has(String(goal.id)):
			goals.append(goal)
	return goals


func get_completed_challenge_goal_names() -> Array[String]:
	var names: Array[String] = []
	for goal in get_completed_challenge_goal_configs():
		names.append(String(goal.name))
	return names


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
