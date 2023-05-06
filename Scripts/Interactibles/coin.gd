extends Area2D

func _ready():
	self.connect("body_entered", _onBodyEntered)

func _onBodyEntered(body):
	Globals.addOneCoin()
	$anim.play("Picked")
	await $anim.animation_finished
	queue_free()
	
