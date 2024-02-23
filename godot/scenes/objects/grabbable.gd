class_name Grabbable
extends RigidBody3D

const SNAP_SPEED = 10.0

signal removed()

@export var outline_material : Material
@export var interactions : Array[ObjectInteraction]
@export var spawn_particle : PackedScene

@onready var _pick_area = $PickArea

var is_removed := false

var _snap_target : Marker3D = null
var _meshes : Array[MeshInstance3D] = []
var _outlines := []


func _ready():
	for child in get_children():
		if child is MeshInstance3D:
			_meshes.append(child)
			var outline = MeshInstance3D.new()
			outline.mesh = child.mesh.create_outline(0.02)
			outline.mesh.surface_set_material(0, outline_material)
			outline.visible = false
			child.add_child(outline)
			_outlines.append(outline)
	
	var pick_shape : CollisionShape3D = $PickArea/CollisionShape3D
	if pick_shape.shape == null:
		var aabb : AABB
		for mi in _meshes:
			var mesh_aabb = mi.mesh.get_aabb()
			aabb = aabb.merge(mesh_aabb)
		aabb.grow(0.02)
			
		#pick_shape.position = aabb.position
		pick_shape.shape = BoxShape3D.new()
		pick_shape.shape.size = aabb.size / 2


func remove():
	visible = false
	is_removed = true
	emit_signal("removed")
	queue_free()


func on_use(with):
	if with is Grabbable:
		var with_scene_path = with.scene_file_path
		for inter in interactions:
			if !inter.other_object || !inter.resulting_object:
				continue
			if with_scene_path == inter.other_object.resource_path:
				var current_transform = with.global_transform
				var parent = with.get_parent_node_3d()
				var new_object = inter.resulting_object.instantiate()
				with.remove()
				new_object.global_transform = current_transform
				parent.add_child(new_object)
				if new_object.spawn_particle != null:
					var spawn_particles = new_object.spawn_particle.instantiate()
					new_object.get_parent().add_child(spawn_particles)
					spawn_particles.global_position = new_object.global_position
					spawn_particles.emitting = true
				break


func set_outline_enabled(value):
	for outline in _outlines:
		outline.visible = value


func set_snap_target(snap_target):
	_snap_target = snap_target
	can_sleep = snap_target == null
	gravity_scale = 0 if snap_target else 1


func set_raycast_exclude(raycast : RayCast3D, excluded : bool):
	for target in [ self, _pick_area ]:
		if excluded:
			raycast.add_exception(target)
		else:
			raycast.remove_exception(target)


func _physics_process(delta):
	if _snap_target:
		# POSITION
		var pos_snap_vec = _snap_target.global_position - global_position
		linear_velocity = pos_snap_vec * SNAP_SPEED
		
		# ROTATION
		var q1 = basis.get_rotation_quaternion()
		var q2 = _snap_target.global_basis.get_rotation_quaternion()
		var qt = q2 * q1.inverse()
		var angle = 2 * acos(qt.w)
		if angle > PI:
			qt = -qt
			angle = TAU - angle
		if abs(angle) > 0.0001:
			var axis = Vector3(qt.x, qt.y, qt.z) / sqrt(1-qt.w*qt.w)
			var w = axis * angle
			angular_velocity = w * SNAP_SPEED
