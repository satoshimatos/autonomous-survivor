extends SceneTree


func _init() -> void:
	var scene_paths: Array[String] = [
		"res://scenes/core/main.tscn",
		"res://scenes/player/player.tscn",
		"res://scenes/enemies/enemy.tscn",
		"res://scenes/enemies/brown_enemy.tscn",
		"res://scenes/enemies/shielded_enemy.tscn",
		"res://scenes/enemies/boss_enemy.tscn",
		"res://scenes/abilities/shock_field.tscn",
		"res://scenes/abilities/artillery_beacon.tscn",
	]
	
	for scene_path in scene_paths:
		var packed_scene := load(scene_path) as PackedScene
		if packed_scene == null:
			push_error("Could not load scene: %s" % scene_path)
			quit(1)
			return
		
		var instance := packed_scene.instantiate()
		if instance == null:
			push_error("Could not instantiate scene: %s" % scene_path)
			quit(1)
			return
		
		instance.queue_free()
	
	print("Scene check passed.")
	quit()
