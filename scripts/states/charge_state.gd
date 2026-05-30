extends EnemyState
class_name ChargeState

@export var duration: float = 2.5
@export var line_growth_speed: float = 300.0
@export var line_width: float = 34.0
@export var line_color: Color = Color(1.0, 0.0, 0.0, 0.72)
@export var next_state_name: String = "DashState"
@export var telegraph_line_path: NodePath = ^"TelegraphLine"

var elapsed: float = 0.0
var locked_direction: Vector2 = Vector2.RIGHT
var telegraph_line: Line2D


func enter() -> void:
	elapsed = 0.0
	locked_direction = get_direction_to_player()
	state_machine.blackboard["dash_direction"] = locked_direction
	state_machine.blackboard["dash_distance"] = line_growth_speed * duration
	setup_telegraph_line()
	update_telegraph_line(0.0)


func exit() -> void:
	if telegraph_line:
		telegraph_line.visible = false
		telegraph_line.remove_from_group("BossChargeDanger")


func update(delta: float) -> void:
	elapsed += delta
	update_telegraph_line(min(elapsed * line_growth_speed, line_growth_speed * duration))
	
	if elapsed >= duration and next_state_name != "":
		request_transition(next_state_name)


func get_direction_to_player() -> Vector2:
	if actor == null:
		return Vector2.RIGHT
	
	var player := actor.get_tree().get_first_node_in_group("Player") as Node2D
	if player == null:
		return Vector2.RIGHT
	
	var direction := actor.global_position.direction_to(player.global_position)
	if direction.is_zero_approx():
		return Vector2.RIGHT
	
	return direction


func setup_telegraph_line() -> void:
	telegraph_line = null
	if actor:
		telegraph_line = actor.get_node_or_null(telegraph_line_path) as Line2D
	
	if telegraph_line == null:
		return
	
	telegraph_line.width = line_width
	telegraph_line.default_color = line_color
	telegraph_line.visible = true
	if not telegraph_line.is_in_group("BossChargeDanger"):
		telegraph_line.add_to_group("BossChargeDanger")


func update_telegraph_line(line_length: float) -> void:
	if telegraph_line == null:
		return
	
	telegraph_line.clear_points()
	telegraph_line.add_point(Vector2.ZERO)
	telegraph_line.add_point(locked_direction * line_length)
	telegraph_line.set_meta("danger_width", line_width)
