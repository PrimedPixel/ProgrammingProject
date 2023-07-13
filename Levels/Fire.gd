extends Area2D

@onready var fire_rect = $FireRect
@onready var fire_collision = $FireCollision
@onready var fire_sprite = $FireSprite

const fire_accel = 0.001
var fire_speed = 0.3

const max_fire_speed = 3.5

var fire_distance = 0

func _process(_delta):
	fire_distance += fire_speed
	fire_speed = min(fire_speed + fire_accel, max_fire_speed)
	
	fire_rect.offset_right = fire_distance
	fire_sprite.position.x = fire_distance
	fire_collision.scale.x = fire_distance * 2


func _on_Fire_body_entered(body):
	if body is Player:
		body.death_animation = "Fire"
		body.die()
