extends Area2D

onready var animation_player = $AnimationPlayer

func choose(list):
	return list[randi() % list.size()]

func _ready():
	randomize()
	animation_player.play("Electric")

	# Randomises the starting frame
	animation_player.advance(choose([0, 0.1]))

func _on_Spikes_body_entered(body):
	if body is Player:
		body.die()
