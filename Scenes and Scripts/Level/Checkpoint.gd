extends Area2D

export var default = false

var checked = false
onready var animation = $CheckpointAnimation

func _ready():
	if default:
		GlobalVariables.checkpoint_pos = position
		animation.play("Active")

func _process(_delta):
	if !checked && default:
		GlobalVariables.checkpoint_pos = position
		animation.play("Active")
		
		checked = true
	
	if GlobalVariables.checkpoint_pos != position:
		animation.play("Inactive")

func _on_Checkpoint_body_entered(_body):
	if animation.get_assigned_animation() == "Inactive":
		SoundPlayer.play_sound(SoundPlayer.Checkpoint)
		animation.play("Active")
		GlobalVariables.checkpoint_pos = position
