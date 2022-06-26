extends Camera2D

onready var player = get_parent().get_node("Player")

var interpolate_val = 2

func _process(delta):
	#Use player's velocity as the lerp value to stop player from going off screen
	#But keep the minimum at 2 (any lower velocity will still allow camera to move)
	var player_vel = player.motion.length() * 0.03
	if player_vel > 2:
		interpolate_val = player_vel
	else:
		interpolate_val = 2
	
	var target = player.get_global_position()
	var mid_x = (target.x + get_global_mouse_position().x) / 2
	var mid_y = (target.y + get_global_mouse_position().y) / 2

	global_position = lerp(global_position, Vector2(mid_x,mid_y), interpolate_val * delta)
