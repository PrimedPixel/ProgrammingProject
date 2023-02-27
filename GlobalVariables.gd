extends Node

var checkpoint_pos = Vector2.ZERO
var coin_count = 0
var death_count = 0

var level_to = null

# Runs when the game first starts
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
