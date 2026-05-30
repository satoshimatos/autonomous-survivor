extends RefCounted
class_name EnemyGeometry


static func get_collision_radius(enemy: Area2D) -> float:
	var collision_shape := enemy.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape and collision_shape.shape is CircleShape2D:
		return (collision_shape.shape as CircleShape2D).radius
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var size := (collision_shape.shape as RectangleShape2D).size
		return max(size.x, size.y) * 0.5
	
	return 0.0
