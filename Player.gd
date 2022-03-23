extends KinematicBody2D

#Equivalent to macros, I suppose
const accel = 512
const max_spd = 64
const ground_frict = 0.25
const air_frict = 0.02
const grav = 200
const jump_force = 128

var key_jump = "ui_select"	#Spacebar is mapped to UI Select (to begin with)
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

#A vector - magnitude and direction (essentially velocity)
var motion = Vector2.ZERO

#onready makes sure that the nodes have been initialised and loaded into the scene
onready var sprite = $Sprite
onready var animation = $AnimationPlayer

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
			#do nothing
			if 1 == 2:
				print("hello")
		
	
	motion = move_and_slide(motion, Vector2.UP)	#Moves the player node by the vector + automatically collides
												#Also returns left over motion, meaning if collided
												#It will return no movement, and stop for the next frame

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_R:
			get_tree().reload_current_scene()
