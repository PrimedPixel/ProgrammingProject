extends Control

@onready var sound_player = $SoundPlayer
@onready var music = $Music
@onready var fade_out = $Music/FadeOut

@onready var main_menu_container = $FirstMenu
@onready var main_menu_container_new_game = $FirstMenu/NewGame

@onready var options_container = $OptionsMenu/OptionsContainer
@onready var options_container_back = $OptionsMenu/OptionsContainer/OptionsBack

func _ready():
	main_menu_container_new_game.grab_focus()


func _on_NewGame_pressed():
	Transition.exit_level_transition()
	await Transition.transition_completed
	
	music.fade_out()
	await fade_out.tween_completed
	
	GlobalVariables.delete_savegame()
	get_tree().change_scene_to_file("res://Scenes and Scripts/Game/Game.tscn")
	
	Transition.enter_level_transition()

func _on_Continue_pressed():
	Transition.exit_level_transition()
	await Transition.transition_completed
	
	music.fade_out()
	await fade_out.tween_completed
	
	get_tree().change_scene_to_file("res://Scenes and Scripts/Game/Game.tscn")
	
	Transition.enter_level_transition()

func _on_Options_pressed():
	main_menu_container.visible = false
	options_container.visible = true
	
	options_container_back.grab_focus()

func _on_Exit_pressed():
	Transition.exit_level_transition()
	
	GlobalVariables.write_savegame()
	
	await Transition.transition_completed
	
	get_tree().quit()

func _on_focus_entered():
	sound_player.play()
