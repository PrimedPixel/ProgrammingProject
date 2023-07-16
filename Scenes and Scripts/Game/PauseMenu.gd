extends Control

@onready var pause_container = $FirstMenu/MenuContainer
@onready var pause_container_resume = $FirstMenu/MenuContainer/Resume

@onready var options_container = $OptionsMenu/OptionsContainer
@onready var options_container_back = $OptionsMenu/OptionsContainer/OptionsBack


func _process(_delta):
	var key_pause = Input.is_action_just_pressed("button_pause")
	
	# Inverts the pause state (i.e., true -> false, and false -> true)
	if key_pause:
		visible = !visible
		get_tree().paused = visible
		pause_container_resume.grab_focus()

# Pause Menu
func _on_Resume_pressed():
	visible = false
	get_tree().paused = false
	

func _on_Options_pressed():
	pause_container.visible = false
	options_container.visible = true
	
	options_container_back.grab_focus()


func _on_Exit_pressed():
	Transition.exit_level_transition()
	
	GlobalVariables.level_to = get_tree().get_current_scene().get_node("SubViewportContainer/SubViewport").get_child(0).get_scene_file_path()
	GlobalVariables.write_savegame()
	
	await Transition.transition_completed
	
#	music.fade_out()
#	yield(fade_out, "tween_completed")
	get_tree().paused = false

	var error = get_tree().change_scene_to_file("res://Scenes and Scripts/Menus/Menu.tscn")
	
	if error != OK:
		printerr("Cannot change scene!")
	
	Transition.enter_level_transition()
