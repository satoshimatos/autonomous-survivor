extends Control

const CartoonUiSkin = preload("res://scripts/ui/cartoon_ui_skin.gd")
const GamepadInputSetup = preload("res://scripts/core/gamepad_input_setup.gd")

@onready var tank_selector: OptionButton = $CenterContainer/VBoxContainer/TankSelector
@onready var tank_summary_label: Label = $CenterContainer/VBoxContainer/TankSummaryLabel
@onready var map_selector: OptionButton = $CenterContainer/VBoxContainer/MapSelector
@onready var map_summary_label: Label = $CenterContainer/VBoxContainer/MapSummaryLabel
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var tank_label: Label = $CenterContainer/VBoxContainer/TankLabel
@onready var map_label: Label = $CenterContainer/VBoxContainer/MapLabel
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var compendium_button: Button = $CenterContainer/VBoxContainer/CompendiumButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var logo: TextureRect = $CenterContainer/VBoxContainer/Logo


func _ready() -> void:
	GamepadInputSetup.ensure_configured()
	apply_visual_skin()
	populate_tank_selector()
	populate_map_selector()
	play_button.grab_focus.call_deferred()


func apply_visual_skin() -> void:
	CartoonUiSkin.apply_label_pop(title_label, Color(1.0, 0.84, 0.16, 1.0))
	logo.pivot_offset = logo.custom_minimum_size * 0.5
	CartoonUiSkin.apply_label_pop(tank_label, Color(0.76, 0.95, 1.0, 1.0))
	CartoonUiSkin.apply_label_pop(tank_summary_label, Color(0.94, 0.98, 1.0, 1.0))
	CartoonUiSkin.apply_label_pop(map_label, Color(0.78, 1.0, 0.84, 1.0))
	CartoonUiSkin.apply_label_pop(map_summary_label, Color(0.94, 1.0, 0.95, 1.0))
	CartoonUiSkin.apply_option_button(tank_selector)
	CartoonUiSkin.apply_option_button(map_selector)
	CartoonUiSkin.apply_button(play_button, Color(0.16, 0.58, 0.32, 1.0))
	CartoonUiSkin.apply_button(compendium_button, Color(0.22, 0.34, 0.68, 1.0))
	CartoonUiSkin.apply_button(quit_button, Color(0.58, 0.18, 0.24, 1.0))


func _on_play_button_pressed() -> void:
	if not get_run_config().can_start_selected_tank() or not get_run_config().can_start_selected_map():
		update_selected_tank(tank_selector.selected)
		update_selected_map(map_selector.selected)
		return
	get_run_config().start_new_run()
	get_tree().change_scene_to_file("res://scenes/core/main.tscn")


func _on_compendium_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/core/compendium_menu.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func populate_tank_selector() -> void:
	tank_selector.clear()
	var selected_index := 0
	var run_config = get_run_config()
	var unlock_manager = get_unlock_manager()
	var tank_archetypes: Array = run_config.tank_archetypes
	for i in range(tank_archetypes.size()):
		var tank: Dictionary = tank_archetypes[i]
		var is_unlocked: bool = unlock_manager.is_tank_unlocked(String(tank.id))
		var label: String = String(tank.name) if is_unlocked else "%s (Locked)" % String(tank.name)
		tank_selector.add_item(label)
		tank_selector.set_item_metadata(i, String(tank.id))
		if is_unlocked and String(tank.id) == String(run_config.selected_tank_id):
			selected_index = i
	
	tank_selector.select(selected_index)
	update_selected_tank(selected_index)


func populate_map_selector() -> void:
	map_selector.clear()
	var selected_index := 0
	var run_config = get_run_config()
	var unlock_manager = get_unlock_manager()
	var map_catalog: Array = run_config.map_catalog
	for i in range(map_catalog.size()):
		var map_config: Dictionary = map_catalog[i]
		var is_unlocked: bool = unlock_manager.is_map_unlocked(String(map_config.id))
		var label: String = String(map_config.name) if is_unlocked else "%s (Locked)" % String(map_config.name)
		map_selector.add_item(label)
		map_selector.set_item_metadata(i, String(map_config.id))
		if is_unlocked and String(map_config.id) == String(run_config.selected_map_id):
			selected_index = i

	map_selector.select(selected_index)
	update_selected_map(selected_index)


func update_selected_tank(index: int) -> void:
	var tank_id := String(tank_selector.get_item_metadata(index))
	var run_config = get_run_config()
	var unlock_manager = get_unlock_manager()
	var tank: Dictionary = run_config.get_tank_by_id(tank_id)
	var is_unlocked: bool = unlock_manager.is_tank_unlocked(tank_id)
	if is_unlocked:
		run_config.set_selected_tank(tank_id)
		tank_summary_label.text = "%s\nUnlocked" % String(tank.summary)
	else:
		run_config.selected_tank_id = tank_id
		tank_summary_label.text = "%s\nUnlock: %s" % [String(tank.summary), unlock_manager.get_tank_unlock_hint(tank_id)]
	update_play_button_state()


func update_selected_map(index: int) -> void:
	var map_id := String(map_selector.get_item_metadata(index))
	var run_config = get_run_config()
	var unlock_manager = get_unlock_manager()
	var map_config: Dictionary = run_config.get_map_by_id(map_id)
	var is_unlocked: bool = unlock_manager.is_map_unlocked(map_id)
	if is_unlocked:
		run_config.set_selected_map(map_id)
		map_summary_label.text = "%s\nUnlocked" % String(map_config.summary)
	else:
		run_config.selected_map_id = map_id
		map_summary_label.text = "%s\nUnlock: %s" % [String(map_config.summary), unlock_manager.get_map_unlock_hint(map_id)]
	update_play_button_state()


func update_play_button_state() -> void:
	var can_start: bool = get_run_config().can_start_selected_tank() and get_run_config().can_start_selected_map()
	play_button.disabled = not can_start
	play_button.text = "Play" if can_start else "Locked"


func _on_tank_selector_item_selected(index: int) -> void:
	update_selected_tank(index)


func _on_map_selector_item_selected(index: int) -> void:
	update_selected_map(index)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_previous") or event.is_action_pressed("ui_left"):
		if map_selector.has_focus():
			select_relative_unlocked_map(-1)
		else:
			select_relative_unlocked_tank(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu_next") or event.is_action_pressed("ui_right"):
		if map_selector.has_focus():
			select_relative_unlocked_map(1)
		else:
			select_relative_unlocked_tank(1)
		get_viewport().set_input_as_handled()


func select_relative_unlocked_tank(direction: int) -> void:
	if tank_selector.item_count <= 0:
		return

	var index := tank_selector.selected
	for step in range(tank_selector.item_count):
		index = wrapi(index + direction, 0, tank_selector.item_count)
		tank_selector.select(index)
		update_selected_tank(index)
		return


func select_relative_unlocked_map(direction: int) -> void:
	if map_selector.item_count <= 0:
		return

	var index := map_selector.selected
	for step in range(map_selector.item_count):
		index = wrapi(index + direction, 0, map_selector.item_count)
		map_selector.select(index)
		update_selected_map(index)
		return


func get_run_config() -> Node:
	return get_node("/root/RunConfig")


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")
