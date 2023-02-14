extends ViewportContainer

onready var raycast = $Viewport/Level/RopeCast
onready var viewport = $Viewport

func _process(_delta):
#	var local_to_viewport = get_viewport_transform() * get_global_transform()
#	var viewport_to_local = local_to_viewport.affine_inverse()
#
#	var mouse_position_viewport = get_local_mouse_position()
#	var mouse_position_local = viewport_to_local * mouse_position_viewport
#
#	raycast.update_pos(mouse_position_local * 6)
	
#	var global_pos = get_global_mouse_position()
#	var viewport_pos = viewport.global_position
#	var local_pos = global_pos - viewport_pos
#	var raycast_pos = sprite.to_global(local_pos)
#	raycast.update_pos(local_pos)	
	
	
#	var pos  = get_local_mouse_position()
#	raycast.update_pos(pos)

#	var mouse_pos = get_viewport().get_mouse_position()
#	mouse_pos.x = mouse_pos.x / 6
#	mouse_pos.y = mouse_pos.y / 6
	
#	raycast.update_pos(mouse_pos / 6)

#func _input(event):
#	if event.is_action_pressed("mouse_left"):
#		raycast.update_pos(viewport.canvas_transform.affine_inverse().xform(event.position) / 6)
	pass
