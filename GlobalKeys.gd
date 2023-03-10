extends Node

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_R:
					get_tree().reload_current_scene()
				KEY_T:
					Transition.exit_level_transition()
				KEY_Y:
					Transition.enter_level_transition()
				KEY_F:
					GlobalVariables.write_savegame()
					print("Saved game!")
				KEY_F11:
					OS.window_fullscreen = !OS.window_fullscreen
				KEY_ESCAPE:
					get_tree().quit()
