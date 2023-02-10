extends Area2D


# Sets up, in the Godot IDE, a space to select the levels
export(String, FILE, "*.tscn") var target_level_path = ""


func _on_NextLevelCollider_body_entered(body):
	if !(body is Player) || target_level_path.empty():
		return
	
	Transition.exit_level_transition()
	yield(Transition, "transition_completed")
	
	get_tree().change_scene(target_level_path)
	
	Transition.enter_level_transition()
