extends Node2D

onready var viewport = $ViewportContainer/Viewport

func _ready():
	if GlobalVariables.level_to is String && GlobalVariables.level_to != "":
		# Changes the default level in the "Game" scene to the new one
		var viewport_child = viewport.get_child(0)
		viewport_child.queue_free()
		
		var new_scene = load(GlobalVariables.level_to)
		
		# Waits until the scene has been deleted (1 frame)
		yield(get_tree(), "idle_frame")
		
		# Creates the new scene
		var new_level = new_scene.instance()
		viewport.add_child(new_level)
