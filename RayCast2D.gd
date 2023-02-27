extends RayCast2D

onready var rope_able = get_parent().get_parent().get_node("Tiles/RopeAble")
onready var non_rope_able = get_parent().get_parent().get_node("Tiles/NonRopeAble")

onready var mouse_cursor = get_tree().get_current_scene().get_node("MouseCursor")

const rope_able_texture = preload("res://Cross.png")
const non_rope_able_texture = preload("res://cross 2.png")
const no_block_texture = preload("res://circle cross.png")

var point = Vector2(0, 0)

var mouse_pos = Vector2.ZERO

# This raycast will occur every frame
# The player will read the "point" variable
# Once the left mouse button has been pressed
func _physics_process(_delta):
	point = -1
	
	if is_colliding():
		var tile = get_collider()
		if tile is TileMap:
			# switch statement depending on the tile type
			match tile:
				rope_able:
					point = get_collision_point()
					mouse_cursor.set_texture(rope_able_texture)
					
				non_rope_able:
					mouse_cursor.set_texture(non_rope_able_texture)
	else:
		mouse_cursor.set_texture(no_block_texture)

# Sets the raycast to the mouse_position
# The viewport mode in Godot transforms
# The mouse position twice, so it's necessary
# To use an inverse matrix first
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_pos =  get_canvas_transform().affine_inverse() * event.position
		
		set_cast_to(to_local(mouse_pos))
