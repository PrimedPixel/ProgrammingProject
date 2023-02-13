extends Viewport

var game_mouse_pos = Vector2.ZERO
onready var rope_cast = $Level/Player/RopeCast

func _process(_delta):
	game_mouse_pos = get_mouse_position() / 6
	print(game_mouse_pos)
	
	rope_cast.set_cast_to(rope_cast.to_local(game_mouse_pos))
