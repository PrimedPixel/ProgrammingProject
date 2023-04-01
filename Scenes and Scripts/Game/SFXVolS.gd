extends HSlider

onready var sfx_bus = AudioServer.get_bus_index("Sound Effects")

# Called when the node enters the scene tree for the first time.
func _ready():
	min_value = 0.0001
	value = db2linear(AudioServer.get_bus_volume_db(sfx_bus))
