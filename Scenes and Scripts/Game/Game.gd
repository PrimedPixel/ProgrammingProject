extends Node2D

@onready var viewport = $SubViewportContainer/SubViewport

func _ready():
	if GlobalVariables.level_to is String && GlobalVariables.level_to != "":
		# Changes the default level in the "Game" scene to the new one
		var viewport_child = viewport.get_child(0)
		viewport_child.queue_free()
		
		var new_scene = load(GlobalVariables.level_to)
		
		# Waits until the scene has been deleted (1 frame)
		await get_tree().process_frame
		
		# Creates the new scene
		var new_level = new_scene.instantiate()
		viewport.add_child(new_level)
