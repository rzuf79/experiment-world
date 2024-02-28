class_name Grabbable
extends RigidBody3D

class DisabledRigidbody:
	var node : RigidBody3D
	var collision_layer : int
	var collision_mask : int
	var connected_joints : Array[Dictionary] = []
	var position : Vector3
	var rotation : Vector3

const SNAP_SPEED = 10.0

signal removed()

@export var display_name : String = "" : get = _get_display_name
@export var outline_material : Material
@export var interactions : Array[ObjectInteraction]
@export var spawn_particle : PackedScene
@export var on_use_anim_name : String = ""

@onready var _pick_area = $PickArea

var is_removed := false

var _snap_target : Marker3D = null
var _meshes : Array[MeshInstance3D] = []
var _outlines := []
var _disabled_rigidbodies : Array[DisabledRigidbody] = []


func _ready():
	for child in find_children("", "MeshInstance3D", true):
		_meshes.append(child)
		if child.get_meta("no_outline", false) == false:
			var outline = MeshInstance3D.new()
			outline.mesh = child.mesh.create_outline(0.02)
			outline.mesh.surface_set_material(0, outline_material)
			outline.visible = false
			child.add_child(outline)
			_outlines.append(outline)
	
	# add invisible RBs to the disabled list. 
	# maybe there should be some kind of flag for it
	for child in find_children("", "RigidBody3D", true):
		if !child.visible:
			_set_rigidbody_enabled(child, false)


func remove():
	visible = false
	is_removed = true
	emit_signal("removed")
	queue_free()


func on_use(with, backwards = false):
	if !on_use_anim_name.is_empty():
		for child in get_children():
			if child is AnimationPlayer:
				child.stop(false)
				child.play(on_use_anim_name)
	
	if with is Grabbable:
		var with_scene_path = with.scene_file_path
		for inter in interactions:
			if (inter.direction == ObjectInteraction.InteractionType.BACKWARDS) && !backwards:
				continue
			if with_scene_path == inter.other_object.resource_path:
				var current_transform = global_transform if backwards else with.global_transform
				var parent = with.get_parent_node_3d()
				
				if inter.remove_self && inter.remove_other:
					remove()
					with.remove()
				elif inter.remove_self:
					if backwards:
						remove()
					else:
						with.remove()
				
				if inter.resulting_object:
					var new_object = inter.resulting_object.instantiate()
					new_object.global_transform = current_transform
					parent.add_child(new_object)
					if new_object.spawn_particle != null:
						var spawn_particles = new_object.spawn_particle.instantiate()
						new_object.get_parent().add_child(spawn_particles)
						spawn_particles.global_position = new_object.global_position
						spawn_particles.emitting = true
				
				break
		
		for inter in with.interactions:
			if (inter.direction == ObjectInteraction.InteractionType.BOTH_WAYS \
				|| inter.direction == ObjectInteraction.InteractionType.BACKWARDS) \
				&& inter.other_object.resource_path == scene_file_path:
				with.on_use(self, true)
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


func _physics_process(_delta):
	if _snap_target:
		# POSITION
		var pos_snap_vec = _snap_target.global_position - global_position
		linear_velocity = pos_snap_vec * SNAP_SPEED
		
		# ROTATION
		# calculating angular velocity to reach the desired rotation
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


func _set_rigidbody_enabled(rigid_node : RigidBody3D, value : bool):
	var disabled_rb : DisabledRigidbody = null
	for dr in _disabled_rigidbodies:
		if dr.node == rigid_node:
			disabled_rb = dr
			break
	if value:
		assert(disabled_rb != null) # make sure to disable a rigidbody before enabling it
		rigid_node.visible = true
		rigid_node.collision_layer = disabled_rb.collision_layer
		rigid_node.collision_mask = disabled_rb.collision_mask
		rigid_node.position = disabled_rb.position
		rigid_node.rotation = disabled_rb.rotation
		rigid_node.freeze = false
		rigid_node.sleeping = false
		for joint_entry in disabled_rb.connected_joints:
			joint_entry.joint.node_a = joint_entry.node_a
			joint_entry.joint.node_b = joint_entry.node_b
		_disabled_rigidbodies.erase(disabled_rb)
	else:
		assert(disabled_rb == null) # this one's already disabled
		var disableds_entry = DisabledRigidbody.new()
		disableds_entry.node = rigid_node
		disableds_entry.collision_layer = rigid_node.collision_layer
		disableds_entry.collision_mask = rigid_node.collision_mask
		disableds_entry.position = rigid_node.position
		disableds_entry.rotation = rigid_node.rotation
		rigid_node.freeze = true
		rigid_node.sleeping = true
		rigid_node.collision_layer = 0
		rigid_node.collision_mask = 0
		rigid_node.visible = false
		
		for joint in find_children("", "Joint3D", true):
			if joint.node_a == joint.get_path_to(rigid_node) || joint.node_b == joint.get_path_to(rigid_node):
				var new_entry = { 
					joint = joint,
					node_a = joint.node_a,
					node_b = joint.node_b
				}
				disableds_entry.connected_joints.append(new_entry)
				joint.node_a = NodePath()
				joint.node_b = NodePath()
		
		_disabled_rigidbodies.append(disableds_entry)


func _get_display_name():
	return display_name
