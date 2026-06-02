extends CharacterBody2D

signal defeated
signal upgrade_recieved
signal exp_changed(current_exp: int, required_exp: int, level: int)
signal health_changed(current_health: int, maximum_health: int)
signal damaged(player_position: Vector2)

var speed: float = 115.0
var max_health: int = 10
var health: int:
	set(value):
		health = value
		if is_node_ready():
			%HealthLabel.text = "HP: %s / %s" % [health, max_health]
		update_smoke_state()
		health_changed.emit(health, max_health)

var i_window: float = 0.75
var i_timer: float = INF

var fire_interval: float = 1.0
var fire_cooldown: float = INF
var attack_damage: float = 10.0
var rotation_speed: float = deg_to_rad(720.0)
var speed_level: int = 0
var fire_rate_level: int = 0
var damage_level: int = 0
var regeneration_level: int = 0
var regeneration_amount: int = 0
var regeneration_interval: float = 0.0
var regeneration_virtual_interval: float = 0.0
var regeneration_timer: float = 0.0
var exp_bonus_level: int = 0
var splash_level: int = 0
var piercing_level: int = 0
var barbed_wire_level: int = 0
var armor_level: int = 0
var magnet_level: int = 0
var cannon_level: int = 0
var targeting_array_level: int = 0
var accelerator_level: int = 0
var alloy_plating_level: int = 0
var recycler_level: int = 0
var payload_rack_level: int = 0
var reactive_shield_level: int = 0
var gyro_stabilizer_level: int = 0
var rapid_loader_level: int = 0
var high_caliber_level: int = 0
var nanobots_level: int = 0
var kinetic_treads_level: int = 0
var ammo_synthesizer_level: int = 0
var shatter_rounds_level: int = 0
var phase_core_level: int = 0
var capacitor_bank_level: int = 0
var salvage_magnet_level: int = 0
var emergency_repairs_level: int = 0
var combustion_mix_level: int = 0
var heat_sinks_level: int = 0
var overclocked_barrel_level: int = 0
var rail_stabilizer_level: int = 0
var missile_guidance_level: int = 0
var ordnance_bay_level: int = 0
var field_amplifier_level: int = 0
var volt_coils_level: int = 0
var gravity_anchor_level: int = 0
var repair_drones_level: int = 0
var crystal_lens_level: int = 0
var munition_printer_level: int = 0
var stabilized_chassis_level: int = 0
var vector_thrusters_level: int = 0
var impact_fuse_level: int = 0
var armor_piercers_level: int = 0
var weakpoint_scanner_level: int = 0
var med_pump_level: int = 0
var orbit_gears_level: int = 0
var mine_dispenser_level: int = 0
var drone_command_level: int = 0
var lucky_core_level: int = 0
var extra_upgrade_levels: Dictionary = {}
var passive_power_levels: Dictionary = {}
var extra_upgrade_effect_cache: Dictionary = {}
var passive_power_effect_cache: Dictionary = {}
var extra_upgrade_effect_cache_dirty: bool = true
var passive_power_effect_cache_dirty: bool = true
var emergency_repair_timer: float = 0.0
var barbed_wire_cooldowns := {}
var selected_tank_id: String = "vanguard"
var selected_tank_name: String = "Vanguard"

var level: int = 1
var current_exp: int = 0
var pending_upgrade_selections: int = 0
var pending_upgrade_levels: Array[int] = []
var pending_ability_selections: int = 0
var active_upgrade_level: int = 0
var upgrade_selection_active: bool = false
var ability_selection_active: bool = false
var muzzle_burst_timer: float = INF
var landmine_level: int = 0
var landmine_timer: float = 0.0
var active_landmines: Array[Node2D] = []
var circular_saw_level: int = 0
var circular_saws: Array[Node2D] = []
var circular_saw_orbit_angle: float = 0.0
var footsoldier_level: int = 0
var footsoldiers: Array[Node2D] = []
var shock_field_level: int = 0
var shock_field: Node2D
var artillery_level: int = 0
var artillery_beacon: Node2D
var drone_swarm_level: int = 0
var drone_swarm: Node2D
var oil_slick_level: int = 0
var oil_slick_dispenser: Node2D
var freeze_pulse_level: int = 0
var freeze_pulse: Node2D
var chain_lightning_level: int = 0
var chain_lightning: Node2D
var guardian_satellite_level: int = 0
var guardian_satellite: Node2D
var overdrive_core_level: int = 0
var overdrive_core: Node2D
var flame_wave_level: int = 0
var flame_wave: Node2D
var repair_beacon_level: int = 0
var repair_beacon: Node2D
var missile_pod_level: int = 0
var missile_pod: Node2D
var gravity_well_level: int = 0
var gravity_well: Node2D
var railgun_orbiter_level: int = 0
var railgun_orbiter: Node2D
var tesla_pylon_level: int = 0
var tesla_pylon: Node2D
var nanite_cloud_level: int = 0
var nanite_cloud: Node2D
var ricochet_rounds_level: int = 0
var ricochet_rounds: Node2D
var chrono_burst_level: int = 0
var chrono_burst: Node2D
var active_evolution_ids: Array[String] = []
var evolution_catalog: Array[Dictionary] = [
	{
		"id": "shrapnel_core",
		"name": "Shrapnel Core",
		"requirements": {"damage": 4, "splash": 3, "piercing": 2},
		"effects": {"projectile_damage_multiplier": 1.2, "splash_radius_bonus": 18.0, "piercing_bonus": 2, "projectile_scale": 1.22},
	},
	{
		"id": "storm_armor",
		"name": "Storm Armor",
		"requirements": {"shock_field": 3, "barbed_wire": 3, "armor": 3},
		"effects": {"shock_field_level_bonus": 2, "barbed_wire_radius_bonus": 30.0, "barbed_wire_damage_multiplier": 1.35, "armor_reduction_bonus": 0.08},
	},
	{
		"id": "drone_foundry",
		"name": "Drone Foundry",
		"requirements": {"drone_swarm": 2, "cannon": 3, "fire_rate": 4},
		"effects": {"drone_swarm_level_bonus": 2, "cannon_projectile_bonus": 1, "projectile_damage_multiplier": 1.1, "projectile_scale": 1.12},
	},
	{
		"id": "critical_payload",
		"name": "Critical Payload",
		"requirements": {"targeting_array": 3, "payload_rack": 3, "damage": 4},
		"effects": {"crit_chance_bonus": 0.12, "crit_multiplier_bonus": 0.35, "splash_damage_multiplier": 1.2, "projectile_scale": 1.1},
	},
	{
		"id": "repair_loop",
		"name": "Repair Loop",
		"requirements": {"recycler": 3, "alloy_plating": 3, "reactive_shield": 2},
		"effects": {"recycler_heal_chance_bonus": 0.08, "armor_reduction_bonus": 0.05},
	},
	{
		"id": "storm_grid",
		"name": "Storm Grid",
		"requirements": {"chain_lightning": 3, "shock_field": 3, "freeze_pulse": 2},
		"effects": {"chain_lightning_level_bonus": 2, "shock_field_level_bonus": 1},
	},
	{
		"id": "guardian_protocol",
		"name": "Guardian Protocol",
		"requirements": {"guardian_satellite": 3, "overdrive_core": 3, "armor": 3},
		"effects": {"guardian_satellite_level_bonus": 2, "overdrive_damage_bonus": 0.12, "armor_reduction_bonus": 0.04},
	},
	{
		"id": "siege_command",
		"name": "Siege Command",
		"requirements": {"missile_pod": 3, "railgun_orbiter": 3, "targeting_array": 3},
		"effects": {"missile_pod_level_bonus": 2, "railgun_orbiter_level_bonus": 2, "projectile_damage_multiplier": 1.12},
	},
	{
		"id": "singularity_engine",
		"name": "Singularity Engine",
		"requirements": {"gravity_well": 3, "flame_wave": 3, "combustion_mix": 2},
		"effects": {"gravity_well_level_bonus": 2, "flame_wave_level_bonus": 2, "splash_damage_multiplier": 1.12},
	},
	{
		"id": "field_medic",
		"name": "Field Medic",
		"requirements": {"repair_beacon": 3, "nanobots": 3, "armor": 2},
		"effects": {"repair_beacon_level_bonus": 2, "armor_reduction_bonus": 0.03, "overdrive_damage_bonus": 0.04},
	},
	{
		"id": "coil_reactor",
		"name": "Coil Reactor",
		"requirements": {"volt_coils": 3, "capacitor_bank": 3, "chain_lightning": 3},
		"effects": {"chain_lightning_level_bonus": 2, "shock_field_level_bonus": 1, "overdrive_damage_bonus": 0.08},
	},
	{
		"id": "war_factory",
		"name": "War Factory",
		"requirements": {"ordnance_bay": 3, "missile_guidance": 3, "munition_printer": 3},
		"effects": {"missile_pod_level_bonus": 2, "cannon_projectile_bonus": 1, "splash_damage_multiplier": 1.14},
	},
	{
		"id": "recovery_swarm",
		"name": "Recovery Swarm",
		"requirements": {"repair_drones": 3, "repair_beacon": 3, "nanobots": 3},
		"effects": {"repair_beacon_level_bonus": 2, "heal_multiplier_bonus": 0.18, "armor_reduction_bonus": 0.03},
	},
	{
		"id": "death_orbit",
		"name": "Death Orbit",
		"requirements": {"orbit_gears": 3, "circular_saw": 3, "guardian_satellite": 3},
		"effects": {"guardian_satellite_level_bonus": 2, "barbed_wire_radius_bonus": 18.0, "power_contact_damage_bonus": 0.18},
	},
	{
		"id": "breach_rounds",
		"name": "Breach Rounds",
		"requirements": {"armor_piercers": 3, "weakpoint_scanner": 3, "railgun_orbiter": 2},
		"effects": {"railgun_orbiter_level_bonus": 2, "projectile_damage_multiplier": 1.16, "crit_multiplier_bonus": 0.25},
	},
	{
		"id": "time_cage",
		"name": "Time Cage",
		"requirements": {"chrono_burst": 3, "gravity_well": 3, "field_amplifier": 3},
		"effects": {"chrono_burst_level_bonus": 2, "gravity_well_level_bonus": 1, "splash_damage_multiplier": 1.1},
	},
	{
		"id": "storm_battery",
		"name": "Storm Battery",
		"requirements": {"tesla_pylon": 3, "volt_coils": 3, "chain_lightning": 3},
		"effects": {"tesla_pylon_level_bonus": 2, "chain_lightning_level_bonus": 1, "overdrive_damage_bonus": 0.08},
	},
]

const PROJECTILE = preload("uid://bkslemqb5h4g1")
const UPGRADE = preload("uid://gi785n7oy38v")
const ABILITY_MENU = preload("res://scenes/ui/ability_menu.tscn")
const LANDMINE = preload("res://scenes/abilities/landmine.tscn")
const CIRCULAR_SAW = preload("res://scenes/abilities/circular_saw.tscn")
const FOOTSOLDIER = preload("res://scenes/abilities/footsoldier.tscn")
const SHOCK_FIELD = preload("res://scenes/abilities/shock_field.tscn")
const ARTILLERY_BEACON = preload("res://scenes/abilities/artillery_beacon.tscn")
const DRONE_SWARM = preload("res://scenes/abilities/drone_swarm.tscn")
const OIL_SLICK_DISPENSER = preload("res://scenes/abilities/oil_slick_dispenser.tscn")
const FREEZE_PULSE = preload("res://scenes/abilities/freeze_pulse.tscn")
const CHAIN_LIGHTNING = preload("res://scenes/abilities/chain_lightning.tscn")
const GUARDIAN_SATELLITE = preload("res://scenes/abilities/guardian_satellite.tscn")
const OVERDRIVE_CORE = preload("res://scenes/abilities/overdrive_core.tscn")
const FLAME_WAVE = preload("res://scenes/abilities/flame_wave.tscn")
const REPAIR_BEACON = preload("res://scenes/abilities/repair_beacon.tscn")
const MISSILE_POD = preload("res://scenes/abilities/missile_pod.tscn")
const GRAVITY_WELL = preload("res://scenes/abilities/gravity_well.tscn")
const RAILGUN_ORBITER = preload("res://scenes/abilities/railgun_orbiter.tscn")
const TESLA_PYLON = preload("res://scenes/abilities/tesla_pylon.tscn")
const NANITE_CLOUD = preload("res://scenes/abilities/nanite_cloud.tscn")
const RICOCHET_ROUNDS = preload("res://scenes/abilities/ricochet_rounds.tscn")
const CHRONO_BURST = preload("res://scenes/abilities/chrono_burst.tscn")
const MUZZLE_BURST_INTERVAL: float = 0.15
const REGEN_START_INTERVAL: float = 5.0
const REGEN_INTERVAL_STEP: float = 1.0 / 3.0
const REGEN_MIN_INTERVAL: float = 5.0
const REGEN_MIN_VIRTUAL_INTERVAL: float = 1.0 / 6.0
const LANDMINE_BASE_INTERVAL: float = 5.0
const LANDMINE_INTERVAL_STEP: float = 0.5
const LANDMINE_MIN_INTERVAL: float = 1.0
const LANDMINE_BASE_DAMAGE_MULTIPLIER: float = 2.0
const LANDMINE_DAMAGE_LEVEL_MULTIPLIER: float = 1.35
const BARBED_WIRE_RADIUS: float = 38.0
const BARBED_WIRE_DAMAGE_INTERVAL: float = 0.5
const BARBED_WIRE_DAMAGE_MULTIPLIER: float = 0.33
const ARMOR_DAMAGE_REDUCTION_PER_LEVEL: float = 0.08
const ARMOR_MAX_DAMAGE_REDUCTION: float = 0.65
const MAGNET_BASE_RADIUS: float = 98.0
const MAGNET_RADIUS_PER_LEVEL: float = 46.0
const CANNON_SPREAD_DEGREES: float = 12.0
const TARGETING_ARRAY_CRIT_CHANCE_PER_LEVEL: float = 0.04
const TARGETING_ARRAY_CRIT_MULTIPLIER: float = 1.5
const ACCELERATOR_PROJECTILE_SPEED_PER_LEVEL: float = 0.12
const ALLOY_PLATING_HEALTH_PER_LEVEL: int = 2
const RECYCLER_HEAL_CHANCE_PER_LEVEL: float = 0.12
const RECYCLER_BOSS_HEAL_AMOUNT: int = 3
const PAYLOAD_RACK_SPLASH_RADIUS_PER_LEVEL: float = 6.0
const PAYLOAD_RACK_SPLASH_DAMAGE_PER_LEVEL: float = 0.06
const REACTIVE_SHIELD_I_WINDOW_PER_LEVEL: float = 0.08
const GYRO_ROTATION_MULTIPLIER: float = 1.12
const RAPID_LOADER_FIRE_INTERVAL_MULTIPLIER: float = 0.94
const HIGH_CALIBER_DAMAGE_MULTIPLIER: float = 1.12
const HIGH_CALIBER_PROJECTILE_SCALE_PER_LEVEL: float = 0.04
const NANOBOTS_HEAL_BONUS_PER_LEVEL: float = 0.5
const KINETIC_TREADS_SPEED_MULTIPLIER: float = 1.1
const SHATTER_ROUNDS_RADIUS_PER_LEVEL: float = 4.0
const SHATTER_ROUNDS_DAMAGE_PER_LEVEL: float = 0.03
const PHASE_CORE_SPEED_PER_LEVEL: float = 0.06
const PHASE_CORE_PIERCE_PER_TWO_LEVELS: int = 1
const CAPACITOR_BANK_DAMAGE_PER_LEVEL: float = 0.055
const SALVAGE_MAGNET_EXP_PER_LEVEL: float = 0.08
const SALVAGE_MAGNET_RADIUS_PER_LEVEL: float = 24.0
const EMERGENCY_REPAIRS_INTERVAL: float = 9.0
const EMERGENCY_REPAIRS_HEALTH_RATIO: float = 0.42
const COMBUSTION_MIX_AREA_DAMAGE_PER_LEVEL: float = 0.065
const HEAT_SINKS_FIRE_INTERVAL_MULTIPLIER: float = 0.965
const OVERCLOCKED_BARREL_FIRE_INTERVAL_MULTIPLIER: float = 0.97
const OVERCLOCKED_BARREL_DAMAGE_MULTIPLIER: float = 1.07
const RAIL_STABILIZER_CRIT_CHANCE_PER_LEVEL: float = 0.025
const MISSILE_GUIDANCE_RADIUS_PER_LEVEL: float = 2.0
const ORDNANCE_BAY_RADIUS_PER_LEVEL: float = 5.0
const ORDNANCE_BAY_DAMAGE_PER_LEVEL: float = 0.045
const VOLT_COILS_POWER_DAMAGE_PER_LEVEL: float = 0.03
const GRAVITY_ANCHOR_AREA_DAMAGE_PER_LEVEL: float = 0.04
const REPAIR_DRONES_HEAL_BONUS_PER_LEVEL: float = 0.08
const CRYSTAL_LENS_EXP_PER_LEVEL: float = 0.05
const CRYSTAL_LENS_CRIT_CHANCE_PER_LEVEL: float = 0.02
const STABILIZED_CHASSIS_ARMOR_PER_LEVEL: float = 0.025
const STABILIZED_CHASSIS_ROTATION_MULTIPLIER: float = 1.06
const VECTOR_THRUSTERS_SPEED_MULTIPLIER: float = 1.07
const VECTOR_THRUSTERS_PROJECTILE_SPEED_PER_LEVEL: float = 0.035
const VECTOR_THRUSTERS_ROTATION_MULTIPLIER: float = 1.04
const IMPACT_FUSE_RADIUS_PER_LEVEL: float = 3.0
const IMPACT_FUSE_DAMAGE_PER_LEVEL: float = 0.035
const ARMOR_PIERCERS_DAMAGE_PER_LEVEL: float = 0.045
const ARMOR_PIERCERS_PIERCE_PER_TWO_LEVELS: int = 1
const WEAKPOINT_SCANNER_CRIT_CHANCE_PER_LEVEL: float = 0.018
const WEAKPOINT_SCANNER_CRIT_MULTIPLIER_PER_LEVEL: float = 0.06
const MED_PUMP_HEAL_BONUS_PER_LEVEL: float = 0.07
const MED_PUMP_EMERGENCY_INTERVAL_REDUCTION: float = 0.35
const ORBIT_GEARS_CONTACT_DAMAGE_PER_LEVEL: float = 0.08
const MINE_DISPENSER_INTERVAL_REDUCTION: float = 0.18
const MINE_DISPENSER_DAMAGE_PER_LEVEL: float = 0.08
const DRONE_COMMAND_PET_DAMAGE_PER_LEVEL: float = 0.07
const LUCKY_CORE_EXP_PER_LEVEL: float = 0.03
const LUCKY_CORE_CRIT_CHANCE_PER_LEVEL: float = 0.01

@onready var camera: Camera2D = $Camera2D
@onready var tank_base: Sprite2D = $TankBase
@onready var tank_cannon: Sprite2D = $TankCannon
@onready var barbed_wire_ring: Sprite2D = $BarbedWireRing
@onready var auto_driver: Node = $AutoDriver
@onready var ai_behavior_label: Label = $AiBehaviorLabel

var smoke_particles: GPUParticles2D
var is_dead: bool = false


func _ready() -> void:
	setup_smoke_particles()
	apply_selected_tank_archetype()
	health = max_health
	exp_changed.emit(current_exp, get_required_exp(), level)


func _physics_process(delta: float) -> void:
	i_timer += delta
	fire_cooldown += delta
	muzzle_burst_timer += delta
	circular_saw_orbit_angle += TAU / 2.0 * delta
	process_regeneration(delta)
	process_emergency_repairs(delta)
	process_landmine_placement(delta)
	process_barbed_wire(delta)
	process_personal_magnet()
	update_invincibility_visual()
	
	var input: Vector2 = get_movement_input(delta)
	velocity = input.normalized() * speed
	if velocity.length_squared() > 0.0:
		tank_base.rotation = rotate_toward_angle(tank_base.rotation, velocity.angle() + PI / 2.0, rotation_speed * delta)
	velocity *= get_power_speed_multiplier()
	move_and_slide()
	process_wall_recovery_collision()
	
	var enemy = get_nearest_enemy()
	if enemy:
		var target_direction := global_position.direction_to(enemy.global_position)
		var target_rotation := target_direction.angle() + PI / 2.0
		tank_cannon.rotation = rotate_toward_angle(tank_cannon.rotation, target_rotation, rotation_speed * delta)
		
		if fire_cooldown >= fire_interval and is_angle_aligned(tank_cannon.rotation, target_rotation):
			fire_projectile_volley(target_direction)
			fire_cooldown = 0.0
			spawn_muzzle_burst()


func get_movement_input(delta: float) -> Vector2:
	if auto_driver != null and auto_driver.is_active:
		var movement: Vector2 = auto_driver.get_movement_vector(delta)
		update_ai_behavior_label()
		return movement
	
	update_ai_behavior_label()
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func set_auto_driver_active(active: bool) -> void:
	if auto_driver == null:
		return
	
	if active:
		auto_driver.activate()
	else:
		auto_driver.deactivate()


func is_auto_driver_active() -> bool:
	return auto_driver != null and auto_driver.is_active


func process_wall_recovery_collision() -> void:
	if auto_driver == null or not auto_driver.is_active:
		return
	
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is StaticBody2D:
			auto_driver.trigger_wall_recovery()
			return


func update_ai_behavior_label() -> void:
	if ai_behavior_label == null:
		return
	
	var should_show: bool = auto_driver != null and auto_driver.is_active and not is_dead
	ai_behavior_label.visible = should_show
	if should_show:
		ai_behavior_label.text = "AI: %s" % auto_driver.current_behavior_label


func set_auto_driver_enemy_avoidance_active(active: bool) -> void:
	if auto_driver == null:
		return
	
	auto_driver.set_enemy_avoidance_active(active)


func is_auto_driver_enemy_avoidance_active() -> bool:
	return auto_driver != null and auto_driver.enemy_avoidance_active


func set_auto_driver_exp_seek_active(active: bool) -> void:
	if auto_driver == null:
		return
	
	auto_driver.set_exp_seek_active(active)


func is_auto_driver_exp_seek_active() -> bool:
	return auto_driver != null and auto_driver.exp_seek_active


func set_auto_driver_wrench_seek_active(active: bool) -> void:
	if auto_driver == null:
		return
	
	auto_driver.set_wrench_seek_active(active)


func is_auto_driver_wrench_seek_active() -> bool:
	return auto_driver != null and auto_driver.wrench_seek_active


func set_auto_driver_supply_seek_active(active: bool) -> void:
	if auto_driver == null:
		return
	
	auto_driver.set_supply_seek_active(active)


func is_auto_driver_supply_seek_active() -> bool:
	return auto_driver != null and auto_driver.supply_seek_active


func set_auto_driver_powerup_seek_active(active: bool) -> void:
	if auto_driver == null:
		return
	
	auto_driver.set_powerup_seek_active(active)


func is_auto_driver_powerup_seek_active() -> bool:
	return auto_driver != null and auto_driver.powerup_seek_active


func set_auto_driver_upgrade_pick_active(active: bool) -> void:
	if auto_driver == null:
		return
	
	auto_driver.upgrade_pick_active = active


func is_auto_driver_upgrade_pick_active() -> bool:
	return auto_driver != null and auto_driver.upgrade_pick_active


func add_exp(amount: int) -> void:
	current_exp += amount
	
	while current_exp >= get_required_exp():
		current_exp -= get_required_exp()
		level += 1
		increase_max_health_from_level()
		pending_upgrade_selections += 1
		pending_upgrade_levels.append(level)
		upgrade_recieved.emit()
	
	show_upgrade_selection()
	exp_changed.emit(current_exp, get_required_exp(), level)


func get_required_exp() -> int:
	var high_level_pressure: float = pow(float(max(level - 10, 0)), 1.8) * 1.2
	return int(ceil(12.0 + float(level) * 5.0 + pow(float(level), 1.45) * 2.4 + high_level_pressure))


func show_upgrade_selection() -> void:
	if upgrade_selection_active or ability_selection_active or pending_upgrade_selections <= 0 or is_dead:
		return
	
	pending_upgrade_selections -= 1
	active_upgrade_level = pending_upgrade_levels.pop_front()
	upgrade_selection_active = true
	get_tree().paused = true
	
	var upgrade = UPGRADE.instantiate()
	upgrade.player = self
	get_tree().current_scene.add_child(upgrade)
	if is_auto_driver_upgrade_pick_active() and upgrade.has_method("pick_random_upgrade"):
		upgrade.call_deferred("pick_random_upgrade")


func request_supply_upgrade_selection() -> void:
	pending_upgrade_selections += 1
	pending_upgrade_levels.append(0)
	show_upgrade_selection()


func complete_upgrade_selection() -> void:
	upgrade_selection_active = false
	
	if active_upgrade_level > 0 and active_upgrade_level % 5 == 0:
		pending_ability_selections += 1
	
	active_upgrade_level = 0
	
	if pending_ability_selections > 0:
		call_deferred("show_ability_selection")
		return
	
	if pending_upgrade_selections > 0:
		call_deferred("show_upgrade_selection")
		return
	
	if not is_dead:
		get_tree().paused = false


func show_ability_selection() -> void:
	if upgrade_selection_active or ability_selection_active or pending_ability_selections <= 0 or is_dead:
		return
	
	pending_ability_selections -= 1
	ability_selection_active = true
	get_tree().paused = true
	
	var ability_menu = ABILITY_MENU.instantiate()
	ability_menu.player = self
	get_tree().current_scene.add_child(ability_menu)
	if is_auto_driver_upgrade_pick_active() and ability_menu.has_method("pick_random_ability"):
		ability_menu.call_deferred("pick_random_ability")


func request_supply_ability_selection() -> void:
	pending_ability_selections += 1
	show_ability_selection()


func complete_ability_selection() -> void:
	ability_selection_active = false
	
	if pending_upgrade_selections > 0:
		call_deferred("show_upgrade_selection")
		return
	
	if pending_ability_selections > 0:
		call_deferred("show_ability_selection")
		return
	
	if not is_dead:
		get_tree().paused = false


func upgrade_landmine() -> void:
	landmine_level += 1
	landmine_timer = min(landmine_timer, get_landmine_interval())


func upgrade_circular_saw() -> void:
	circular_saw_level += 1
	var saw = CIRCULAR_SAW.instantiate()
	saw.player = self
	saw.saw_index = circular_saws.size()
	add_child(saw)
	circular_saws.append(saw)
	update_circular_saw_count()


func update_circular_saw_count() -> void:
	for i in range(circular_saws.size()):
		var saw = circular_saws[i]
		if is_instance_valid(saw):
			saw.saw_index = i
			saw.saw_count = circular_saws.size()


func upgrade_footsoldier() -> void:
	footsoldier_level += 1
	var main := get_tree().current_scene
	if main == null:
		return
	
	var footsoldier = FOOTSOLDIER.instantiate()
	main.add_child(footsoldier)
	footsoldier.global_position = global_position + Vector2(randf_range(-24.0, 24.0), randf_range(-24.0, 24.0))
	footsoldiers.append(footsoldier)
	update_footsoldier_count()


func update_footsoldier_count() -> void:
	for i in range(footsoldiers.size()):
		var footsoldier = footsoldiers[i]
		if is_instance_valid(footsoldier) and footsoldier.has_method("configure"):
			footsoldier.configure(self, i, footsoldiers.size())


func upgrade_shock_field() -> void:
	shock_field_level += 1
	if is_instance_valid(shock_field):
		if shock_field.has_method("update_level"):
			shock_field.update_level(get_effective_ability_level("shock_field"))
		return
	
	shock_field = SHOCK_FIELD.instantiate()
	add_child(shock_field)
	if shock_field.has_method("configure"):
		shock_field.configure(self, get_effective_ability_level("shock_field"))


func upgrade_artillery() -> void:
	artillery_level += 1
	if is_instance_valid(artillery_beacon):
		if artillery_beacon.has_method("update_level"):
			artillery_beacon.update_level(get_effective_ability_level("artillery"))
		return
	
	var main := get_tree().current_scene
	if main == null:
		return
	
	artillery_beacon = ARTILLERY_BEACON.instantiate()
	main.add_child(artillery_beacon)
	if artillery_beacon.has_method("configure"):
		artillery_beacon.configure(self, get_effective_ability_level("artillery"))


func apply_selected_tank_archetype() -> void:
	var tank: Dictionary = get_run_config().get_selected_tank()
	var run_config = get_run_config()
	selected_tank_id = String(tank.get("id", selected_tank_id))
	selected_tank_name = String(tank.get("name", selected_tank_name))
	speed *= float(tank.get("speed_multiplier", 1.0))
	max_health = max(1, max_health + int(tank.get("health_bonus", 0)) + run_config.get_meta_reward_bonus("starting_health_bonus"))
	attack_damage *= float(tank.get("damage_multiplier", 1.0))
	fire_interval *= float(tank.get("fire_interval_multiplier", 1.0)) * float(run_config.get_modifier_multiplier("player_fire_interval_multiplier"))
	
	speed_level += int(tank.get("speed_level", 0))
	damage_level += int(tank.get("damage_level", 0))
	fire_rate_level += int(tank.get("fire_rate_level", 0))
	regeneration_level += int(tank.get("regeneration_level", 0))
	armor_level += int(tank.get("armor_level", 0))
	magnet_level += int(tank.get("magnet_level", 0))
	cannon_level += int(tank.get("cannon_level", 0))
	exp_bonus_level += int(tank.get("exp_bonus_level", 0))
	capacitor_bank_level += int(tank.get("capacitor_bank_level", 0))
	
	var tint: Color = tank.get("color", Color.WHITE) as Color
	tank_base.modulate = tint
	tank_cannon.modulate = tint
	
	apply_starting_ability_levels(tank)
	apply_meta_progression_rewards(run_config)
	update_evolutions()


func get_run_config() -> Node:
	return get_node("/root/RunConfig")


func apply_meta_progression_rewards(run_config: Node) -> void:
	for i in range(run_config.get_meta_reward_bonus("starting_armor_level")):
		armor_level += 1
	for i in range(run_config.get_meta_reward_bonus("starting_damage_level")):
		upgrade_damage()
	for i in range(run_config.get_meta_reward_bonus("starting_exp_level")):
		upgrade_exp()
	for i in range(run_config.get_meta_reward_bonus("starting_magnet_level")):
		magnet_level += 1


func apply_starting_ability_levels(tank: Dictionary) -> void:
	for i in range(int(tank.get("landmine_level", 0))):
		upgrade_landmine()
	for i in range(int(tank.get("circular_saw_level", 0))):
		upgrade_circular_saw()
	for i in range(int(tank.get("footsoldier_level", 0))):
		upgrade_footsoldier()
	for i in range(int(tank.get("shock_field_level", 0))):
		upgrade_shock_field()
	for i in range(int(tank.get("artillery_level", 0))):
		upgrade_artillery()
	for i in range(int(tank.get("drone_swarm_level", 0))):
		upgrade_drone_swarm()
	for i in range(int(tank.get("oil_slick_level", 0))):
		upgrade_oil_slick()
	for i in range(int(tank.get("freeze_pulse_level", 0))):
		upgrade_freeze_pulse()
	for i in range(int(tank.get("chain_lightning_level", 0))):
		upgrade_chain_lightning()
	for i in range(int(tank.get("guardian_satellite_level", 0))):
		upgrade_guardian_satellite()
	for i in range(int(tank.get("overdrive_core_level", 0))):
		upgrade_overdrive_core()
	for i in range(int(tank.get("flame_wave_level", 0))):
		upgrade_flame_wave()
	for i in range(int(tank.get("repair_beacon_level", 0))):
		upgrade_repair_beacon()
	for i in range(int(tank.get("missile_pod_level", 0))):
		upgrade_missile_pod()
	for i in range(int(tank.get("gravity_well_level", 0))):
		upgrade_gravity_well()
	for i in range(int(tank.get("railgun_orbiter_level", 0))):
		upgrade_railgun_orbiter()
	for i in range(int(tank.get("tesla_pylon_level", 0))):
		upgrade_tesla_pylon()
	for i in range(int(tank.get("nanite_cloud_level", 0))):
		upgrade_nanite_cloud()
	for i in range(int(tank.get("ricochet_rounds_level", 0))):
		upgrade_ricochet_rounds()
	for i in range(int(tank.get("chrono_burst_level", 0))):
		upgrade_chrono_burst()


func upgrade_drone_swarm() -> void:
	drone_swarm_level += 1
	if is_instance_valid(drone_swarm):
		if drone_swarm.has_method("update_level"):
			drone_swarm.update_level(get_effective_ability_level("drone_swarm"))
		return
	
	drone_swarm = DRONE_SWARM.instantiate()
	add_child(drone_swarm)
	if drone_swarm.has_method("configure"):
		drone_swarm.configure(self, get_effective_ability_level("drone_swarm"))


func upgrade_oil_slick() -> void:
	oil_slick_level += 1
	if is_instance_valid(oil_slick_dispenser):
		if oil_slick_dispenser.has_method("update_level"):
			oil_slick_dispenser.update_level(oil_slick_level)
		return
	
	oil_slick_dispenser = OIL_SLICK_DISPENSER.instantiate()
	add_child(oil_slick_dispenser)
	if oil_slick_dispenser.has_method("configure"):
		oil_slick_dispenser.configure(self, oil_slick_level)


func upgrade_freeze_pulse() -> void:
	freeze_pulse_level += 1
	if is_instance_valid(freeze_pulse):
		if freeze_pulse.has_method("update_level"):
			freeze_pulse.update_level(freeze_pulse_level)
		return
	
	freeze_pulse = FREEZE_PULSE.instantiate()
	add_child(freeze_pulse)
	if freeze_pulse.has_method("configure"):
		freeze_pulse.configure(self, freeze_pulse_level)


func upgrade_chain_lightning() -> void:
	chain_lightning_level += 1
	if is_instance_valid(chain_lightning):
		if chain_lightning.has_method("update_level"):
			chain_lightning.update_level(get_effective_ability_level("chain_lightning"))
		return

	chain_lightning = CHAIN_LIGHTNING.instantiate()
	add_child(chain_lightning)
	if chain_lightning.has_method("configure"):
		chain_lightning.configure(self, get_effective_ability_level("chain_lightning"))


func upgrade_guardian_satellite() -> void:
	guardian_satellite_level += 1
	if is_instance_valid(guardian_satellite):
		if guardian_satellite.has_method("update_level"):
			guardian_satellite.update_level(get_effective_ability_level("guardian_satellite"))
		return

	guardian_satellite = GUARDIAN_SATELLITE.instantiate()
	add_child(guardian_satellite)
	if guardian_satellite.has_method("configure"):
		guardian_satellite.configure(self, get_effective_ability_level("guardian_satellite"))


func upgrade_overdrive_core() -> void:
	overdrive_core_level += 1
	if is_instance_valid(overdrive_core):
		if overdrive_core.has_method("update_level"):
			overdrive_core.update_level(overdrive_core_level)
		return

	overdrive_core = OVERDRIVE_CORE.instantiate()
	add_child(overdrive_core)
	if overdrive_core.has_method("configure"):
		overdrive_core.configure(self, overdrive_core_level)


func upgrade_flame_wave() -> void:
	flame_wave_level += 1
	if is_instance_valid(flame_wave):
		if flame_wave.has_method("update_level"):
			flame_wave.update_level(get_effective_ability_level("flame_wave"))
		return

	flame_wave = FLAME_WAVE.instantiate()
	add_child(flame_wave)
	if flame_wave.has_method("configure"):
		flame_wave.configure(self, get_effective_ability_level("flame_wave"))


func upgrade_repair_beacon() -> void:
	repair_beacon_level += 1
	if is_instance_valid(repair_beacon):
		if repair_beacon.has_method("update_level"):
			repair_beacon.update_level(get_effective_ability_level("repair_beacon"))
		return

	repair_beacon = REPAIR_BEACON.instantiate()
	add_child(repair_beacon)
	if repair_beacon.has_method("configure"):
		repair_beacon.configure(self, get_effective_ability_level("repair_beacon"))


func upgrade_missile_pod() -> void:
	missile_pod_level += 1
	if is_instance_valid(missile_pod):
		if missile_pod.has_method("update_level"):
			missile_pod.update_level(get_effective_ability_level("missile_pod"))
		return

	missile_pod = MISSILE_POD.instantiate()
	add_child(missile_pod)
	if missile_pod.has_method("configure"):
		missile_pod.configure(self, get_effective_ability_level("missile_pod"))


func upgrade_gravity_well() -> void:
	gravity_well_level += 1
	if is_instance_valid(gravity_well):
		if gravity_well.has_method("update_level"):
			gravity_well.update_level(get_effective_ability_level("gravity_well"))
		return

	gravity_well = GRAVITY_WELL.instantiate()
	add_child(gravity_well)
	if gravity_well.has_method("configure"):
		gravity_well.configure(self, get_effective_ability_level("gravity_well"))


func upgrade_railgun_orbiter() -> void:
	railgun_orbiter_level += 1
	if is_instance_valid(railgun_orbiter):
		if railgun_orbiter.has_method("update_level"):
			railgun_orbiter.update_level(get_effective_ability_level("railgun_orbiter"))
		return

	railgun_orbiter = RAILGUN_ORBITER.instantiate()
	add_child(railgun_orbiter)
	if railgun_orbiter.has_method("configure"):
		railgun_orbiter.configure(self, get_effective_ability_level("railgun_orbiter"))


func upgrade_tesla_pylon() -> void:
	tesla_pylon_level += 1
	if is_instance_valid(tesla_pylon):
		if tesla_pylon.has_method("update_level"):
			tesla_pylon.update_level(get_effective_ability_level("tesla_pylon"))
		return

	tesla_pylon = TESLA_PYLON.instantiate()
	add_child(tesla_pylon)
	if tesla_pylon.has_method("configure"):
		tesla_pylon.configure(self, get_effective_ability_level("tesla_pylon"))


func upgrade_nanite_cloud() -> void:
	nanite_cloud_level += 1
	if is_instance_valid(nanite_cloud):
		if nanite_cloud.has_method("update_level"):
			nanite_cloud.update_level(get_effective_ability_level("nanite_cloud"))
		return

	nanite_cloud = NANITE_CLOUD.instantiate()
	add_child(nanite_cloud)
	if nanite_cloud.has_method("configure"):
		nanite_cloud.configure(self, get_effective_ability_level("nanite_cloud"))


func upgrade_ricochet_rounds() -> void:
	ricochet_rounds_level += 1
	if is_instance_valid(ricochet_rounds):
		if ricochet_rounds.has_method("update_level"):
			ricochet_rounds.update_level(get_effective_ability_level("ricochet_rounds"))
		return

	ricochet_rounds = RICOCHET_ROUNDS.instantiate()
	add_child(ricochet_rounds)
	if ricochet_rounds.has_method("configure"):
		ricochet_rounds.configure(self, get_effective_ability_level("ricochet_rounds"))


func upgrade_chrono_burst() -> void:
	chrono_burst_level += 1
	if is_instance_valid(chrono_burst):
		if chrono_burst.has_method("update_level"):
			chrono_burst.update_level(get_effective_ability_level("chrono_burst"))
		return

	chrono_burst = CHRONO_BURST.instantiate()
	add_child(chrono_burst)
	if chrono_burst.has_method("configure"):
		chrono_burst.configure(self, get_effective_ability_level("chrono_burst"))


func process_landmine_placement(delta: float) -> void:
	if landmine_level <= 0 or is_dead:
		return
	
	landmine_timer += delta
	var placement_interval := get_landmine_interval()
	if landmine_timer < placement_interval:
		return
	
	landmine_timer -= placement_interval
	place_landmine()


func place_landmine() -> void:
	var main := get_tree().current_scene
	if main == null:
		return
	
	cleanup_active_landmines()
	if active_landmines.size() >= landmine_level:
		return
	
	var landmine = LANDMINE.instantiate()
	landmine.player = self
	landmine.damage_multiplier = get_landmine_damage_multiplier()
	main.add_child(landmine)
	landmine.global_position = global_position
	active_landmines.append(landmine)
	landmine.call_deferred("check_overlapping_landmines")


func cleanup_active_landmines() -> void:
	for i in range(active_landmines.size() - 1, -1, -1):
		if not is_instance_valid(active_landmines[i]):
			active_landmines.remove_at(i)


func get_landmine_interval() -> float:
	return max(LANDMINE_BASE_INTERVAL - float(landmine_level - 1) * LANDMINE_INTERVAL_STEP - float(mine_dispenser_level) * MINE_DISPENSER_INTERVAL_REDUCTION, LANDMINE_MIN_INTERVAL)


func get_landmine_damage_multiplier() -> float:
	return LANDMINE_BASE_DAMAGE_MULTIPLIER * pow(LANDMINE_DAMAGE_LEVEL_MULTIPLIER, float(max(landmine_level - 1, 0))) * (1.0 + float(mine_dispenser_level) * MINE_DISPENSER_DAMAGE_PER_LEVEL) * get_area_damage_multiplier()


func get_valid_upgrade_ids() -> Array[String]:
	var upgrade_pool: Array[String] = [
		"speed",
		"fire_rate",
		"damage",
		"exp",
		"splash",
		"piercing",
		"barbed_wire",
		"armor",
		"magnet",
		"cannon",
		"targeting_array",
		"accelerator",
		"alloy_plating",
		"recycler",
		"payload_rack",
		"reactive_shield",
		"gyro_stabilizer",
		"rapid_loader",
		"high_caliber",
		"nanobots",
		"kinetic_treads",
		"ammo_synthesizer",
		"shatter_rounds",
		"phase_core",
		"capacitor_bank",
		"salvage_magnet",
		"emergency_repairs",
		"combustion_mix",
		"heat_sinks",
		"overclocked_barrel",
		"rail_stabilizer",
		"missile_guidance",
		"ordnance_bay",
		"field_amplifier",
		"volt_coils",
		"gravity_anchor",
		"repair_drones",
		"crystal_lens",
		"munition_printer",
		"stabilized_chassis",
		"vector_thrusters",
		"impact_fuse",
		"armor_piercers",
		"weakpoint_scanner",
		"med_pump",
		"orbit_gears",
		"mine_dispenser",
		"drone_command",
		"lucky_core",
	]
	upgrade_pool.append_array(get_extra_upgrade_ids())
	if can_upgrade_regeneration():
		upgrade_pool.append("regeneration")

	var valid_upgrades: Array[String] = []
	for upgrade_id in upgrade_pool:
		if are_upgrade_prerequisites_met(upgrade_id):
			valid_upgrades.append(upgrade_id)
	
	return valid_upgrades


func are_upgrade_prerequisites_met(upgrade_id: String) -> bool:
	var extra_upgrade := get_extra_upgrade_config(upgrade_id)
	if not extra_upgrade.is_empty():
		var required: Dictionary = extra_upgrade.get("requires", {}) as Dictionary
		for key in required.keys():
			if get_build_level_for_evolution(String(key)) < int(required[key]):
				return false
		return true
	match upgrade_id:
		"payload_rack", "shatter_rounds", "impact_fuse":
			return has_splash_build()
		"combustion_mix":
			return has_splash_build() or landmine_level > 0 or barbed_wire_level > 0 or flame_wave_level > 0
		"missile_guidance":
			return missile_pod_level > 0
		"ordnance_bay":
			return has_splash_build() or artillery_level > 0 or missile_pod_level > 0
		"field_amplifier":
			return has_field_or_aura_power()
		"volt_coils":
			return shock_field_level > 0 or chain_lightning_level > 0 or tesla_pylon_level > 0
		"gravity_anchor":
			return gravity_well_level > 0
		"repair_drones":
			return repair_beacon_level > 0 or nanite_cloud_level > 0
		"med_pump":
			return nanobots_level > 0 or repair_beacon_level > 0 or nanite_cloud_level > 0 or emergency_repairs_level > 0
		"orbit_gears":
			return circular_saw_level > 0 or guardian_satellite_level > 0 or barbed_wire_level > 0
		"mine_dispenser":
			return landmine_level > 0
		"drone_command":
			return footsoldier_level > 0 or drone_swarm_level > 0 or guardian_satellite_level > 0
		"armor_piercers":
			return piercing_level > 0 or railgun_orbiter_level > 0
		"weakpoint_scanner":
			return targeting_array_level > 0 or railgun_orbiter_level > 0
		"rail_stabilizer":
			return targeting_array_level > 0 or railgun_orbiter_level > 0
		"capacitor_bank":
			return has_active_power()
		"accelerator":
			return piercing_level > 0 or cannon_level > 0 or railgun_orbiter_level > 0
		"ammo_synthesizer":
			return cannon_level > 0
		"phase_core":
			return piercing_level > 0
		"salvage_magnet":
			return magnet_level > 0 or exp_bonus_level > 0
		"crystal_lens":
			return exp_bonus_level > 0 or targeting_array_level > 0
		"munition_printer":
			return cannon_level > 0 or ammo_synthesizer_level > 0
		"lucky_core":
			return crystal_lens_level > 0 or targeting_array_level > 0 or munition_printer_level > 0
	return true


func has_splash_build() -> bool:
	return splash_level > 0 or payload_rack_level > 0 or artillery_level > 0 or landmine_level > 0 or missile_pod_level > 0 or flame_wave_level > 0


func has_field_or_aura_power() -> bool:
	return shock_field_level > 0 or flame_wave_level > 0 or gravity_well_level > 0 or repair_beacon_level > 0 or nanite_cloud_level > 0


func has_active_power() -> bool:
	if not passive_power_levels.is_empty():
		return true
	return (
		landmine_level > 0
		or circular_saw_level > 0
		or footsoldier_level > 0
		or shock_field_level > 0
		or artillery_level > 0
		or drone_swarm_level > 0
		or oil_slick_level > 0
		or freeze_pulse_level > 0
		or chain_lightning_level > 0
		or guardian_satellite_level > 0
		or overdrive_core_level > 0
		or flame_wave_level > 0
		or repair_beacon_level > 0
		or missile_pod_level > 0
		or gravity_well_level > 0
		or railgun_orbiter_level > 0
		or tesla_pylon_level > 0
		or nanite_cloud_level > 0
		or ricochet_rounds_level > 0
		or chrono_burst_level > 0
	)


func apply_upgrade_by_id(upgrade_id: String) -> void:
	if apply_extra_upgrade_by_id(upgrade_id):
		update_evolutions()
		return

	match upgrade_id:
		"speed":
			speed_level += 1
			speed *= 1.2
		"fire_rate":
			fire_rate_level += 1
			fire_interval *= 0.885
		"damage":
			upgrade_damage()
		"regeneration":
			upgrade_regeneration()
		"exp":
			upgrade_exp()
		"splash":
			upgrade_splash()
		"piercing":
			upgrade_piercing()
		"barbed_wire":
			upgrade_barbed_wire()
		"armor":
			armor_level += 1
		"magnet":
			magnet_level += 1
		"cannon":
			cannon_level += 1
		"targeting_array":
			targeting_array_level += 1
		"accelerator":
			accelerator_level += 1
		"alloy_plating":
			upgrade_alloy_plating()
		"recycler":
			recycler_level += 1
		"payload_rack":
			payload_rack_level += 1
		"reactive_shield":
			upgrade_reactive_shield()
		"gyro_stabilizer":
			upgrade_gyro_stabilizer()
		"rapid_loader":
			upgrade_rapid_loader()
		"high_caliber":
			upgrade_high_caliber()
		"nanobots":
			nanobots_level += 1
		"kinetic_treads":
			upgrade_kinetic_treads()
		"ammo_synthesizer":
			ammo_synthesizer_level += 1
		"shatter_rounds":
			shatter_rounds_level += 1
		"phase_core":
			phase_core_level += 1
		"capacitor_bank":
			capacitor_bank_level += 1
		"salvage_magnet":
			salvage_magnet_level += 1
		"emergency_repairs":
			emergency_repairs_level += 1
		"combustion_mix":
			combustion_mix_level += 1
		"heat_sinks":
			upgrade_heat_sinks()
		"overclocked_barrel":
			upgrade_overclocked_barrel()
		"rail_stabilizer":
			rail_stabilizer_level += 1
		"missile_guidance":
			missile_guidance_level += 1
			update_power_level("missile_pod")
		"ordnance_bay":
			ordnance_bay_level += 1
			update_power_level("artillery")
			update_power_level("missile_pod")
		"field_amplifier":
			field_amplifier_level += 1
			update_power_level("shock_field")
			update_power_level("flame_wave")
			update_power_level("repair_beacon")
			update_power_level("gravity_well")
		"volt_coils":
			volt_coils_level += 1
			update_power_level("shock_field")
			update_power_level("chain_lightning")
		"gravity_anchor":
			gravity_anchor_level += 1
			update_power_level("gravity_well")
		"repair_drones":
			repair_drones_level += 1
			update_power_level("repair_beacon")
		"crystal_lens":
			crystal_lens_level += 1
		"munition_printer":
			munition_printer_level += 1
		"stabilized_chassis":
			upgrade_stabilized_chassis()
		"vector_thrusters":
			upgrade_vector_thrusters()
		"impact_fuse":
			impact_fuse_level += 1
		"armor_piercers":
			armor_piercers_level += 1
		"weakpoint_scanner":
			weakpoint_scanner_level += 1
			update_power_level("railgun_orbiter")
		"med_pump":
			med_pump_level += 1
		"orbit_gears":
			orbit_gears_level += 1
			update_power_level("guardian_satellite")
		"mine_dispenser":
			mine_dispenser_level += 1
		"drone_command":
			drone_command_level += 1
			update_power_level("drone_swarm")
			update_power_level("guardian_satellite")
		"lucky_core":
			lucky_core_level += 1
	update_evolutions()


func get_extra_upgrade_ids() -> Array[String]:
	var ids: Array[String] = []
	for upgrade in get_extra_upgrade_catalog():
		ids.append(String(upgrade.id))
	return ids


func get_extra_upgrade_config(upgrade_id: String) -> Dictionary:
	for upgrade in get_extra_upgrade_catalog():
		if String(upgrade.id) == upgrade_id:
			return upgrade
	return {}


func apply_extra_upgrade_by_id(upgrade_id: String) -> bool:
	var upgrade := get_extra_upgrade_config(upgrade_id)
	if upgrade.is_empty():
		return false
	extra_upgrade_levels[upgrade_id] = int(extra_upgrade_levels.get(upgrade_id, 0)) + 1
	extra_upgrade_effect_cache_dirty = true
	var effects: Dictionary = upgrade.get("effects", {}) as Dictionary
	if effects.has("speed_multiplier"):
		speed *= 1.0 + float(effects.speed_multiplier)
	if effects.has("fire_interval_multiplier"):
		fire_interval *= float(effects.fire_interval_multiplier)
	if effects.has("damage_multiplier"):
		attack_damage *= 1.0 + float(effects.damage_multiplier)
	if effects.has("max_health"):
		max_health += int(effects.max_health)
		health = min(health + int(effects.max_health), max_health)
	if effects.has("armor_levels"):
		armor_level += int(effects.armor_levels)
	if effects.has("magnet_levels"):
		magnet_level += int(effects.magnet_levels)
	return true


func get_extra_upgrade_catalog() -> Array[Dictionary]:
	return [
		{"id": "auto_loader", "effects": {"fire_interval_multiplier": 0.96}},
		{"id": "focus_lens", "effects": {"crit_chance": 0.025, "crit_multiplier": 0.05}, "requires": {"targeting_array": 1}},
		{"id": "reinforced_tracks", "effects": {"speed_multiplier": 0.04, "armor_levels": 1}},
		{"id": "field_medic_kit", "effects": {"heal_multiplier": 0.14, "max_health": 1}},
		{"id": "repair_gel", "effects": {"heal_multiplier": 0.16}, "requires": {"nanobots": 1}},
		{"id": "salvage_claws", "effects": {"recycler_chance": 0.05}, "requires": {"recycler": 1}},
		{"id": "wide_nozzle", "effects": {"splash_radius": 5.0}, "requires": {"splash": 1}},
		{"id": "chain_fuse", "effects": {"splash_damage": 0.05}, "requires": {"splash": 1}},
		{"id": "reactive_tracks", "effects": {"speed_multiplier": 0.05, "invulnerability": 0.04}},
		{"id": "polished_barrel", "effects": {"damage_multiplier": 0.05, "projectile_speed": 0.04}},
		{"id": "pickup_scoop", "effects": {"pickup_radius": 20.0}},
		{"id": "overcharger", "effects": {"power_damage": 0.05}, "requires": {"shock_field": 1}},
		{"id": "boss_buster", "effects": {"boss_damage": 0.08}},
		{"id": "elite_hunter", "effects": {"elite_damage": 0.07}},
		{"id": "crystal_converter", "effects": {"exp_value": 0.06}, "requires": {"exp": 1}},
		{"id": "armor_gasket", "effects": {"armor_levels": 1, "heal_multiplier": 0.05}},
		{"id": "blast_compound", "effects": {"splash_radius": 4.0, "splash_damage": 0.04}, "requires": {"splash": 1}},
		{"id": "coolant_loop", "effects": {"fire_interval_multiplier": 0.975, "power_damage": 0.03}},
		{"id": "recoil_brace", "effects": {"damage_multiplier": 0.04, "crit_chance": 0.015}},
		{"id": "split_chamber", "effects": {"extra_shot_chance": 0.05}, "requires": {"cannon": 1}},
		{"id": "power_coupler", "effects": {"power_damage": 0.06}, "requires": {"shock_field": 1}},
		{"id": "shock_absorbers", "effects": {"armor_levels": 1, "invulnerability": 0.03}},
		{"id": "supply_scanner", "effects": {"pickup_radius": 14.0, "exp_value": 0.03}},
		{"id": "wrench_arm", "effects": {"pickup_radius": 26.0, "heal_multiplier": 0.08}},
		{"id": "battle_vault", "effects": {"max_health": 2, "armor_levels": 1}},
		{"id": "kinetic_capacitor", "effects": {"speed_multiplier": 0.04, "power_damage": 0.04}, "requires": {"speed": 1}},
		{"id": "prism_rounds", "effects": {"crit_chance": 0.02, "projectile_speed": 0.04}, "requires": {"piercing": 1}},
		{"id": "target_link", "effects": {"crit_chance": 0.018, "pet_damage": 0.05}, "requires": {"footsoldier": 1}},
		{"id": "flare_core", "effects": {"splash_damage": 0.05, "power_damage": 0.04}, "requires": {"flame_wave": 1}},
		{"id": "lucky_battery", "effects": {"extra_shot_chance": 0.035, "exp_value": 0.04}, "requires": {"lucky_core": 1}},
		{"id": "thermal_jacket", "effects": {"fire_interval_multiplier": 0.985, "armor_levels": 1}, "requires": {"fire_rate": 1}},
		{"id": "shrapnel_matrix", "effects": {"splash_damage": 0.06, "crit_multiplier": 0.04}, "requires": {"splash": 1}},
		{"id": "hollow_point_feed", "effects": {"damage_multiplier": 0.06, "crit_multiplier": 0.04}, "requires": {"damage": 1}},
		{"id": "engine_supercharger", "effects": {"speed_multiplier": 0.06, "projectile_speed": 0.03}, "requires": {"speed": 1}},
		{"id": "field_siphon", "effects": {"recycler_chance": 0.04, "heal_multiplier": 0.05}, "requires": {"recycler": 1}},
		{"id": "orbital_prism", "effects": {"extra_shot_chance": 0.035, "crit_chance": 0.015}, "requires": {"prism_rounds": 1}},
		{"id": "nano_plating", "effects": {"armor_levels": 1, "heal_multiplier": 0.07}, "requires": {"nanobots": 1}},
		{"id": "kinetic_scoop", "effects": {"pickup_radius": 18.0, "speed_multiplier": 0.03}, "requires": {"magnet": 1}},
		{"id": "capacitor_mesh", "effects": {"power_damage": 0.05, "crit_chance": 0.012}, "requires": {"capacitor_bank": 1}},
		{"id": "drone_uplink", "effects": {"pet_damage": 0.08, "projectile_damage": 0.03}, "requires": {"drone_command": 1}},
		{"id": "blast_retainer", "effects": {"splash_radius": 3.0, "splash_damage": 0.03, "area_damage": 0.03}, "requires": {"splash": 1}},
		{"id": "mender_tracks", "effects": {"speed_multiplier": 0.03, "heal_multiplier": 0.07}, "requires": {"field_medic_kit": 1}},
		{"id": "lucky_shrapnel", "effects": {"extra_shot_chance": 0.04, "splash_damage": 0.04}, "requires": {"lucky_core": 1}},
		{"id": "gravity_fins", "effects": {"projectile_speed": 0.05, "area_damage": 0.04}, "requires": {"gravity_anchor": 1}},
		{"id": "reinforced_ammo_belt", "effects": {"fire_interval_multiplier": 0.985, "extra_shot_chance": 0.025}, "requires": {"fire_rate": 1}},
		{"id": "crystal_reservoir", "effects": {"exp_value": 0.05, "pickup_radius": 12.0}, "requires": {"exp": 1}},
		{"id": "storm_insulator", "effects": {"armor_levels": 1, "power_damage": 0.035}, "requires": {"volt_coils": 1}},
		{"id": "target_predictor", "effects": {"crit_chance": 0.025, "projectile_speed": 0.035}, "requires": {"targeting_array": 1}},
		{"id": "emergency_battery", "effects": {"max_health": 1, "power_damage": 0.04, "heal_multiplier": 0.05}, "requires": {"overdrive_core": 1}},
		{"id": "singularity_lens", "effects": {"area_damage": 0.05, "pickup_radius": 16.0, "power_damage": 0.05}, "requires": {"black_hole_mines": 1}},
	]


func get_extra_upgrade_level(upgrade_id: String) -> int:
	return int(extra_upgrade_levels.get(upgrade_id, 0))


func get_extra_upgrade_effect(effect_id: String) -> float:
	if extra_upgrade_effect_cache_dirty:
		rebuild_extra_upgrade_effect_cache()
	return float(extra_upgrade_effect_cache.get(effect_id, 0.0))


func rebuild_extra_upgrade_effect_cache() -> void:
	extra_upgrade_effect_cache.clear()
	for upgrade in get_extra_upgrade_catalog():
		var level := get_extra_upgrade_level(String(upgrade.id))
		if level <= 0:
			continue
		var effects: Dictionary = upgrade.get("effects", {}) as Dictionary
		for effect_id in effects.keys():
			if effect_id in ["speed_multiplier", "fire_interval_multiplier", "damage_multiplier", "max_health", "armor_levels", "magnet_levels"]:
				continue
			extra_upgrade_effect_cache[effect_id] = float(extra_upgrade_effect_cache.get(effect_id, 0.0)) + float(effects[effect_id]) * float(level)
	extra_upgrade_effect_cache_dirty = false


func upgrade_damage() -> void:
	damage_level += 1
	attack_damage *= 1.2925


func upgrade_exp() -> void:
	exp_bonus_level += 1


func get_exp_value(base_exp_value: int) -> int:
	return int(ceil(float(base_exp_value) * (1.0 + float(exp_bonus_level) * 0.25 + float(salvage_magnet_level) * SALVAGE_MAGNET_EXP_PER_LEVEL + float(crystal_lens_level) * CRYSTAL_LENS_EXP_PER_LEVEL + float(lucky_core_level) * LUCKY_CORE_EXP_PER_LEVEL + get_extra_upgrade_effect("exp_value") + get_passive_power_effect("exp_value"))))


func upgrade_splash() -> void:
	splash_level += 1


func get_splash_radius() -> float:
	if splash_level <= 0 and payload_rack_level <= 0:
		return 0.0

	var upgrade_radius := 0.0
	if splash_level > 0:
		upgrade_radius = 10.0 + float(splash_level - 1) * 5.0

	return upgrade_radius + get_payload_splash_radius_bonus() + float(shatter_rounds_level) * SHATTER_ROUNDS_RADIUS_PER_LEVEL + float(ordnance_bay_level) * ORDNANCE_BAY_RADIUS_PER_LEVEL + float(missile_guidance_level) * MISSILE_GUIDANCE_RADIUS_PER_LEVEL + float(impact_fuse_level) * IMPACT_FUSE_RADIUS_PER_LEVEL + get_extra_upgrade_effect("splash_radius") + get_passive_power_effect("splash_radius") + get_evolution_effect_value("splash_radius_bonus")


func get_payload_splash_radius_bonus() -> float:
	return float(payload_rack_level) * PAYLOAD_RACK_SPLASH_RADIUS_PER_LEVEL


func get_splash_damage_multiplier() -> float:
	return (1.0 + float(payload_rack_level) * PAYLOAD_RACK_SPLASH_DAMAGE_PER_LEVEL + float(shatter_rounds_level) * SHATTER_ROUNDS_DAMAGE_PER_LEVEL + float(ordnance_bay_level) * ORDNANCE_BAY_DAMAGE_PER_LEVEL + float(impact_fuse_level) * IMPACT_FUSE_DAMAGE_PER_LEVEL + get_extra_upgrade_effect("splash_damage") + get_passive_power_effect("splash_damage")) * get_area_damage_multiplier() * get_evolution_effect_multiplier("splash_damage_multiplier")


func spawn_muzzle_burst() -> void:
	if muzzle_burst_timer < MUZZLE_BURST_INTERVAL:
		return
	
	muzzle_burst_timer = 0.0
	var muzzle_position: Vector2 = global_position + Vector2.UP.rotated(tank_cannon.rotation) * 34.0
	var main := get_tree().current_scene
	if main and main.has_method("spawn_particle_burst"):
		main.spawn_particle_burst(main, muzzle_position, 20, Color(1.0, 0.72, 0.12, 1.0), 150.0, 0.12, Vector2(1.5, 2.5), true)


func upgrade_piercing() -> void:
	piercing_level += 1


func upgrade_barbed_wire() -> void:
	barbed_wire_level += 1
	update_barbed_wire_visual()


func get_barbed_wire_damage() -> float:
	return attack_damage * BARBED_WIRE_DAMAGE_MULTIPLIER * float(barbed_wire_level) * get_area_damage_multiplier() * get_evolution_effect_multiplier("barbed_wire_damage_multiplier")


func process_barbed_wire(delta: float) -> void:
	if barbed_wire_level <= 0 or is_dead:
		barbed_wire_cooldowns.clear()
		return
	
	for enemy_id in barbed_wire_cooldowns.keys():
		barbed_wire_cooldowns[enemy_id] = max(float(barbed_wire_cooldowns[enemy_id]) - delta, 0.0)
	
	var active_enemy_ids := {}
	var radius := BARBED_WIRE_RADIUS + get_evolution_effect_value("barbed_wire_radius_bonus")
	var radius_squared := radius * radius
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		if global_position.distance_squared_to(enemy.global_position) > radius_squared:
			continue
		
		var enemy_id: int = enemy.get_instance_id()
		active_enemy_ids[enemy_id] = true
		if not barbed_wire_cooldowns.has(enemy_id):
			barbed_wire_cooldowns[enemy_id] = 0.0
		if float(barbed_wire_cooldowns[enemy_id]) > 0.0:
			continue
		
		var actual_damage: int = enemy.hit(get_barbed_wire_damage())
		var main := get_tree().current_scene
		if actual_damage > 0 and main and main.has_method("record_player_damage"):
			main.record_player_damage(actual_damage)
		barbed_wire_cooldowns[enemy_id] = BARBED_WIRE_DAMAGE_INTERVAL
	
	for enemy_id in barbed_wire_cooldowns.keys():
		if not active_enemy_ids.has(enemy_id):
			barbed_wire_cooldowns.erase(enemy_id)


func increase_max_health_from_level() -> void:
	max_health += 1
	health = min(health + 1, max_health)


func get_projectile_hp() -> int:
	return piercing_level + 1 + int(floor(float(phase_core_level) / 2.0)) * PHASE_CORE_PIERCE_PER_TWO_LEVELS + int(floor(float(armor_piercers_level) / 2.0)) * ARMOR_PIERCERS_PIERCE_PER_TWO_LEVELS + int(get_evolution_effect_value("piercing_bonus"))


func get_projectile_speed() -> float:
	return 500.0 * (1.0 + float(accelerator_level) * ACCELERATOR_PROJECTILE_SPEED_PER_LEVEL + float(phase_core_level) * PHASE_CORE_SPEED_PER_LEVEL + float(vector_thrusters_level) * VECTOR_THRUSTERS_PROJECTILE_SPEED_PER_LEVEL + get_extra_upgrade_effect("projectile_speed") + get_passive_power_effect("projectile_speed"))


func get_crit_chance() -> float:
	return min(float(targeting_array_level) * TARGETING_ARRAY_CRIT_CHANCE_PER_LEVEL + float(rail_stabilizer_level) * RAIL_STABILIZER_CRIT_CHANCE_PER_LEVEL + float(crystal_lens_level) * CRYSTAL_LENS_CRIT_CHANCE_PER_LEVEL + float(weakpoint_scanner_level) * WEAKPOINT_SCANNER_CRIT_CHANCE_PER_LEVEL + float(lucky_core_level) * LUCKY_CORE_CRIT_CHANCE_PER_LEVEL + get_extra_upgrade_effect("crit_chance") + get_passive_power_effect("crit_chance") + get_evolution_effect_value("crit_chance_bonus"), 0.9)


func get_crit_multiplier() -> float:
	if targeting_array_level <= 0:
		return 1.0 + get_extra_upgrade_effect("crit_multiplier") + get_passive_power_effect("crit_multiplier")
	return TARGETING_ARRAY_CRIT_MULTIPLIER + float(weakpoint_scanner_level) * WEAKPOINT_SCANNER_CRIT_MULTIPLIER_PER_LEVEL + get_extra_upgrade_effect("crit_multiplier") + get_passive_power_effect("crit_multiplier") + get_evolution_effect_value("crit_multiplier_bonus")


func fire_projectile_volley(target_direction: Vector2) -> void:
	var projectile_count := get_projectile_count()
	var spread_radians := deg_to_rad(CANNON_SPREAD_DEGREES)
	var middle_index := float(projectile_count - 1) / 2.0
	for i in range(projectile_count):
		var direction := target_direction.rotated((float(i) - middle_index) * spread_radians).normalized()
		var projectile_config := {
			"direction": direction,
		"damage": attack_damage * get_projectile_damage_multiplier(),
			"splash_radius": get_splash_radius(),
			"splash_damage_multiplier": get_splash_damage_multiplier(),
			"max_piercing_hp": get_projectile_hp(),
			"speed": get_projectile_speed(),
			"critical_chance": get_crit_chance(),
			"critical_multiplier": get_crit_multiplier(),
			"projectile_scale": get_projectile_scale(),
			"fade_in_duration": 0.08,
		}
		var main := get_tree().current_scene
		if main and main.has_method("spawn_projectile"):
			main.spawn_projectile(projectile_config, global_position + direction * 32.0)
		else:
			var proj = PROJECTILE.instantiate()
			get_tree().current_scene.add_child(proj)
			proj.global_position = global_position + direction * 32.0
			proj.launch(projectile_config)


func get_armor_damage_reduction() -> float:
	return min(float(armor_level) * ARMOR_DAMAGE_REDUCTION_PER_LEVEL + float(stabilized_chassis_level) * STABILIZED_CHASSIS_ARMOR_PER_LEVEL + get_passive_power_effect("armor") + get_evolution_effect_value("armor_reduction_bonus"), ARMOR_MAX_DAMAGE_REDUCTION)


func get_projectile_count() -> int:
	var projectile_count := 1 + cannon_level + int(get_evolution_effect_value("cannon_projectile_bonus")) + int(floor(float(ammo_synthesizer_level) / 2.0)) + int(floor(float(munition_printer_level) / 3.0))
	if ammo_synthesizer_level % 2 == 1 and randf() < 0.5:
		projectile_count += 1
	if munition_printer_level % 3 != 0 and randf() < 0.33:
		projectile_count += 1
	if lucky_core_level > 0 and randf() < min(float(lucky_core_level) * 0.025, 0.25):
		projectile_count += 1
	if randf() < min(get_extra_upgrade_effect("extra_shot_chance") + get_passive_power_effect("extra_shot_chance"), 0.65):
		projectile_count += 1
	return projectile_count


func get_area_damage_multiplier() -> float:
	return 1.0 + float(combustion_mix_level) * COMBUSTION_MIX_AREA_DAMAGE_PER_LEVEL + float(gravity_anchor_level) * GRAVITY_ANCHOR_AREA_DAMAGE_PER_LEVEL + get_extra_upgrade_effect("area_damage") + get_passive_power_effect("area_damage")


func upgrade_alloy_plating() -> void:
	alloy_plating_level += 1
	max_health += ALLOY_PLATING_HEALTH_PER_LEVEL
	health = min(health + ALLOY_PLATING_HEALTH_PER_LEVEL, max_health)


func upgrade_reactive_shield() -> void:
	reactive_shield_level += 1
	i_window += REACTIVE_SHIELD_I_WINDOW_PER_LEVEL


func upgrade_gyro_stabilizer() -> void:
	gyro_stabilizer_level += 1
	rotation_speed *= GYRO_ROTATION_MULTIPLIER


func upgrade_rapid_loader() -> void:
	rapid_loader_level += 1
	fire_interval *= RAPID_LOADER_FIRE_INTERVAL_MULTIPLIER


func upgrade_high_caliber() -> void:
	high_caliber_level += 1
	attack_damage *= HIGH_CALIBER_DAMAGE_MULTIPLIER


func upgrade_kinetic_treads() -> void:
	kinetic_treads_level += 1
	speed *= KINETIC_TREADS_SPEED_MULTIPLIER


func upgrade_heat_sinks() -> void:
	heat_sinks_level += 1
	fire_interval *= HEAT_SINKS_FIRE_INTERVAL_MULTIPLIER


func upgrade_overclocked_barrel() -> void:
	overclocked_barrel_level += 1
	fire_interval *= OVERCLOCKED_BARREL_FIRE_INTERVAL_MULTIPLIER
	attack_damage *= OVERCLOCKED_BARREL_DAMAGE_MULTIPLIER


func upgrade_stabilized_chassis() -> void:
	stabilized_chassis_level += 1
	rotation_speed *= STABILIZED_CHASSIS_ROTATION_MULTIPLIER


func upgrade_vector_thrusters() -> void:
	vector_thrusters_level += 1
	speed *= VECTOR_THRUSTERS_SPEED_MULTIPLIER
	rotation_speed *= VECTOR_THRUSTERS_ROTATION_MULTIPLIER


func try_recycler_heal(is_boss: bool = false) -> void:
	if recycler_level <= 0 or is_dead or health >= max_health:
		return

	if is_boss:
		var boss_healed_amount := heal(RECYCLER_BOSS_HEAL_AMOUNT + recycler_level)
		if boss_healed_amount > 0:
			show_self_heal_popup(boss_healed_amount)
		return

	var heal_chance: float = min(float(recycler_level) * RECYCLER_HEAL_CHANCE_PER_LEVEL + get_extra_upgrade_effect("recycler_chance") + get_passive_power_effect("recycler_chance") + get_evolution_effect_value("recycler_heal_chance_bonus"), 0.8)
	if randf() <= heal_chance:
		var healed_amount := heal(1 + int(get_passive_power_effect("recycler_heal")))
		if healed_amount > 0:
			show_self_heal_popup(healed_amount)


func show_self_heal_popup(healed_amount: int) -> void:
	var main := get_tree().current_scene
	if healed_amount > 0 and main and main.has_method("show_healing_popup"):
		main.show_healing_popup(global_position + Vector2(0.0, -28.0), healed_amount)


func process_emergency_repairs(delta: float) -> void:
	if emergency_repairs_level <= 0 or is_dead or health >= max_health:
		return
	if get_health_ratio() > EMERGENCY_REPAIRS_HEALTH_RATIO:
		emergency_repair_timer = 0.0
		return

	emergency_repair_timer += delta
	if emergency_repair_timer < get_emergency_repairs_interval():
		return

	emergency_repair_timer = 0.0
	heal(emergency_repairs_level)


func get_emergency_repairs_interval() -> float:
	return max(EMERGENCY_REPAIRS_INTERVAL - float(med_pump_level) * MED_PUMP_EMERGENCY_INTERVAL_REDUCTION, 3.0)


func update_evolutions() -> Array[String]:
	var newly_active: Array[String] = []
	for evolution in evolution_catalog:
		var evolution_id := String(evolution.id)
		if active_evolution_ids.has(evolution_id):
			continue
		if not are_evolution_requirements_met(evolution):
			continue
		
		active_evolution_ids.append(evolution_id)
		newly_active.append(evolution_id)
	
	if not newly_active.is_empty():
		apply_evolution_runtime_updates()
	return newly_active


func are_evolution_requirements_met(evolution: Dictionary) -> bool:
	var requirements: Dictionary = evolution.get("requirements", {}) as Dictionary
	for requirement_id in requirements.keys():
		if get_build_level_for_evolution(String(requirement_id)) < int(requirements[requirement_id]):
			return false
	return true


func get_build_level_for_evolution(build_id: String) -> int:
	match build_id:
		"speed":
			return speed_level
		"fire_rate":
			return fire_rate_level
		"damage":
			return damage_level
		"regeneration":
			return regeneration_level
		"exp":
			return exp_bonus_level
		"splash":
			return splash_level
		"piercing":
			return piercing_level
		"barbed_wire":
			return barbed_wire_level
		"armor":
			return armor_level
		"magnet":
			return magnet_level
		"cannon":
			return cannon_level
		"targeting_array":
			return targeting_array_level
		"accelerator":
			return accelerator_level
		"alloy_plating":
			return alloy_plating_level
		"recycler":
			return recycler_level
		"payload_rack":
			return payload_rack_level
		"reactive_shield":
			return reactive_shield_level
		"gyro_stabilizer":
			return gyro_stabilizer_level
		"rapid_loader":
			return rapid_loader_level
		"high_caliber":
			return high_caliber_level
		"nanobots":
			return nanobots_level
		"kinetic_treads":
			return kinetic_treads_level
		"ammo_synthesizer":
			return ammo_synthesizer_level
		"shatter_rounds":
			return shatter_rounds_level
		"phase_core":
			return phase_core_level
		"capacitor_bank":
			return capacitor_bank_level
		"salvage_magnet":
			return salvage_magnet_level
		"emergency_repairs":
			return emergency_repairs_level
		"combustion_mix":
			return combustion_mix_level
		"heat_sinks":
			return heat_sinks_level
		"overclocked_barrel":
			return overclocked_barrel_level
		"rail_stabilizer":
			return rail_stabilizer_level
		"missile_guidance":
			return missile_guidance_level
		"ordnance_bay":
			return ordnance_bay_level
		"field_amplifier":
			return field_amplifier_level
		"volt_coils":
			return volt_coils_level
		"gravity_anchor":
			return gravity_anchor_level
		"repair_drones":
			return repair_drones_level
		"crystal_lens":
			return crystal_lens_level
		"munition_printer":
			return munition_printer_level
		"stabilized_chassis":
			return stabilized_chassis_level
		"vector_thrusters":
			return vector_thrusters_level
		"impact_fuse":
			return impact_fuse_level
		"armor_piercers":
			return armor_piercers_level
		"weakpoint_scanner":
			return weakpoint_scanner_level
		"med_pump":
			return med_pump_level
		"orbit_gears":
			return orbit_gears_level
		"mine_dispenser":
			return mine_dispenser_level
		"drone_command":
			return drone_command_level
		"lucky_core":
			return lucky_core_level
		"landmine":
			return landmine_level
		"circular_saw":
			return circular_saw_level
		"footsoldier":
			return footsoldier_level
		"shock_field":
			return shock_field_level
		"artillery":
			return artillery_level
		"drone_swarm":
			return drone_swarm_level
		"oil_slick":
			return oil_slick_level
		"freeze_pulse":
			return freeze_pulse_level
		"chain_lightning":
			return chain_lightning_level
		"guardian_satellite":
			return guardian_satellite_level
		"overdrive_core":
			return overdrive_core_level
		"flame_wave":
			return flame_wave_level
		"repair_beacon":
			return repair_beacon_level
		"missile_pod":
			return missile_pod_level
		"gravity_well":
			return gravity_well_level
		"railgun_orbiter":
			return railgun_orbiter_level
		"tesla_pylon":
			return tesla_pylon_level
		"nanite_cloud":
			return nanite_cloud_level
		"ricochet_rounds":
			return ricochet_rounds_level
		"chrono_burst":
			return chrono_burst_level
	if extra_upgrade_levels.has(build_id):
		return get_extra_upgrade_level(build_id)
	if passive_power_levels.has(build_id):
		return get_passive_power_level(build_id)
	return 0


func upgrade_passive_power(power_id: String) -> void:
	passive_power_levels[power_id] = get_passive_power_level(power_id) + 1
	passive_power_effect_cache_dirty = true
	update_evolutions()


func get_passive_power_level(power_id: String) -> int:
	return int(passive_power_levels.get(power_id, 0))


func get_passive_power_effect(effect_id: String) -> float:
	if passive_power_effect_cache_dirty:
		rebuild_passive_power_effect_cache()
	return float(passive_power_effect_cache.get(effect_id, 0.0))


func rebuild_passive_power_effect_cache() -> void:
	passive_power_effect_cache.clear()
	for power in get_passive_power_catalog():
		var level := get_passive_power_level(String(power.id))
		if level <= 0:
			continue
		var effects: Dictionary = power.get("effects", {}) as Dictionary
		for effect_id in effects.keys():
			passive_power_effect_cache[effect_id] = float(passive_power_effect_cache.get(effect_id, 0.0)) + float(effects[effect_id]) * float(level)
	passive_power_effect_cache_dirty = false


func get_passive_power_catalog() -> Array[Dictionary]:
	return [
		{"id": "vampire_circuit", "effects": {"recycler_chance": 0.08, "heal_multiplier": 0.08}},
		{"id": "ion_lance", "effects": {"projectile_damage": 0.08, "projectile_speed": 0.06}},
		{"id": "meteor_shell", "effects": {"splash_radius": 7.0, "splash_damage": 0.07}},
		{"id": "bulldozer_aura", "effects": {"contact_damage": 0.1, "armor": 0.015}},
		{"id": "supply_beacon", "effects": {"pickup_radius": 18.0, "exp_value": 0.04}},
		{"id": "black_hole_mines", "effects": {"area_damage": 0.08, "splash_radius": 5.0}},
		{"id": "pulse_drone", "effects": {"pet_damage": 0.1, "projectile_damage": 0.03}},
		{"id": "acid_pool", "effects": {"area_damage": 0.07, "splash_damage": 0.05}},
		{"id": "guardian_wall", "effects": {"armor": 0.025, "heal_multiplier": 0.05}},
		{"id": "critical_storm", "effects": {"crit_chance": 0.035, "crit_multiplier": 0.08}},
		{"id": "repair_burst", "effects": {"heal_multiplier": 0.16, "recycler_heal": 1.0}},
		{"id": "magnet_storm", "effects": {"pickup_radius": 32.0, "power_damage": 0.04}},
		{"id": "orbital_cannon", "effects": {"extra_shot_chance": 0.06, "projectile_damage": 0.05}},
		{"id": "ember_turret", "effects": {"power_damage": 0.08, "area_damage": 0.04}},
		{"id": "time_shock", "effects": {"crit_chance": 0.02, "power_damage": 0.06}},
		{"id": "phase_magnet", "effects": {"pickup_radius": 24.0, "projectile_speed": 0.05}},
		{"id": "munition_swarm", "effects": {"extra_shot_chance": 0.05, "pet_damage": 0.06, "projectile_damage": 0.04}},
		{"id": "fortress_protocol", "effects": {"armor": 0.03, "heal_multiplier": 0.08}},
		{"id": "storm_catalyst", "effects": {"power_damage": 0.07, "crit_chance": 0.015, "area_damage": 0.03}},
		{"id": "golden_reactor", "effects": {"exp_value": 0.08, "extra_shot_chance": 0.025, "power_damage": 0.03}},
	]


func upgrade_vampire_circuit() -> void:
	upgrade_passive_power("vampire_circuit")


func upgrade_ion_lance() -> void:
	upgrade_passive_power("ion_lance")


func upgrade_meteor_shell() -> void:
	upgrade_passive_power("meteor_shell")


func upgrade_bulldozer_aura() -> void:
	upgrade_passive_power("bulldozer_aura")


func upgrade_supply_beacon() -> void:
	upgrade_passive_power("supply_beacon")


func upgrade_black_hole_mines() -> void:
	upgrade_passive_power("black_hole_mines")


func upgrade_pulse_drone() -> void:
	upgrade_passive_power("pulse_drone")


func upgrade_acid_pool() -> void:
	upgrade_passive_power("acid_pool")


func upgrade_guardian_wall() -> void:
	upgrade_passive_power("guardian_wall")


func upgrade_critical_storm() -> void:
	upgrade_passive_power("critical_storm")


func upgrade_repair_burst() -> void:
	upgrade_passive_power("repair_burst")


func upgrade_magnet_storm() -> void:
	upgrade_passive_power("magnet_storm")


func upgrade_orbital_cannon() -> void:
	upgrade_passive_power("orbital_cannon")


func upgrade_ember_turret() -> void:
	upgrade_passive_power("ember_turret")


func upgrade_time_shock() -> void:
	upgrade_passive_power("time_shock")


func upgrade_phase_magnet() -> void:
	upgrade_passive_power("phase_magnet")


func upgrade_munition_swarm() -> void:
	upgrade_passive_power("munition_swarm")


func upgrade_fortress_protocol() -> void:
	upgrade_passive_power("fortress_protocol")


func upgrade_storm_catalyst() -> void:
	upgrade_passive_power("storm_catalyst")


func upgrade_golden_reactor() -> void:
	upgrade_passive_power("golden_reactor")


func apply_evolution_runtime_updates() -> void:
	for ability_id in ["shock_field", "artillery", "drone_swarm", "chain_lightning", "guardian_satellite", "flame_wave", "repair_beacon", "missile_pod", "gravity_well", "railgun_orbiter", "tesla_pylon", "nanite_cloud", "ricochet_rounds", "chrono_burst"]:
		update_power_level(ability_id)
	update_barbed_wire_visual()
	spawn_evolution_burst()


func update_power_level(ability_id: String) -> void:
	var ability_node: Node2D = null
	match ability_id:
		"shock_field":
			ability_node = shock_field
		"artillery":
			ability_node = artillery_beacon
		"drone_swarm":
			ability_node = drone_swarm
		"chain_lightning":
			ability_node = chain_lightning
		"guardian_satellite":
			ability_node = guardian_satellite
		"flame_wave":
			ability_node = flame_wave
		"repair_beacon":
			ability_node = repair_beacon
		"missile_pod":
			ability_node = missile_pod
		"gravity_well":
			ability_node = gravity_well
		"railgun_orbiter":
			ability_node = railgun_orbiter
		"tesla_pylon":
			ability_node = tesla_pylon
		"nanite_cloud":
			ability_node = nanite_cloud
		"ricochet_rounds":
			ability_node = ricochet_rounds
		"chrono_burst":
			ability_node = chrono_burst
	if is_instance_valid(ability_node) and ability_node.has_method("update_level"):
		ability_node.update_level(get_effective_ability_level(ability_id))


func get_effective_ability_level(ability_id: String) -> int:
	match ability_id:
		"shock_field":
			return shock_field_level + int(get_evolution_effect_value("shock_field_level_bonus")) + int(floor(float(field_amplifier_level) / 2.0)) + int(floor(float(volt_coils_level) / 2.0))
		"artillery":
			return artillery_level + int(floor(float(ordnance_bay_level) / 2.0))
		"drone_swarm":
			return drone_swarm_level + int(get_evolution_effect_value("drone_swarm_level_bonus")) + int(floor(float(drone_command_level) / 2.0))
		"chain_lightning":
			return chain_lightning_level + int(get_evolution_effect_value("chain_lightning_level_bonus")) + int(floor(float(volt_coils_level) / 2.0))
		"guardian_satellite":
			return guardian_satellite_level + int(get_evolution_effect_value("guardian_satellite_level_bonus")) + int(floor(float(orbit_gears_level + drone_command_level) / 2.0))
		"flame_wave":
			return flame_wave_level + int(get_evolution_effect_value("flame_wave_level_bonus")) + int(floor(float(field_amplifier_level) / 2.0))
		"repair_beacon":
			return repair_beacon_level + int(get_evolution_effect_value("repair_beacon_level_bonus")) + int(floor(float(field_amplifier_level) / 2.0)) + int(floor(float(repair_drones_level) / 2.0))
		"missile_pod":
			return missile_pod_level + int(get_evolution_effect_value("missile_pod_level_bonus")) + int(floor(float(missile_guidance_level + ordnance_bay_level) / 2.0))
		"gravity_well":
			return gravity_well_level + int(get_evolution_effect_value("gravity_well_level_bonus")) + int(floor(float(field_amplifier_level + gravity_anchor_level) / 2.0))
		"railgun_orbiter":
			return railgun_orbiter_level + int(get_evolution_effect_value("railgun_orbiter_level_bonus")) + int(floor(float(rail_stabilizer_level + weakpoint_scanner_level) / 2.0))
		"tesla_pylon":
			return tesla_pylon_level + int(get_evolution_effect_value("tesla_pylon_level_bonus")) + int(floor(float(volt_coils_level) / 2.0))
		"nanite_cloud":
			return nanite_cloud_level + int(floor(float(repair_drones_level + med_pump_level) / 2.0))
		"ricochet_rounds":
			return ricochet_rounds_level + int(floor(float(armor_piercers_level + lucky_core_level) / 2.0))
		"chrono_burst":
			return chrono_burst_level + int(get_evolution_effect_value("chrono_burst_level_bonus")) + int(floor(float(field_amplifier_level) / 2.0))
	return get_build_level_for_evolution(ability_id)


func get_projectile_damage_multiplier() -> float:
	return get_power_damage_multiplier() * (1.0 + float(armor_piercers_level) * ARMOR_PIERCERS_DAMAGE_PER_LEVEL + get_passive_power_effect("projectile_damage")) * get_evolution_effect_multiplier("projectile_damage_multiplier")


func get_power_damage_multiplier() -> float:
	var multiplier := 1.0 + float(capacitor_bank_level) * CAPACITOR_BANK_DAMAGE_PER_LEVEL + float(volt_coils_level) * VOLT_COILS_POWER_DAMAGE_PER_LEVEL + get_extra_upgrade_effect("power_damage") + get_passive_power_effect("power_damage") + get_evolution_effect_value("overdrive_damage_bonus")
	if is_instance_valid(overdrive_core) and overdrive_core.has_method("get_damage_multiplier"):
		multiplier *= overdrive_core.get_damage_multiplier()
	return multiplier


func get_contact_power_damage_multiplier() -> float:
	return get_power_damage_multiplier() * (1.0 + float(orbit_gears_level) * ORBIT_GEARS_CONTACT_DAMAGE_PER_LEVEL + get_passive_power_effect("contact_damage") + get_evolution_effect_value("power_contact_damage_bonus"))


func get_pet_damage_multiplier() -> float:
	return get_power_damage_multiplier() * (1.0 + float(drone_command_level) * DRONE_COMMAND_PET_DAMAGE_PER_LEVEL + get_passive_power_effect("pet_damage"))


func get_power_speed_multiplier() -> float:
	if is_instance_valid(overdrive_core) and overdrive_core.has_method("get_speed_multiplier"):
		return overdrive_core.get_speed_multiplier()
	return 1.0


func get_evolution_effect_value(effect_id: String) -> float:
	var total := 0.0
	for evolution in get_active_evolution_configs():
		var effects: Dictionary = evolution.get("effects", {}) as Dictionary
		total += float(effects.get(effect_id, 0.0))
	return total


func get_evolution_effect_multiplier(effect_id: String) -> float:
	var multiplier := 1.0
	for evolution in get_active_evolution_configs():
		var effects: Dictionary = evolution.get("effects", {}) as Dictionary
		if effects.has(effect_id):
			multiplier *= float(effects.get(effect_id, 1.0))
	return multiplier


func get_evolution_projectile_scale() -> float:
	var scale_multiplier := 1.0
	for evolution in get_active_evolution_configs():
		var effects: Dictionary = evolution.get("effects", {}) as Dictionary
		if effects.has("projectile_scale"):
			scale_multiplier = max(scale_multiplier, float(effects.projectile_scale))
	return scale_multiplier


func get_projectile_scale() -> float:
	return get_evolution_projectile_scale() + float(high_caliber_level) * HIGH_CALIBER_PROJECTILE_SCALE_PER_LEVEL


func get_active_evolution_configs() -> Array[Dictionary]:
	var evolutions: Array[Dictionary] = []
	for evolution in evolution_catalog:
		if active_evolution_ids.has(String(evolution.id)):
			evolutions.append(evolution)
	return evolutions


func get_active_evolution_names() -> Array[String]:
	var names: Array[String] = []
	for evolution in get_active_evolution_configs():
		names.append(String(evolution.name))
	return names


func spawn_evolution_burst() -> void:
	var main := get_tree().current_scene
	if main and main.has_method("spawn_particle_burst"):
		main.spawn_particle_burst(main, global_position, 42, Color(0.35, 1.0, 0.9, 1.0), 250.0, 0.35, Vector2(4.0, 8.0), true)


func process_personal_magnet() -> void:
	if magnet_level <= 0 or is_dead:
		return
	
	var pull_radius := MAGNET_BASE_RADIUS + float(magnet_level - 1) * MAGNET_RADIUS_PER_LEVEL + float(salvage_magnet_level) * SALVAGE_MAGNET_RADIUS_PER_LEVEL + get_extra_upgrade_effect("pickup_radius") + get_passive_power_effect("pickup_radius")
	var pull_radius_squared := pull_radius * pull_radius
	for exp_orb in get_tree().get_nodes_in_group("ExpOrb"):
		if is_instance_valid(exp_orb) and global_position.distance_squared_to(exp_orb.global_position) <= pull_radius_squared:
			if exp_orb.has_method("set_magnet_active"):
				exp_orb.set_magnet_active(true, self)


func upgrade_regeneration() -> void:
	regeneration_level += 1
	if regeneration_amount <= 0:
		regeneration_virtual_interval = REGEN_START_INTERVAL
	else:
		regeneration_virtual_interval = max(regeneration_virtual_interval - REGEN_INTERVAL_STEP, REGEN_MIN_VIRTUAL_INTERVAL)
	
	regeneration_amount = maxi(1, ceili(REGEN_MIN_INTERVAL / regeneration_virtual_interval))
	regeneration_interval = float(regeneration_amount) * regeneration_virtual_interval
	regeneration_timer = 0.0


func can_upgrade_regeneration() -> bool:
	return regeneration_amount <= 0 or regeneration_virtual_interval > REGEN_MIN_VIRTUAL_INTERVAL


func process_regeneration(delta: float) -> void:
	if regeneration_interval <= 0.0 or regeneration_amount <= 0 or is_dead:
		return
	
	regeneration_timer += delta
	if regeneration_timer < regeneration_interval:
		return
	
	regeneration_timer = 0.0
	if health < max_health:
		health = min(health + regeneration_amount, max_health)


func rotate_toward_angle(current: float, target: float, max_delta: float) -> float:
	var difference := wrapf(target - current, -PI, PI)
	if abs(difference) <= max_delta:
		return target
	
	return current + sign(difference) * max_delta


func is_angle_aligned(current: float, target: float) -> bool:
	return abs(wrapf(target - current, -PI, PI)) <= deg_to_rad(1.0)


func hit(damage_amount: int = 1) -> bool:
	if i_timer < i_window:
		return false
	var reduced_damage := maxi(1, int(ceil(float(damage_amount) * (1.0 - get_armor_damage_reduction()))))
	var previous_health := health
	health = max(health - reduced_damage, 0)
	var main := get_tree().current_scene
	if main and main.has_method("record_player_damage_taken"):
		main.record_player_damage_taken(previous_health - health)
	if camera.has_method("start_shake"):
		camera.start_shake()
	damaged.emit(global_position)
	
	if health <= 0:
		is_dead = true
		disable_combat_on_death()
		set_tank_visible(false)
		update_smoke_state()
		defeated.emit()
	
	i_timer = 0.0
	return true


func disable_combat_on_death() -> void:
	fire_cooldown = -INF
	landmine_timer = 0.0
	barbed_wire_cooldowns.clear()
	clear_active_ability_nodes(active_landmines)
	clear_active_ability_nodes(circular_saws)
	clear_active_ability_nodes(footsoldiers)
	if is_instance_valid(shock_field):
		shock_field.queue_free()
		shock_field = null
	if is_instance_valid(artillery_beacon):
		artillery_beacon.queue_free()
		artillery_beacon = null
	if is_instance_valid(drone_swarm):
		drone_swarm.queue_free()
		drone_swarm = null
	if is_instance_valid(oil_slick_dispenser):
		oil_slick_dispenser.queue_free()
		oil_slick_dispenser = null
	if is_instance_valid(freeze_pulse):
		freeze_pulse.queue_free()
		freeze_pulse = null
	if is_instance_valid(chain_lightning):
		chain_lightning.queue_free()
		chain_lightning = null
	if is_instance_valid(guardian_satellite):
		guardian_satellite.queue_free()
		guardian_satellite = null
	if is_instance_valid(overdrive_core):
		overdrive_core.queue_free()
		overdrive_core = null
	if is_instance_valid(flame_wave):
		flame_wave.queue_free()
		flame_wave = null
	if is_instance_valid(repair_beacon):
		repair_beacon.queue_free()
		repair_beacon = null
	if is_instance_valid(missile_pod):
		missile_pod.queue_free()
		missile_pod = null
	if is_instance_valid(gravity_well):
		gravity_well.queue_free()
		gravity_well = null
	if is_instance_valid(railgun_orbiter):
		railgun_orbiter.queue_free()
		railgun_orbiter = null
	if is_instance_valid(tesla_pylon):
		tesla_pylon.queue_free()
		tesla_pylon = null
	if is_instance_valid(nanite_cloud):
		nanite_cloud.queue_free()
		nanite_cloud = null
	if is_instance_valid(ricochet_rounds):
		ricochet_rounds.queue_free()
		ricochet_rounds = null
	if is_instance_valid(chrono_burst):
		chrono_burst.queue_free()
		chrono_burst = null


func clear_active_ability_nodes(nodes: Array[Node2D]) -> void:
	for node in nodes:
		if is_instance_valid(node):
			node.queue_free()
	nodes.clear()


func heal(heal_amount: int) -> int:
	if heal_amount <= 0 or health >= max_health or is_dead:
		return 0
	
	heal_amount = int(ceil(float(heal_amount) * get_heal_multiplier()))
	var previous_health := health
	health = min(health + heal_amount, max_health)
	return health - previous_health


func get_heal_multiplier() -> float:
	return 1.0 + float(nanobots_level) * NANOBOTS_HEAL_BONUS_PER_LEVEL + float(repair_drones_level) * REPAIR_DRONES_HEAL_BONUS_PER_LEVEL + float(med_pump_level) * MED_PUMP_HEAL_BONUS_PER_LEVEL + get_extra_upgrade_effect("heal_multiplier") + get_passive_power_effect("heal_multiplier") + get_evolution_effect_value("heal_multiplier_bonus")


func get_pickup_collection_radius() -> float:
	var magnet_radius := 0.0
	if magnet_level > 0:
		magnet_radius = MAGNET_BASE_RADIUS + float(magnet_level - 1) * MAGNET_RADIUS_PER_LEVEL
	return 28.0 + magnet_radius * 0.35 + float(salvage_magnet_level) * SALVAGE_MAGNET_RADIUS_PER_LEVEL * 0.5 + get_extra_upgrade_effect("pickup_radius") + get_passive_power_effect("pickup_radius")


func update_invincibility_visual() -> void:
	if i_timer >= i_window or is_dead:
		tank_base.modulate.a = 1.0
		tank_cannon.modulate.a = 1.0
		return
	
	var pulse: float = 0.35 + abs(sin(i_timer * TAU * 6.0)) * 0.65
	tank_base.modulate.a = pulse
	tank_cannon.modulate.a = pulse


func get_health_ratio() -> float:
	return float(health) / float(max_health)


func setup_smoke_particles() -> void:
	smoke_particles = GPUParticles2D.new()
	smoke_particles.name = "SmokeParticles"
	smoke_particles.emitting = false
	smoke_particles.visible = false
	smoke_particles.amount = 70
	smoke_particles.lifetime = 0.8
	smoke_particles.process_material = create_smoke_particle_material()
	smoke_particles.texture = create_smoke_particle_texture()
	smoke_particles.z_index = 3
	add_child(smoke_particles)


func create_smoke_particle_material() -> ParticleProcessMaterial:
	var particle_material := ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, -1, 0)
	particle_material.spread = 52.0
	particle_material.initial_velocity_min = 65.0
	particle_material.initial_velocity_max = 95.0
	particle_material.gravity = Vector3(0, -18, 0)
	particle_material.scale_min = 0.9
	particle_material.scale_max = 1.7
	particle_material.scale_curve = create_smoke_scale_curve()
	particle_material.color = Color(0.48, 0.48, 0.48, 0.62)
	particle_material.color_ramp = create_smoke_alpha_ramp()
	return particle_material


func create_smoke_scale_curve() -> CurveTexture:
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 0.75))
	curve.add_point(Vector2(1.0, 1.7))
	var texture := CurveTexture.new()
	texture.curve = curve
	return texture


func create_smoke_alpha_ramp() -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.55, 0.55, 0.55, 0.58))
	gradient.set_color(1, Color(0.55, 0.55, 0.55, 0.0))
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture


func create_smoke_particle_texture() -> ImageTexture:
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var center := Vector2(15.5, 15.5)
	
	for y in range(32):
		for x in range(32):
			var distance: float = center.distance_to(Vector2(x, y))
			var alpha: float = clamp(1.0 - distance / 15.0, 0.0, 1.0)
			alpha = pow(alpha, 0.7)
			image.set_pixel(x, y, Color(0.55, 0.55, 0.55, alpha))
	
	return ImageTexture.create_from_image(image)


func update_smoke_state() -> void:
	if not is_node_ready() or smoke_particles == null:
		return
	
	var should_emit := not is_dead and get_health_ratio() <= 0.2
	smoke_particles.visible = should_emit
	smoke_particles.emitting = should_emit
	
	if is_dead:
		smoke_particles.restart()


func set_tank_visible(should_show: bool) -> void:
	tank_base.visible = should_show
	tank_cannon.visible = should_show
	update_barbed_wire_visual()


func update_barbed_wire_visual() -> void:
	if not is_node_ready() or barbed_wire_ring == null:
		return
	
	barbed_wire_ring.visible = not is_dead and barbed_wire_level > 0


func get_nearest_enemy() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("Enemy")
	var nearest: Node2D = null
	var nearest_distance: float = INF
	
	for enemy in enemies:
		if enemy.has_method("is_damageable") and not enemy.is_damageable():
			continue
		
		var dist: float = global_position.distance_squared_to(enemy.global_position)
		if dist < nearest_distance:
			nearest = enemy
			nearest_distance = dist
	
	return nearest
