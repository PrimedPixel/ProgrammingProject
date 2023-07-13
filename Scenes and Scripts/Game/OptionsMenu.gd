extends Control

@onready var options_container = $OptionsContainer
@onready var options_container_back = $OptionsContainer/OptionsBack

@onready var controls_container = $ControlsContainer
@onready var controls_container_back = $ControlsContainer/ControlsBack

@onready var first_menu = get_parent().get_node("FirstMenu")
@onready var first_menu_node = first_menu.get_child(0)

var changing = false
var changing_key = ""

@onready var up_button = $ControlsContainer/UpContainer/UpButton
@onready var down_button = $ControlsContainer/DownContainer/DownButton
@onready var left_button = $ControlsContainer/LeftContainer/LeftButton
@onready var right_button = $ControlsContainer/RightContainer/RightButton
@onready var jump_button = $ControlsContainer/JumpContainer/JumpButton

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("Sound Effects")

# Options Menu
func _on_OptionsBack_pressed():
	first_menu.visible = true
	options_container.visible = false
	
	first_menu_node.grab_focus()


func _on_Controls_pressed():
	controls_container.visible = true
	options_container.visible = false
	
	controls_container_back.grab_focus()


func _on_Fullscreen_pressed():
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED


func _on_MasterVolS_value_changed(value):
	if master_bus != null:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))


func _on_MusicVolS_value_changed(value):
	if music_bus != null:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_SFXVolS_value_changed(value):
	if sfx_bus != null:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))


# Controls
func _on_ControlsBack_pressed():
	options_container.visible = true
	controls_container.visible = false
	
	options_container_back.grab_focus()
	

func change_key(map_key, new_key):
	# Delete key of pressed button
	if !InputMap.action_get_events(map_key).is_empty():
		InputMap.action_erase_event(map_key, InputMap.action_get_events(map_key)[0])
			
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
			
			await get_tree().idle_frame
			
			up_button.focus_mode = Control.FOCUS_ALL
			down_button.focus_mode = Control.FOCUS_ALL
			left_button.focus_mode = Control.FOCUS_ALL
			right_button.focus_mode = Control.FOCUS_ALL
			jump_button.focus_mode = Control.FOCUS_ALL
			
			match changing_key:
				"button_up":
					up_button.update_text()
					up_button.button_pressed = false
					up_button.grab_focus()
				"button_down":
					down_button.update_text()
					down_button.button_pressed = false
					down_button.grab_focus()
				"button_left":
					left_button.update_text()
					left_button.button_pressed = false
					left_button.grab_focus()
				"button_right":
					right_button.update_text()
					right_button.button_pressed = false
					right_button.grab_focus()
				"button_jump":
					jump_button.update_text()
					jump_button.button_pressed = false
					jump_button.grab_focus()
