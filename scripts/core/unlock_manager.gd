extends Node

const SAVE_PATH: String = "user://unlock_state.cfg"

var unlocked_tanks: Array[String] = ["vanguard", "scout"]
var unlocked_maps: Array[String] = ["map1"]
var unlocked_abilities: Array[String] = ["landmine", "circular_saw", "footsoldier", "shock_field", "vampire_circuit", "supply_beacon", "bulldozer_aura", "magnet_storm", "phase_magnet"]
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
	{"id": "storm_build", "name": "Storm Build", "metric": "build_sum", "build_keys": ["volt_coils", "field_amplifier", "capacitor_bank"], "threshold": 4, "reward_text": "+1 starting magnet", "rewards": {"starting_magnet_level": 1}},
	{"id": "control_build", "name": "Control Build", "metric": "build_sum", "build_keys": ["gravity_anchor", "field_amplifier", "barbed_wire"], "threshold": 5, "reward_text": "+1 starting health", "rewards": {"starting_health_bonus": 1}},
]


func _ready() -> void:
	load_unlocks()


func load_unlocks() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		save_unlocks()
		return
	
	unlocked_tanks = array_to_string_array(config.get_value("unlocks", "tanks", unlocked_tanks))
	unlocked_maps = array_to_string_array(config.get_value("unlocks", "maps", unlocked_maps))
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
	config.set_value("unlocks", "maps", unlocked_maps)
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
	unlock_id(unlocked_maps, "map1")
	for ability_id in ["landmine", "circular_saw", "footsoldier", "shock_field", "vampire_circuit", "supply_beacon", "bulldozer_aura", "magnet_storm", "phase_magnet"]:
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
	add_unlocks_for_victory(result, unlocked_messages)
	add_challenge_rewards_for_result(result, unlocked_messages)
	save_unlocks()
	return unlocked_messages


func add_unlocks_for_progress(unlocked_messages: Array[String]) -> void:
	if best_survival_seconds >= 420:
		try_unlock("tank", "fortress", "Fortress tank", unlocked_messages)
		try_unlock("ability", "oil_slick", "Oil Slick ability", unlocked_messages)
		try_unlock("modifier", "supply_rain", "Supply Rain modifier", unlocked_messages)
	if best_level >= 12:
		try_unlock("tank", "collector", "Collector tank", unlocked_messages)
		try_unlock("ability", "drone_swarm", "Drone Swarm ability", unlocked_messages)
	if total_bosses_defeated >= 3:
		try_unlock("tank", "twin_cannon", "Twin Cannon tank", unlocked_messages)
		try_unlock("ability", "artillery", "Artillery ability", unlocked_messages)
		try_unlock("modifier", "boss_contract", "Boss Contract modifier", unlocked_messages)
	if best_enemies_defeated >= 900:
		try_unlock("tank", "engineer", "Engineer tank", unlocked_messages)
		try_unlock("modifier", "salvage_field", "Salvage Field modifier", unlocked_messages)
	if best_level >= 18:
		try_unlock("tank", "storm_chaser", "Storm Chaser tank", unlocked_messages)
	if best_survival_seconds >= 900:
		try_unlock("tank", "pyroclast", "Pyroclast tank", unlocked_messages)
	if total_bosses_defeated >= 8:
		try_unlock("tank", "medic", "Medic tank", unlocked_messages)
	if best_survival_seconds >= 1500 and best_level >= 22:
		try_unlock("tank", "singularity_rig", "Singularity Rig tank", unlocked_messages)
	if best_level >= 20:
		try_unlock("tank", "glass_rail", "Glass Rail tank", unlocked_messages)
	if best_enemies_defeated >= 1400:
		try_unlock("tank", "bulldozer", "Bulldozer tank", unlocked_messages)
	if best_level >= 24:
		try_unlock("tank", "swarm_broker", "Swarm Broker tank", unlocked_messages)
	if best_survival_seconds >= 1200:
		try_unlock("tank", "sapper", "Sapper tank", unlocked_messages)
	if best_survival_seconds >= 1500 and total_bosses_defeated >= 10:
		try_unlock("tank", "chrono_tank", "Chrono Tank", unlocked_messages)
	if best_level >= 26:
		try_unlock("tank", "gold_engine", "Gold Engine tank", unlocked_messages)
	if best_survival_seconds >= 1800:
		try_unlock("tank", "rift_skimmer", "Rift Skimmer tank", unlocked_messages)
	if total_bosses_defeated >= 14:
		try_unlock("tank", "fortress_medic", "Fortress Medic tank", unlocked_messages)
	if best_level >= 28:
		try_unlock("tank", "meteor_twins", "Meteor Twins tank", unlocked_messages)
	if best_survival_seconds >= 1800 and total_bosses_defeated >= 18:
		try_unlock("tank", "storm_foundry", "Storm Foundry tank", unlocked_messages)
	if best_level >= 10:
		try_unlock("ability", "freeze_pulse", "Freeze Pulse ability", unlocked_messages)
		try_unlock("ability", "ion_lance", "Ion Lance power", unlocked_messages)
		try_unlock("ability", "acid_pool", "Acid Pool power", unlocked_messages)
		try_unlock("modifier", "unstable_engine", "Unstable Engine modifier", unlocked_messages)
	if best_level >= 12:
		try_unlock("ability", "overdrive_core", "Overdrive Core ability", unlocked_messages)
		try_unlock("ability", "guardian_wall", "Guardian Wall power", unlocked_messages)
		try_unlock("ability", "critical_storm", "Critical Storm power", unlocked_messages)
	if best_survival_seconds >= 240:
		try_unlock("ability", "flame_wave", "Flame Wave ability", unlocked_messages)
		try_unlock("ability", "meteor_shell", "Meteor Shell power", unlocked_messages)
	if best_survival_seconds >= 300:
		try_unlock("ability", "repair_beacon", "Repair Beacon ability", unlocked_messages)
		try_unlock("ability", "repair_burst", "Repair Burst power", unlocked_messages)
	if best_survival_seconds >= 480:
		try_unlock("ability", "missile_pod", "Missile Pod ability", unlocked_messages)
		try_unlock("ability", "pulse_drone", "Pulse Drone power", unlocked_messages)
	if best_survival_seconds >= 600:
		try_unlock("ability", "chain_lightning", "Chain Lightning ability", unlocked_messages)
		try_unlock("ability", "orbital_cannon", "Orbital Cannon power", unlocked_messages)
	if best_level >= 14:
		try_unlock("ability", "gravity_well", "Gravity Well ability", unlocked_messages)
		try_unlock("ability", "black_hole_mines", "Black Hole Mines power", unlocked_messages)
		try_unlock("ability", "munition_swarm", "Munition Swarm power", unlocked_messages)
	if best_survival_seconds >= 900:
		try_unlock("ability", "guardian_satellite", "Guardian Satellite ability", unlocked_messages)
		try_unlock("ability", "ember_turret", "Ember Turret power", unlocked_messages)
		try_unlock("ability", "fortress_protocol", "Fortress Protocol power", unlocked_messages)
	if total_bosses_defeated >= 2:
		try_unlock("ability", "railgun_orbiter", "Railgun Orbiter ability", unlocked_messages)
	if best_survival_seconds >= 720:
		try_unlock("ability", "tesla_pylon", "Tesla Pylon ability", unlocked_messages)
		try_unlock("ability", "storm_catalyst", "Storm Catalyst power", unlocked_messages)
	if best_level >= 16:
		try_unlock("ability", "nanite_cloud", "Nanite Cloud ability", unlocked_messages)
	if best_survival_seconds >= 1080:
		try_unlock("ability", "ricochet_rounds", "Ricochet Rounds ability", unlocked_messages)
	if best_survival_seconds >= 1320:
		try_unlock("ability", "chrono_burst", "Chrono Burst ability", unlocked_messages)
		try_unlock("ability", "time_shock", "Time Shock power", unlocked_messages)
		try_unlock("ability", "golden_reactor", "Golden Reactor power", unlocked_messages)


func add_unlocks_for_victory(result: Dictionary, unlocked_messages: Array[String]) -> void:
	if not bool(result.get("victory", false)):
		return
	match String(result.get("map_id", "")):
		"map1":
			try_unlock("map", "map2", "Scrap Maze map", unlocked_messages)
		"map2":
			try_unlock("map", "map3", "Crystal Expanse map", unlocked_messages)
		"map3":
			try_unlock("map", "map4", "Toxic Foundry map", unlocked_messages)
		"map4":
			try_unlock("map", "map5", "Void Crucible map", unlocked_messages)
		"map5":
			try_unlock("map", "map6", "Moonlit Graveyard map", unlocked_messages)
		"map6":
			try_unlock("map", "map7", "Neon Grid map", unlocked_messages)
		"map7":
			try_unlock("map", "map8", "Frozen Scar map", unlocked_messages)
		"map8":
			try_unlock("map", "map9", "Ember Rift map", unlocked_messages)
		"map9":
			try_unlock("map", "map10", "Astral Engine map", unlocked_messages)


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


func get_tank_unlock_hint(tank_id: String) -> String:
	if is_tank_unlocked(tank_id):
		return "Unlocked"
	match tank_id:
		"fortress":
			return "Survive 7:00 in any run."
		"collector":
			return "Reach level 12 in any run."
		"twin_cannon":
			return "Defeat 3 total bosses across runs."
		"engineer":
			return "Defeat 900 enemies across your best run record."
		"storm_chaser":
			return "Reach level 18 in any run."
		"pyroclast":
			return "Survive 15:00 in any run."
		"medic":
			return "Defeat 8 total bosses across runs."
		"singularity_rig":
			return "Survive 25:00 and reach level 22."
		"glass_rail":
			return "Reach level 20 in any run."
		"bulldozer":
			return "Defeat 1400 enemies in your best run record."
		"swarm_broker":
			return "Reach level 24 in any run."
		"sapper":
			return "Survive 20:00 in any run."
		"chrono_tank":
			return "Survive 25:00 and defeat 10 total bosses."
		"gold_engine":
			return "Reach level 26 in any run."
		"rift_skimmer":
			return "Win any map at 30:00."
		"fortress_medic":
			return "Defeat 14 total bosses across runs."
		"meteor_twins":
			return "Reach level 28 in any run."
		"storm_foundry":
			return "Win any map and defeat 18 total bosses."
	return "Progress further to reveal this unlock."


func get_progress_report(recent_unlocks: Array[String] = []) -> String:
	var lines: Array[String] = [
		"Permanent Progress",
		"Best time: %s  Best level: %s" % [format_seconds(best_survival_seconds), best_level],
		"Best kills: %s  Total bosses: %s" % [best_enemies_defeated, total_bosses_defeated],
		"Tanks: %s  Maps: %s  Abilities: %s  Modifiers: %s" % [unlocked_tanks.size(), unlocked_maps.size(), unlocked_abilities.size(), unlocked_modifiers.size()],
	]
	if not recent_unlocks.is_empty():
		lines.append("New unlocks: %s" % ", ".join(recent_unlocks))

	var next_goals := get_next_unlock_goal_lines()
	if not next_goals.is_empty():
		lines.append("Next goals:")
		lines.append_array(next_goals.slice(0, 4))
	return "\n".join(lines)


func get_next_unlock_goal_lines() -> Array[String]:
	var lines: Array[String] = []
	if not is_map_unlocked("map2"):
		lines.append("- Map: Win Dust Bowl at 30:00 to unlock Scrap Maze.")
	elif not is_map_unlocked("map3"):
		lines.append("- Map: Win Scrap Maze at 30:00 to unlock Crystal Expanse.")
	elif not is_map_unlocked("map4"):
		lines.append("- Map: Win Crystal Expanse at 30:00 to unlock Toxic Foundry.")
	elif not is_map_unlocked("map5"):
		lines.append("- Map: Win Toxic Foundry at 30:00 to unlock Void Crucible.")
	elif not is_map_unlocked("map6"):
		lines.append("- Map: Win Void Crucible at 30:00 to unlock Moonlit Graveyard.")
	elif not is_map_unlocked("map7"):
		lines.append("- Map: Win Moonlit Graveyard at 30:00 to unlock Neon Grid.")
	elif not is_map_unlocked("map8"):
		lines.append("- Map: Win Neon Grid at 30:00 to unlock Frozen Scar.")
	elif not is_map_unlocked("map9"):
		lines.append("- Map: Win Frozen Scar at 30:00 to unlock Ember Rift.")
	elif not is_map_unlocked("map10"):
		lines.append("- Map: Win Ember Rift at 30:00 to unlock Astral Engine.")
	for tank_id in ["fortress", "collector", "twin_cannon", "engineer", "storm_chaser", "pyroclast", "medic", "singularity_rig", "glass_rail", "bulldozer", "swarm_broker", "sapper", "chrono_tank", "gold_engine", "rift_skimmer", "fortress_medic", "meteor_twins", "storm_foundry"]:
		if not is_tank_unlocked(tank_id):
			lines.append("- Tank: %s" % get_tank_unlock_hint(tank_id))
	for ability_goal in get_ability_goal_catalog():
		if not is_ability_unlocked(String(ability_goal.id)):
			lines.append("- Ability: %s" % String(ability_goal.hint))
	for goal in challenge_goal_catalog:
		if not completed_challenge_goals.has(String(goal.id)):
			lines.append("- Challenge: %s for %s" % [String(goal.name), String(goal.reward_text)])
	return lines


func get_ability_goal_catalog() -> Array[Dictionary]:
	return [
		{"id": "freeze_pulse", "hint": "Reach level 10 to unlock Freeze Pulse."},
		{"id": "overdrive_core", "hint": "Reach level 12 to unlock Overdrive Core."},
		{"id": "flame_wave", "hint": "Survive 4:00 to unlock Flame Wave."},
		{"id": "repair_beacon", "hint": "Survive 5:00 to unlock Repair Beacon."},
		{"id": "chain_lightning", "hint": "Survive 10:00 to unlock Chain Lightning."},
		{"id": "gravity_well", "hint": "Reach level 14 to unlock Gravity Well."},
		{"id": "railgun_orbiter", "hint": "Defeat 2 total bosses to unlock Railgun Orbiter."},
		{"id": "chrono_burst", "hint": "Survive 22:00 to unlock Chrono Burst."},
	]


func format_seconds(total_seconds: int) -> String:
	var minutes := int(float(total_seconds) / 60.0)
	var seconds_remainder := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds_remainder]


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
		"map":
			if unlock_id(unlocked_maps, id):
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


func is_map_unlocked(map_id: String) -> bool:
	return unlocked_maps.has(map_id)


func get_map_unlock_hint(map_id: String) -> String:
	if is_map_unlocked(map_id):
		return "Unlocked"
	match map_id:
		"map2":
			return "Win Dust Bowl at 30:00."
		"map3":
			return "Win Scrap Maze at 30:00."
		"map4":
			return "Win Crystal Expanse at 30:00."
		"map5":
			return "Win Toxic Foundry at 30:00."
		"map6":
			return "Win Void Crucible at 30:00."
		"map7":
			return "Win Moonlit Graveyard at 30:00."
		"map8":
			return "Win Neon Grid at 30:00."
		"map9":
			return "Win Frozen Scar at 30:00."
		"map10":
			return "Win Ember Rift at 30:00."
	return "Progress further to reveal this map."


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
