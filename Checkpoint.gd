extends Area2D

onready var animation = $CheckpointAnimation

func _process(_delta):
	if GlobalVariables.checkpoint_pos != position:
		animation.play("RedStill")

func _on_Checkpoint_body_entered(_body):
	if animation.get_assigned_animation() == "RedStill":
		SoundPlayer.play_sound(SoundPlayer.Checkpoint)
		animation.play("RedActive")
		GlobalVariables.checkpoint_pos = position
