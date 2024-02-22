extends Grabbable

@onready var _anim = $AnimationPlayer


func on_use(with):
	if with:
		print(with.name)
	_anim.stop(false)
	_anim.play("cut")
