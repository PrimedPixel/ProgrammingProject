extends Button

func _ready():
	pressed = OS.window_fullscreen


func _process(_delta):
	text = "Fullscreen: " + str(OS.window_fullscreen)
