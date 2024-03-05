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
	var interacted = false
	match with_path:
		axle_scene.resource_path:
			if !_axle1.visible:
				_set_rigidbody_enabled(_axle1, true)
				interacted = true
			elif !_axle2.visible:
				_set_rigidbody_enabled(_axle2, true)
				interacted = true
		straw_scene.resource_path:
			if !_straw.visible:
				_straw.visible = true
				interacted = true
		balloon_scene.resource_path:
			if !_balloon.visible && _straw.visible:
				_balloon.visible = true
				interacted = true
	
	if interacted:
		with.remove()


func _get_display_name():
	return "Bottle"
