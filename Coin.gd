extends Area2D

onready var sprite = $Sprite

func _process(_delta):
	sprite.offset = Vector2(0, sin(float(Time.get_ticks_msec()) / 100) * 2)

func _on_Coin_body_entered(_body):
	GlobalVariables.coin_count += 1
	SoundPlayer.play_sound(SoundPlayer.Coin)
	queue_free()	#deletes the instance
