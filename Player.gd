extends KinematicBody2D

#Equivalent to macros, I suppose
const accel = 512
const max_air_spd = 128
const max_ground_spd = 64
const term_vel = 192
const ground_frict = 0.5
const air_frict = 0.04
const grav = 200
const jump_force = 128

const max_rope_len = 250
const min_rope_len = 50

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

var rope_angle_vel = 0

var offset = Vector2(3, -7)

#A vector - magnitude and direction (essentially velocity)
var motion = Vector2.ZERO

#onready makes sure that the nodes have been initialised and loaded into the scene
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var rope_cast = $RopeCast
onready var line = get_parent().get_node("RopeLine")

#Built in function from KinematicBody2D
#_physics_process causes jitter issues on !=60Hz monitors
#_process seems to eliminate this issue without any caveats
func _process(delta):
	var input_jump = Input.is_action_just_pressed(key_jump)
	var input_up = Input.get_action_strength(key_up)
	var input_down = Input.get_action_strength(key_down)
	var input_left = Input.get_action_strength(key_left)
	var input_right = Input.get_action_strength(key_right)
	
	match player_state:
		state.normal:
			var x_input = input_right - input_left
			
			if x_input != 0:
				motion.x += x_input * accel * delta		#Multiply by delta since occuring every frame
				
				sprite.flip_h = x_input < 0
				
			
			motion.y += grav * delta	#Multiply by delta since occuring every frame
			motion.y = clamp(motion.y, -term_vel, term_vel)
			
			if floor(abs(motion.x)) == 0:
				animation.play("Idle")
			else:
				animation.play("Run")
			
			if is_on_floor():
				motion.x = clamp(motion.x, -max_ground_spd, max_ground_spd)
				
				if input_jump:
					motion.y = -jump_force
				
				if x_input == 0:
					motion.x = lerp(motion.x, 0, ground_frict)
			else:												#checks that we're moving up quickly
				motion.x = clamp(motion.x, -max_air_spd, max_air_spd)
				
				if Input.is_action_just_released("ui_select") and motion.y < -jump_force / 2:#variable jump height
					motion.y = -jump_force / 2
				
#				if x_input == 0:
				motion.x = lerp(motion.x, 0, air_frict)
					
				animation.play("Jump")
		state.swing:
			animation.play("Swing")
			
			#Changes the length of the rope based on up / down
			rope_len = clamp(rope_len + ((input_down - input_up) * 2), min_rope_len, max_rope_len)
			
			var rope_angle_accel = 0.03 * cos((rope_pos - position).angle())
			rope_angle_vel += rope_angle_accel
			rope_angle_vel *= 0.5

			angle_to += rope_angle_vel
			
			#If not colliding with something
			if get_slide_count() == 0:
				#Changes the angle of the rope based on left / right
				angle_to = angle_to + ((input_right - input_left) * 0.04)
			else:
				#Inverse the change of angle while colliding
				angle_to = angle_to - ((input_right - input_left) * 0.07)
			
			#Calculates new rope position
			var position_to = Vector2(
				sin(angle_to),
				cos(angle_to)
			) * rope_len + rope_pos
			
			#Calculates the movement from the current position to the new one
			motion = position_to - position
#			position = position_to
			
			#Change speed of players animation depending on speed of movement in x axis
			if abs(motion.x) > 1.5:			#Minimum animation speed
				animation.playback_speed = abs(motion.x) * 0.03
			
			#Will move quicker to the target position if not colliding
			if get_slide_count() == 0:
				motion *= 5
			
			#Resets player state out of rope state
			if Input.is_action_just_released("ui_select"):
#					motion *= 2	3				#Increase motion to make swing feel more significant
					line.clear_points()
					animation.playback_speed = 1 	#Reset animation speed
					player_state = state.normal
#
#			line.clear_points()
#			line.add_point(position_to + offset)
#			line.add_point(rope_pos)
	
	motion = move_and_slide(motion, Vector2.UP)	#Moves the player node by the vector + automatically collides
												#Also returns left over motion, meaning if collided
												#It will return no movement, and stop for the next frame
	
	#Rope animation	
	if player_state == state.swing:
		#Adds rope points to the line
		#This has to be after the move_and_slide so the position has been updated
		var x_input = (input_right - input_left)
		
		if x_input != 0:
			sprite.flip_h = x_input < 0
			
			if x_input > 0:
				offset = Vector2(3, -7)
			else:
				offset = Vector2(-3, -7)
		
		line.clear_points()
		line.add_point(position + offset)
		line.add_point(rope_pos)
	
func _on_spike_body_entered(body):
	pass

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
#				if to_local(cast).length() <= max_rope_len:
				#Take properties of rope len
				rope_pos = cast
				rope_len = (position - rope_pos).length()
				
				angle_to = deg2rad(90) - (position - rope_pos).angle()
				
#					motion = Vector2.ZERO		#Dunno if this is needed
				player_state = state.swing

func die():
	print("die!")
