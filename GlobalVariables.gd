extends Node

export var checkpoint_pos = Vector2.ZERO
export var coin_count = 0
export var death_count = 0

export var level_to = -1

var save_file = File.new()
var save_file_path = "user://save.json"

func save_exists():
	return save_file.file_exists(save_file_path)

func write_savegame():
	var error = save_file.open(save_file_path, File.WRITE)
	
	if error != OK:
		printerr("Could not open save file for writing!")
		return
	
	# For whatever reason (I suspect since we're running from a singleton
	# get_viewport() does not work, so it must be manually get
	var current_level_path = get_tree().get_current_scene().get_node("ViewportContainer/Viewport").get_child(0).get_filename()
	
	var data = {
		"checkpoint_position":
		{
			"x": checkpoint_pos.x,
			"y": checkpoint_pos.y,
		},
		
		"stats":
		{
			"coin_count": coin_count,
			"death_count": death_count,
		},
		
		"continue_level": current_level_path,
	}
	
	var json_str = JSON.print(data)
	save_file.store_string(json_str)
	save_file.close()

func load_savegame():
	var error = save_file.open(save_file_path, File.READ)
	
	if error != OK:
		printerr("Could not open save file for reading!")
		return
	
	var file_data = save_file.get_as_text()
	save_file.close()
	
	var data = JSON.parse(file_data).result
	
	checkpoint_pos = Vector2(data.checkpoint_position.x, data.checkpoint_position.y)
	coin_count = data.stats.coin_count
	death_count = data.stats.death_count

	level_to = data.continue_level

func delete_savegame():
	var dir = Directory.new()
	dir.remove(save_file_path)
	
	# Perhaps there's a way to do this without repeating?
	checkpoint_pos = Vector2.ZERO
	coin_count = 0
	death_count = 0
	level_to = -1

# Runs when the game first starts
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	load_savegame()
	
	print(level_to)
