extends RayCast2D

onready var rope_able = get_parent().get_node("Tiles").get_node("RopeAble")
onready var non_rope_able = get_parent().get_node("Tiles").get_node("NonRopeAble")
onready var sprite = $Sprite

onready var camera = get_parent().get_node("Cam")

var game_size = Vector2(320, 180)
var start_pos = Vector2(160, 128)
onready var window_scale = (OS.window_size / game_size).x
onready var viewport = get_viewport()

var point = Vector2(0, 0)
#var ray_length = 160

func _ready():
	var start_pos = global_position * 6
	start_pos = Vector2(160, 128)
	print(start_pos)

# This raycast will occur every frame
# The player will read the "point" variable
# Once the left mouse button has been pressed
func _physics_process(_delta):
	
#	var val = viewport.get_mouse_position()
#	print(val)
#	set_cast_to(to_local(val))
#	set_cast_to(to_local(Vector2(20, 44)))
	
#	var view_container = viewport.get_parent()
#	var mouse_position = view_container.get_local_mouse_position()
#
#	var screen_pos = viewport.get_mouse_position()
#	var ray_origin = camera.global_transform[2].normalized() * camera.global_transform[2].length()
#	var ray_target = camera.get_global_transform().affine_inverse().xform(to_global(screen_pos))
#	var ray_direction = (ray_target - ray_origin).normalized()
#	ray_target = ray_origin + ray_direction * 1000
#	var local_pos = to_local(ray_target) - sprite.global_transform.origin
#	sprite.global_position = to_global(ray_target)
#	set_cast_to(to_local(local_pos))
	
#	var pos_val = (get_global_mouse_position() - start_pos) / 6
#	print("Raycast: " + str(get_global_mouse_position()))
#	sprite.global_position = pos_val
##
#	set_cast_to(to_local(pos_val))
	
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
	sprite.global_position = pos
#
	set_cast_to(to_local(pos))
	pass
