extends Node

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_R:
					var error = get_tree().reload_current_scene()
					
					if error != OK:
						printerr("Cannot reload scene!")
				KEY_T:
					Transition.exit_level_transition()
				KEY_Y:
					Transition.enter_level_transition()
				KEY_F:
					GlobalVariables.write_savegame()
					print("Saved game!")
				KEY_F11:
					get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
