extends Area2D

var pulse_time: float = 0.0
var is_active: bool = true


func activate(spawn_position: Vector2) -> void:
	global_position = spawn_position
	visible = true
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	is_active = true
	if not is_in_group("DynamitePickup"):
		add_to_group("DynamitePickup")


func deactivate() -> void:
	is_active = false
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	global_position = Vector2(-100000.0, -100000.0)
	if is_in_group("DynamitePickup"):
		remove_from_group("DynamitePickup")


func _process(delta: float) -> void:
	if not is_active:
		return
	
	pulse_time += delta
	var pulse: float = 1.0 + sin(pulse_time * TAU * 2.0) * 0.15
	$PickupSprite.scale = Vector2.ONE * 0.375 * pulse


func _on_body_entered(body: Node2D) -> void:
	if is_active and body.is_in_group("Player"):
		var main: Node = get_tree().current_scene
		if main and main.has_method("activate_dynamite"):
			main.activate_dynamite()
		deactivate()
