extends CanvasLayer

const HEART_ROW_SIZE = 8
const HEART_OFFSET = 16

@onready var HEART = $Heart
@onready var COINS_LABEL = $coinText

var GUI_healh_cup
var GUI_healh_current


func _ready():
	_setHealthUI()
	Globals.connect("COIN_CHANGED", updateCoins)
	resetHUD()

func _process(delta):
	_checkForLivesSync()


func resetHUD():
	updateCoins()
	
func redrawHeatlh():
	for heart in HEART.get_children():
		var index = heart.get_index()
		var x = (index % HEART_ROW_SIZE) * HEART_OFFSET
		var y = (index / HEART_ROW_SIZE) * HEART_OFFSET
		heart.position = Vector2(x, y)
	
		var last_heart = floor(Globals.playerLives)
		if index  >= last_heart:
			heart.frame = 0
		if index < last_heart:
			heart.frame = 4

func updateCoins():
	COINS_LABEL.text = str(Globals.getCoins())


func _checkForLivesSync():
	if Globals.playerLives != GUI_healh_current || \
		Globals.playerLivesCap != GUI_healh_cup:
		redrawHeatlh()
	GUI_healh_current = Globals.playerLives
	GUI_healh_cup = Globals.playerLivesCap

func _setHealthUI():
	for i in Globals.playerLives:
		var new_heart = Sprite2D.new()
		new_heart.texture = HEART.texture
		new_heart.hframes = HEART.hframes
		HEART.add_child(new_heart)
