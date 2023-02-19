extends Node2D

onready var raycast = get_parent().get_node("ViewportContainer/Viewport/Level/Player/RopeCast")

func _process(_delta):
	position = get_global_mouse_position()
#	raycast.update_pos(position / 6)
