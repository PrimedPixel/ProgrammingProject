extends RayCast2D

var point = Vector2(0, 0)

func cast_to_coordinate(coordinate):
	var the_position = to_local(coordinate)
	
	set_cast_to(the_position)
	set_enabled(true)
	
	if is_colliding():
		if get_collider() is TileMap:
			point = get_collision_point()
			
			return point
	else:
		return -1
