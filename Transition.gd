extends CanvasLayer

onready var rect_animation = $RectAnimation

signal transition_completed 

func exit_level_transition():
	rect_animation.play("ExitLevel")
	
func enter_level_transition():
	rect_animation.play("EnterLevel")


func _on_RectAnimation_animation_finished(anim_name):
	emit_signal("transition_completed")
