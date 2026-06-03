extends Control

const CartoonUiSkin = preload("res://scripts/ui/cartoon_ui_skin.gd")
const GamepadInputSetup = preload("res://scripts/core/gamepad_input_setup.gd")
const MAIN_SCENE = preload("res://scenes/core/main.tscn")
const UPGRADE_MENU = preload("res://scenes/ui/upgrade.tscn")
const ABILITY_MENU = preload("res://scenes/ui/ability_menu.tscn")

const CATEGORIES: Array[String] = [
	"Maps",
	"Tanks",
	"Upgrades",
	"Abilities",
	"Enemies",
	"Bosses",
	"Modifiers",
	"Unlock Goals",
]

@onready var category_selector: OptionButton = $MarginContainer/VBoxContainer/HeaderRow/CategorySelector
@onready var browser_panel: Control = $MarginContainer/VBoxContainer/ContentRow/BrowserPanel
@onready var card_grid: GridContainer = $MarginContainer/VBoxContainer/ContentRow/BrowserPanel/CardScroll/CardGrid
@onready var detail_panel: Control = $MarginContainer/VBoxContainer/ContentRow/DetailPanel
@onready var detail_icon: TextureRect = $MarginContainer/VBoxContainer/ContentRow/DetailPanel/VBoxContainer/DetailIcon
@onready var detail_text: RichTextLabel = $MarginContainer/VBoxContainer/ContentRow/DetailPanel/VBoxContainer/DetailText
@onready var detail_back_button: Button = $MarginContainer/VBoxContainer/ContentRow/DetailPanel/VBoxContainer/DetailBackButton
@onready var back_button: Button = $MarginContainer/VBoxContainer/FooterRow/BackButton

var current_entries: Array[Dictionary] = []


func _ready() -> void:
	GamepadInputSetup.ensure_configured()
	apply_visual_skin()
	populate_categories()
	show_category(0)
	category_selector.grab_focus.call_deferred()


func apply_visual_skin() -> void:
	CartoonUiSkin.apply_label_pop($MarginContainer/VBoxContainer/TitleLabel, Color(1.0, 0.86, 0.24, 1.0))
	CartoonUiSkin.apply_option_button(category_selector)
	CartoonUiSkin.apply_button(back_button, Color(0.54, 0.18, 0.28, 1.0))
	CartoonUiSkin.apply_button(detail_back_button, Color(0.22, 0.34, 0.68, 1.0))


func populate_categories() -> void:
	category_selector.clear()
	for category in CATEGORIES:
		category_selector.add_item(category)


func show_category(category_index: int) -> void:
	current_entries = build_entries_for_category(CATEGORIES[category_index])
	show_browser()
	for child in card_grid.get_children():
		child.queue_free()
	for i in range(current_entries.size()):
		add_entry_card(current_entries[i], i)


func add_entry_card(entry: Dictionary, index: int) -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(180, 140)
	button.text = String(entry.get("name", "Unknown"))
	button.icon = entry.get("texture", null) as Texture2D
	button.expand_icon = true
	button.clip_text = true
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.focus_mode = Control.FOCUS_ALL
	CartoonUiSkin.apply_button(button, entry.get("accent", Color(0.18, 0.32, 0.48, 1.0)) as Color)
	button.pressed.connect(func(): show_entry(index))
	card_grid.add_child(button)


func build_entries_for_category(category: String) -> Array[Dictionary]:
	match category:
		"Maps":
			return get_map_entries()
		"Tanks":
			return get_tank_entries()
		"Upgrades":
			return get_upgrade_entries()
		"Abilities":
			return get_ability_entries()
		"Enemies":
			return get_enemy_entries()
		"Bosses":
			return get_boss_entries()
		"Modifiers":
			return get_modifier_entries()
		"Unlock Goals":
			return get_unlock_goal_entries()
	return []


func get_map_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var run_config = get_run_config()
	var unlock_manager = get_unlock_manager()
	for map_config in run_config.map_catalog:
		var map_id := String(map_config.id)
		var status := "Unlocked" if unlock_manager.is_map_unlocked(map_id) else "Locked"
		entries.append({
			"name": "%s [%s]" % [String(map_config.name), status],
			"texture": load("res://assets/backgrounds/wasteland_arena_generated.png"),
			"accent": get_map_accent(map_id),
			"detail": format_map_detail(map_config, status, unlock_manager.get_map_unlock_hint(map_id)),
		})
	return entries


func format_map_detail(map_config: Dictionary, status: String, unlock_hint: String) -> String:
	var lines: Array[String] = [
		"[b]%s[/b]" % String(map_config.name),
		String(map_config.summary),
		"",
		"Status: %s" % status,
		"Unlock: %s" % unlock_hint,
		"Spawn interval x%.2f, boss interval x%.2f" % [
			float(map_config.get("spawn_interval_multiplier", 1.0)),
			float(map_config.get("boss_spawn_interval_multiplier", 1.0)),
		],
		"Enemy growth: speed x%.2f, health x%.2f, damage x%.2f" % [
			float(map_config.get("enemy_speed_growth_multiplier", 1.0)),
			float(map_config.get("enemy_health_growth_multiplier", 1.0)),
			float(map_config.get("enemy_damage_growth_multiplier", 1.0)),
		],
		"Active cap bonus: %+d, cap limit: %d, elite odds x%.2f" % [
			int(map_config.get("active_enemy_cap_bonus", 0)),
			int(map_config.get("active_enemy_cap_limit", 225)),
			float(map_config.get("elite_chance_multiplier", 1.0)),
		],
		"Gimmick: %s" % String(map_config.get("map_gimmick", "none")).capitalize(),
	]
	return "\n".join(lines)


func get_map_accent(map_id: String) -> Color:
	match map_id:
		"map2":
			return Color(0.55, 0.34, 0.2, 1.0)
		"map3":
			return Color(0.18, 0.52, 0.72, 1.0)
		"map4":
			return Color(0.38, 0.56, 0.18, 1.0)
		"map5":
			return Color(0.28, 0.14, 0.52, 1.0)
	return Color(0.36, 0.32, 0.26, 1.0)


func get_tank_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var run_config = get_run_config()
	var unlock_manager = get_unlock_manager()
	for tank in run_config.tank_archetypes:
		var tank_id := String(tank.id)
		var status := "Unlocked" if unlock_manager.is_tank_unlocked(tank_id) else "Locked"
		entries.append({
			"name": "%s [%s]" % [String(tank.name), status],
			"texture": load("res://assets/visual/player/tank_base_cartoon.png"),
			"accent": tank.get("color", Color(0.22, 0.34, 0.48, 1.0)),
			"detail": format_tank_detail(tank, status, unlock_manager.get_tank_unlock_hint(tank_id)),
		})
	return entries


func format_tank_detail(tank: Dictionary, status: String, unlock_hint: String) -> String:
	var lines: Array[String] = [
		"[b]%s[/b]" % String(tank.name),
		String(tank.summary),
		"",
		"Status: %s" % status,
		"Unlock: %s" % unlock_hint,
		"Speed x%.2f, damage x%.2f, fire interval x%.2f, health %+d" % [
			float(tank.get("speed_multiplier", 1.0)),
			float(tank.get("damage_multiplier", 1.0)),
			float(tank.get("fire_interval_multiplier", 1.0)),
			int(tank.get("health_bonus", 0)),
		],
	]
	lines.append("Starting bonuses: %s" % format_nonzero_keys(tank, [
		"speed_level", "damage_level", "fire_rate_level", "regeneration_level", "armor_level",
		"magnet_level", "cannon_level", "exp_bonus_level", "splash_level", "capacitor_bank_level",
		"landmine_level", "circular_saw_level", "footsoldier_level", "shock_field_level",
		"artillery_level", "drone_swarm_level", "oil_slick_level", "freeze_pulse_level",
		"chain_lightning_level", "flame_wave_level", "repair_beacon_level", "nanite_cloud_level",
		"gravity_well_level",
	]))
	return "\n".join(lines)


func get_upgrade_entries() -> Array[Dictionary]:
	var menu = UPGRADE_MENU.instantiate()
	var catalog: Dictionary = menu.upgrade_catalog
	var ids := catalog.keys()
	ids.sort()
	var entries: Array[Dictionary] = []
	for upgrade_id in ids:
		var data: Dictionary = catalog[upgrade_id]
		entries.append({
			"name": String(data.get("title", upgrade_id)).replace("+ ", ""),
			"texture": menu.get_upgrade_icon(String(upgrade_id)),
			"accent": menu.RARITY_COLORS.get(menu.get_upgrade_rarity(String(upgrade_id)), Color(0.18, 0.32, 0.48, 1.0)),
			"detail": "[b]%s[/b]\nTag: %s\nRarity: %s\nEffect: %s\nSynergy hooks: %s" % [
				String(data.get("title", upgrade_id)),
				String(data.get("tag", "UPGRADE")),
				menu.get_upgrade_rarity(String(upgrade_id)),
				String(data.get("hint", "")),
				", ".join(data.get("synergy", []) as Array),
			],
		})
	menu.free()
	return entries


func get_ability_entries() -> Array[Dictionary]:
	var menu = ABILITY_MENU.instantiate()
	var entries: Array[Dictionary] = []
	for ability in menu.ability_catalog:
		var tags: Array = ability.get("tags", []) as Array
		entries.append({
			"name": String(ability.label).replace("+1 ", "").replace("+ ", ""),
			"texture": menu.get_ability_icon(String(ability.id)),
			"accent": menu.RARITY_COLORS.get(String(ability.get("rarity", "Common")), Color(0.16, 0.40, 0.64, 1.0)),
			"detail": "[b]%s[/b]\nRarity: %s\nBase weight: %.1f\nTags: %s\nUnlock status: %s\nLevel property: %s\nSynergy upgrades: %s\nSynergy abilities: %s" % [
				String(ability.label),
				String(ability.get("rarity", "Common")),
				float(ability.get("base_weight", 1.0)),
				", ".join(tags),
				"Unlocked" if get_unlock_manager().is_ability_unlocked(String(ability.id)) else "Locked",
				String(ability.get("level_property", "")),
				", ".join(ability.get("synergy_upgrades", []) as Array),
				", ".join(ability.get("synergy_abilities", []) as Array),
			],
		})
	menu.free()
	return entries


func get_enemy_entries() -> Array[Dictionary]:
	var main = MAIN_SCENE.instantiate()
	var entries := format_combat_catalog(main.enemy_variant_catalog, false)
	main.free()
	return entries


func get_boss_entries() -> Array[Dictionary]:
	var main = MAIN_SCENE.instantiate()
	var entries := format_combat_catalog(main.boss_variant_catalog, true)
	main.free()
	return entries


func format_combat_catalog(catalog: Array[Dictionary], is_boss: bool) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for config in catalog:
		var weight_text := "Weight %.1f, growth %.1f/min, cap %.1f" % [
			float(config.get("weight", config.get("base_weight", 0.0))),
			float(config.get("growth_per_minute", 0.0)),
			float(config.get("max_weight", 0.0)),
		]
		var detail_lines: Array[String] = [
			"[b]%s[/b]" % String(config.id).capitalize(),
			"Appears after: %s" % format_seconds(float(config.get("unlock_seconds", 0.0))),
			weight_text,
			"Health: %s  Speed: %.1f  Contact damage: %s" % [int(config.get("health", 0)), float(config.get("speed", 0.0)), int(config.get("contact_damage", 0))],
			"EXP drops: %s, min tier %s" % [int(config.get("exp_drop_count", 0)), int(config.get("exp_drop_min_tier", 1))],
			"Scale: %.2f" % float(config.get("scale", 1.0)),
		]
		if is_boss:
			detail_lines.append("Behavior: %s" % String(config.get("behavior", "boss")))
			detail_lines.append("Phase thresholds: %s" % str(config.get("phase_thresholds", [])))
			detail_lines.append("Ability modules: %s" % str(config.get("ability_modules", [])))
		else:
			detail_lines.append("Movement: %s" % String(config.get("movement_style", "chase")))
		entries.append({
			"name": String(config.id).capitalize(),
			"texture": get_combat_texture(config, is_boss),
			"accent": config.get("color", Color(0.18, 0.32, 0.48, 1.0)),
			"detail": "\n".join(detail_lines),
		})
	return entries


func get_modifier_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for modifier in get_run_config().run_modifier_catalog:
		var modifier_id := String(modifier.id)
		var status := "Unlocked" if get_unlock_manager().is_modifier_unlocked(modifier_id) else "Locked"
		entries.append({
			"name": "%s [%s]" % [String(modifier.name), status],
			"texture": load("res://assets/pickups/supply_box_green.png"),
			"accent": Color(0.24, 0.42, 0.24, 1.0),
			"detail": "[b]%s[/b]\n%s\nStatus: %s\nEffects: %s" % [
				String(modifier.name),
				String(modifier.summary),
				status,
				format_modifier_effects(modifier),
			],
		})
	return entries


func get_unlock_goal_entries() -> Array[Dictionary]:
	var unlock_manager = get_unlock_manager()
	var entries: Array[Dictionary] = [{
		"name": "Progress Summary",
		"texture": load("res://assets/pickups/magnet_pickup_sprite.png"),
		"accent": Color(0.25, 0.38, 0.62, 1.0),
		"detail": unlock_manager.get_progress_report(),
	}]
	for goal in unlock_manager.challenge_goal_catalog:
		var status := "Complete" if unlock_manager.completed_challenge_goals.has(String(goal.id)) else "Incomplete"
		entries.append({
			"name": "%s [%s]" % [String(goal.name), status],
			"texture": load("res://assets/pickups/wrench.png"),
			"accent": Color(0.42, 0.28, 0.18, 1.0),
			"detail": "[b]%s[/b]\nMetric: %s\nTarget: %s\nReward: %s\nStatus: %s" % [
				String(goal.name),
				String(goal.metric),
				str(goal.get("threshold", "")),
				String(goal.reward_text),
				status,
			],
		})
	return entries


func show_entry(index: int) -> void:
	if index < 0 or index >= current_entries.size():
		return
	browser_panel.visible = false
	detail_panel.visible = true
	detail_icon.texture = current_entries[index].get("texture", null) as Texture2D
	detail_text.text = String(current_entries[index].get("detail", ""))


func show_browser() -> void:
	browser_panel.visible = true
	detail_panel.visible = false


func get_combat_texture(config: Dictionary, is_boss: bool) -> Texture2D:
	var texture_path := String(config.get("texture", ""))
	if texture_path != "" and ResourceLoader.exists(texture_path):
		return load(texture_path)
	if is_boss:
		return load("res://assets/visual/enemies/boss_core_cartoon.png")
	return load("res://assets/visual/enemies/enemy_scout_cartoon.png")


func format_nonzero_keys(data: Dictionary, keys: Array[String]) -> String:
	var parts: Array[String] = []
	for key in keys:
		var value := int(data.get(key, 0))
		if value != 0:
			parts.append("%s %+d" % [key.replace("_level", "").replace("_", " ").capitalize(), value])
	return ", ".join(parts) if not parts.is_empty() else "None"


func format_modifier_effects(modifier: Dictionary) -> String:
	var ignored := ["id", "name", "summary"]
	var parts: Array[String] = []
	for key in modifier.keys():
		if ignored.has(String(key)):
			continue
		parts.append("%s: %s" % [String(key), str(modifier[key])])
	return ", ".join(parts)


func format_seconds(duration_seconds: float) -> String:
	var total_seconds := int(floor(duration_seconds))
	var minutes := int(float(total_seconds) / 60.0)
	var seconds_remainder := total_seconds % 60
	return "%02d:%02d" % [minutes, seconds_remainder]


func _on_category_selector_item_selected(index: int) -> void:
	show_category(index)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/core/main_menu.tscn")


func _on_detail_back_button_pressed() -> void:
	show_browser()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_button_pressed()
		get_viewport().set_input_as_handled()


func get_run_config() -> Node:
	return get_node("/root/RunConfig")


func get_unlock_manager() -> Node:
	return get_node("/root/UnlockManager")
