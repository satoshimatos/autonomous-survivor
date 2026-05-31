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
const MAGNET_BASE_RADIUS: float = 86.0
const MAGNET_RADIUS_PER_LEVEL: float = 38.0
const CANNON_SPREAD_DEGREES: float = 12.0

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
	process_landmine_placement(delta)
	process_barbed_wire(delta)
	process_personal_magnet()
	update_invincibility_visual()
	
	var input: Vector2 = get_movement_input(delta)
	velocity = input.normalized() * speed
	if velocity.length_squared() > 0.0:
		tank_base.rotation = rotate_toward_angle(tank_base.rotation, velocity.angle() + PI / 2.0, rotation_speed * delta)
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
			shock_field.update_level(shock_field_level)
		return
	
	shock_field = SHOCK_FIELD.instantiate()
	add_child(shock_field)
	if shock_field.has_method("configure"):
		shock_field.configure(self, shock_field_level)


func upgrade_artillery() -> void:
	artillery_level += 1
	if is_instance_valid(artillery_beacon):
		if artillery_beacon.has_method("update_level"):
			artillery_beacon.update_level(artillery_level)
		return
	
	var main := get_tree().current_scene
	if main == null:
		return
	
	artillery_beacon = ARTILLERY_BEACON.instantiate()
	main.add_child(artillery_beacon)
	if artillery_beacon.has_method("configure"):
		artillery_beacon.configure(self, artillery_level)


func apply_selected_tank_archetype() -> void:
	var tank: Dictionary = get_run_config().get_selected_tank()
	selected_tank_id = String(tank.get("id", selected_tank_id))
	selected_tank_name = String(tank.get("name", selected_tank_name))
	speed *= float(tank.get("speed_multiplier", 1.0))
	max_health = max(1, max_health + int(tank.get("health_bonus", 0)))
	attack_damage *= float(tank.get("damage_multiplier", 1.0))
	fire_interval *= float(tank.get("fire_interval_multiplier", 1.0)) * float(get_run_config().get_modifier_multiplier("player_fire_interval_multiplier"))
	
	speed_level += int(tank.get("speed_level", 0))
	damage_level += int(tank.get("damage_level", 0))
	fire_rate_level += int(tank.get("fire_rate_level", 0))
	armor_level += int(tank.get("armor_level", 0))
	magnet_level += int(tank.get("magnet_level", 0))
	cannon_level += int(tank.get("cannon_level", 0))
	exp_bonus_level += int(tank.get("exp_bonus_level", 0))
	
	var tint: Color = tank.get("color", Color.WHITE) as Color
	tank_base.modulate = tint
	tank_cannon.modulate = tint
	
	apply_starting_ability_levels(tank)


func get_run_config() -> Node:
	return get_node("/root/RunConfig")


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


func upgrade_drone_swarm() -> void:
	drone_swarm_level += 1
	if is_instance_valid(drone_swarm):
		if drone_swarm.has_method("update_level"):
			drone_swarm.update_level(drone_swarm_level)
		return
	
	drone_swarm = DRONE_SWARM.instantiate()
	add_child(drone_swarm)
	if drone_swarm.has_method("configure"):
		drone_swarm.configure(self, drone_swarm_level)


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
	return max(LANDMINE_BASE_INTERVAL - float(landmine_level - 1) * LANDMINE_INTERVAL_STEP, LANDMINE_MIN_INTERVAL)


func get_landmine_damage_multiplier() -> float:
	return LANDMINE_BASE_DAMAGE_MULTIPLIER * pow(LANDMINE_DAMAGE_LEVEL_MULTIPLIER, float(max(landmine_level - 1, 0)))


func get_valid_upgrade_ids() -> Array[String]:
	var valid_upgrades: Array[String] = ["speed", "fire_rate", "damage", "exp", "splash", "piercing", "barbed_wire", "armor", "magnet", "cannon"]
	if can_upgrade_regeneration():
		valid_upgrades.append("regeneration")
	
	return valid_upgrades


func apply_upgrade_by_id(upgrade_id: String) -> void:
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


func upgrade_damage() -> void:
	damage_level += 1
	attack_damage *= 1.2925


func upgrade_exp() -> void:
	exp_bonus_level += 1


func get_exp_value(base_exp_value: int) -> int:
	return int(ceil(float(base_exp_value) * (1.0 + float(exp_bonus_level) * 0.25)))


func upgrade_splash() -> void:
	splash_level += 1


func get_splash_radius() -> float:
	if splash_level <= 0:
		return 0.0
	
	return 10.0 + float(splash_level - 1) * 5.0


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
	return attack_damage * BARBED_WIRE_DAMAGE_MULTIPLIER * float(barbed_wire_level)


func process_barbed_wire(delta: float) -> void:
	if barbed_wire_level <= 0 or is_dead:
		barbed_wire_cooldowns.clear()
		return
	
	for enemy_id in barbed_wire_cooldowns.keys():
		barbed_wire_cooldowns[enemy_id] = max(float(barbed_wire_cooldowns[enemy_id]) - delta, 0.0)
	
	var active_enemy_ids := {}
	var radius_squared := BARBED_WIRE_RADIUS * BARBED_WIRE_RADIUS
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
	return piercing_level + 1


func fire_projectile_volley(target_direction: Vector2) -> void:
	var projectile_count := 1 + cannon_level
	var spread_radians := deg_to_rad(CANNON_SPREAD_DEGREES)
	var middle_index := float(projectile_count - 1) / 2.0
	for i in range(projectile_count):
		var direction := target_direction.rotated((float(i) - middle_index) * spread_radians).normalized()
		var projectile_config := {
			"direction": direction,
			"damage": attack_damage,
			"splash_radius": get_splash_radius(),
			"max_piercing_hp": get_projectile_hp(),
			"fade_in_duration": 0.08,
		}
		var main := get_tree().current_scene
		if main and main.has_method("spawn_projectile"):
			main.spawn_projectile(projectile_config, global_position + direction * 32.0)
		else:
			var proj = PROJECTILE.instantiate()
			get_tree().current_scene.add_child(proj)
			proj.launch(projectile_config)
			proj.global_position = global_position + direction * 32.0


func get_armor_damage_reduction() -> float:
	return min(float(armor_level) * ARMOR_DAMAGE_REDUCTION_PER_LEVEL, ARMOR_MAX_DAMAGE_REDUCTION)


func process_personal_magnet() -> void:
	if magnet_level <= 0 or is_dead:
		return
	
	var pull_radius := MAGNET_BASE_RADIUS + float(magnet_level - 1) * MAGNET_RADIUS_PER_LEVEL
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


func clear_active_ability_nodes(nodes: Array[Node2D]) -> void:
	for node in nodes:
		if is_instance_valid(node):
			node.queue_free()
	nodes.clear()


func heal(heal_amount: int) -> int:
	if heal_amount <= 0 or health >= max_health or is_dead:
		return 0
	
	var previous_health := health
	health = min(health + heal_amount, max_health)
	return health - previous_health


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
