extends CharacterBody2D

var SPEED = 15
var GRAVITY = 30
enum States {MOVE, DEAD}
var CurrentState = States.MOVE
var deathAnimInProgress = false

var moving_left = true
var health = 3

@onready var hitbox = $hitbox
@onready var anim = $anim

func _ready():
	hitbox.connect("area_entered", _onHitboxAreaEntered)

func _physics_process(delta):
	if CurrentState == States.MOVE:
		_move()
		_floor_detect()
		_updateAnims()
		move_and_slide()
	if CurrentState == States.DEAD:
		return

func _move():
	if moving_left:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED

func _updateAnims():
	anim.play("Idle")

func _floor_detect():
	if $RayCastX.is_colliding() || !$RayCastY.is_colliding():
		_changeEnemyAndRayCastDirection()

func _changeEnemyAndRayCastDirection():
	moving_left = !moving_left
	scale.x = -scale.x

func _onHitboxAreaEntered(area):
	if area.name == "Sword":
		_tookDamage()

func _tookDamage():
	health -= 1
	if health <= 0 && CurrentState != States.DEAD:
		_death()

func _death():
	CurrentState = States.DEAD
	anim.play("Dead")
	await anim.animation_finished
	queue_free()
