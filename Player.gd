extends KinematicBody2D

#Equivalent to macros, I suppose
const accel = 512
const max_spd = 64
const ground_frict = 0.25
const air_frict = 0.02
const grav = 200
const jump_force = 128

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
	match player_state:
		state.normal:
			var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			var y_input = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
			
			if x_input != 0:
				motion.x += x_input * accel * delta		#Multiply by delta since occuring every frame
				motion.x = clamp(motion.x, -max_spd, max_spd)
				
				sprite.flip_h = x_input < 0
				
			
			motion.y += grav * delta	#Multiply by delta since occuring every frame
			
			if floor(motion.x) == 0:
				animation.play("Idle")
			else:
				animation.play("Run")
			
			if is_on_floor():
				if Input.is_action_just_pressed("ui_up"):
					motion.y = -jump_force
				
				if x_input == 0:
					motion.x = lerp(motion.x, 0, ground_frict)
			else:												#checks that we're moving up quickly
				if Input.is_action_just_released("ui_up") and motion.y < -jump_force / 2:#variable jump height
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
