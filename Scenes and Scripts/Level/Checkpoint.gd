extends Area2D

@export var default = false

var checked = 0
@onready var animation = $CheckpointAnimation

func _process(_delta):
	if checked < 10 && default && GlobalVariables.checkpoint_pos == Vector2.ZERO:
		GlobalVariables.checkpoint_pos = position
		animation.play("Active")
		
		checked += 1
	
	if GlobalVariables.checkpoint_pos != position:
		animation.play("Inactive")

func _on_Checkpoint_body_entered(_body):
	if animation.get_assigned_animation() == "Inactive":
		SoundPlayer.play_sound(SoundPlayer.Checkpoint)
		animation.play("Active")
		GlobalVariables.checkpoint_pos = position
