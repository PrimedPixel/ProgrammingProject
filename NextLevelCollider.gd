extends Area2D


# Sets up, in the Godot IDE, a space to select the levels
#export(PackedScene, FILE, "*.tscn") var target_level_path
export(PackedScene) var target_level_path

func _on_NextLevelCollider_body_entered(body):
	if !(body is Player): #|| target_level_path.empty():
		return
	
	Transition.exit_level_transition()
	yield(Transition, "transition_completed")
	
	var viewport = get_viewport()
	var viewport_child = viewport.get_child(viewport.get_child_count() - 1)
	viewport_child.queue_free()
	
	var new_scene = target_level_path.instance()
	viewport.add_child(new_scene)
	
	Transition.enter_level_transition()
