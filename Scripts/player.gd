extends CharacterBody2D


var SPEED = 200.0
var VELOCITY_CLAMNP = 100.0
var GRAVITY = 20
var JUMP = 400
var JUMP_IN_AIR_LIMIT = 2
var KICK_FREEZE = 0.3
var KICK_FORCE = Vector2(125,-225)
var INVULNERABILITY = 2
var INVULNERABILITY_BLINK = 0.05

var health = Globals.playerLives

enum PlayerStates {MOVE, SWORD, KICKED, DEATH}
var CurrentState = PlayerStates.MOVE
var jump_in_air_counter = 0
var swordAnimInProgress = false
var deathAnimInProgress = false
var freezeTimer = Timer.new()
var invulTimer = Timer.new()
var isInvulnerable = false
var isInvulnerableBlinkState = false

func _ready():
	$Sword/CollisionShape2D.disabled = true
	$anim.connect("animation_finished", _onAnimationFinised)
	$hitbox.connect("area_entered", _onHitboxAreaEntred)
	
	add_child(freezeTimer)
	freezeTimer.connect("timeout", _onFreezeTimeOut)
	add_child(invulTimer)
	invulTimer.connect("timeout", _onInvulTimeOut)


func _physics_process(delta):
	match CurrentState:
		PlayerStates.MOVE:
			_handleInputs(delta)
			_handleGravity()
			_updateBasicAnims()
		PlayerStates.SWORD:
			_handleInputs(delta)
			_handleGravity()
			_updateAttackAnims()
		PlayerStates.DEATH:
			_handleGravity()
		PlayerStates.KICKED:
			_handleGravity()
	
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
	
func _kick(direction):
	velocity.y = KICK_FORCE.y
	velocity.x = KICK_FORCE.x * direction

func _stop():
	velocity.x = 0

func _getKick(area):
	if CurrentState != PlayerStates.DEATH:
		CurrentState = PlayerStates.KICKED
		if !freezeTimer.is_stopped():
			freezeTimer.stop()
		freezeTimer.start(KICK_FREEZE)
		
	var direction
	var areaX = area.global_position.x
	var playerX = global_position.x
	if areaX <= playerX:
		direction = 1
	else:
		direction = -1
	
	_kick(direction)
	

func _onFreezeTimeOut():
	if CurrentState == PlayerStates.KICKED:
		CurrentState = PlayerStates.MOVE
	
	
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

func _onHitboxAreaEntred(area):
	var isEnemy = area.is_in_group("ENEMY")
	if isEnemy:
		_takeDamage(area)

func _takeDamage(area):
	if isInvulnerable: return
	if CurrentState == PlayerStates.KICKED: return

	health -= 1
	Globals.playerLives = health
	if health <= 0:
		_death()
	else:
		_getKick(area)
		_setInvul()

func _death():
	_stop()
	if deathAnimInProgress: return
	
	CurrentState = PlayerStates.DEATH
	$anim.play("Dead")
	await $anim.animation_finished
	Globals.playerLives = Globals.playerLivesCap
	get_tree().reload_current_scene()
	
func _setInvul():
	isInvulnerable = true
	invulTimer.start(INVULNERABILITY_BLINK)
	await (get_tree().create_timer(INVULNERABILITY)).timeout
	_disableInvul()

func _disableInvul():
	isInvulnerable = false
	invulTimer.stop()
	$Sprite2D.material.set_shader_parameter("flash_modifier", 0)

func _onInvulTimeOut():
	_toggleInvulBlink()

func _toggleInvulBlink():
	var state = int(isInvulnerableBlinkState)
	isInvulnerableBlinkState = !isInvulnerableBlinkState
	$Sprite2D.material.set_shader_parameter("flash_modifier", state)
