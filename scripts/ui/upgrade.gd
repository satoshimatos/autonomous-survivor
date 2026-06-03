extends Control

const AI_MENU_VIEW_DELAY: float = 0.5
const AI_SELECTION_FLASH_DELAY: float = 0.5
const AI_SELECTION_FLASH_COLOR: Color = Color(1.0, 0.95, 0.25, 1.0)
const CartoonUiSkin = preload("res://scripts/ui/cartoon_ui_skin.gd")
const RARITY_COLORS: Dictionary = {
	"Common": Color(0.20, 0.46, 0.34, 1.0),
	"Uncommon": Color(0.16, 0.42, 0.72, 1.0),
	"Rare": Color(0.50, 0.24, 0.78, 1.0),
	"Epic": Color(0.86, 0.42, 0.12, 1.0),
}

var player: CharacterBody2D
var displayed_upgrades: Array[String] = []
var ai_pick_in_progress: bool = false
var selection_locked: bool = false

var upgrade_catalog: Dictionary = {
	"speed": {"title": "+ SPEED", "tag": "MOBILITY", "hint": "Raises tank movement speed.", "synergy": ["magnet", "oil_slick_level"]},
	"fire_rate": {"title": "+ FIRE RATE", "tag": "WEAPON", "hint": "Reduces cannon cooldown so the tank shoots more often.", "synergy": ["damage", "cannon", "footsoldier_level", "drone_swarm_level"]},
	"damage": {"title": "+ DAMAGE", "tag": "WEAPON", "hint": "Raises main cannon damage.", "synergy": ["fire_rate", "splash", "piercing", "shock_field_level"]},
	"regeneration": {"title": "+ REGENERATION", "tag": "SUSTAIN", "hint": "Repairs the tank slowly over time.", "synergy": ["armor", "barbed_wire"]},
	"exp": {"title": "+ EXP VALUE", "tag": "ECONOMY", "hint": "Makes every EXP crystal worth more.", "synergy": ["magnet"]},
	"splash": {"title": "+ SPLASH", "tag": "AREA", "hint": "Adds an explosion radius to cannon shells.", "synergy": ["damage", "piercing", "artillery_level", "landmine_level"]},
	"piercing": {"title": "+ PIERCING", "tag": "CLEAR", "hint": "Lets cannon shells hit additional enemies before disappearing.", "synergy": ["damage", "splash", "fire_rate"]},
	"barbed_wire": {"title": "+ BARBED WIRE", "tag": "CONTACT", "hint": "Creates a close-range damage ring around the tank.", "synergy": ["armor", "regeneration", "shock_field_level"]},
	"armor": {"title": "+ ARMOR", "tag": "DEFENSE", "hint": "Reduce incoming hit damage.", "synergy": ["barbed_wire", "regeneration", "circular_saw_level"]},
	"magnet": {"title": "+ MAGNET", "tag": "ECONOMY", "hint": "Pull EXP from farther away.", "synergy": ["exp", "speed", "artillery_level"]},
	"cannon": {"title": "+ MULTISHOT", "tag": "MULTISHOT", "hint": "Adds another shell to each cannon volley.", "synergy": ["damage", "fire_rate", "drone_swarm_level"]},
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
	"auto_loader": {"title": "+ AUTO LOADER", "tag": "TEMPO", "hint": "Slightly lowers cannon cooldown.", "synergy": ["fire_rate"]},
	"focus_lens": {"title": "+ FOCUS LENS", "tag": "CRIT", "hint": "Adds crit chance and crit damage after Targeting Array.", "synergy": ["targeting_array"]},
	"reinforced_tracks": {"title": "+ REINFORCED TRACKS", "tag": "DEFENSE", "hint": "Adds armor and a small speed boost.", "synergy": ["speed", "armor"]},
	"field_medic_kit": {"title": "+ FIELD MEDIC KIT", "tag": "SUSTAIN", "hint": "Raises healing received and max health.", "synergy": ["nanobots", "repair_beacon_level"]},
	"repair_gel": {"title": "+ REPAIR GEL", "tag": "SUSTAIN", "hint": "Strongly improves all healing after Nanobots.", "synergy": ["nanobots"]},
	"salvage_claws": {"title": "+ SALVAGE CLAWS", "tag": "SUSTAIN", "hint": "Increases the chance for enemy kills to repair the tank.", "synergy": ["recycler"]},
	"wide_nozzle": {"title": "+ WIDE NOZZLE", "tag": "AREA", "hint": "Expands shell explosion radius.", "synergy": ["splash"]},
	"chain_fuse": {"title": "+ CHAIN FUSE", "tag": "AREA", "hint": "Raises explosion damage.", "synergy": ["splash"]},
	"reactive_tracks": {"title": "+ REACTIVE TRACKS", "tag": "MOBILITY", "hint": "Adds speed and slightly longer safety after being hit.", "synergy": ["speed", "reactive_shield"]},
	"polished_barrel": {"title": "+ POLISHED BARREL", "tag": "WEAPON", "hint": "Raises cannon damage and shell speed.", "synergy": ["damage", "accelerator"]},
	"pickup_scoop": {"title": "+ PICKUP SCOOP", "tag": "ECONOMY", "hint": "Increases pickup reach for crystals and repair items.", "synergy": ["magnet"]},
	"overcharger": {"title": "+ OVERCHARGER", "tag": "POWER", "hint": "Raises ability damage after owning a power.", "synergy": ["shock_field_level", "capacitor_bank"]},
	"boss_buster": {"title": "+ BOSS BUSTER", "tag": "WEAPON", "hint": "Adds damage pressure intended for boss fights.", "synergy": ["damage"]},
	"elite_hunter": {"title": "+ ELITE HUNTER", "tag": "WEAPON", "hint": "Adds damage pressure against dangerous special enemies.", "synergy": ["damage"]},
	"crystal_converter": {"title": "+ CRYSTAL CONVERTER", "tag": "ECONOMY", "hint": "Increases EXP value after taking EXP upgrades.", "synergy": ["exp"]},
	"armor_gasket": {"title": "+ ARMOR GASKET", "tag": "DEFENSE", "hint": "Adds armor and improves healing.", "synergy": ["armor", "nanobots"]},
	"blast_compound": {"title": "+ BLAST COMPOUND", "tag": "AREA", "hint": "Raises explosion radius and explosion damage.", "synergy": ["splash"]},
	"coolant_loop": {"title": "+ COOLANT LOOP", "tag": "TEMPO", "hint": "Slightly lowers cannon cooldown and improves power damage.", "synergy": ["fire_rate", "capacitor_bank"]},
	"recoil_brace": {"title": "+ RECOIL BRACE", "tag": "WEAPON", "hint": "Raises cannon damage and crit chance.", "synergy": ["damage", "targeting_array"]},
	"split_chamber": {"title": "+ SPLIT CHAMBER", "tag": "MULTISHOT", "hint": "Adds a chance to fire one extra shell after taking Multishot.", "synergy": ["cannon"]},
	"power_coupler": {"title": "+ POWER COUPLER", "tag": "POWER", "hint": "Raises ability damage after owning a power.", "synergy": ["shock_field_level"]},
	"shock_absorbers": {"title": "+ SHOCK ABSORBERS", "tag": "DEFENSE", "hint": "Adds armor and slightly longer hit protection.", "synergy": ["armor"]},
	"supply_scanner": {"title": "+ SUPPLY SCANNER", "tag": "ECONOMY", "hint": "Improves pickup reach and EXP value.", "synergy": ["magnet", "exp"]},
	"wrench_arm": {"title": "+ WRENCH ARM", "tag": "SUSTAIN", "hint": "Greatly improves repair pickup reach and healing received.", "synergy": ["magnet", "nanobots"]},
	"battle_vault": {"title": "+ BATTLE VAULT", "tag": "DEFENSE", "hint": "Adds max health and armor.", "synergy": ["armor"]},
	"kinetic_capacitor": {"title": "+ KINETIC CAPACITOR", "tag": "MOBILITY", "hint": "Adds speed and power damage after movement upgrades.", "synergy": ["speed"]},
	"prism_rounds": {"title": "+ PRISM ROUNDS", "tag": "CRIT", "hint": "Adds crit chance and shell speed after Piercing.", "synergy": ["piercing"]},
	"target_link": {"title": "+ TARGET LINK", "tag": "PET", "hint": "Improves crit chance and pet damage after owning a pet.", "synergy": ["footsoldier_level"]},
	"flare_core": {"title": "+ FLARE CORE", "tag": "AREA", "hint": "Improves area and power damage after Flame Wave.", "synergy": ["flame_wave_level"]},
	"lucky_battery": {"title": "+ LUCKY BATTERY", "tag": "LUCK", "hint": "Adds EXP value and occasional extra shells after Lucky Core.", "synergy": ["lucky_core"]},
	"thermal_jacket": {"title": "+ THERMAL JACKET", "tag": "TEMPO", "hint": "Adds armor while slightly improving firing cadence after Fire Rate.", "synergy": ["fire_rate", "armor"]},
	"shrapnel_matrix": {"title": "+ SHRAPNEL MATRIX", "tag": "AREA", "hint": "Raises explosion damage and crit damage after Splash.", "synergy": ["splash", "targeting_array"]},
	"hollow_point_feed": {"title": "+ HOLLOW POINT FEED", "tag": "WEAPON", "hint": "Raises cannon damage and crit damage after Damage.", "synergy": ["damage", "targeting_array"]},
	"engine_supercharger": {"title": "+ ENGINE SUPERCHARGER", "tag": "MOBILITY", "hint": "Boosts tank speed and shell speed after Speed.", "synergy": ["speed", "accelerator"]},
	"field_siphon": {"title": "+ FIELD SIPHON", "tag": "SUSTAIN", "hint": "Improves kill-repair chance and healing after Recycler.", "synergy": ["recycler", "nanobots"]},
	"orbital_prism": {"title": "+ ORBITAL PRISM", "tag": "MULTISHOT", "hint": "Adds extra-shell chance and crit chance after Prism Rounds.", "synergy": ["prism_rounds", "cannon"]},
	"nano_plating": {"title": "+ NANO PLATING", "tag": "DEFENSE", "hint": "Adds armor and stronger repairs after Nanobots.", "synergy": ["nanobots", "armor"]},
	"kinetic_scoop": {"title": "+ KINETIC SCOOP", "tag": "ECONOMY", "hint": "Raises pickup reach and speed after Magnet.", "synergy": ["magnet", "speed"]},
	"capacitor_mesh": {"title": "+ CAPACITOR MESH", "tag": "POWER", "hint": "Raises ability damage and crit chance after Capacitor Bank.", "synergy": ["capacitor_bank", "targeting_array"]},
	"drone_uplink": {"title": "+ DRONE UPLINK", "tag": "PET", "hint": "Improves pet damage and projectile damage after Drone Command.", "synergy": ["drone_command", "footsoldier_level"]},
	"blast_retainer": {"title": "+ BLAST RETAINER", "tag": "AREA", "hint": "Adds blast radius, blast damage, and area damage after Splash.", "synergy": ["splash", "combustion_mix"]},
	"mender_tracks": {"title": "+ MENDER TRACKS", "tag": "SUSTAIN", "hint": "Adds speed and healing after Field Medic Kit.", "synergy": ["field_medic_kit", "speed"]},
	"lucky_shrapnel": {"title": "+ LUCKY SHRAPNEL", "tag": "LUCK", "hint": "Adds extra shells and explosion damage after Lucky Core.", "synergy": ["lucky_core", "splash"]},
	"gravity_fins": {"title": "+ GRAVITY FINS", "tag": "CONTROL", "hint": "Adds shell speed and area damage after Gravity Anchor.", "synergy": ["gravity_anchor", "accelerator"]},
	"reinforced_ammo_belt": {"title": "+ REINFORCED AMMO BELT", "tag": "MULTISHOT", "hint": "Slightly improves fire cadence and extra-shell chance after Fire Rate.", "synergy": ["fire_rate", "cannon"]},
	"crystal_reservoir": {"title": "+ CRYSTAL RESERVOIR", "tag": "ECONOMY", "hint": "Raises EXP value and pickup reach after EXP Value.", "synergy": ["exp", "magnet"]},
	"storm_insulator": {"title": "+ STORM INSULATOR", "tag": "POWER", "hint": "Adds armor and power damage after Volt Coils.", "synergy": ["volt_coils", "armor"]},
	"target_predictor": {"title": "+ TARGET PREDICTOR", "tag": "CRIT", "hint": "Adds crit chance and shell speed after Targeting Array.", "synergy": ["targeting_array", "accelerator"]},
	"emergency_battery": {"title": "+ EMERGENCY BATTERY", "tag": "SUSTAIN", "hint": "Adds max health, power damage, and healing after Overdrive Core.", "synergy": ["overdrive_core_level", "nanobots"]},
	"singularity_lens": {"title": "+ SINGULARITY LENS", "tag": "POWER", "hint": "Greatly improves area damage, pickup reach, and power damage after Black Hole Mines.", "synergy": ["black_hole_mines"]},
}

@onready var buttons: Array[Button] = [
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/OptionButton1,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/OptionButton2,
	$CanvasLayer/ColorRect/MarginContainer/VBoxContainer/OptionsRow/OptionButton3,
]
@onready var detail_label: Label = $CanvasLayer/ColorRect/MarginContainer/VBoxContainer/DetailLabel
@onready var celebration: Control = $CanvasLayer/ChoiceCelebration


func _ready() -> void:
	apply_visual_skin()
	connect_focus_updates()
	roll_upgrade_options()
	if not buttons.is_empty() and buttons[0].visible:
		buttons[0].grab_focus.call_deferred()


func apply_visual_skin() -> void:
	CartoonUiSkin.apply_label_pop($CanvasLayer/ColorRect/Label, Color(1.0, 0.9, 0.28, 1.0))
	CartoonUiSkin.apply_label_pop(detail_label, Color(0.95, 1.0, 0.93, 1.0))
	for button in buttons:
		CartoonUiSkin.apply_button(button, Color(0.18, 0.46, 0.34, 1.0))
		button.focus_mode = Control.FOCUS_ALL


func connect_focus_updates() -> void:
	for i in range(buttons.size()):
		var slot_index := i
		buttons[i].focus_entered.connect(func(): update_detail_for_slot(slot_index))
		buttons[i].mouse_entered.connect(func(): update_detail_for_slot(slot_index))


func roll_upgrade_options() -> void:
	if player == null:
		for button in buttons:
			button.visible = false
		detail_label.text = "Upgrade preview requires an active run."
		return
	var valid_upgrades: Array[String] = player.get_valid_upgrade_ids()
	
	valid_upgrades.shuffle()
	displayed_upgrades = valid_upgrades.slice(0, mini(3, valid_upgrades.size()))
	
	for i in range(buttons.size()):
		if i < displayed_upgrades.size():
			buttons[i].visible = true
			configure_card_button(buttons[i], displayed_upgrades[i])
		else:
			buttons[i].visible = false

	update_detail_for_slot(0)


func configure_card_button(button: Button, upgrade_id: String) -> void:
	var data: Dictionary = upgrade_catalog.get(upgrade_id, {}) as Dictionary
	var rarity := get_upgrade_rarity(upgrade_id)
	button.text = ""
	button.tooltip_text = ""
	button.icon = null
	CartoonUiSkin.apply_button(button, RARITY_COLORS.get(rarity, RARITY_COLORS["Common"]) as Color)
	(button.get_node("NameLabel") as Label).text = String(data.get("title", "UNKNOWN")).replace("+ ", "")
	(button.get_node("TagLabel") as Label).text = "[%s]  %s" % [rarity.to_upper(), String(data.get("tag", "UPGRADE"))]
	(button.get_node("Icon") as TextureRect).texture = get_upgrade_icon(upgrade_id)


func get_upgrade_rarity(upgrade_id: String) -> String:
	match upgrade_id:
		"speed", "exp", "armor", "magnet", "barbed_wire", "regeneration", "auto_loader", "pickup_scoop", "field_medic_kit", "reinforced_tracks", "supply_scanner", "crystal_reservoir":
			return "Common"
		"fire_rate", "damage", "splash", "piercing", "targeting_array", "accelerator", "alloy_plating", "recycler", "payload_rack", "reactive_shield", "gyro_stabilizer", "rapid_loader", "nanobots", "kinetic_treads", "shatter_rounds", "phase_core", "salvage_magnet", "emergency_repairs", "focus_lens", "repair_gel", "chain_fuse", "reactive_tracks", "polished_barrel", "crystal_converter", "armor_gasket", "coolant_loop", "recoil_brace", "shock_absorbers", "wrench_arm", "prism_rounds", "thermal_jacket", "engine_supercharger", "kinetic_scoop", "mender_tracks":
			return "Uncommon"
		"cannon", "high_caliber", "ammo_synthesizer", "capacitor_bank", "combustion_mix", "heat_sinks", "overclocked_barrel", "rail_stabilizer", "missile_guidance", "ordnance_bay", "field_amplifier", "volt_coils", "gravity_anchor", "repair_drones", "crystal_lens", "munition_printer", "stabilized_chassis", "vector_thrusters", "impact_fuse", "armor_piercers", "weakpoint_scanner", "med_pump", "orbit_gears", "mine_dispenser", "drone_command", "salvage_claws", "wide_nozzle", "overcharger", "boss_buster", "elite_hunter", "blast_compound", "split_chamber", "power_coupler", "battle_vault", "kinetic_capacitor", "target_link", "flare_core", "shrapnel_matrix", "hollow_point_feed", "field_siphon", "nano_plating", "capacitor_mesh", "drone_uplink", "blast_retainer", "gravity_fins", "reinforced_ammo_belt", "storm_insulator", "target_predictor":
			return "Rare"
		"lucky_core", "lucky_battery", "orbital_prism", "lucky_shrapnel", "emergency_battery", "singularity_lens":
			return "Epic"
	return "Common"


func get_upgrade_label(upgrade_id: String) -> String:
	var data: Dictionary = upgrade_catalog.get(upgrade_id, {}) as Dictionary
	if data.is_empty():
		return "UNKNOWN"
	
	var synergy_text := get_synergy_text(upgrade_id)
	if synergy_text != "":
		synergy_text = "\nSYNC: %s" % synergy_text
	return "%s\n[%s]%s" % [
		String(data.title),
		String(data.tag),
		synergy_text,
	]


func get_upgrade_tooltip(upgrade_id: String) -> String:
	var data: Dictionary = upgrade_catalog.get(upgrade_id, {}) as Dictionary
	if data.is_empty():
		return ""
	return "%s\n%s" % [String(data.hint), get_synergy_text(upgrade_id)]


func get_upgrade_icon(upgrade_id: String) -> Texture2D:
	var icon_path := "res://assets/ui/icons/upgrades/icon_upgrade_%s.png" % upgrade_id
	if ResourceLoader.exists(icon_path):
		return load(icon_path)
	return null


func update_detail_for_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= displayed_upgrades.size():
		detail_label.text = ""
		return

	var upgrade_id := displayed_upgrades[slot_index]
	var data: Dictionary = upgrade_catalog.get(upgrade_id, {}) as Dictionary
	if data.is_empty():
		detail_label.text = ""
		return

	var synergy_text := get_synergy_text(upgrade_id)
	var current_level := get_synergy_level(upgrade_id)
	var level_text := "Current level: %s" % current_level
	if synergy_text != "":
		detail_label.text = "%s\n%s. %s." % [String(data.hint), level_text, synergy_text.capitalize()]
	else:
		detail_label.text = "%s\n%s." % [String(data.hint), level_text]


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
	if player.has_method("get_extra_upgrade_level"):
		return int(player.get_extra_upgrade_level(synergy_id))
	if player.has_method("get_passive_power_level"):
		return int(player.get_passive_power_level(synergy_id))
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
	if selection_locked or slot_index >= displayed_upgrades.size():
		return
	
	selection_locked = true
	await play_selection_feedback(slot_index)
	if not is_inside_tree():
		return
	player.apply_upgrade_by_id(displayed_upgrades[slot_index])
	
	if player.has_method("complete_upgrade_selection"):
		player.complete_upgrade_selection()
	
	queue_free()


func play_selection_feedback(slot_index: int) -> void:
	for button in buttons:
		button.disabled = true
	if slot_index < 0 or slot_index >= buttons.size():
		return

	update_detail_for_slot(slot_index)
	var selected_button := buttons[slot_index]
	var upgrade_id := displayed_upgrades[slot_index]
	var rarity := get_upgrade_rarity(upgrade_id)
	var accent: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["Common"]) as Color
	if celebration and celebration.has_method("celebrate_pick"):
		celebration.call("celebrate_pick", selected_button.get_global_rect().get_center(), accent)

	selected_button.pivot_offset = selected_button.size * 0.5
	var tween := selected_button.create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(selected_button, "scale", Vector2(1.12, 1.12), 0.12)
	tween.tween_property(selected_button, "rotation", -0.035, 0.12)
	tween.chain().tween_property(selected_button, "scale", Vector2(1.0, 1.0), 0.16)
	tween.tween_property(selected_button, "rotation", 0.0, 0.16)
	await get_tree().create_timer(0.2, true, false, true).timeout


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
	
	update_detail_for_slot(slot_index)
	var selected_button: Button = buttons[slot_index]
	var selected_style := StyleBoxFlat.new()
	selected_style.bg_color = AI_SELECTION_FLASH_COLOR
	selected_style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	selected_style.set_border_width_all(3)
	selected_button.add_theme_stylebox_override("normal", selected_style)
	selected_button.add_theme_stylebox_override("disabled", selected_style)
	(selected_button.get_node("TagLabel") as Label).text = "[AI PICK]"


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
