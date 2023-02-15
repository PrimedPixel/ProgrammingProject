extends Camera2D

onready var player = get_parent().get_node("Player")
onready var viewpoint_container = get_parent().get_parent().get_parent()
onready var viewport = get_parent().get_parent()
onready var camera = get_parent().get_node("Cam")

var interpolate_val = 2

var game_size = Vector2(320, 180)
onready var window_scale = (OS.window_size / game_size).x
onready var actual_cam_pos = global_position

func _fprocess(delta):
	#Use player's velocity as the lerp value to stop player from going off screen
	#But keep the minimum at 2 (any lower velocity will still allow camera to move)
	var player_vel = player.motion.length() * 0.03
	if player_vel > 2:
		interpolate_val = player_vel
	else:
		interpolate_val = 2
	
#	var target = player.get_global_position()
#
#	var mouse_pos = viewport.get_mouse_position() / window_scale
#
#	var mid_x = (target.x + mouse_pos.x) / 2
#	var mid_y = (target.y + mouse_pos.y) / 2

	var pos = viewport.get_mouse_position() / window_scale - (game_size / 2) + player.global_position

	actual_cam_pos = lerp(actual_cam_pos, pos, interpolate_val * delta)
	
	var subpixel_pos = actual_cam_pos.round() - actual_cam_pos
	
	viewpoint_container.material.set_shader_param("camera_offset", subpixel_pos)
	
	global_position = actual_cam_pos.round()
