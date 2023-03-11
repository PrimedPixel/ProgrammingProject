extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	update_text()


func update_text():
	set_text(InputMap.get_action_list("button_up")[0].as_text())
