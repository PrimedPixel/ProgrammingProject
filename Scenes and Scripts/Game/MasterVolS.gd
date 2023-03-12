extends HSlider

onready var master_bus = AudioServer.get_bus_index("Master")

# Called when the node enters the scene tree for the first time.
func _ready():
	value = db2linear(AudioServer.get_bus_volume_db(master_bus))
