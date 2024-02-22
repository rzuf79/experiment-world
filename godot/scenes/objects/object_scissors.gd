extends Grabbable

@onready var _anim = $AnimationPlayer


func on_use(with):
	_anim.stop(false)
	_anim.play("cut")
	super.on_use(with)
