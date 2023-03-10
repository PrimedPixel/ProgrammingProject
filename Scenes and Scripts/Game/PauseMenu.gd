extends Control


func _process(_delta):
	var key_pause = Input.is_action_just_pressed("button_pause")
	
	# Inverts the pause state (i.e., true -> false, and false -> true)
	if key_pause:
		visible = !visible
		get_tree().paused = visible
		$VerticalContainer/Options.grab_focus()


func _on_Options_pressed():
	pass # Replace with function body.


func _on_Exit_pressed():
	Transition.exit_level_transition()
	yield(Transition, "transition_completed")
	
#	music.fade_out()
#	yield(fade_out, "tween_completed")
	get_tree().paused = false
	
	GlobalVariables.write_savegame()
	get_tree().change_scene("res://Scenes and Scripts/Menus/Menu.tscn")
	
	Transition.enter_level_transition()
