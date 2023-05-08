extends Node

signal COIN_CHANGED

var playerLivesCap = 3
var playerLives = playerLivesCap
var _coins = 0
var _onPause = false

func _ready():
	self.set_process(true)

func _process(delta):
	_handlePausePress()


func addOneCoin():
	_coins += 10
	self.emit_signal("COIN_CHANGED")

func getCoins():
	return _coins

func _handlePausePress():
	if Input.is_action_just_pressed("ui_pause"):
		if get_tree().paused:
			_unpauseGame()
		else:
			_pauseGame()

func _pauseGame():
	get_tree().paused = true
	self.set_process(true)
	print(self.can_process())
	
func _unpauseGame():
	get_tree().paused = false
