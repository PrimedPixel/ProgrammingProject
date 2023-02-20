extends Node2D

onready var viewport = $ViewportContainer/Viewport

func _ready():
	if GlobalVariables.level_to != null:
		# Changes the default level in the "Game" scene to the new one
		var viewport_child = viewport.get_child(viewport.get_child_count() - 1)
		viewport_child.queue_free()
		
		# Waits until the scene has been deleted (1 frame)
		yield(get_tree(), "idle_frame")
		
		# Creates the new scene
		var new_scene = GlobalVariables.level_to.instance()
		viewport.add_child(new_scene)
