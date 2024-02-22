extends CharacterBody3D

const SPEED = 5.0
const RUN_SPEED = 10.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENSITIVITY = 50.0

@onready var _camera = $Camera3D
@onready var _mesh = $MeshInstance3D
@onready var _head_raycast = $Camera3D/RayCast3D
@onready var _hand_marker = $Camera3D/HandMarker

var _gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var _look_dir := Vector2.ZERO

var _hand_object : Grabbable


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


func _input(event : InputEvent):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_look_dir = event.relative * 0.01
	
	if event.is_action_pressed("interact"):
		if !_hand_object:
			var collider = _head_raycast.get_collider()
			if collider && collider is Grabbable:
				_hand_object = collider
				_hand_object.set_snap_target(_hand_marker)
	
	if event.is_action_pressed("drop"):
		if _hand_object:
			_hand_object.set_snap_target(null)
			_hand_object = null


func _rotate_camera(delta : float, sensitivity_mod : float = 1.0):
	#var input = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	#_look_dir += input
	rotation.y -= _look_dir.x * CAMERA_SENSITIVITY * delta
	var new_rot = _camera.rotation.x - _look_dir.y * CAMERA_SENSITIVITY * sensitivity_mod * delta
	_camera.rotation.x = clamp(new_rot, -PI/2, PI/2)
	_look_dir = Vector2.ZERO
