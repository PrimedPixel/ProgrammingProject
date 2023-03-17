extends HSlider

onready var music_bus = AudioServer.get_bus_index("Music")

# Called when the node enters the scene tree for the first time.
func _ready():
	value = db2linear(AudioServer.get_bus_volume_db(music_bus))

