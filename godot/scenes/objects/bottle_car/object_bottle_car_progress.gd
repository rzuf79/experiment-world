extends Grabbable



func on_use(with, backwards = false):
	super.on_use(with, backwards)
	_set_rigidbody_enabled($RigidBodyAxle1, true)


func _get_display_name():
	return "Bottle"
