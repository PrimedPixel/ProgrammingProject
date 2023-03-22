extends Control

var can_process = false

var label = null

var level = null
var player = null
var cam = null

var spikes = null
var checkpoints = null
var coins = null

var fire = null

onready var master_bus = AudioServer.get_bus_index("Master")
onready var music_bus = AudioServer.get_bus_index("Music")
onready var sfx_bus = AudioServer.get_bus_index("Sound Effects")

func enable():
	label = $Label

	level = get_parent().get_node("ViewportContainer/Viewport").get_child(0)
	player = level.get_node("Player")
	cam = level.get_node("Cam")
	
	spikes = level.get_node("Spikes")
	checkpoints = level.get_node("Checkpoints")
	coins = level.get_node("Coins")
	
	fire = level.get_node_or_null("Fire")
	
	can_process = true

func _process(_delta):
	visible = can_process
	
	if can_process:
		var master_vol = AudioServer.get_bus_volume_db(master_bus)
		var music_vol = AudioServer.get_bus_volume_db(music_bus)
		var sfx_vol = AudioServer.get_bus_volume_db(sfx_bus)
		
		var rope_angle = fmod(player.angle_to, (2 * PI))
		
		label.text = "FPS: " + str(Engine.get_frames_per_second()) + 											\
			"\nFullscreen: " + str(OS.window_fullscreen) +														\
			"\nMaster Vol: " + str(master_vol) + "db, " + str(db2linear(master_vol)) +							\
			"\nMusic Vol: " + str(music_vol) + "db, " + str(db2linear(music_vol)) +								\
			"\nSFX Vol: " + str(sfx_vol) + "db, " + str(db2linear(sfx_vol)) +									\
																												\
			"\n\nPlayer Velocity: " + str(player.motion) +														\
			"\nPlayer Speed: " + str(player.motion.length()) +													\
			"\nPlayer Position: " + str(player.position) +														\
			"\nPlayer Global Position: " + str(player.global_position) +										\
			"\nPlayer State: " + str(player.player_state) +														\
			"\nPlayer Collision: " + str(player.colliding) +													\
			"\nPlayer is_on_floor: " + str(player.is_on_floor()) +												\
			"\nPlayer is_on_wall: " + str(player.is_on_wall()) +												\
			"\nPlayer is_on_ceil: " + str(player.is_on_ceiling()) +												\
																												\
			"\n\nRope Pos Player: " + str(player.rope_pos) +													\
			"\nRope Pos Caset: " + str(player.cast) +															\
			"\nRope Length: " + str(player.rope_len) +															\
			"\nRope Angle: " + str(rope_angle) + ", " + str(rad2deg(rope_angle)) + "°" + 						\
																												\
			"\n\nCamera Position: " + str(cam.position) +														\
			"\nCamera Global Position: " + str(cam.global_position) +											\
			"\nCamera Interp: " + str(cam.interpolate_val) +													\
																												\
			"\nSpike Node Count: " + str(spikes.get_child_count()) +											\
			"\nDeath Count: " + str(GlobalVariables.death_count) +												\
			"\nCheckpoint Node Count: " + str(checkpoints.get_child_count()) +									\
			"\nCheckpoint Position: " + str(GlobalVariables.checkpoint_pos) +									\
			"\nCoin Node Count: " + str(coins.get_child_count()) +												\
			"\nCoin Count: " + str(GlobalVariables.coin_count)
			
		if fire != null:
			label.text += "\n\nFire Distance: " + str(fire.fire_distance)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_F3:
					enable()
