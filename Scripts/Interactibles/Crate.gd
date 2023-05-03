extends StaticBody2D

var health = 3

func _ready():
	$hitbox.connect("area_entered", _onHitboxAreaEntered)

func _onHitboxAreaEntered(area):
	if area.name == "Sword":
		$anim.play("hurt")
		health -= 1
		await $anim.animation_finished
		$anim.play("active")
		
	if health <= 0:
		$anim.play("destroyed")
		await $anim.animation_finished
		queue_free()
