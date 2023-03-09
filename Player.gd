extends KinematicBody2D
class_name Player

# Equivalent to macros, I suppose
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

var key_jump = "button_w"	# Spacebar is mapped to UI Select (to begin with)
var key_up = "button_w"
var key_down = "button_s"
var key_left = "button_a"
var key_right = "button_d"

# Gross
enum state {
	normal,
	swing
}

var player_state = state.normal

# Variables for the rope that cannot be re-initialised
var cast = -1
var rope_len = 0
var angle_to = 0
var rope_pos = Vector2.ZERO

var rope_angle_vel = 0

var offset = Vector2(9, -9)

# A vector - magnitude and direction (essentially velocity)
var motion = Vector2.ZERO

# onready makes sure that the nodes have been initialised and loaded into the scene
onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var coyote_timer = $CoyoteTimer
onready var jump_buffer_timer = $JumpBufferTimer

onready var rope_cast = get_parent().get_node("Player/RopeCast")
onready var line = $RopeLine

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
		motion.x = lerp(motion.x, 0, ground_frict)
		
func air_speed_modifiers():
	# Maximum horizontal speed in air
	motion.x = clamp(motion.x, -max_air_spd, max_air_spd)
	
	# Air friction - slowly decelerating the player
	motion.x = lerp(motion.x, 0, air_frict)

func rope_angle_changes(colliding, x_input):
	# Pendulum
	var rope_angle_accel = 0.03 * cos((rope_pos - (position + offset)).angle())
	rope_angle_vel += rope_angle_accel
	rope_angle_vel *= 0.5
	
	# Limits the velocity of swinging on the rope
	if colliding:
		rope_angle_vel = clamp(rope_angle_vel, -0.5, 0.5)
	else:
		rope_angle_vel = clamp(rope_angle_vel, -1.5, 1.5)

	angle_to += rope_angle_vel
	
	angle_to = angle_to + (x_input * 0.04)
	
#	if !colliding:
#		# Changes the angle of the rope based on left / right
#		angle_to = angle_to + (x_input * 0.04)
#	else:
#		# Inverse the change of angle while colliding
#		angle_to = angle_to - (x_input * 0.07)

func reset_rope():
	line.clear_points()
	animation.playback_speed = 1 	# Reset animation speed
	player_state = state.normal

func rope_animation(x_input):
	# Change speed of players animation depending on speed of movement in x axis
		if abs(motion.x) > 1.5:			# Minimum animation speed
			animation.playback_speed = abs(motion.x) * 0.005
		
		# Updates the rope's offset if the player's sprite has flipped
		# This make it line up with the player's hand
		if x_input != 0:
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
			
			angle_to = deg2rad(90) - (position - rope_pos).angle()
			
			SoundPlayer.play_sound(SoundPlayer.Grapple)
			player_state = state.swing

func die():
	animation.play("Die")
	
	SoundPlayer.stop_sound(SoundPlayer.Wind)
	SoundPlayer.play_sound(SoundPlayer.Damage)
	
	Transition.exit_level_transition()
	yield(Transition, "transition_completed")
	
	animation.play("Idle")
	position = GlobalVariables.checkpoint_pos
	GlobalVariables.death_count += 1
	
	reset_rope()
	
	Transition.enter_level_transition()

func wind_noise():
	# Gets the channel in which the wind sound is playing
	var sound_channel = SoundPlayer.is_playing(SoundPlayer.Wind)
	var vel = motion.length()
	if sound_channel && SoundPlayer.get_channel_pitch_scale(sound_channel) && vel > 40:
		SoundPlayer.set_channel_pitch_scale(sound_channel, 0.6 * pow(vel / 100, 1.01))
		SoundPlayer.set_channel_vol(sound_channel, -100 / pow(4, vel / 100))

# Built in function from KinematicBody2D
# _physics_process causes jitter issues on !=60Hz monitors
# _process seems to eliminate this issue without any caveats?
func _process(delta):
	if Transition.rect_animation.is_playing():
		return
	
	var input_up = Input.get_action_strength("button_w")
	var input_down = Input.get_action_strength("button_s")
	var input_left = Input.get_action_strength("button_a")
	var input_right = Input.get_action_strength("button_d")
	
	var input_mouse = Input.is_action_just_pressed("mouse_left")
	
	var x_input = input_right - input_left
	
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
			
			if input_up:
				jump_buffer_timer.start()
			
			if coyote_on_floor:
					
				ground_speed_modifiers(x_input)
				
				# Allows the player to jump if the jump buffer timer has not stopped
				if !jump_buffer_timer.is_stopped():
					SoundPlayer.play_sound(SoundPlayer.Jump)
					motion.y = -jump_force
					jump_buffer_timer.stop()
					coyote_timer.stop()
			
			if !is_on_floor():
				air_speed_modifiers()
				
				# Variable jump height
				# Checks that jump button isn't pressed and moving up quickly											
				if Input.is_action_just_released(key_jump) and motion.y < (-jump_force * 0.5):
					# Halves the jump force, making the player land quickly
					motion.y = -jump_force * 0.5
				
				# Sets the player's animation to jump / in air
				animation.play("Jump")
			elif SoundPlayer.stop_sound(SoundPlayer.Wind):
				SoundPlayer.play_sound(SoundPlayer.Land)
			
		state.swing:
			animation.play("Swing")
			
			var colliding = get_slide_count() != 0
			
			rope_angle_changes(colliding, x_input)
			
			# Changes the length of the rope based on up / down
			rope_len = clamp(rope_len + ((input_down - input_up) * 2), min_rope_len, max_rope_len)
						
			# Calculates new rope position
			var position_to = Vector2(
				sin(angle_to),
				cos(angle_to)
			) * rope_len + rope_pos
			
			# Calculates the movement from the current position to the new one
			motion = position_to - position
			
			if motion.length() > max_rope_spd:
				motion = motion.normalized() * max_rope_spd
			
			# Will move quicker to the target position if not colliding
			# (since KinematicBody2D slowly approaches, like a bungee chord)
			if get_slide_count() == 0:
				motion *= 5
			
			# Resets player state out of rope state
			if Input.is_action_just_released("ui_select"):
				reset_rope()
	
	# Checks to see if the player is on the floor before the move_and_slide
	# function updates the player's position
	var floor_before_move = is_on_floor()
	
	motion = move_and_slide(motion, Vector2.UP)	# Moves the player node by the vector + automatically collides
												# Also returns left over motion, meaning if collided
												# It will return no movement, and stop for the next frame
	
	# If the player's new position is not on the floor, but it was the previous frame
	if floor_before_move && !is_on_floor():
		var channel = SoundPlayer.play_sound(SoundPlayer.Wind)
		SoundPlayer.set_channel_vol(channel, -100)
		coyote_timer.start()
	
	# Rope animation
	if player_state == state.swing:
		rope_animation(x_input)
	
	# Wind noise
	wind_noise()
	
	if input_mouse:
		initialise_rope()
