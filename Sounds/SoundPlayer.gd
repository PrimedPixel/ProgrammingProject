extends Node

const Checkpoint = preload("res://Sounds/Checkpoint.wav")
const Coin = preload("res://Sounds/Coin.wav")
const Damage = preload("res://Sounds/Damage.wav")
const Grapple = preload("res://Sounds/Grapple.wav")
const Jump = preload("res://Sounds/Jump.wav")
const Menu = preload("res://Sounds/Menu.wav")
#const Swing = preload("res://Sounds/Swing.wav")
#const Swing = preload("res://Sounds/White Noise.wav")
#const Swing = preload("res://Sounds/Pink Noise.wav")
const Wind = preload("res://Sounds/Brown Noise.wav")
#const Swing = preload("res://Sounds/Whiter Noise.wav")
const Land = preload("res://Sounds/Land.wav")

onready var audio_player = $AudioPlayers

func play_sound(sound):
	# Loops through each audio channel
	for channel in audio_player.get_children():
		# Plays the specified sound in the
		# First available audio channel
		if !channel.playing:
			channel.stream = sound
			channel.play()
			
			# Resets the pitch and volume since they
			# might have been altered previously
			channel.set_pitch_scale(1)
			channel.set_volume_db(0)
			return channel
			

func is_playing(sound):
	# Loops through each audio channel
	for channel in audio_player.get_children():
		if channel.playing && channel.stream == sound:
			return channel
	
	return null
	
func stop_sound(sound):
	var channel = is_playing(sound)
	
	if channel:
		channel.stop()
		return true
	
	return false
	

func get_channel_pitch_scale(channel):
	return channel.get_pitch_scale()

func set_channel_pitch_scale(channel, value):
	if channel.is_playing():
		channel.set_pitch_scale(value)

func get_channel_vol(channel):
	return channel.get_volume_db()
	
func set_channel_vol(channel, value):
	if channel != null:
		if channel.is_playing():
			channel.set_volume_db(min(value, 0))
