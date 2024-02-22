class_name Grabbable
extends RigidBody3D

const SNAP_SPEED = 10.0

@export var outline_material : Material

var _snap_target : Marker3D = null
var _outlines := []


func _ready():
	for child in get_children():
		if child is MeshInstance3D:
			var outline = MeshInstance3D.new()
			outline.mesh = child.mesh.create_outline(0.02)
			outline.mesh.surface_set_material(0, outline_material)
			outline.visible = false
			child.add_child(outline)
			_outlines.append(outline)


func set_outline_enabled(value):
	for outline in _outlines:
		outline.visible = value


func set_snap_target(snap_target):
	_snap_target = snap_target
	can_sleep = snap_target == null
	gravity_scale = 0 if snap_target else 1


func _physics_process(delta):
	if _snap_target:
		# POSITION
		var vec = _snap_target.global_position - global_position
		linear_velocity = vec * SNAP_SPEED
		
		# ROTATION
		angular_velocity = angular_velocity.lerp(Vector3.ZERO, delta * 10.0)
		var target_quat = _snap_target.global_basis.get_rotation_quaternion()
		quaternion = quaternion.slerp(target_quat, delta * 5.0)
