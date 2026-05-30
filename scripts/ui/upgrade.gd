extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)

var player: CharacterBody2D
var displayed_upgrades: Array[String] = []
var ai_pick_in_progress: bool = false

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
		else:
			buttons[i].visible = false


func get_upgrade_label(upgrade_id: String) -> String:
	match upgrade_id:
		"speed":
			return "+ SPEED"
		"fire_rate":
			return "+ FIRE RATE"
		"damage":
			return "+ DAMAGE"
		"regeneration":
			return "+ REGENERATION"
		"exp":
			return "+ EXP"
		"splash":
			return "+ SPLASH"
		"piercing":
			return "+ PIERCING"
		"barbed_wire":
			return "+ BARBED WIRE"
		"armor":
			return "+ ARMOR"
		"magnet":
			return "+ MAGNET"
		"cannon":
			return "+ CANNON"
	
	return "UNKNOWN"


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
