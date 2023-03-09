extends Sprite

func _process(_delta):
	offset = Vector2(0, sin(float(Time.get_ticks_msec()) / 1000) * 2)
