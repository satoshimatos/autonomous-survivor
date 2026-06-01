extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)
const OPTION_COUNT: int = 3

var player: CharacterBody2D
var ai_pick_in_progress: bool = false
var displayed_abilities: Array[Dictionary] = []

var ability_catalog: Array[Dictionary] = [
	{"id": "landmine", "label": "+1 PLACE LANDMINE", "method": "upgrade_landmine", "level_property": "landmine_level", "rarity": "Common", "base_weight": 18.0, "tags": ["device", "area"], "synergy_upgrades": ["mine_dispenser", "impact_fuse"], "synergy_abilities": ["oil_slick_level", "artillery_level"]},
	{"id": "circular_saw", "label": "+1 CIRCULAR SAW", "method": "upgrade_circular_saw", "level_property": "circular_saw_level", "rarity": "Common", "base_weight": 17.0, "tags": ["orbit", "contact"], "synergy_upgrades": ["orbit_gears", "armor", "speed"], "synergy_abilities": ["shock_field_level", "freeze_pulse_level"]},
	{"id": "footsoldier", "label": "+ FOOTSOLDIER", "method": "upgrade_footsoldier", "level_property": "footsoldier_level", "rarity": "Uncommon", "base_weight": 13.0, "tags": ["pet", "projectile"], "synergy_upgrades": ["drone_command", "fire_rate", "piercing"], "synergy_abilities": ["drone_swarm_level"]},
	{"id": "shock_field", "label": "+ SHOCK FIELD", "method": "upgrade_shock_field", "level_property": "shock_field_level", "rarity": "Uncommon", "base_weight": 12.0, "tags": ["aura", "crowd-control"], "synergy_upgrades": ["armor", "barbed_wire", "damage"], "synergy_abilities": ["circular_saw_level", "freeze_pulse_level"]},
	{"id": "artillery", "label": "+ ARTILLERY", "method": "upgrade_artillery", "level_property": "artillery_level", "rarity": "Rare", "base_weight": 8.0, "late_level": 12, "late_weight_multiplier": 1.65, "tags": ["area", "burst"], "synergy_upgrades": ["damage", "splash", "ordnance_bay"], "synergy_abilities": ["landmine_level", "oil_slick_level"]},
	{"id": "drone_swarm", "label": "+ DRONE SWARM", "method": "upgrade_drone_swarm", "level_property": "drone_swarm_level", "rarity": "Uncommon", "base_weight": 12.0, "tags": ["pet", "projectile"], "synergy_upgrades": ["drone_command", "fire_rate", "cannon"], "synergy_abilities": ["footsoldier_level"]},
	{"id": "oil_slick", "label": "+ OIL SLICK", "method": "upgrade_oil_slick", "level_property": "oil_slick_level", "rarity": "Common", "base_weight": 15.0, "tags": ["device", "crowd-control"], "synergy_upgrades": ["speed", "armor"], "synergy_abilities": ["landmine_level", "artillery_level"]},
	{"id": "freeze_pulse", "label": "+ FREEZE PULSE", "method": "upgrade_freeze_pulse", "level_property": "freeze_pulse_level", "rarity": "Rare", "base_weight": 7.0, "late_level": 10, "late_weight_multiplier": 1.8, "tags": ["burst", "crowd-control"], "synergy_upgrades": ["armor", "barbed_wire", "damage"], "synergy_abilities": ["shock_field_level", "circular_saw_level"]},
	{"id": "chain_lightning", "label": "+ CHAIN LIGHTNING", "method": "upgrade_chain_lightning", "level_property": "chain_lightning_level", "rarity": "Rare", "base_weight": 7.5, "late_level": 12, "late_weight_multiplier": 1.7, "tags": ["chain", "crowd-control"], "synergy_upgrades": ["damage", "volt_coils", "capacitor_bank"], "synergy_abilities": ["shock_field_level", "freeze_pulse_level"]},
	{"id": "guardian_satellite", "label": "+ GUARDIAN SATELLITE", "method": "upgrade_guardian_satellite", "level_property": "guardian_satellite_level", "rarity": "Uncommon", "base_weight": 11.0, "tags": ["orbit", "defense"], "synergy_upgrades": ["armor", "payload_rack", "reactive_shield"], "synergy_abilities": ["circular_saw_level", "overdrive_core_level"]},
	{"id": "overdrive_core", "label": "+ OVERDRIVE CORE", "method": "upgrade_overdrive_core", "level_property": "overdrive_core_level", "rarity": "Rare", "base_weight": 8.5, "late_level": 8, "late_weight_multiplier": 1.4, "tags": ["buff", "mobility"], "synergy_upgrades": ["speed", "damage", "accelerator"], "synergy_abilities": ["guardian_satellite_level", "drone_swarm_level"]},
	{"id": "flame_wave", "label": "+ FLAME WAVE", "method": "upgrade_flame_wave", "level_property": "flame_wave_level", "rarity": "Uncommon", "base_weight": 11.0, "late_level": 6, "late_weight_multiplier": 1.45, "tags": ["area", "burn"], "synergy_upgrades": ["field_amplifier", "combustion_mix", "splash"], "synergy_abilities": ["oil_slick_level", "gravity_well_level"]},
	{"id": "repair_beacon", "label": "+ REPAIR BEACON", "method": "upgrade_repair_beacon", "level_property": "repair_beacon_level", "rarity": "Uncommon", "base_weight": 9.5, "late_level": 7, "late_weight_multiplier": 1.35, "tags": ["sustain", "support"], "synergy_upgrades": ["repair_drones", "nanobots", "reactive_shield"], "synergy_abilities": ["guardian_satellite_level", "overdrive_core_level"]},
	{"id": "missile_pod", "label": "+ MISSILE POD", "method": "upgrade_missile_pod", "level_property": "missile_pod_level", "rarity": "Uncommon", "base_weight": 10.0, "late_level": 8, "late_weight_multiplier": 1.55, "tags": ["area", "projectile"], "synergy_upgrades": ["missile_guidance", "ordnance_bay", "combustion_mix"], "synergy_abilities": ["artillery_level", "railgun_orbiter_level"]},
	{"id": "gravity_well", "label": "+ GRAVITY WELL", "method": "upgrade_gravity_well", "level_property": "gravity_well_level", "rarity": "Rare", "base_weight": 7.0, "late_level": 14, "late_weight_multiplier": 1.8, "tags": ["crowd-control", "area"], "synergy_upgrades": ["gravity_anchor", "field_amplifier", "combustion_mix"], "synergy_abilities": ["flame_wave_level", "chain_lightning_level"]},
	{"id": "railgun_orbiter", "label": "+ RAILGUN ORBITER", "method": "upgrade_railgun_orbiter", "level_property": "railgun_orbiter_level", "rarity": "Rare", "base_weight": 7.5, "late_level": 14, "late_weight_multiplier": 1.75, "tags": ["pierce", "projectile"], "synergy_upgrades": ["rail_stabilizer", "accelerator", "high_caliber"], "synergy_abilities": ["missile_pod_level", "drone_swarm_level"]},
]

@onready var ability_buttons: Array[Button] = [
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/LandmineButton,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/CircularSawButton,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/FootsoldierButton,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/ShockFieldButton,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/ArtilleryButton,
]


func _ready() -> void:
	roll_ability_options()


func roll_ability_options() -> void:
	displayed_abilities = roll_weighted_ability_options()
	
	for i in range(ability_buttons.size()):
		var button := ability_buttons[i]
		if i < displayed_abilities.size():
			button.visible = true
			button.text = get_ability_button_label(displayed_abilities[i])
			button.disabled = false
		else:
			button.visible = false


func roll_weighted_ability_options() -> Array[Dictionary]:
	var available_options := get_unlocked_ability_options()
	var rolled_options: Array[Dictionary] = []
	for i in range(mini(OPTION_COUNT, available_options.size())):
		var picked_index := pick_weighted_ability_index(available_options)
		rolled_options.append(available_options[picked_index])
		available_options.remove_at(picked_index)
	return rolled_options


func get_unlocked_ability_options() -> Array[Dictionary]:
	var unlocked_options: Array[Dictionary] = []
	var unlock_manager = get_unlock_manager()
	for ability in ability_catalog:
		if unlock_manager.is_ability_unlocked(String(ability.id)):
			unlocked_options.append(ability.duplicate(true))
	if unlocked_options.is_empty() and not ability_catalog.is_empty():
		unlocked_options.append(ability_catalog[0].duplicate(true))
	return unlocked_options


func pick_weighted_ability_index(options: Array[Dictionary]) -> int:
	var total_weight: float = 0.0
	var weights: Array[float] = []
	for ability in options:
		var weight := get_ability_roll_weight(ability)
		weights.append(weight)
		total_weight += weight
	
	if total_weight <= 0.0:
		return randi_range(0, options.size() - 1)
	
	var roll := randf() * total_weight
	for i in range(options.size()):
		roll -= weights[i]
		if roll <= 0.0:
			return i
	
	return options.size() - 1


func get_ability_roll_weight(ability: Dictionary) -> float:
	var weight := float(ability.get("base_weight", 1.0))
	var ability_level := get_player_property_as_int(String(ability.get("level_property", "")))
	if ability_level <= 0:
		weight *= 1.18
	else:
		weight *= 1.0 + min(float(ability_level) * 0.08, 0.45)
	
	var late_level := int(ability.get("late_level", 999))
	if player != null and player.level >= late_level:
		weight *= float(ability.get("late_weight_multiplier", 1.0))
	
	weight *= get_upgrade_synergy_multiplier(ability.get("synergy_upgrades", []) as Array)
	weight *= get_ability_synergy_multiplier(ability.get("synergy_abilities", []) as Array)
	return max(weight, 0.01)


func get_upgrade_synergy_multiplier(upgrade_ids: Array) -> float:
	var multiplier := 1.0
	for upgrade_id in upgrade_ids:
		var level := get_upgrade_level(String(upgrade_id))
		if level > 0:
			multiplier += min(0.18 + float(level) * 0.025, 0.38)
	return multiplier


func get_ability_synergy_multiplier(ability_properties: Array) -> float:
	var multiplier := 1.0
	for ability_property in ability_properties:
		var level := get_player_property_as_int(String(ability_property))
		if level > 0:
			multiplier += min(0.25 + float(level) * 0.04, 0.55)
	return multiplier


func get_upgrade_level(upgrade_id: String) -> int:
	if player == null:
		return 0
	match upgrade_id:
		"speed":
			return player.speed_level
		"fire_rate":
			return player.fire_rate_level
		"damage":
			return player.damage_level
		"regeneration":
			return player.regeneration_level
		"exp":
			return player.exp_bonus_level
		"splash":
			return player.splash_level
		"piercing":
			return player.piercing_level
		"barbed_wire":
			return player.barbed_wire_level
		"armor":
			return player.armor_level
		"magnet":
			return player.magnet_level
		"cannon":
			return player.cannon_level
		"targeting_array":
			return player.targeting_array_level
		"accelerator":
			return player.accelerator_level
		"payload_rack":
			return player.payload_rack_level
		"reactive_shield":
			return player.reactive_shield_level
		"rapid_loader":
			return player.rapid_loader_level
		"high_caliber":
			return player.high_caliber_level
		"capacitor_bank":
			return player.capacitor_bank_level
		"combustion_mix":
			return player.combustion_mix_level
		"nanobots":
			return player.nanobots_level
		"shatter_rounds":
			return player.shatter_rounds_level
		"heat_sinks":
			return player.heat_sinks_level
		"overclocked_barrel":
			return player.overclocked_barrel_level
		"rail_stabilizer":
			return player.rail_stabilizer_level
		"missile_guidance":
			return player.missile_guidance_level
		"ordnance_bay":
			return player.ordnance_bay_level
		"field_amplifier":
			return player.field_amplifier_level
		"volt_coils":
			return player.volt_coils_level
		"gravity_anchor":
			return player.gravity_anchor_level
		"repair_drones":
			return player.repair_drones_level
		"crystal_lens":
			return player.crystal_lens_level
		"munition_printer":
			return player.munition_printer_level
		"stabilized_chassis":
			return player.stabilized_chassis_level
		"vector_thrusters":
			return player.vector_thrusters_level
		"impact_fuse":
			return player.impact_fuse_level
		"armor_piercers":
			return player.armor_piercers_level
		"weakpoint_scanner":
			return player.weakpoint_scanner_level
		"med_pump":
			return player.med_pump_level
		"orbit_gears":
			return player.orbit_gears_level
		"mine_dispenser":
			return player.mine_dispenser_level
		"drone_command":
			return player.drone_command_level
		"lucky_core":
			return player.lucky_core_level
	return 0


func get_player_property_as_int(property_name: String) -> int:
	if player == null or property_name == "":
		return 0
	return int(player.get(property_name))


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")


func get_ability_button_label(ability: Dictionary) -> String:
	var tags: Array = ability.get("tags", []) as Array
	var tag_text := ""
	if not tags.is_empty():
		tag_text = "  %s" % String(tags[0]).to_upper()
	return "%s  [%s]%s" % [
		String(ability.label),
		String(ability.rarity).to_upper(),
		tag_text
	]


func apply_ability(slot_index: int) -> void:
	if slot_index >= displayed_abilities.size():
		return
	
	var method_name := String(displayed_abilities[slot_index].method)
	if player and player.has_method(method_name):
		player.call(method_name)
		if player.has_method("update_evolutions"):
			player.update_evolutions()
	complete_selection()


func complete_selection() -> void:
	if player and player.has_method("complete_ability_selection"):
		player.complete_ability_selection()
	
	queue_free()


func pick_random_ability() -> void:
	if displayed_abilities.is_empty() or ai_pick_in_progress:
		return
	
	ai_pick_in_progress = true
	var slot_index: int = randi_range(0, displayed_abilities.size() - 1)
	await get_tree().create_timer(AI_MENU_VIEW_DELAY, true, false, true).timeout
	if not is_inside_tree():
		return
	highlight_ai_selection(slot_index)
	await get_tree().create_timer(AI_SELECTION_FLASH_DELAY, true, false, true).timeout
	if not is_inside_tree():
		return
	apply_ability(slot_index)


func highlight_ai_selection(slot_index: int) -> void:
	for button in ability_buttons:
		button.disabled = true
	
	if slot_index >= ability_buttons.size():
		return
	
	var selected_button: Button = ability_buttons[slot_index]
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = AI_SELECTION_FLASH_COLOR
	selected_style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	selected_style.set_border_width_all(3)
	selected_button.add_theme_stylebox_override("normal", selected_style)
	selected_button.add_theme_stylebox_override("disabled", selected_style)
	selected_button.text = "%s  [AI]" % selected_button.text


func _on_landmine_button_pressed() -> void:
	apply_ability(0)


func _on_circular_saw_button_pressed() -> void:
	apply_ability(1)


func _on_footsoldier_button_pressed() -> void:
	apply_ability(2)


func _on_shock_field_button_pressed() -> void:
	apply_ability(3)


func _on_artillery_button_pressed() -> void:
	apply_ability(4)
