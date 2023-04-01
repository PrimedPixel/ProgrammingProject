extends Node

export var checkpoint_pos = Vector2.ZERO
export var coin_count = 0
export var death_count = 0

export var level_to = -1

onready var master_bus = AudioServer.get_bus_index("Master")
onready var music_bus = AudioServer.get_bus_index("Music")
onready var sfx_bus = AudioServer.get_bus_index("Sound Effects")

var save_file = File.new()
var save_file_path = "user://save.json"

func save_exists():
	return save_file.file_exists(save_file_path)

func write_savegame():
	# Checks that the file exists
	var error = save_file.open(save_file_path, File.WRITE)
	
	if error != OK:
		printerr("Could not open save file for writing!")
		return
	
	# Stores the data in a dictionary
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
		
		"continue_level": level_to,
		
		"options":
		{
			"fullscreen": OS.window_fullscreen,
			"master_vol": AudioServer.get_bus_volume_db(master_bus),
			"music_vol": AudioServer.get_bus_volume_db(music_bus),
			"sfx_vol": AudioServer.get_bus_volume_db(sfx_bus),
			
			"controls":
			{
				"up": InputMap.get_action_list("button_up")[0].scancode,
				"down": InputMap.get_action_list("button_down")[0].scancode,
				"left": InputMap.get_action_list("button_left")[0].scancode,
				"right": InputMap.get_action_list("button_right")[0].scancode,
				"jump": InputMap.get_action_list("button_jump")[0].scancode,
			},
		},
	}
	
	# Saves the data into a JSON formatted string, then writes said string
	var json_str = JSON.print(data)
	save_file.store_string(json_str)
	save_file.close()

func load_savegame():
	# Opens the file
	var error = save_file.open(save_file_path, File.READ)
	
	# Checks the file is readable
	if error != OK:
		printerr("Could not open save file for reading!")
		return
	
	# Loads the data into a varialbe and closes the file
	var file_data = save_file.get_as_text()
	save_file.close()
	
	# Parses (decodes) the JSON data
	var data = JSON.parse(file_data).result
	
	# Applies the data to the variables
	checkpoint_pos = Vector2(data.checkpoint_position.x, data.checkpoint_position.y)
	coin_count = data.stats.coin_count
	death_count = data.stats.death_count

	level_to = data.continue_level
	
	OS.window_fullscreen = data.options.fullscreen
	AudioServer.set_bus_volume_db(master_bus, data.options.master_vol)
	AudioServer.set_bus_volume_db(music_bus, data.options.music_vol)
	AudioServer.set_bus_volume_db(sfx_bus, data.options.sfx_vol)
	
	change_key("button_up", data.options.controls.up)
	change_key("button_down", data.options.controls.down)
	change_key("button_left", data.options.controls.left)
	change_key("button_right", data.options.controls.right)
	change_key("button_jump", data.options.controls.jump)

func delete_savegame():
	if save_exists():
		var dir = Directory.new()
		dir.remove(save_file_path)
	
	# Perhaps there's a way to do this without repeating?
	checkpoint_pos = Vector2.ZERO
	coin_count = 0
	death_count = 0
	level_to = -1


func change_key(map_key, new_key):
	# Delete key of pressed button
	if !InputMap.get_action_list(map_key).empty():
		InputMap.action_erase_event(map_key, InputMap.get_action_list(map_key)[0])
			
	# Add new Key
	var key = InputEventKey.new()
	key.scancode = new_key
	InputMap.action_add_event(map_key, key)


# Runs when the game first starts
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	load_savegame()
