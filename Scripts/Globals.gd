extends Node

signal COIN_CHANGED

var playerLivesCap = 3
var playerLives = playerLivesCap
var _coins = 0

func addOneCoin():
	_coins += 1
	self.emit_signal("COIN_CHANGED")

func getCoins():
	return _coins
