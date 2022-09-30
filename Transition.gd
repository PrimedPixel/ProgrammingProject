extends CanvasLayer

onready var rect_animation = $RectAnimation

func exit_level_transition():
	rect_animation.play("ExitLevel")
	
func enter_level_transition():
	rect_animation.play("EnterLevel")
