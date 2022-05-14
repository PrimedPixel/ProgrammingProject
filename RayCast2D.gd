extends RayCast2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	pass

onready var line = get_parent().get_parent().get_node("RopeLine")
var point = Vector2(0, 0)

func cast_to_coordinate(coordinate):
	var the_position = to_local(coordinate)
	#print(position[0], position[1])
	
	set_cast_to(the_position)
	set_enabled(true)
	#print(get_collider(), get_collision_point())
	
	if is_colliding():
		if get_collider() is TileMap:
			point = get_collision_point()
			
			line.clear_points()
			line.add_point(to_global(position))
			line.add_point(point)
			
			return point
	else:
		return -1
	
	
	set_enabled(false)
