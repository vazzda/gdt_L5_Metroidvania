extends CharacterBody2D

var SPEED = 15
var GRAVITY = 30
var moving_left = true

func _physics_process(delta):
	_move()
	_floor_detect()
	_updateAnims()
	move_and_slide()

func _move():
	if moving_left:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED

func _updateAnims():
	$anim.play("Idle")

func _floor_detect():
	if $RayCastX.is_colliding() || !$RayCastY.is_colliding():
		_changeEnemyAndRayCastDirection()

func _changeEnemyAndRayCastDirection():
	moving_left = !moving_left
	scale.x = -scale.x
