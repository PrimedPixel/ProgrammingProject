extends Sprite

var gamepad = false

func _ready():
	if !Input.get_connected_joypads().empty():
		gamepad = true

func _process(_delta):
	if !gamepad:
		position = get_global_mouse_position()
