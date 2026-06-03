extends Node2D

const MAP1_ID: String = "map1"
const MAP2_ID: String = "map2"
const MAP1_ARENA_SIZE: Vector2 = Vector2(1620, 930)
const MAP1_BOUNDS_SIZE: Vector2 = Vector2(1940, 1250)
const MAP2_ARENA_SIZE: Vector2 = Vector2(2300, 1400)
const MAP2_BOUNDS_SIZE: Vector2 = Vector2(2620, 1720)
const SEARCH_STEP: float = 28.0
const SEARCH_DIRECTIONS: int = 18

@export var arena_center: Vector2 = Vector2(576, 324)
@export var map2_obstacles_path: NodePath = ^"Map2Obstacles"

var selected_map_id: String = MAP1_ID
var active_obstacle_rects: Array[Rect2] = []
var map2_obstacles: Node


func _ready() -> void:
	map2_obstacles = get_node_or_null(map2_obstacles_path)
	apply_map(MAP1_ID)


func apply_map(map_id: String) -> void:
	selected_map_id = map_id
	if map2_obstacles:
		map2_obstacles.visible = map_id == MAP2_ID
		set_collision_enabled_recursive(map2_obstacles, map_id == MAP2_ID)
	rebuild_obstacle_cache()


func get_arena_size() -> Vector2:
	return MAP2_ARENA_SIZE if selected_map_id == MAP2_ID else MAP1_ARENA_SIZE


func get_bounds_size() -> Vector2:
	return MAP2_BOUNDS_SIZE if selected_map_id == MAP2_ID else MAP1_BOUNDS_SIZE


func get_arena_rect() -> Rect2:
	var arena_size := get_arena_size()
	return Rect2(arena_center - arena_size / 2.0, arena_size)


func is_walkable(world_position: Vector2, clearance: float = 0.0) -> bool:
	if not get_arena_rect().grow(-clearance).has_point(world_position):
		return false
	for rect in active_obstacle_rects:
		if rect.grow(clearance).has_point(world_position):
			return false
	return true


func get_nearest_walkable_position(world_position: Vector2, clearance: float = 0.0) -> Vector2:
	var arena_rect := get_arena_rect().grow(-clearance)
	var clamped_position := Vector2(
		clamp(world_position.x, arena_rect.position.x, arena_rect.end.x),
		clamp(world_position.y, arena_rect.position.y, arena_rect.end.y)
	)
	if is_walkable(clamped_position, clearance):
		return clamped_position

	var base_angle := randf() * TAU
	for ring in range(1, 18):
		var radius := SEARCH_STEP * float(ring)
		for i in range(SEARCH_DIRECTIONS):
			var angle := base_angle + TAU * float(i) / float(SEARCH_DIRECTIONS)
			var candidate := clamped_position + Vector2.RIGHT.rotated(angle) * radius
			candidate.x = clamp(candidate.x, arena_rect.position.x, arena_rect.end.x)
			candidate.y = clamp(candidate.y, arena_rect.position.y, arena_rect.end.y)
			if is_walkable(candidate, clearance):
				return candidate

	return clamped_position


func resolve_actor_step(current_position: Vector2, target_position: Vector2, clearance: float) -> Vector2:
	if is_walkable(target_position, clearance):
		return target_position
	var x_only := Vector2(target_position.x, current_position.y)
	if is_walkable(x_only, clearance):
		return x_only
	var y_only := Vector2(current_position.x, target_position.y)
	if is_walkable(y_only, clearance):
		return y_only
	return get_nearest_walkable_position(current_position, clearance)


func rebuild_obstacle_cache() -> void:
	active_obstacle_rects.clear()
	if selected_map_id != MAP2_ID or map2_obstacles == null:
		return
	for collision_shape in find_collision_shapes(map2_obstacles):
		if not collision_shape is CollisionShape2D:
			continue
		var shape := (collision_shape as CollisionShape2D).shape
		if shape is RectangleShape2D:
			var rect_size: Vector2 = (shape as RectangleShape2D).size * collision_shape.global_scale.abs()
			active_obstacle_rects.append(Rect2(collision_shape.global_position - rect_size / 2.0, rect_size))


func find_collision_shapes(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in root.get_children():
		if child is CollisionShape2D:
			result.append(child)
		result.append_array(find_collision_shapes(child))
	return result


func set_collision_enabled_recursive(root: Node, enabled: bool) -> void:
	for child in root.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = not enabled
		set_collision_enabled_recursive(child, enabled)
