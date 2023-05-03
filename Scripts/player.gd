extends CharacterBody2D


var SPEED = 200.0
var VELOCITY_CLAMNP = 100.0
var GRAVITY = 20
var JUMP = 400
var JUMP_IN_AIR_LIMIT = 2

enum PlayerStates {MOVE, SWORD}
var CurrentState = PlayerStates.MOVE
var jump_in_air_counter = 0
var swordAnimInProgress = false

func _ready():
	$Sword/CollisionShape2D.disabled = true
	$anim.connect("animation_finished", _onAnimationFinised)

func _physics_process(delta):
	_handleInputs(delta)
	_handleGravity()

	match CurrentState:
		PlayerStates.MOVE:
			_updateBasicAnims()
		PlayerStates.SWORD:
			_updateAttackAnims()
	
	move_and_slide()


func _handleInputs(delta):
	var movement = Input.get_action_strength("ui_move_right") - \
		Input.get_action_strength("ui_move_left")

	if movement != 0:
		if movement > 0.0:		
			_moveRight(delta)
		if movement < 0.0:
			_moveLeft(delta)
	if movement == 0.0:
		_moveIdle()
		
	if Input.is_action_just_pressed("ui_jump"):
		if is_on_floor():
			_jump()
		else:
			_jumpInAir()
	_checkJumpInAirState()
	
	if Input.is_action_just_pressed("ui_sword"):
		_sword(movement)


func _moveRight(delta):
	velocity.x += SPEED * delta
	velocity.x = clamp(SPEED, VELOCITY_CLAMNP, SPEED)
	$Sprite2D.flip_h = false
	$Sword/CollisionShape2D.position = Vector2(0, 0)

func _moveLeft(delta):
	velocity.x -= SPEED * delta
	velocity.x = clamp(SPEED, -VELOCITY_CLAMNP, -SPEED)
	$Sprite2D.flip_h = true
	$Sword/CollisionShape2D.position = Vector2(-50, 0)

func _moveIdle():
	velocity.x = 0.0

func _jump():
	velocity.y = -JUMP
	
func _jumpInAir():
	if jump_in_air_counter < JUMP_IN_AIR_LIMIT:
		jump_in_air_counter += 1
		_jump()

func _checkJumpInAirState():
	if is_on_floor() && jump_in_air_counter != 0:
		jump_in_air_counter = 0

func _sword(movement):
	CurrentState = PlayerStates.SWORD

func _handleGravity():
	velocity.y += GRAVITY


func _updateBasicAnims():
	var movement = Input.get_action_strength("ui_move_right") - \
		Input.get_action_strength("ui_move_left")

	if !is_on_floor() && velocity.y > 10:
		$anim.play("Fall")
		return
	if !is_on_floor():
		$anim.play("Jump")
		return

	if movement != 0:
		$anim.play("Walk")
	else:
		$anim.play("Idle")


func _updateAttackAnims():
	if CurrentState == PlayerStates.SWORD && !swordAnimInProgress:
		$anim.play("Sword")
		swordAnimInProgress = true



func _onAnimationFinised(name: String):
	if name == "Sword":
		_resetPlayerState()
	swordAnimInProgress = false


func _resetPlayerState():
	CurrentState = PlayerStates.MOVE


