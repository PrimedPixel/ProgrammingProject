extends Area2D

onready var animation = $CoinAnimation

func _ready():
	animation.play("CoinAnimation")

func _on_Coin_body_entered(_body):
	GlobalVariables.coin_count += 1
	SoundPlayer.play_sound(SoundPlayer.Coin)
	queue_free()	#deletes the instance
