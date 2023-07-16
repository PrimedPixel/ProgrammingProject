extends RayCast2D

@onready var rope_able = get_parent().get_parent().get_node("Tiles/RopeAble")
@onready var non_rope_able = get_parent().get_parent().get_node("Tiles/NonRopeAble")
@onready var non_rope_able_through = get_parent().get_parent().get_node("Tiles/NonRopeAbleThrough")

@onready var cam = get_parent().get_parent().get_node("Cam")

@onready var mouse_cursor = get_tree().get_current_scene().get_node("MouseCursor")

@onready var player = get_parent()

@onready var line_2d = $Line2D

const rope_able_texture = preload("res://Dynamic Assets/Ropeable Cursor.png")
const non_rope_able_texture = preload("res://Dynamic Assets/Non-Ropeable Cursor.png")
const no_block_texture = preload("res://Dynamic Assets/No Tile Cursor.png")

var point = Vector2(0, 0)

var mouse_pos = Vector2.ZERO
var aim_vector = Vector2.ZERO

var gamepad = false

func _ready():
	# Gamepad is connected
	if !Input.get_connected_joypads().is_empty():
		gamepad = true

# This raycast will occur every frame
# The player will read the "point" variable
# Once the left mouse button has been pressed
func _physics_process(_delta):
	point = -1
	
	# Likely gonna want to separate this into a separate function, but oh well
	if gamepad:
		var x_axis = Input.get_action_strength("rstick_right") - Input.get_action_strength("rstick_left")
		var y_axis = Input.get_action_strength("rstick_down") - Input.get_action_strength("rstick_up")
		
		aim_vector = Vector2(x_axis, y_axis).normalized() * player.max_rope_len
		
		set_target_position(aim_vector)
	
	var aimed_point = aim_vector
	
	if is_colliding():
		aimed_point = to_local(get_collision_point())
		
		var tile = get_collider()
		if tile is TileMap:
			# switch statement depending on the tile type
			match tile:
				rope_able:
					point = get_collision_point()
					mouse_cursor.set_texture(rope_able_texture)
					
				non_rope_able, non_rope_able_through:
					mouse_cursor.set_texture(non_rope_able_texture)
		
			if (player.global_position - get_collision_point()).length() > player.max_rope_len:
				mouse_cursor.set_texture(non_rope_able_texture)
	else:
		mouse_cursor.set_texture(no_block_texture)
	
	if gamepad:
		var temp_pos_x = global_position.x - cam.global_position.x + 320 + aimed_point.x
		var temp_pos_y = global_position.y - cam.global_position.y + 180 + aimed_point.y
		
		var pos_to = Vector2(temp_pos_x, temp_pos_y)
		
		mouse_cursor.position = pos_to * 3
		
		line_2d.clear_points()
		line_2d.add_point(position)
		line_2d.add_point(aimed_point)

# Sets the raycast to the mouse_position
# The viewport mode in Godot transforms
# The mouse position twice, so it's necessary
# To use an inverse matrix first
func _unhandled_input(event):
	if !gamepad && (event is InputEventMouseMotion):
		mouse_pos =  get_canvas_transform().affine_inverse() * event.position
		
		set_target_position(to_local(mouse_pos))
