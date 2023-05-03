extends CharacterBody2D

enum PlayerStates {MOVE, SWORD}
var CurrentState = PlayerStates.MOVE

var SPEED = 200.0
var VELOCITY_CLAMNP = 100.0
var GRAVITY = 20
var JUMP = 400
var JUMP_IN_AIR_LIMIT = 2

var jump_in_air_counter = 0

func _ready():
	$Sword/CollisionShape2D.disabled = true
	$anim.connect("animation_finished", _onAnimationFinised)

func _physics_process(delta):
#	Move(delta)
	
	match CurrentState:
		PlayerStates.MOVE:
			Move(delta)
		PlayerStates.SWORD:
			Sword()
	
	velocity.y += GRAVITY
	move_and_slide()


func Move(delta):
	var movement = Input.get_action_strength("ui_move_right") - \
			Input.get_action_strength("ui_move_left")

	if movement != 0:
		if movement > 0.0:
			velocity.x += SPEED * delta
			velocity.x = clamp(SPEED, VELOCITY_CLAMNP, SPEED)
			$Sprite2D.flip_h = false
			$anim.play("Walk")
			$Sword/CollisionShape2D.position = Vector2(0, 0)
		if movement < 0.0:
			velocity.x -= SPEED * delta
			velocity.x = clamp(SPEED, -VELOCITY_CLAMNP, -SPEED)
			$Sprite2D.flip_h = true
			$anim.play("Walk")
			$Sword/CollisionShape2D.position = Vector2(-50, 0)
	
	if movement == 0.0:
		velocity.x = 0.0
		$anim.play("Idle")
	
	if Input.is_action_just_pressed("ui_jump") && is_on_floor():
		Jump()
	if Input.is_action_just_pressed("ui_jump") && !is_on_floor():
		if jump_in_air_counter < JUMP_IN_AIR_LIMIT:
			Jump()
			jump_in_air_counter += 1
	if is_on_floor() && jump_in_air_counter != 0:
		jump_in_air_counter = 0

	if !is_on_floor():
		$anim.play("Jump")
	if !is_on_floor() && velocity.y > 10:
		$anim.play("Fall")
	
	if Input.is_action_just_pressed("ui_sword"):
		CurrentState = PlayerStates.SWORD
		velocity.x = movement


func Jump():
	velocity.y = -JUMP

func Sword():
	$anim.play("Sword")


func _onAnimationFinised(name: String):
	if name == "Sword":
		_resetPlayerState()

func _resetPlayerState():
	CurrentState = PlayerStates.MOVE


