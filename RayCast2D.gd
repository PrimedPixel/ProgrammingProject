extends RayCast2D

onready var rope_able = get_parent().get_parent().get_node("RopeAble")
onready var non_rope_able = get_parent().get_parent().get_node("NonRopeAble")

var point = Vector2(0, 0)
#var ray_length = 160

# This raycast will occur every frame
# The player will read the "point" variable
# Once the left mouse button has been pressed
func _physics_process(_delta):
	set_cast_to(get_local_mouse_position())
	
	point = -1
	
	if is_colliding():
		var tile = get_collider()
		if tile is TileMap:
			# switch statement depending on the tile type
			match tile:
				rope_able:
					point = get_collision_point()
					
				non_rope_able:
					pass;
					
