extends Area2D

signal defeated(enemy_position: Vector2, exp_drop_count: int, exp_drop_min_tier: int)

@export var base_speed: float = 25.0
@export var health: int = 1000
@export var contact_damage: int = 5
@export var exp_drop_count: int = 30
@export var exp_drop_min_tier: int = 1
@export var boss_behavior: String = "charger"
@export var ability_modules: Array[Dictionary] = []
@export var phase_thresholds: Array[float] = []

const ARENA_INSET: float = 72.0

var speed: float = 25.0
var player: CharacterBody2D
var main: Node2D
var is_defeated: bool = false
var hit_flash_timer: float = 0.0
var base_modulate: Color = Color.WHITE
var base_health: int = 1000
var max_health: int = 1000
var variant_color: Color = Color.WHITE
var variant_scale: float = 1.0
var pulse_timer: float = 0.0
var slow_timer: float = 0.0
var slow_multiplier: float = 1.0
var ability_timers: Array[float] = []
var phase_index: int = 0

@onready var mesh_instance: MeshInstance2D = $MeshInstance2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var health_bar: Control = $HealthBar
@onready var state_machine: StateMachine = $StateMachine


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	main = get_tree().current_scene
	speed = base_speed
	base_health = health
	max_health = health
	apply_variant_visuals()
	base_modulate = mesh_instance.modulate
	update_health_bar()
	state_machine.setup(self)


func _process(delta: float) -> void:
	pulse_timer += delta
	update_status_effects(delta)
	update_behavior_effect(delta)
	update_phase_state()
	update_ability_modules(delta)
	update_hit_flash(delta)
	state_machine.update(delta)
	clamp_to_arena()
	process_contact_damage()


func configure_variant(config: Dictionary) -> void:
	base_speed = float(config.get("speed", base_speed))
	speed = base_speed
	health = int(config.get("health", health))
	contact_damage = int(config.get("contact_damage", contact_damage))
	exp_drop_count = int(config.get("exp_drop_count", exp_drop_count))
	exp_drop_min_tier = int(config.get("exp_drop_min_tier", exp_drop_min_tier))
	boss_behavior = String(config.get("behavior", boss_behavior))
	ability_modules = get_typed_ability_modules(config.get("ability_modules", []))
	phase_thresholds = get_typed_phase_thresholds(config.get("phase_thresholds", []))
	reset_ability_timers()
	variant_color = config.get("color", Color.WHITE) as Color
	variant_scale = float(config.get("scale", 1.0))
	if is_node_ready():
		base_health = health
		max_health = health
		apply_variant_visuals()
		base_modulate = mesh_instance.modulate
		update_health_bar()


func reset_ability_timers() -> void:
	ability_timers.clear()
	for module in ability_modules:
		var initial_delay := float(module.get("initial_delay", module.get("cooldown", 4.0)))
		ability_timers.append(initial_delay)


func get_typed_ability_modules(raw_modules: Variant) -> Array[Dictionary]:
	var typed_modules: Array[Dictionary] = []
	if not (raw_modules is Array):
		return typed_modules
	
	for module in raw_modules:
		if module is Dictionary:
			typed_modules.append((module as Dictionary).duplicate(true))
	
	return typed_modules


func get_typed_phase_thresholds(raw_thresholds: Variant) -> Array[float]:
	var typed_thresholds: Array[float] = []
	if not (raw_thresholds is Array):
		return typed_thresholds
	
	for threshold in raw_thresholds:
		typed_thresholds.append(float(threshold))
	
	return typed_thresholds


func apply_variant_visuals() -> void:
	if variant_color != Color.WHITE:
		mesh_instance.modulate = variant_color
	if not is_equal_approx(variant_scale, 1.0):
		mesh_instance.scale = Vector2.ONE * variant_scale
		collision_shape.scale = Vector2.ONE * variant_scale


func apply_slow(duration: float, multiplier: float) -> void:
	slow_timer = max(slow_timer, duration)
	slow_multiplier = min(slow_multiplier, clamp(multiplier, 0.05, 1.0))
	if is_node_ready():
		mesh_instance.modulate = base_modulate.lerp(Color(0.35, 0.85, 1.0, 1.0), 0.35)


func update_status_effects(delta: float) -> void:
	if slow_timer <= 0.0:
		return
	
	slow_timer = max(slow_timer - delta, 0.0)
	if slow_timer <= 0.0:
		slow_multiplier = 1.0
		if hit_flash_timer <= 0.0:
			mesh_instance.modulate = base_modulate


func get_status_speed_multiplier() -> float:
	return slow_multiplier if slow_timer > 0.0 else 1.0


func update_behavior_effect(delta: float) -> void:
	match boss_behavior:
		"bulwark":
			mesh_instance.rotation += delta * 0.35
		"sprinter":
			speed = base_speed * (1.0 + max(0.0, sin(pulse_timer * 2.5)) * 0.75) * get_status_speed_multiplier()
		"crusher":
			mesh_instance.scale = Vector2.ONE * variant_scale * (1.0 + sin(pulse_timer * 6.0) * 0.035)
		"wraith":
			mesh_instance.modulate.a = 0.72 + abs(sin(pulse_timer * 2.0)) * 0.28
		"monarch":
			mesh_instance.rotation = sin(pulse_timer * 1.4) * 0.18
			speed = base_speed * (0.92 + abs(sin(pulse_timer * 1.1)) * 0.22) * get_status_speed_multiplier()
		"tempest":
			mesh_instance.rotation += delta * 1.2
			speed = base_speed * (1.0 + max(0.0, sin(pulse_timer * 3.3)) * 0.55) * get_status_speed_multiplier()
		"bastion":
			mesh_instance.scale = Vector2.ONE * variant_scale * (1.0 + sin(pulse_timer * 3.2) * 0.025)
		_:
			pass


func update_phase_state() -> void:
	if phase_thresholds.is_empty() or max_health <= 0:
		return
	
	var health_ratio := float(health) / float(max_health)
	while phase_index < phase_thresholds.size() and health_ratio <= float(phase_thresholds[phase_index]):
		phase_index += 1
		base_speed *= 1.08
		contact_damage += 1
		if main and main.has_method("spawn_boss_phase_burst"):
			main.spawn_boss_phase_burst(global_position, phase_index)


func update_ability_modules(delta: float) -> void:
	if ability_modules.is_empty() or main == null or not main.has_method("execute_boss_ability"):
		return
	
	for i in range(ability_modules.size()):
		ability_timers[i] -= delta
		if ability_timers[i] > 0.0:
			continue
		var module: Dictionary = ability_modules[i]
		main.execute_boss_ability(self, module, phase_index)
		var phase_cooldown_multiplier := pow(float(module.get("phase_cooldown_multiplier", 0.86)), phase_index)
		ability_timers[i] = float(module.get("cooldown", 6.0)) * phase_cooldown_multiplier


func process_contact_damage() -> void:
	var bodies := get_overlapping_bodies()
	if bodies.is_empty():
		return
	
	var body = bodies[0]
	if body.is_in_group("Player"):
		var damage_amount := contact_damage
		if main and main.has_method("get_scaled_enemy_contact_damage"):
			damage_amount = main.get_scaled_enemy_contact_damage(contact_damage)
		
		body.hit(damage_amount)


func hit(damage: float = 10.0, show_number: bool = true) -> int:
	if is_defeated:
		return 0
	if not is_damageable():
		return 0
	
	var actual_damage: int = mini(floori(damage), health)
	health -= actual_damage
	update_health_bar()
	
	if show_number and main and main.has_method("show_damage_number"):
		main.show_damage_number(global_position, actual_damage)
		start_hit_flash()
	
	if health <= 0:
		is_defeated = true
		defeated.emit(global_position, exp_drop_count, exp_drop_min_tier)
		queue_free()
	
	return actual_damage


func update_health_bar() -> void:
	if health_bar == null:
		return
	
	var health_ratio := 0.0
	if max_health > 0:
		health_ratio = clamp(float(health) / float(max_health), 0.0, 1.0)
	
	health_bar.set_progress(health_ratio)


func is_damageable() -> bool:
	if main and main.has_method("is_position_in_arena"):
		return main.is_position_in_arena(global_position)
	
	return true


func clamp_to_arena() -> bool:
	if main == null or not main.has_method("get_arena_rect"):
		return false
	
	var arena_rect: Rect2 = main.get_arena_rect().grow(-ARENA_INSET)
	if arena_rect.size.x <= 0.0 or arena_rect.size.y <= 0.0:
		arena_rect = main.get_arena_rect()
	
	var clamped_position := Vector2(
		clamp(global_position.x, arena_rect.position.x, arena_rect.end.x),
		clamp(global_position.y, arena_rect.position.y, arena_rect.end.y)
	)
	var was_clamped := global_position.distance_squared_to(clamped_position) > 0.01
	global_position = clamped_position
	return was_clamped


func set_global_speed_scale(global_speed_scale: float) -> void:
	speed = base_speed * global_speed_scale


func apply_speed_multiplier(multiplier: float) -> void:
	speed *= multiplier


func apply_health_bonus(total_bonus_percent: float) -> void:
	var previous_max_health := max_health
	max_health = int(ceil(float(base_health) * (1.0 + total_bonus_percent)))
	var health_gain := max_health - previous_max_health
	if health_gain > 0:
		health += health_gain
		update_health_bar()


func start_hit_flash() -> void:
	hit_flash_timer = 0.08
	mesh_instance.modulate = Color.WHITE


func update_hit_flash(delta: float) -> void:
	if hit_flash_timer <= 0.0:
		return
	
	hit_flash_timer -= delta
	if hit_flash_timer <= 0.0:
		mesh_instance.modulate = base_modulate
