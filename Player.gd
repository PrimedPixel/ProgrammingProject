extends KinematicBody2D

#Equivalent to macros, I suppose
const accel = 512
const max_spd = 64
const term_vel = 192
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

#Variables for the rope that cannot be re-initialised
var cast = -1
var rope_len = 0
var angle_to = 0
var rope_pos = Vector2.ZERO

#A vector - magnitude and direction (essentially velocity)
var motion = Vector2.ZERO

#onready makes sure that the nodes have been initialised and loaded into the scene
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var rope_cast = $RopeCast
onready var line = get_parent().get_node("RopeLine")

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
			motion.y = clamp(motion.y, -term_vel, term_vel)
			
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
			
			#Changes the length of the rope based on up / down
			rope_len = clamp(rope_len + ((input_down - input_up) * 5), 50, 500)
			
			#If not colliding with something
			if get_slide_count() == 0:
				#Changes the angle of the rope based on left / right
				angle_to = angle_to + ((input_right - input_left) * 0.05)
			else:
				#Inverse the change of angle while colliding
				angle_to = angle_to - ((input_right - input_left) * 0.07)
			
			#Calculates new rope position
			var position_to = Vector2(
				sin(angle_to),
				cos(angle_to)
			) * rope_len + rope_pos
			
			#Adds rope points to the line
			line.clear_points()
			line.add_point(position)
			line.add_point(rope_pos)
			
			#Calculates the movement from the current position to the new one
			motion = position_to - position
			
			#Resets player state out of rope state
			if Input.is_action_just_released("ui_select"):
#					motion.x *= 10
					motion.y *= 0.75
					line.clear_points()
					player_state = state.normal
	
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
	
	#If mouse button pressed
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			
			#Initialise rope swing
			cast = rope_cast.cast_to_coordinate(get_global_mouse_position())
			if typeof(cast) == TYPE_VECTOR2:
				rope_pos = cast
				#Take properties of rope len
				rope_len = to_local(cast).length()
				angle_to = cast.angle()
				player_state = state.swing
