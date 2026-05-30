extends Node2D

const BASE_DROP_INTERVAL: float = 3.8
const DROP_INTERVAL_STEP: float = 0.28
const MIN_DROP_INTERVAL: float = 1.35
const OIL_SLICK = preload("res://scenes/abilities/oil_slick.tscn")

var player: CharacterBody2D
var oil_level: int = 1
var drop_timer: float = 0.0
var active_slicks: Array[Node2D] = []


func _process(delta: float) -> void:
	if player == null or player.is_dead:
		clear_slicks()
		queue_free()
		return
	
	cleanup_slicks()
	drop_timer += delta
	if drop_timer >= get_drop_interval():
		drop_timer = 0.0
		drop_slick()


func configure(new_player: CharacterBody2D, new_level: int) -> void:
	player = new_player
	oil_level = max(new_level, 1)
	drop_timer = get_drop_interval() * 0.5


func update_level(new_level: int) -> void:
	oil_level = max(new_level, 1)


func get_drop_interval() -> float:
	return max(BASE_DROP_INTERVAL - float(oil_level - 1) * DROP_INTERVAL_STEP, MIN_DROP_INTERVAL)


func get_max_active_slicks() -> int:
	return 4 + oil_level * 2


func drop_slick() -> void:
	var main := get_tree().current_scene
	if main == null:
		return
	
	cleanup_slicks()
	while active_slicks.size() >= get_max_active_slicks():
		var old_slick: Node2D = active_slicks.pop_front()
		if is_instance_valid(old_slick):
			old_slick.queue_free()
	
	var slick = OIL_SLICK.instantiate()
	main.add_child(slick)
	slick.global_position = player.global_position
	if slick.has_method("configure"):
		slick.configure(player, oil_level)
	active_slicks.append(slick)


func cleanup_slicks() -> void:
	for i in range(active_slicks.size() - 1, -1, -1):
		if not is_instance_valid(active_slicks[i]):
			active_slicks.remove_at(i)


func clear_slicks() -> void:
	for slick in active_slicks:
		if is_instance_valid(slick):
			slick.queue_free()
	active_slicks.clear()
