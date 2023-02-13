extends RayCast2D

onready var rope_able = get_parent().get_parent().get_node("Tiles").get_node("RopeAble")
onready var non_rope_able = get_parent().get_parent().get_node("Tiles").get_node("NonRopeAble")

var game_size = Vector2(320, 180)
onready var window_scale = (OS.window_size / game_size).x
onready var viewport = get_parent().get_parent().get_parent()

var point = Vector2(0, 0)
#var ray_length = 160

# This raycast will occur every frame
# The player will read the "point" variable
# Once the left mouse button has been pressed
func _physics_process(_delta):
	
#	var val = viewport.get_mouse_position() / window_scale
#	print(val)
#	set_cast_to(to_local(val))
	
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
					
