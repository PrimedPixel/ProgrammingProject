extends HSlider

@onready var master_bus = AudioServer.get_bus_index("Master")

# Called when the node enters the scene tree for the first time.
func _ready():
	min_value = 0.0001
	value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
