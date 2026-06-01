extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)

var player: CharacterBody2D
var displayed_upgrades: Array[String] = []
var ai_pick_in_progress: bool = false

var upgrade_catalog: Dictionary = {
	"speed": {"title": "+ SPEED", "tag": "MOBILITY", "hint": "Move faster and reposition sooner.", "synergy": ["magnet", "oil_slick_level"]},
	"fire_rate": {"title": "+ FIRE RATE", "tag": "WEAPON", "hint": "Shoot more often.", "synergy": ["damage", "cannon", "footsoldier_level", "drone_swarm_level"]},
	"damage": {"title": "+ DAMAGE", "tag": "POWER", "hint": "Raise all direct weapon damage.", "synergy": ["fire_rate", "splash", "piercing", "shock_field_level"]},
	"regeneration": {"title": "+ REGENERATION", "tag": "SUSTAIN", "hint": "Recover health over time.", "synergy": ["armor", "barbed_wire"]},
	"exp": {"title": "+ EXP", "tag": "ECONOMY", "hint": "Level faster from every orb.", "synergy": ["magnet"]},
	"splash": {"title": "+ SPLASH", "tag": "AREA", "hint": "Projectiles explode over a wider radius.", "synergy": ["damage", "piercing", "artillery_level", "landmine_level"]},
	"piercing": {"title": "+ PIERCING", "tag": "CLEAR", "hint": "Shots pass through more targets.", "synergy": ["damage", "splash", "fire_rate"]},
	"barbed_wire": {"title": "+ BARBED WIRE", "tag": "CONTACT", "hint": "Damage enemies that get too close.", "synergy": ["armor", "regeneration", "shock_field_level"]},
	"armor": {"title": "+ ARMOR", "tag": "DEFENSE", "hint": "Reduce incoming hit damage.", "synergy": ["barbed_wire", "regeneration", "circular_saw_level"]},
	"magnet": {"title": "+ MAGNET", "tag": "ECONOMY", "hint": "Pull EXP from farther away.", "synergy": ["exp", "speed", "artillery_level"]},
	"cannon": {"title": "+ CANNON", "tag": "MULTISHOT", "hint": "Add another cannon to each volley.", "synergy": ["damage", "fire_rate", "drone_swarm_level"]},
	"targeting_array": {"title": "+ TARGETING ARRAY", "tag": "ACCESSORY", "hint": "Adds stacking critical hit chance.", "synergy": ["damage", "fire_rate", "cannon"]},
	"accelerator": {"title": "+ ACCELERATOR", "tag": "ACCESSORY", "hint": "Shots travel faster and reach targets sooner.", "synergy": ["piercing", "splash", "payload_rack"]},
	"alloy_plating": {"title": "+ ALLOY PLATING", "tag": "ACCESSORY", "hint": "Raises max health and repairs some HP.", "synergy": ["armor", "regeneration", "reactive_shield"]},
	"recycler": {"title": "+ RECYCLER", "tag": "ACCESSORY", "hint": "Defeated enemies can repair the tank.", "synergy": ["magnet", "exp", "alloy_plating"]},
	"payload_rack": {"title": "+ PAYLOAD RACK", "tag": "ACCESSORY", "hint": "Adds payload blast radius and splash damage.", "synergy": ["splash", "damage", "accelerator"]},
	"reactive_shield": {"title": "+ REACTIVE SHIELD", "tag": "ACCESSORY", "hint": "Extends post-hit invulnerability windows.", "synergy": ["armor", "alloy_plating", "recycler"]},
}

@onready var buttons: Array[Button] = [
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionButton1,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionButton2,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionButton3,
]


func _ready() -> void:
	roll_upgrade_options()


func roll_upgrade_options() -> void:
	var valid_upgrades: Array[String] = player.get_valid_upgrade_ids()
	
	valid_upgrades.shuffle()
	displayed_upgrades = valid_upgrades.slice(0, mini(3, valid_upgrades.size()))
	
	for i in range(buttons.size()):
		if i < displayed_upgrades.size():
			buttons[i].visible = true
			buttons[i].text = get_upgrade_label(displayed_upgrades[i])
			buttons[i].tooltip_text = get_upgrade_tooltip(displayed_upgrades[i])
		else:
			buttons[i].visible = false


func get_upgrade_label(upgrade_id: String) -> String:
	var data: Dictionary = upgrade_catalog.get(upgrade_id, {}) as Dictionary
	if data.is_empty():
		return "UNKNOWN"
	
	var synergy_text := get_synergy_text(upgrade_id)
	if synergy_text != "":
		synergy_text = "\nSYNC: %s" % synergy_text
	return "%s  [%s]\n%s%s" % [
		String(data.title),
		String(data.tag),
		String(data.hint),
		synergy_text,
	]


func get_upgrade_tooltip(upgrade_id: String) -> String:
	var data: Dictionary = upgrade_catalog.get(upgrade_id, {}) as Dictionary
	if data.is_empty():
		return ""
	return "%s\n%s" % [String(data.hint), get_synergy_text(upgrade_id)]


func get_synergy_text(upgrade_id: String) -> String:
	var data: Dictionary = upgrade_catalog.get(upgrade_id, {}) as Dictionary
	var synergy_ids: Array = data.get("synergy", []) as Array
	var active_synergies: Array[String] = []
	for synergy_id in synergy_ids:
		var level := get_synergy_level(String(synergy_id))
		if level > 0:
			active_synergies.append("%s %s" % [get_synergy_label(String(synergy_id)), level])
	
	if not active_synergies.is_empty():
		return ", ".join(active_synergies.slice(0, 2))
	
	if synergy_ids.is_empty():
		return ""
	return "pairs with %s" % get_synergy_label(String(synergy_ids[0]))


func get_synergy_level(synergy_id: String) -> int:
	if player == null:
		return 0
	match synergy_id:
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
		"alloy_plating":
			return player.alloy_plating_level
		"recycler":
			return player.recycler_level
		"payload_rack":
			return player.payload_rack_level
		"reactive_shield":
			return player.reactive_shield_level
		"landmine_level":
			return player.landmine_level
		"circular_saw_level":
			return player.circular_saw_level
		"footsoldier_level":
			return player.footsoldier_level
		"shock_field_level":
			return player.shock_field_level
		"artillery_level":
			return player.artillery_level
		"drone_swarm_level":
			return player.drone_swarm_level
		"oil_slick_level":
			return player.oil_slick_level
		"freeze_pulse_level":
			return player.freeze_pulse_level
	return 0


func get_synergy_label(synergy_id: String) -> String:
	match synergy_id:
		"fire_rate":
			return "Fire Rate"
		"barbed_wire":
			return "Barbed Wire"
		"landmine_level":
			return "Landmine"
		"circular_saw_level":
			return "Circular Saw"
		"footsoldier_level":
			return "Footsoldier"
		"shock_field_level":
			return "Shock Field"
		"artillery_level":
			return "Artillery"
		"drone_swarm_level":
			return "Drone Swarm"
		"oil_slick_level":
			return "Oil Slick"
		"freeze_pulse_level":
			return "Freeze Pulse"
		"targeting_array":
			return "Targeting Array"
		"alloy_plating":
			return "Alloy Plating"
		"payload_rack":
			return "Payload Rack"
		"reactive_shield":
			return "Reactive Shield"
	return synergy_id.capitalize()


func apply_upgrade(slot_index: int) -> void:
	if slot_index >= displayed_upgrades.size():
		return
	
	player.apply_upgrade_by_id(displayed_upgrades[slot_index])
	
	if player.has_method("complete_upgrade_selection"):
		player.complete_upgrade_selection()
	
	queue_free()


func pick_random_upgrade() -> void:
	if displayed_upgrades.is_empty() or ai_pick_in_progress:
		return
	
	ai_pick_in_progress = true
	var slot_index: int = get_ai_upgrade_slot_index()
	await get_tree().create_timer(AI_MENU_VIEW_DELAY, true, false, true).timeout
	if not is_inside_tree():
		return
	highlight_ai_selection(slot_index)
	await get_tree().create_timer(AI_SELECTION_FLASH_DELAY, true, false, true).timeout
	if not is_inside_tree():
		return
	apply_upgrade(slot_index)


func highlight_ai_selection(slot_index: int) -> void:
	for button in buttons:
		button.disabled = true
	
	if slot_index >= buttons.size():
		return
	
	var selected_button: Button = buttons[slot_index]
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = AI_SELECTION_FLASH_COLOR
	selected_style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	selected_style.set_border_width_all(3)
	selected_button.add_theme_stylebox_override("normal", selected_style)
	selected_button.add_theme_stylebox_override("disabled", selected_style)
	selected_button.text = "%s  [AI]" % selected_button.text


func get_ai_upgrade_slot_index() -> int:
	var preferred_upgrade_id := ""
	var main := get_tree().current_scene
	if main and main.has_method("get_ai_preferred_upgrade_id"):
		preferred_upgrade_id = main.get_ai_preferred_upgrade_id(displayed_upgrades)
	
	if preferred_upgrade_id != "":
		var preferred_index: int = displayed_upgrades.find(preferred_upgrade_id)
		if preferred_index >= 0:
			return preferred_index
	
	return randi_range(0, displayed_upgrades.size() - 1)


func _on_option_button_1_pressed() -> void:
	apply_upgrade(0)


func _on_option_button_2_pressed() -> void:
	apply_upgrade(1)


func _on_option_button_3_pressed() -> void:
	apply_upgrade(2)
