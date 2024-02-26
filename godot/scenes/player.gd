extends CharacterBody3D

const SPEED = 5.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENSITIVITY = 50.0

signal focused_object_changed(object)

@onready var _camera = $Camera3D
@onready var _mesh = $MeshInstance3D
@onready var _head_raycast = $Camera3D/RayCast3D
@onready var _hand_marker = $Camera3D/HandMarker

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _look_dir := Vector2.ZERO

var _hand_object : Grabbable
var _focused_object = null


func _ready():
	pass
	_mesh.visible = false


func _physics_process(delta):
	# GRAVITY
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# JUMP
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# MOVEMENT
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = RUN_SPEED if Input.is_action_pressed("run") else SPEED
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	_rotate_camera(delta)
	move_and_slide()
	
	# RAYCASTING STUFF
	var collider = _head_raycast.get_collider()
	if _focused_object && _focused_object != collider:
		_focused_object.set_outline_enabled(false)
		_focused_object.disconnect("removed", _on_focused_object_removed)
		_focused_object = null
		emit_signal("focused_object_changed", null)
	if collider:
		var current_focused_object = null
		if collider is Grabbable:
			current_focused_object = collider
		elif collider is Area3D && collider.is_in_group(Consts.GROUP_NAME_PICK_AREAS):
			current_focused_object = collider.get_parent()
		
		if current_focused_object.is_removed:
			current_focused_object = null
		
		if current_focused_object && current_focused_object != _focused_object:
			_focused_object = current_focused_object
			_focused_object.connect("removed", _on_focused_object_removed)
			_focused_object.set_outline_enabled(true)
			emit_signal("focused_object_changed", _focused_object)


func _input(event : InputEvent):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look_dir = event.relative * 0.01
	
	if event.is_action_pressed("interact"):
		if _hand_object:
			_hand_object.on_use(_focused_object)
		else:
			if _focused_object:
				grab(_focused_object)
	
	if event.is_action_pressed("drop"):
		drop()


func grab(object : Grabbable):
	drop() # if any
	_hand_object = object
	_hand_object.set_snap_target(_hand_marker)
	_hand_object.set_raycast_exclude(_head_raycast, true)


func drop():
	if _hand_object:
		_hand_object.set_snap_target(null)
		_hand_object.set_raycast_exclude(_head_raycast, false)
		_hand_object = null


func _rotate_camera(delta : float, sensitivity_mod : float = 1.0):
	#var input = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	#_look_dir += input
	rotation.y -= _look_dir.x * CAMERA_SENSITIVITY * delta
	var new_rot = _camera.rotation.x - _look_dir.y * CAMERA_SENSITIVITY * sensitivity_mod * delta
	_camera.rotation.x = clamp(new_rot, -PI/2, PI/2)
	_look_dir = Vector2.ZERO


func _on_focused_object_removed():
	_focused_object = null
