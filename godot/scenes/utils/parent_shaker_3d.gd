extends Node3D

@export var shaking := false
@export var strength := 0.05

var _last_shaking := false
var _root_position : Vector3


func _ready():
	_root_position = get_parent().position


func _process(_delta):
	if shaking:
		var displacement = Vector3(
			randf_range(0, strength),
			randf_range(0, strength),
			randf_range(0, strength)
		)
		get_parent().position = _root_position + displacement
		print(get_parent().position )
	else:
		if _last_shaking:
			get_parent().position = _root_position
	
	_last_shaking = shaking
