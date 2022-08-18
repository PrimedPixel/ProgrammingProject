extends RayCast2D

var point = Vector2(0, 0)
#var ray_length = 160

# This raycast will occur every frame
# The player will read the "point" variable
# Once the left mouse button has been pressed
func _physics_process(_delta):
	set_cast_to(get_local_mouse_position())
	
	point = -1
	
	if is_colliding():
		if get_collider() is TileMap:
			point = get_collision_point()
