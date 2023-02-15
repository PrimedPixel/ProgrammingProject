extends Viewport

onready var raycast = $Level/Player/RopeCast

func _fprocess(_delta):
#	var local_to_viewport = get_viewport_transform() * get_global_transform()
#	var viewport_to_local = local_to_viewport.affine_inverse()
#
#	var mouse_position_viewport = get_local_mouse_position()
#	var mouse_position_local = viewport_to_local * mouse_position_viewport
#
#	raycast.update_pos(mouse_position_local * 6)
	
	
	
	
	var pos  = get_mouse_position()
	raycast.update_pos(pos)
