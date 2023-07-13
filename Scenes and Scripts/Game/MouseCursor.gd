extends Sprite2D

var gamepad = false

func _ready():
	if !Input.get_connected_joypads().is_empty():
		gamepad = true

func _process(_delta):
	if !gamepad:
		position = get_global_mouse_position()
