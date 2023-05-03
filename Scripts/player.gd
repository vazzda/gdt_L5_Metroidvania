extends CharacterBody2D

var SPEED = 200.0
var VELOCITY_CLAMNP = 100.0


func _physics_process(delta):
	Move(delta)
	move_and_slide()


func Move(delta):
	var movement = Input.get_action_strength("ui_right") - \
			Input.get_action_strength("ui_left")

	if movement != 0:
		if movement > 0.0:
			velocity.x += SPEED * delta
			velocity.x = clamp(SPEED, VELOCITY_CLAMNP, SPEED)
			$Sprite2D.flip_h = false
			$anim.play("Walk")
		if movement < 0.0:
			velocity.x -= SPEED * delta
			velocity.x = clamp(SPEED, -VELOCITY_CLAMNP, -SPEED)
			$Sprite2D.flip_h = true
			$anim.play("Walk")
	
	if movement == 0.0:
		velocity.x = 0.0
		$anim.play("Idle")

