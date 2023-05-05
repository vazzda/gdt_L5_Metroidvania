extends CharacterBody2D
class_name Enemy

var SPEED = 15
var RUN_SPEED = 30
var GRAVITY = 80
enum States {RELAX, HUNTING, LOST_PLAYER, DEAD}
var CurrentState = States.RELAX
var health = 1

var deathAnimInProgress = false
var moving_left = false
var lookingToggleCounter = 0
var lookingToggleCounterCap = 3
var lookingToggleCounterTime = 1

@onready var hitbox = $hitbox_enemy
@onready var anim = $anim
@onready var huntLostTimer = $HuntLostTimer

func _ready():
	hitbox.connect("area_entered", _onHitboxAreaEntered)

func _physics_process(delta):
	if CurrentState == States.DEAD:
		return
	if CurrentState == States.RELAX:
		_stroll()
	if CurrentState == States.HUNTING:
		_hunt()
	if CurrentState == States.LOST_PLAYER:
		_lostPlayer()

	_updateAnims()
	move_and_slide()

func _stroll():
	_move()
	_floor_detect()
	_player_detect()

func _hunt():
	_run()
	if !$RayCastLook.is_colliding():
		CurrentState = States.LOST_PLAYER

func _lostPlayer():
	_stop()
	_player_detect()
	
	if huntLostTimer.is_stopped():
		if lookingToggleCounter <= lookingToggleCounterCap:
			lookingToggleCounter += 1
			huntLostTimer.start(lookingToggleCounterTime)
			await huntLostTimer.timeout
			if CurrentState == States.LOST_PLAYER:
				_changeEnemyAndRayCastDirection()
				
		else:
			_resetLookingStates()
			CurrentState = States.RELAX

func _instantLooKNHunt():
	$RayCastLook.force_raycast_update()
	if !$RayCastLook.is_colliding():
		_changeEnemyAndRayCastDirection()
	if $RayCastLook.is_colliding():
		_player_detect()
	


func _move():
	if !moving_left:
		velocity.x = SPEED
	else:
		velocity.x = -SPEED
	velocity.y = GRAVITY

func _run():
	if !moving_left:
		velocity.x = RUN_SPEED
	else:
		velocity.x = -RUN_SPEED
	velocity.y = GRAVITY

func _stop():
		velocity.x = 0
		

func _floor_detect():
	if $RayCastX.is_colliding() || !$RayCastY.is_colliding():
		_changeEnemyAndRayCastDirection()

func _player_detect():
	if $RayCastLook.is_colliding():
		_resetLookingStates()
		CurrentState = States.HUNTING


func _changeEnemyAndRayCastDirection():
	moving_left = !moving_left
	scale.x = -scale.x
	$RayCastLook.force_raycast_update()


func _resetLookingStates():
	lookingToggleCounter = 0



func _updateAnims():
	anim.play("Idle")

func _death():
	CurrentState = States.DEAD
	$hitbox_enemy.queue_free()
	anim.play("Dead")
	await anim.animation_finished
	queue_free()
	

func _onHitboxAreaEntered(area):
	if area.name == "Sword":
		_tookDamage()

func _tookDamage():
	if CurrentState != States.HUNTING:
		_instantLooKNHunt()
		
	health -= 1
	_flash()
	if health <= 0 && CurrentState != States.DEAD:
		_death()

func _flash():
	$Sprite2D.material.set_shader_parameter("flash_modifier", 1)
	await (get_tree().create_timer(0.15)).timeout
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)
