extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()


func update_text():
	set_text(InputMap.action_get_events("button_down")[0].as_text())
