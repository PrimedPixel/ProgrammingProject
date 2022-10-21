extends Node

const Checkpoint = preload("res://Sounds/Checkpoint.wav")
const Coin = preload("res://Sounds/Coin.wav")
const Damage = preload("res://Sounds/Damage.wav")
const Grapple = preload("res://Sounds/Grapple.wav")
const Jump = preload("res://Sounds/Jump.wav")
const Menu = preload("res://Sounds/Menu.wav")
const Swing = preload("res://Sounds/Swing.wav")
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
			break

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
	channel.set_pitch_scale(value)
