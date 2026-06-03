extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)
const OPTION_COUNT: int = 3
const CartoonUiSkin = preload("res://scripts/ui/cartoon_ui_skin.gd")
const AbilityCatalog = preload("res://scripts/core/ability_catalog.gd")
const RARITY_COLORS: Dictionary = {
	"Common": Color(0.14, 0.42, 0.58, 1.0),
	"Uncommon": Color(0.08, 0.62, 0.84, 1.0),
	"Rare": Color(0.40, 0.22, 0.82, 1.0),
	"Epic": Color(0.9, 0.36, 0.12, 1.0),
}

var player: CharacterBody2D
var ai_pick_in_progress: bool = false
var selection_locked: bool = false
var displayed_abilities: Array[Dictionary] = []

var ability_catalog: Array[Dictionary] = AbilityCatalog.get_entries()

@onready var ability_buttons: Array[Button] = [
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/AbilityButton1,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/AbilityButton2,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/AbilityButton3,
]
@onready var detail_label: Label = $CanvasLayer/ColorRect/MarginContainer/VBoxContainer/DetailLabel
@onready var celebration: Control = $CanvasLayer/ChoiceCelebration


func _ready() -> void:
	apply_visual_skin()
	connect_focus_updates()
	roll_ability_options()
	if not ability_buttons.is_empty() and ability_buttons[0].visible:
		ability_buttons[0].grab_focus.call_deferred()


func apply_visual_skin() -> void:
	CartoonUiSkin.apply_label_pop($CanvasLayer/ColorRect/Label, Color(0.74, 0.92, 1.0, 1.0))
	CartoonUiSkin.apply_label_pop(detail_label, Color(0.92, 0.98, 1.0, 1.0))
	for button in ability_buttons:
		CartoonUiSkin.apply_button(button, Color(0.22, 0.34, 0.62, 1.0))
		button.focus_mode = Control.FOCUS_ALL


func connect_focus_updates() -> void:
	for i in range(ability_buttons.size()):
		var slot_index := i
		ability_buttons[i].focus_entered.connect(func(): update_detail_for_slot(slot_index))
		ability_buttons[i].mouse_entered.connect(func(): update_detail_for_slot(slot_index))


func roll_ability_options() -> void:
	displayed_abilities = roll_weighted_ability_options()
	
	for i in range(ability_buttons.size()):
		var button := ability_buttons[i]
		if i < displayed_abilities.size():
			button.visible = true
			configure_card_button(button, displayed_abilities[i])
			button.disabled = false
		else:
			button.visible = false

	update_detail_for_slot(0)


func configure_card_button(button: Button, ability: Dictionary) -> void:
	var rarity := String(ability.get("rarity", "Common"))
	var tags: Array = ability.get("tags", []) as Array
	var tag_text := String(tags[0]).to_upper() if not tags.is_empty() else "POWER"
	button.text = ""
	button.icon = null
	CartoonUiSkin.apply_button(button, RARITY_COLORS.get(rarity, RARITY_COLORS["Common"]) as Color)
	(button.get_node("NameLabel") as Label).text = String(ability.get("label", "ABILITY")).replace("+1 ", "").replace("+ ", "")
	(button.get_node("TagLabel") as Label).text = "[%s]  %s" % [rarity.to_upper(), tag_text]
	(button.get_node("Icon") as TextureRect).texture = get_ability_icon(String(ability.get("id", "")))


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
		if unlock_manager.is_ability_unlocked(String(ability.id)) and are_ability_prerequisites_met(ability):
			unlocked_options.append(ability.duplicate(true))
	if unlocked_options.is_empty() and not ability_catalog.is_empty():
		for ability in ability_catalog:
			if unlock_manager.is_ability_unlocked(String(ability.id)):
				unlocked_options.append(ability.duplicate(true))
				break
	return unlocked_options


func are_ability_prerequisites_met(ability: Dictionary) -> bool:
	var ability_id := String(ability.get("id", ""))
	match ability_id:
		"artillery":
			return get_upgrade_level("splash") > 0 or get_player_property_as_int("landmine_level") > 0 or get_player_property_as_int("oil_slick_level") > 0
		"drone_swarm":
			return get_player_property_as_int("footsoldier_level") > 0 or get_upgrade_level("cannon") > 0
		"freeze_pulse":
			return get_player_property_as_int("shock_field_level") > 0 or get_player_property_as_int("circular_saw_level") > 0 or get_upgrade_level("armor") > 0
		"chain_lightning":
			return get_player_property_as_int("shock_field_level") > 0
		"guardian_satellite":
			return get_player_property_as_int("circular_saw_level") > 0 or get_upgrade_level("armor") > 0
		"overdrive_core":
			return get_upgrade_level("speed") > 0 or get_upgrade_level("damage") > 0
		"flame_wave":
			return get_player_property_as_int("oil_slick_level") > 0 or get_upgrade_level("splash") > 0
		"repair_beacon":
			return get_upgrade_level("nanobots") > 0 or get_upgrade_level("reactive_shield") > 0 or get_upgrade_level("armor") > 0
		"missile_pod":
			return get_player_property_as_int("artillery_level") > 0 or get_upgrade_level("splash") > 0
		"gravity_well":
			return get_player_property_as_int("flame_wave_level") > 0 or get_player_property_as_int("chain_lightning_level") > 0
		"railgun_orbiter":
			return get_upgrade_level("piercing") > 0 or get_upgrade_level("targeting_array") > 0
		"tesla_pylon":
			return get_player_property_as_int("chain_lightning_level") > 0 or get_player_property_as_int("shock_field_level") > 0
		"nanite_cloud":
			return get_player_property_as_int("repair_beacon_level") > 0 or get_upgrade_level("nanobots") > 0
		"ricochet_rounds":
			return get_player_property_as_int("railgun_orbiter_level") > 0 or get_player_property_as_int("chain_lightning_level") > 0
		"chrono_burst":
			return get_player_property_as_int("gravity_well_level") > 0 or get_player_property_as_int("freeze_pulse_level") > 0
		"munition_swarm":
			return get_upgrade_level("cannon") > 0 or get_upgrade_level("drone_command") > 0 or get_player_property_as_int("drone_swarm_level") > 0
		"fortress_protocol":
			return get_upgrade_level("armor") > 0 or get_upgrade_level("nanobots") > 0 or get_player_property_as_int("guardian_satellite_level") > 0
		"storm_catalyst":
			return get_upgrade_level("volt_coils") > 0 or get_player_property_as_int("chain_lightning_level") > 0 or get_player_property_as_int("tesla_pylon_level") > 0
		"golden_reactor":
			return get_upgrade_level("exp") > 0 or get_upgrade_level("lucky_core") > 0
	return true


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
	if player.has_method("get_passive_power_level"):
		var passive_level := int(player.get_passive_power_level(property_name))
		if passive_level > 0:
			return passive_level
	var value = player.get(property_name)
	return int(value) if value != null else 0


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")


func get_ability_icon(ability_id: String) -> Texture2D:
	var icon_path := "res://assets/ui/icons/abilities/icon_ability_%s.png" % ability_id
	if ResourceLoader.exists(icon_path):
		return load(icon_path)
	return null


func update_detail_for_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= displayed_abilities.size():
		detail_label.text = ""
		return
	var ability: Dictionary = displayed_abilities[slot_index]
	var tags: Array = ability.get("tags", []) as Array
	var level_property := String(ability.get("level_property", ""))
	var level := get_player_property_as_int(level_property)
	var tag_text := ", ".join(tags)
	detail_label.text = "%s. Current level: %s. Tags: %s. %s" % [
		String(ability.get("summary", String(ability.get("rarity", "Common")))),
		level,
		tag_text if tag_text != "" else "power",
		String(ability.get("rarity", "Common"))
	]


func apply_ability(slot_index: int) -> void:
	if selection_locked or slot_index >= displayed_abilities.size():
		return
	
	selection_locked = true
	await play_selection_feedback(slot_index)
	if not is_inside_tree():
		return
	var method_name := String(displayed_abilities[slot_index].method)
	if player and player.has_method(method_name):
		player.call(method_name)
		if player.has_method("update_evolutions"):
			player.update_evolutions()
	complete_selection()


func play_selection_feedback(slot_index: int) -> void:
	for button in ability_buttons:
		button.disabled = true
	if slot_index < 0 or slot_index >= ability_buttons.size():
		return

	update_detail_for_slot(slot_index)
	var selected_button := ability_buttons[slot_index]
	var ability := displayed_abilities[slot_index]
	var rarity := String(ability.get("rarity", "Common"))
	var accent: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["Common"]) as Color
	if celebration and celebration.has_method("celebrate_pick"):
		celebration.call("celebrate_pick", selected_button.get_global_rect().get_center(), accent)

	selected_button.pivot_offset = selected_button.size * 0.5
	var tween := selected_button.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(selected_button, "scale", Vector2(1.12, 1.12), 0.12)
	tween.tween_property(selected_button, "rotation", 0.035, 0.12)
	tween.chain().tween_property(selected_button, "scale", Vector2(1.0, 1.0), 0.16)
	tween.tween_property(selected_button, "rotation", 0.0, 0.16)
	await get_tree().create_timer(0.2, true, false, true).timeout


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
	(selected_button.get_node("TagLabel") as Label).text = "[AI PICK]"


func _on_ability_button_1_pressed() -> void:
	apply_ability(0)


func _on_ability_button_2_pressed() -> void:
	apply_ability(1)


func _on_ability_button_3_pressed() -> void:
	apply_ability(2)
