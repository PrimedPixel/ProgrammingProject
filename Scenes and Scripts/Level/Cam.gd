extends Camera2D

@onready var player = get_parent().get_node("Player")
@onready var viewpoint_container = get_parent().get_parent().get_parent()
@onready var viewport = get_parent().get_parent()
@onready var level_bottom = viewport.get_child(0).bottom
@onready var mouse_cursor = get_tree().get_current_scene().get_node("MouseCursor")

#var mouse_pos = Vector2.ZERO

const min_interpolate_val = 2.0
var interpolate_val = min_interpolate_val

var game_size = Vector2(640.0, 360.0)
@onready var window_scale = (Vector2(get_window().size) / game_size).x
@onready var actual_cam_pos = global_position

func _process(delta):
	#Use player's velocity as the lerp value to stop player from going off screen
	#But keep the minimum at 2 (any lower velocity will still allow camera to move)
	var player_vel = player.motion.length() * 0.03
		
	interpolate_val = max(min_interpolate_val, player_vel)
	
	# Global position is a Vector2 (float), not Vector2i
	var mouse_pos = Vector2(mouse_cursor.global_position)
	var player_pos = Vector2(player.global_position)
	var pos = Vector2((mouse_pos / window_scale) - (game_size / 2) + player_pos)
	
	# It was fucking vsync - now i need to see if I can detatch this code and make it run every frame FOR vsync
	
	actual_cam_pos = actual_cam_pos.lerp(pos, interpolate_val * delta)
	
	actual_cam_pos.x = max(actual_cam_pos.x, (game_size / 2).x)
	actual_cam_pos.y = clamp(actual_cam_pos.y, (game_size / 2).y, level_bottom - (game_size / 2).y)
	
	var subpixel_pos = actual_cam_pos.round() - actual_cam_pos
	
	subpixel_pos = Vector2((subpixel_pos.x), (subpixel_pos.y))
	
	viewpoint_container.material.set_shader_parameter("camera_offset", subpixel_pos)
	
	global_position = actual_cam_pos.round()
