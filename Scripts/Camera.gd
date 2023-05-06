extends Camera2D

@onready var player = get_node("../Player")
var speed = 100
var isMoving = false


func _ready():
	pass # Replace with function body.


func _process(delta):
	position = player.global_position
	var x = floor(position.x / 320) * 320
	var y = floor(position.y / 180) * 180
	global_position = Vector2(x, y)
	isMoving = true
	
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", Vector2(x, y), 0.14)
