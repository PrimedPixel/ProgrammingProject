extends HSlider

@onready var music_bus = AudioServer.get_bus_index("Music")

# Called when the node enters the scene tree for the first time.
func _ready():
	min_value = 0.0001
	value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))

