extends AudioStreamPlayer

var tween_out

@export var transition_duration = 1.00
@export var transition_type = 1 # TRANS_SINE

func fade_out():	
	tween_out = create_tween()
	tween_out.tween_property(self, "volume_db", -80, 1).set_ease(Tween.EASE_OUT)
	tween_out.play()
