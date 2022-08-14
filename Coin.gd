extends Area2D

onready var animation = $CoinAnimation

func _ready():
	animation.play("CoinAnimation")

func _on_Coin_body_entered(body):
	GlobalVariables.coin_count += 1
	queue_free()	#deletes the instance
