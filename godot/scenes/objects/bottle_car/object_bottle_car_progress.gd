extends Grabbable

@export var axle_scene : PackedScene
@export var straw_scene : PackedScene
@export var balloon_scene : PackedScene

@onready var _axle1 = $RigidBodyAxle1
@onready var _axle2 = $RigidBodyAxle2
@onready var _straw = $PlasticStraw
@onready var _balloon = $BalloonAnim


func on_use(with, backwards = false):
	super.on_use(with, backwards)
	if with == null:
		return
	
	var with_path = with.scene_file_path
	match with_path:
		axle_scene.resource_path:
			if !_axle1.visible:
				_set_rigidbody_enabled(_axle1, true)
			elif !_axle2.visible:
				_set_rigidbody_enabled(_axle2, true)
		straw_scene.resource_path:
			if !_straw.visible:
				_straw.visible = true
		balloon_scene.resource_path:
			if !_balloon.visible:
				_balloon.visible = true
	with.remove()


func _get_display_name():
	return "Bottle"
