extends KinematicBody2D

#Equivalent to macros, I suppose
const accel = 512
const max_spd = 64
const ground_frict = 0.35
const air_frict = 0.02
const grav = 200
const jump_force = 128

var key_jump = "button_w"	#Spacebar is mapped to UI Select (to begin with)
var key_up = "button_w"
var key_down = "button_s"
var key_left = "button_a"
var key_right = "button_d"

#Gross
enum state {
	normal,
	swing
}

var player_state = state.normal

var local_cast = Vector2(0, 0)
var rope_pos = Vector2.ZERO
var new_cast = Vector2.ZERO
var cast = -1
var rope_angle_vel = 0
var rope_angle = 0
var rope_len = 0

#A vector - magnitude and direction (essentially velocity)
var motion = Vector2.ZERO

#onready makes sure that the nodes have been initialised and loaded into the scene
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var rope_cast = $RopeCast

#Built in function from KinematicBody2D
func _physics_process(delta):
	var input_jump = Input.is_action_just_pressed(key_jump)
	var input_up = Input.get_action_strength(key_up)
	var input_down = Input.get_action_strength(key_down)
	var input_left = Input.get_action_strength(key_left)
	var input_right = Input.get_action_strength(key_right)
	
	match player_state:
		state.normal:
			var x_input = input_right - input_left
			var y_input = input_up - input_down
			
			if x_input != 0:
				motion.x += x_input * accel * delta		#Multiply by delta since occuring every frame
				motion.x = clamp(motion.x, -max_spd, max_spd)
				
				sprite.flip_h = x_input < 0
				
			
			motion.y += grav * delta	#Multiply by delta since occuring every frame
			
			if floor(abs(motion.x)) == 0:
				animation.play("Idle")
			else:
				animation.play("Run")
			
			if is_on_floor():
				if input_jump:
					motion.y = -jump_force
				
				if x_input == 0:
					motion.x = lerp(motion.x, 0, ground_frict)
			else:												#checks that we're moving up quickly
				if Input.is_action_just_released("ui_select") and motion.y < -jump_force / 2:#variable jump height
					motion.y = -jump_force / 2
				
				if x_input == 0:
					motion.x = lerp(motion.x, 0, air_frict)
					
				animation.play("Jump")
		state.swing:
			var local_cast_prev = local_cast
			local_cast = -local_cast
			print(local_cast)
			local_cast = local_cast.rotated(deg2rad(10))
			print(local_cast)
			motion = local_cast + local_cast_prev
#			print(local_cast_prev)
#			print(local_cast)
#			print("###")
			
			local_cast = -local_cast
#			print(rope_angle)
#			var rope_angle_accel = -0.2 * cos(rope_angle)
#			rope_angle_vel += rope_angle_accel
#			rope_angle += rope_angle_vel
#			rope_angle *= 0.99
#			print(rad2deg(rope_angle))
#
#			print("START###########")
#			print(grapple_pos)
#			print(rope_len)
#			print(rope_angle)
#			rope_pos = Vector2(rope_len, 0).rotated(rope_angle)
#			new_cast = Vector2(rope_len, 0).rotated(rope_angle)
#			print(rope_pos, Vector2(rope_len, 0).rotated(rope_angle))
#			motion.x = rope_pos[0] - position[0]
#			motion.y = rope_pos[1] - position[1]
#			print(new_cast)
#			motion = local_cast - new_cast
#			print(motion)
		
	
	motion = move_and_slide(motion, Vector2.UP)	#Moves the player node by the vector + automatically collides
												#Also returns left over motion, meaning if collided
												#It will return no movement, and stop for the next frame

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_R:
					get_tree().reload_current_scene()
				KEY_F11:
					OS.window_fullscreen = !OS.window_fullscreen
				KEY_ESCAPE:
					get_tree().quit()
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			#Initialise rope swing
			cast = rope_cast.cast_to_coordinate(get_global_mouse_position())
			if typeof(cast) == TYPE_VECTOR2:
				local_cast = to_local(cast)
				
#				print(local_cast)
#				rope_angle_vel = 0
				rope_angle = local_cast.angle()
#				print(rad2deg(local_cast.angle()))
				rope_len = local_cast.length()
				player_state = state.swing

func _draw():
	draw_line(Vector2(0, 0), local_cast, Color(1,0,0,1))
