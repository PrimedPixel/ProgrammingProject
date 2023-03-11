extends Control

onready var pause_container = $PauseContainer
onready var pause_container_options = $PauseContainer/Options

onready var options_container = $OptionsContainer
onready var options_container_back = $OptionsContainer/Back

onready var controls_container = $ControlsContainer
onready var controls_container_back = $ControlsContainer/Back

var changing = false
var changing_key = ""

onready var up_button = $ControlsContainer/UpContainer/UpButton
onready var down_button = $ControlsContainer/DownContainer/DownButton
onready var left_button = $ControlsContainer/LeftContainer/LeftButton
onready var right_button = $ControlsContainer/RightContainer/RightButton
onready var jump_button = $ControlsContainer/JumpContainer/JumpButton


onready var master_bus = AudioServer.get_bus_index("Master")
onready var music_bus = AudioServer.get_bus_index("Music")
onready var sfx_bus = AudioServer.get_bus_index("Sound Effects")

func _process(_delta):
	var key_pause = Input.is_action_just_pressed("button_pause")
	
	# Inverts the pause state (i.e., true -> false, and false -> true)
	if key_pause:
		visible = !visible
		get_tree().paused = visible
		pause_container_options.grab_focus()

# Pause Menu
func _on_Options_pressed():
	pause_container.visible = false
	options_container.visible = true
	
	options_container_back.grab_focus()


func _on_Exit_pressed():
	Transition.exit_level_transition()
	yield(Transition, "transition_completed")
	
#	music.fade_out()
#	yield(fade_out, "tween_completed")
	get_tree().paused = false
	
	GlobalVariables.write_savegame()
	get_tree().change_scene("res://Scenes and Scripts/Menus/Menu.tscn")
	
	Transition.enter_level_transition()


# Options Menu
func _on_Back_pressed():
	pause_container.visible = true
	options_container.visible = false
	
	pause_container_options.grab_focus()


func _on_Controls_pressed():
	controls_container.visible = true
	options_container.visible = false
	
	controls_container_back.grab_focus()


func _on_MasterVolS_value_changed(value):
	if master_bus != null:
		AudioServer.set_bus_volume_db(master_bus, linear2db(value))


func _on_MusicVolS_value_changed(value):
	if music_bus != null:
		AudioServer.set_bus_volume_db(music_bus, linear2db(value))

func _on_SFXVolS_value_changed(value):
	if sfx_bus != null:
		AudioServer.set_bus_volume_db(sfx_bus, linear2db(value))


# Controls
func change_key(map_key, new_key):
	# Delete key of pressed button
	if !InputMap.get_action_list(map_key).empty():
		InputMap.action_erase_event(map_key, InputMap.get_action_list(map_key)[0])
	
#	if InputMap.action_has_event(i, new_key):
#		InputMap.action_erase_event(i, new_key)
			
	# Add new Key
	InputMap.action_add_event(map_key, new_key)


func _on_UpButton_button_down():
	changing = true
	changing_key = "button_up"
	
	disable_controls_focus()
	
	up_button.set_text("Press Key")
	

func _on_DownButton_button_down():
	changing = true
	changing_key = "button_down"
	
	disable_controls_focus()
	
	down_button.set_text("Press Key")


func _on_LeftButton_button_down():
	changing = true
	changing_key = "button_left"
	
	disable_controls_focus()
	
	left_button.set_text("Press Key")


func _on_RightButton_button_down():
	changing = true
	changing_key = "button_right"
	
	disable_controls_focus()
	
	right_button.set_text("Press Key")


func _on_JumpButton_button_down():
	changing = true
	changing_key = "button_jump"
	
	disable_controls_focus()
	
	jump_button.set_text("Press Key")


func disable_controls_focus():
	up_button.focus_mode = Control.FOCUS_NONE
	down_button.focus_mode = Control.FOCUS_NONE
	left_button.focus_mode = Control.FOCUS_NONE
	right_button.focus_mode = Control.FOCUS_NONE
	jump_button.focus_mode = Control.FOCUS_NONE


func _input(event):
	if event is InputEventKey:
		if InputMap.action_has_event("ui_accept", event):
				return
			
		if changing:
			change_key(changing_key, event)
			changing = false
			
			yield(get_tree(), "idle_frame")
			
			up_button.focus_mode = Control.FOCUS_ALL
			down_button.focus_mode = Control.FOCUS_ALL
			left_button.focus_mode = Control.FOCUS_ALL
			right_button.focus_mode = Control.FOCUS_ALL
			jump_button.focus_mode = Control.FOCUS_ALL
			
			match changing_key:
				"button_up":
					up_button.update_text()
					up_button.pressed = false
					up_button.grab_focus()
				"button_down":
					down_button.update_text()
					down_button.pressed = false
					down_button.grab_focus()
				"button_left":
					left_button.update_text()
					left_button.pressed = false
					left_button.grab_focus()
				"button_right":
					right_button.update_text()
					right_button.pressed = false
					right_button.grab_focus()
				"button_jump":
					jump_button.update_text()
					jump_button.pressed = false
					jump_button.grab_focus()

