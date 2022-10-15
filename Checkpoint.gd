extends Area2D

onready var animation = $CheckpointAnimation

func _process(_delta):
	if GlobalVariables.checkpoint_pos != position:
		animation.play("RedStill")

func _on_Checkpoint_body_entered(_body):
	animation.play("RedActive")
	GlobalVariables.checkpoint_pos = position