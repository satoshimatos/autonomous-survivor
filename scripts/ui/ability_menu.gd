extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)
const OPTION_COUNT: int = 3

var player: CharacterBody2D
var ai_pick_in_progress: bool = false
var displayed_abilities: Array[Dictionary] = []

var ability_catalog: Array[Dictionary] = [
	{"label": "+1 PLACE LANDMINE", "method": "upgrade_landmine"},
	{"label": "+1 CIRCULAR SAW", "method": "upgrade_circular_saw"},
	{"label": "+ FOOTSOLDIER", "method": "upgrade_footsoldier"},
	{"label": "+ SHOCK FIELD", "method": "upgrade_shock_field"},
	{"label": "+ ARTILLERY", "method": "upgrade_artillery"},
	{"label": "+ DRONE SWARM", "method": "upgrade_drone_swarm"},
	{"label": "+ OIL SLICK", "method": "upgrade_oil_slick"},
	{"label": "+ FREEZE PULSE", "method": "upgrade_freeze_pulse"},
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
	var options := ability_catalog.duplicate()
	options.shuffle()
	displayed_abilities = options.slice(0, OPTION_COUNT)
	
	for i in range(ability_buttons.size()):
		var button := ability_buttons[i]
		if i < displayed_abilities.size():
			button.visible = true
			button.text = String(displayed_abilities[i].label)
			button.disabled = false
		else:
			button.visible = false


func apply_ability(slot_index: int) -> void:
	if slot_index >= displayed_abilities.size():
		return
	
	var method_name := String(displayed_abilities[slot_index].method)
	if player and player.has_method(method_name):
		player.call(method_name)
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
