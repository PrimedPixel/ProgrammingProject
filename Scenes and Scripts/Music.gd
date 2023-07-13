extends AudioStreamPlayer

@onready var tween_out = $FadeOut

@export var transition_duration = 1.00
@export var transition_type = 1 # TRANS_SINE

func fade_out():
	# tween music volume down to 0
	tween_out.interpolate_property(self, "volume_db", 0, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()
	# when the tween ends, the music will be stopped

func _on_FadeOut_tween_all_completed(object, _key):
	object.stop()
