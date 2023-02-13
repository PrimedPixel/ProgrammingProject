extends RayCast2D

onready var rope_able = get_parent().get_parent().get_node("Tiles").get_node("RopeAble")
onready var non_rope_able = get_parent().get_parent().get_node("Tiles").get_node("NonRopeAble")
onready var sprite = $Sprite

var game_size = Vector2(320, 180)
var start_pos = Vector2.ZERO
onready var window_scale = (OS.window_size / game_size).x
onready var viewport = get_viewport()

var point = Vector2(0, 0)
#var ray_length = 160

func _ready():
	var start_pos = global_position
	print(start_pos)

# This raycast will occur every frame
# The player will read the "point" variable
# Once the left mouse button has been pressed
func _physics_process(_delta):
	
#	var val = viewport.get_mouse_position()
#	print(val)
#	set_cast_to(to_local(val))
#	set_cast_to(to_local(Vector2(20, 44)))
	
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
					
func update_pos(pos):
	sprite.global_position = pos - (start_pos * 10000)
	
	set_cast_to(sprite.position)
