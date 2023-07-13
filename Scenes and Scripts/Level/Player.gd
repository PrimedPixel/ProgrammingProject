extends CharacterBody2D
class_name Player

# Equivalent to macros in gamemaker
const accel = 512
const max_air_spd = 128
const max_ground_spd = 64
const term_vel = 192
const ground_frict = 0.5
const air_frict = 0.04
const grav = 200
const jump_force = 128

const max_rope_len = 250
const min_rope_len = 20

const max_rope_spd = 250

var key_jump = "button_jump"	# Spacebar is mapped to UI Select (to begin with)
var key_up = "button_up"
var key_down = "button_s"
var key_left = "button_a"
var key_right = "button_d"

var gamepad_id = -1

# Enumerator to store player states (represetns 0, 1, or 2 respectively)
enum state {
	normal,
	swing,
	debug,
}

var player_state = state.normal

var was_on_floor = true

# Variables for the rope that cannot be re-initialised
var cast = -1
var rope_len = 0
var angle_to = 0
var rope_pos = Vector2.ZERO

var rope_angle_vel = 0

var offset = Vector2(9, -9)

# A vector - magnitude and direction (essentially velocity)
var motion = Vector2(0.0, 0.0)

var colliding = false

var global_mouse_pos = Vector2.ZERO

var death_animation = "Die"

# onready makes sure that the nodes have been initialised and loaded into the scene
@onready var sprite = $Sprite2D
@onready var animation = $AnimationPlayer
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer

@onready var rope_cast = get_parent().get_node("Player/RopeCast")
@onready var line = $RopeLine

@onready var level = get_viewport().get_child(0)
@onready var level_bottom = level.bottom

@onready var wind_noise_player = $WindNoisePlayer

# float max_abs(a: float, b: float)
# Returns the value with the highest magnitude from zero
func max_abs(a, b):
	if max(abs(a), abs(b)) == abs(a):
		return a
	else:
		return b

func horizontal_movement(x_input, delta):
	motion.x += x_input * accel * delta
	sprite.flip_h = x_input < 0

func gravity(delta):
	motion.y += grav * delta
	motion.y = clamp(motion.y, -term_vel, term_vel)
	
func normal_animation():
	if floor(abs(motion.x)) == 0:
		animation.play("Idle")
	else:
		animation.play("Run")

func ground_speed_modifiers(x_input):
	# Maximum horizontal speed on ground
	motion.x = clamp(motion.x, -max_ground_spd, max_ground_spd)
	
	# Ground friction - slowly decelerating the player (if no input)
	if x_input == 0:
		motion.x = lerpf(motion.x, 0.0, ground_frict)
		
func air_speed_modifiers():
	# Maximum horizontal speed in air
	motion.x = clamp(motion.x, -max_air_spd, max_air_spd)
	
	# Air friction - slowly decelerating the player
	motion.x = lerp(motion.x, 0.0, air_frict)

func rope_angle_changes(x_input):
	# Pendulum
	if !colliding:
		var rope_angle_accel = 0.03 * cos((rope_pos - (position + offset)).angle())
		rope_angle_vel += rope_angle_accel
		rope_angle_vel *= 0.5
	
#	# Limits the velocity of swinging on the rope
#	if colliding:
#		rope_angle_vel = clamp(rope_angle_vel, -0.5, 0.5)
#	else:
#		rope_angle_vel = clamp(rope_angle_vel, -1.5, 1.5)

		angle_to += rope_angle_vel
	else:
		angle_to -= rope_angle_vel
		rope_angle_vel = 0
	
#	angle_to = angle_to + (x_input * 0.04)
	
	if !colliding:
		# Changes the angle of the rope based on left / right
		angle_to += x_input * 0.04
	else:
		# Inverse the change of angle while colliding
		angle_to -= x_input * 0.2

func reset_rope():
	line.clear_points()
	animation.speed_scale = 1.0 	# Reset animation speed
	player_state = state.normal

func rope_animation(x_input):
	# Change speed of players animation depending on speed of movement in x axis
#		if abs(motion.x) > 1.5:			# Minimum animation speed
#			animation.playback_speed = abs(motion.x) * 0.005
		
		# Updates the rope's offset if the player's sprite has flipped
		# This makes it line up with the player's hand
		if x_input != 0 && !colliding:
			sprite.flip_h = x_input < 0
		
		if !sprite.flip_h:
			offset = Vector2(-9, -9)
		else:
			offset = Vector2(9, -9)
		
		# Adds rope points to the line
		# This has to be after the move_and_slide so the position has been updated
		line.clear_points()
		line.add_point(offset)
		line.add_point(to_local(rope_pos))

func initialise_rope():
		# Initialise rope swing
		cast = rope_cast.point
		
		if typeof(cast) == TYPE_VECTOR2:
			# Take properties of rope len
			rope_pos = cast
			rope_len = (position - rope_pos).length()
			
			if rope_len < max_rope_len:
				angle_to = deg_to_rad(90) - (position - rope_pos).angle()
				
				SoundPlayer.play_sound(SoundPlayer.Grapple)
				player_state = state.swing
				Input.start_joy_vibration(gamepad_id, 1, 1, 0.25)

func die():
	if animation.get_current_animation() != death_animation:
		animation.play(death_animation)
		
#		SoundPlayer.stop_sound(SoundPlayer.Wind)
		SoundPlayer.play_sound(SoundPlayer.Damage)
		Input.start_joy_vibration(gamepad_id, 1, 1, 0.5)
		
		Transition.exit_level_transition()
		await Transition.transition_completed
		
		level = get_viewport().get_child(0)
		
		if level.get_scene_file_path() == "res://Levels/Level4.tscn":
			level.get_node("Fire").fire_distance = 0
			level.get_node("Fire").fire_speed = 0.3
			
			level.get_node("Music").seek(0)
		
		animation.play("Idle")
		death_animation = "Die"
		position = GlobalVariables.checkpoint_pos
		GlobalVariables.death_count += 1
		
		reset_rope()
		
		Transition.enter_level_transition()

func wind_noise():
	var spd = motion.length() - max_ground_spd
	var max_spd = max_rope_spd - max_ground_spd
	
	# The rope code multiplies the motion by 5, so it can, indeed, be larger than max_spd
	if spd > max_spd:
		spd = max_spd
	
	# Negative numbers hurt it :(
	if spd < 0:
		spd = 0
	
	var vol = spd / max_spd
	
	# Just in case, as well
	if vol > 1:
		vol = 1
		printerr("Error: wind noise volume is too fat and large, unlike my cock")
	
	wind_noise_player.set_volume_db(linear_to_db(vol))

func _ready():
	var arr = Input.get_connected_joypads()
	if !arr.is_empty():
		gamepad_id = arr[0]	# should be device 0, but not necessarily
	
	if GlobalVariables.checkpoint_pos != Vector2.ZERO:
		global_position = GlobalVariables.checkpoint_pos
	
	# This should be done already, perhaps unnecessary?
	wind_noise_player.play()
	wind_noise_player.set_volume_db(linear_to_db(0))

# Built in function from KinematicBody2D
# _physics_process causes jitter issues on !=60Hz monitors
# _process seems to eliminate this issue without any caveats?
# although this should be looked into
func _process(delta):
	
	if Transition.rect_animation.is_playing():
		return
	
	var input_keyboard_up = Input.get_action_strength("button_up")
	var input_keyboard_down = Input.get_action_strength("button_down")
	var input_keyboard_left = Input.get_action_strength("button_left")
	var input_keyboard_right = Input.get_action_strength("button_right")
	var input_keyboard_jump = Input.get_action_strength("button_jump")
	
	var input_controller_up = max(Input.get_action_strength("dpad_up"), Input.get_action_strength("lstick_up"))
	var input_controller_down = max(Input.get_action_strength("dpad_down"), Input.get_action_strength("lstick_down"))
	var input_controller_left = max(Input.get_action_strength("dpad_left"), Input.get_action_strength("lstick_left"))
	var input_controller_right = max(Input.get_action_strength("dpad_right"), Input.get_action_strength("lstick_right"))
	var input_controller_jump = Input.get_action_strength("gamepad_jump")
	var input_controller_fire = Input.is_action_just_pressed("gamepad_fire")
	
	var input_up = max(input_keyboard_up, input_controller_up)
	var input_down = max(input_keyboard_down, input_controller_down)
	var input_left = max(input_keyboard_left, input_controller_left)
	var input_right = max(input_keyboard_right, input_controller_right)
	var input_jump = max(input_keyboard_jump, input_controller_jump)
	
	var input_mouse = Input.is_action_just_pressed("mouse_left")
	var input_mouse_right = Input.is_action_just_pressed("mouse_right")
	
	var input_fire = max(float(input_mouse), float(input_controller_fire))
	
	# Mouse wheel events only have a "just_released" event, for some reason
	var input_mouse_up = Input.is_action_just_released("mouse_up")
	var input_mouse_down = Input.is_action_just_released("mouse_down")
	
	var x_input = input_right - input_left
	var y_input = input_down - input_up
	var trig_input = Input.get_action_strength("gamepad_r_trig") - Input.get_action_strength("gamepad_l_trig")
	
	colliding = get_slide_collision_count() != 0
	
	match player_state:
		state.normal:
			
			if x_input != 0:
				horizontal_movement(x_input, delta)
			
			# Add gravity to the player & stops the player from infinitely accel
			gravity(delta)
			
			# Animate any ground animations now that the motion has been calculated
			normal_animation()
				
			# True if the player is on the floor, or was in the last 0.15 seconds
			var coyote_on_floor = is_on_floor() || !coyote_timer.is_stopped()
			
			if input_jump:
				jump_buffer_timer.start()
			
			# Runs if the player is on the floor, or coyote in the air
			if coyote_on_floor:
				# Runs if the player has just landed
				if !was_on_floor:
					was_on_floor = true
					
					SoundPlayer.play_sound(SoundPlayer.Land)
					
					Input.start_joy_vibration(gamepad_id, 1, 1, 0.25)
				
				ground_speed_modifiers(x_input)
				
				# Allows the player to jump if the jump buffer timer has not stopped
				if !jump_buffer_timer.is_stopped():
					SoundPlayer.play_sound(SoundPlayer.Jump)
					motion.y = -jump_force
					jump_buffer_timer.stop()
					coyote_timer.stop()
			
			if !is_on_floor():
				air_speed_modifiers()
				
				was_on_floor = false
				
				# Variable jump height
				# Checks that jump button isn't pressed and moving up quickly											
				if Input.is_action_just_released(key_jump) and motion.y < (-jump_force * 0.5):
					# Halves the jump force, making the player land quickly
					motion.y = -jump_force * 0.5
				
				# Sets the player's animation to jump / in air
				animation.play("Jump")
			
			if position.y > level_bottom + 32:
				die()
			
		state.swing:
			animation.play("Swing")
			
			rope_angle_changes(x_input)
			
			var alt_input = max_abs((int(input_mouse_down) - int(input_mouse_up)) * 4, trig_input * 2)
			
			var len_change = max_abs(y_input * 2, alt_input)
			
			if !colliding:
				# Changes the length of the rope based on up / down
				rope_len = clamp(rope_len + len_change, min_rope_len, max_rope_len)
			else:
				rope_len = clamp(rope_len - abs(len_change), min_rope_len, max_rope_len)
						
			# Calculates new rope position
			var position_to = Vector2(
				sin(angle_to),
				cos(angle_to)
			) * rope_len + rope_pos
			
			# Calculates the movement from the current position to the new one
			motion = position_to - position
			
			if motion.length() > max_rope_spd:
				print("normalised length")
				motion = motion.normalized() * max_rope_spd
			
			# Will move quicker to the target position if not colliding
			# (since KinematicBody2D slowly approaches, like a bungee chord)
			if !colliding:
				motion *= 5
			
			# Resets player state out of rope state
			if input_jump || input_mouse_right || Input.is_action_just_pressed("gamepad_release") || is_on_floor():
				reset_rope()
		state.debug:
			motion.x = x_input * 500
			motion.y = y_input * 500
			
			if input_mouse:
				global_position = global_mouse_pos
			
	# Checks to see if the player is on the floor before the move_and_slide
	# function updates the player's position
	var floor_before_move = is_on_floor()
	
	set_velocity(motion)
	set_up_direction(Vector2.UP)
	move_and_slide()
	motion = velocity	# Moves the player node by the vector + automatically collides
												# Also returns left over motion, meaning if collided
												# It will return no movement, and stop for the next frame
	
	# If the player's new position is not on the floor, but it was the previous frame
	if floor_before_move && !is_on_floor():
#		var channel = SoundPlayer.play_sound(SoundPlayer.Wind)
#		SoundPlayer.set_channel_vol(channel, -100)
		coyote_timer.start()
	
	# Rope animation
	if player_state == state.swing:
		rope_animation(x_input)
	
	# Wind noise
	wind_noise()
	
	if input_fire && !is_on_floor():
		initialise_rope()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_1:
					player_state = state.normal
				KEY_2:
					player_state = state.swing
				KEY_3:
					player_state = state.debug

	if event is InputEventMouseMotion:
			global_mouse_pos =  get_canvas_transform().affine_inverse() * event.position
