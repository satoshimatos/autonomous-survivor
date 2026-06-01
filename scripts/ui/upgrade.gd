extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)
const CartoonUiSkin = preload("res://scripts/ui/cartoon_ui_skin.gd")

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
	"gyro_stabilizer": {"title": "+ GYRO STABILIZER", "tag": "CONTROL", "hint": "Rotate faster and acquire targets sooner.", "synergy": ["fire_rate", "cannon", "accelerator"]},
	"rapid_loader": {"title": "+ RAPID LOADER", "tag": "WEAPON", "hint": "Slightly lowers fire interval.", "synergy": ["fire_rate", "damage", "ammo_synthesizer"]},
	"high_caliber": {"title": "+ HIGH CALIBER", "tag": "POWER", "hint": "Raises damage and projectile size.", "synergy": ["damage", "targeting_array", "piercing"]},
	"nanobots": {"title": "+ NANOBOTS", "tag": "SUSTAIN", "hint": "Increases all healing received.", "synergy": ["regeneration", "recycler", "emergency_repairs"]},
	"kinetic_treads": {"title": "+ KINETIC TREADS", "tag": "MOBILITY", "hint": "Adds another movement speed multiplier.", "synergy": ["speed", "oil_slick_level", "magnet"]},
	"ammo_synthesizer": {"title": "+ AMMO SYNTH", "tag": "MULTISHOT", "hint": "Adds alternating extra shots to volleys.", "synergy": ["cannon", "rapid_loader", "damage"]},
	"shatter_rounds": {"title": "+ SHATTER ROUNDS", "tag": "AREA", "hint": "Adds splash radius and splash damage.", "synergy": ["splash", "payload_rack", "combustion_mix"]},
	"phase_core": {"title": "+ PHASE CORE", "tag": "CLEAR", "hint": "Adds projectile speed and periodic piercing.", "synergy": ["piercing", "accelerator", "high_caliber"]},
	"capacitor_bank": {"title": "+ CAPACITOR BANK", "tag": "POWER", "hint": "Amplifies weapon and power damage.", "synergy": ["damage", "overdrive_core_level", "chain_lightning_level"]},
	"salvage_magnet": {"title": "+ SALVAGE MAGNET", "tag": "ECONOMY", "hint": "Boosts EXP value and pickup pull radius.", "synergy": ["magnet", "exp", "recycler"]},
	"emergency_repairs": {"title": "+ EMERGENCY REPAIRS", "tag": "SUSTAIN", "hint": "Repairs the tank while critically damaged.", "synergy": ["armor", "nanobots", "reactive_shield"]},
	"combustion_mix": {"title": "+ COMBUSTION MIX", "tag": "AREA", "hint": "Raises splash and contact-area damage.", "synergy": ["splash", "barbed_wire", "landmine_level"]},
	"heat_sinks": {"title": "+ HEAT SINKS", "tag": "TEMPO", "hint": "Lowers firing interval without adding shots.", "synergy": ["fire_rate", "overdrive_core_level", "railgun_orbiter_level"]},
	"overclocked_barrel": {"title": "+ OVERCLOCKED BARREL", "tag": "WEAPON", "hint": "Raises damage while slightly lowering fire interval.", "synergy": ["damage", "rapid_loader", "heat_sinks"]},
	"rail_stabilizer": {"title": "+ RAIL STABILIZER", "tag": "PRECISION", "hint": "Adds crit chance and boosts Railgun Orbiter levels.", "synergy": ["targeting_array", "railgun_orbiter_level", "accelerator"]},
	"missile_guidance": {"title": "+ MISSILE GUIDANCE", "tag": "AREA", "hint": "Boosts Missile Pod levels and adds blast radius.", "synergy": ["missile_pod_level", "payload_rack", "ordnance_bay"]},
	"ordnance_bay": {"title": "+ ORDNANCE BAY", "tag": "AREA", "hint": "Raises splash radius, splash damage, and siege power levels.", "synergy": ["splash", "artillery_level", "missile_pod_level"]},
	"field_amplifier": {"title": "+ FIELD AMPLIFIER", "tag": "AURA", "hint": "Boosts aura and field powers every two levels.", "synergy": ["shock_field_level", "flame_wave_level", "gravity_well_level"]},
	"volt_coils": {"title": "+ VOLT COILS", "tag": "POWER", "hint": "Boosts electric powers and power damage.", "synergy": ["chain_lightning_level", "shock_field_level", "capacitor_bank"]},
	"gravity_anchor": {"title": "+ GRAVITY ANCHOR", "tag": "CONTROL", "hint": "Boosts Gravity Well and area damage.", "synergy": ["gravity_well_level", "combustion_mix", "barbed_wire"]},
	"repair_drones": {"title": "+ REPAIR DRONES", "tag": "SUSTAIN", "hint": "Improves healing and Repair Beacon level.", "synergy": ["repair_beacon_level", "nanobots", "recycler"]},
	"crystal_lens": {"title": "+ CRYSTAL LENS", "tag": "ECONOMY", "hint": "Adds EXP value and crit chance.", "synergy": ["exp", "salvage_magnet", "targeting_array"]},
	"munition_printer": {"title": "+ MUNITION PRINTER", "tag": "MULTISHOT", "hint": "Adds periodic extra shots to volleys.", "synergy": ["cannon", "ammo_synthesizer", "ordnance_bay"]},
	"stabilized_chassis": {"title": "+ STABILIZED CHASSIS", "tag": "DEFENSE", "hint": "Adds armor reduction and rotation control.", "synergy": ["armor", "gyro_stabilizer", "reactive_shield"]},
	"vector_thrusters": {"title": "+ VECTOR THRUSTERS", "tag": "MOBILITY", "hint": "Boosts movement, rotation, and projectile speed.", "synergy": ["speed", "accelerator", "kinetic_treads"]},
	"impact_fuse": {"title": "+ IMPACT FUSE", "tag": "AREA", "hint": "Adds blast radius and splash damage.", "synergy": ["splash", "shatter_rounds", "ordnance_bay"]},
	"armor_piercers": {"title": "+ ARMOR PIERCERS", "tag": "CLEAR", "hint": "Adds projectile damage and periodic pierce.", "synergy": ["piercing", "phase_core", "weakpoint_scanner"]},
	"weakpoint_scanner": {"title": "+ WEAKPOINT SCANNER", "tag": "PRECISION", "hint": "Adds crit power and boosts rail beams.", "synergy": ["targeting_array", "rail_stabilizer", "railgun_orbiter_level"]},
	"med_pump": {"title": "+ MED PUMP", "tag": "SUSTAIN", "hint": "Improves healing and emergency repair cadence.", "synergy": ["nanobots", "repair_drones", "emergency_repairs"]},
	"orbit_gears": {"title": "+ ORBIT GEARS", "tag": "CONTACT", "hint": "Boosts orbit contact damage and satellite levels.", "synergy": ["circular_saw_level", "guardian_satellite_level", "barbed_wire"]},
	"mine_dispenser": {"title": "+ MINE DISPENSER", "tag": "DEVICE", "hint": "Places stronger mines more often.", "synergy": ["landmine_level", "combustion_mix", "impact_fuse"]},
	"drone_command": {"title": "+ DRONE COMMAND", "tag": "PET", "hint": "Boosts pet damage and drone-style power levels.", "synergy": ["footsoldier_level", "drone_swarm_level", "guardian_satellite_level"]},
	"lucky_core": {"title": "+ LUCKY CORE", "tag": "LUCK", "hint": "Adds EXP, crit chance, and occasional extra shots.", "synergy": ["crystal_lens", "targeting_array", "munition_printer"]},
}

@onready var buttons: Array[Button] = [
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionButton1,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionButton2,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionButton3,
]


func _ready() -> void:
	apply_visual_skin()
	roll_upgrade_options()


func apply_visual_skin() -> void:
	CartoonUiSkin.apply_label_pop($CanvasLayer/ColorRect/Label, Color(1.0, 0.9, 0.28, 1.0))
	for button in buttons:
		CartoonUiSkin.apply_button(button, Color(0.18, 0.46, 0.34, 1.0))


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
		"gyro_stabilizer":
			return player.gyro_stabilizer_level
		"rapid_loader":
			return player.rapid_loader_level
		"high_caliber":
			return player.high_caliber_level
		"nanobots":
			return player.nanobots_level
		"kinetic_treads":
			return player.kinetic_treads_level
		"ammo_synthesizer":
			return player.ammo_synthesizer_level
		"shatter_rounds":
			return player.shatter_rounds_level
		"phase_core":
			return player.phase_core_level
		"capacitor_bank":
			return player.capacitor_bank_level
		"salvage_magnet":
			return player.salvage_magnet_level
		"emergency_repairs":
			return player.emergency_repairs_level
		"combustion_mix":
			return player.combustion_mix_level
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
		"chain_lightning_level":
			return player.chain_lightning_level
		"guardian_satellite_level":
			return player.guardian_satellite_level
		"overdrive_core_level":
			return player.overdrive_core_level
		"flame_wave_level":
			return player.flame_wave_level
		"repair_beacon_level":
			return player.repair_beacon_level
		"missile_pod_level":
			return player.missile_pod_level
		"gravity_well_level":
			return player.gravity_well_level
		"railgun_orbiter_level":
			return player.railgun_orbiter_level
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
		"gyro_stabilizer":
			return "Gyro Stabilizer"
		"rapid_loader":
			return "Rapid Loader"
		"high_caliber":
			return "High Caliber"
		"kinetic_treads":
			return "Kinetic Treads"
		"ammo_synthesizer":
			return "Ammo Synth"
		"shatter_rounds":
			return "Shatter Rounds"
		"phase_core":
			return "Phase Core"
		"capacitor_bank":
			return "Capacitor Bank"
		"salvage_magnet":
			return "Salvage Magnet"
		"emergency_repairs":
			return "Emergency Repairs"
		"combustion_mix":
			return "Combustion Mix"
		"heat_sinks":
			return "Heat Sinks"
		"overclocked_barrel":
			return "Overclocked Barrel"
		"rail_stabilizer":
			return "Rail Stabilizer"
		"missile_guidance":
			return "Missile Guidance"
		"ordnance_bay":
			return "Ordnance Bay"
		"field_amplifier":
			return "Field Amplifier"
		"volt_coils":
			return "Volt Coils"
		"gravity_anchor":
			return "Gravity Anchor"
		"repair_drones":
			return "Repair Drones"
		"crystal_lens":
			return "Crystal Lens"
		"munition_printer":
			return "Munition Printer"
		"stabilized_chassis":
			return "Stabilized Chassis"
		"vector_thrusters":
			return "Vector Thrusters"
		"impact_fuse":
			return "Impact Fuse"
		"armor_piercers":
			return "Armor Piercers"
		"weakpoint_scanner":
			return "Weakpoint Scanner"
		"med_pump":
			return "Med Pump"
		"orbit_gears":
			return "Orbit Gears"
		"mine_dispenser":
			return "Mine Dispenser"
		"drone_command":
			return "Drone Command"
		"lucky_core":
			return "Lucky Core"
		"chain_lightning_level":
			return "Chain Lightning"
		"guardian_satellite_level":
			return "Guardian Satellite"
		"overdrive_core_level":
			return "Overdrive Core"
		"flame_wave_level":
			return "Flame Wave"
		"repair_beacon_level":
			return "Repair Beacon"
		"missile_pod_level":
			return "Missile Pod"
		"gravity_well_level":
			return "Gravity Well"
		"railgun_orbiter_level":
			return "Railgun Orbiter"
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
