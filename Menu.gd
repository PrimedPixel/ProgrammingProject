extends Control

onready var sound_player = $SoundPlayer

func _ready():
	$Viewport/VerticalContainer/NewGame.grab_focus()


func _on_NewGame_pressed():
	Transition.exit_level_transition()
	yield(Transition, "transition_completed")
	
	get_tree().change_scene("res://DebugRoom.tscn")
	
	Transition.enter_level_transition()

func _on_Continue_pressed():
	pass # Replace with function body.

func _on_Options_pressed():
	pass # Replace with function body.

func _on_Exit_pressed():
	Transition.exit_level_transition()
	yield(Transition, "transition_completed")
	
	get_tree().quit()

func _on_focus_entered():
	sound_player.play()
