extends Area2D

onready var player = get_parent().get_node("Player")

func _on_Spikes_body_entered(body):
	player.die()
