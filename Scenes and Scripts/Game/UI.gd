extends Control

@onready var coin_count = $CanvasUI/CoinUI/CoinCount
@onready var death_count = $CanvasUI/DeathUI/DeathCount

@onready var coin_ui = $CanvasUI/CoinUI
@onready var death_ui = $CanvasUI/DeathUI

@onready var coin_timer = $CanvasUI/CoinUI/CoinTimer
@onready var death_timer = $CanvasUI/DeathUI/DeathTimer

#onready var player = get_parent().get_node("ViewportContainer/Viewport/Level/Player")

var previous_coin = 0
var previous_death = 0

var ui_onscreen = 0
var ui_offscreen = 0

func _ready():
	# Multiply by 6 since the UI is 6 times the scale of the in game resolution
	# (320, 180) * 6 = (1920, 1080)
	ui_onscreen = death_ui.position.y * 3
	ui_offscreen = -(ui_onscreen + (64 * 3))
	
	coin_ui.position.y = ui_offscreen
	death_ui.position.y = ui_offscreen

func update_count(count_node, count_var, ui_node, timer_node, previous):
	count_node.text = str(count_var)
	
	if previous != count_var:
		timer_node.start()
		
	if !timer_node.is_stopped():
		previous = count_var
		
		ui_node.position.y = lerp(ui_node.position.y, ui_onscreen, 0.005)
	else:
		ui_node.position.y = lerp(ui_node.position.y, ui_offscreen, 0.005)
	
	return previous

func _process(_delta):

	previous_coin = update_count(coin_count, GlobalVariables.coin_count, coin_ui, coin_timer, previous_coin)
	
	previous_death = update_count(death_count, GlobalVariables.death_count, death_ui, death_timer, previous_death)
	
	if Input.is_action_pressed("button_lctrl"): # && player.is_on_floor():
		coin_timer.start()
		death_timer.start()
