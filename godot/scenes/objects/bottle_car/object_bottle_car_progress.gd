extends Grabbable

enum { STATE_NONE, STATE_PROGRESS, STATE_FINISHED }

const ANIM_NAME_INFLATE = "inflate"
const ANIM_NAME_DEFLATE = "deflate"

@export var axle_scene : PackedScene
@export var straw_scene : PackedScene
@export var balloon_scene : PackedScene

@onready var _axle1 = $RigidBodyAxle1
@onready var _axle2 = $RigidBodyAxle2
@onready var _straw = $PlasticStraw
@onready var _balloon = $BalloonAnim

@onready var _exhaust = $Exhaust
@onready var _exhaust_particles = $ExhaustParticles
@onready var _bottle_shaker = $Bottle/ParentShaker3D
@onready var _straw_shaker = $PlasticStraw/ParentShaker3D
@onready var _balloon_anim = $AnimationPlayer
@onready var _pieces = [ _axle1, _axle2, _straw, _balloon ]


func on_use(with, backwards = false):
	if _get_state() == STATE_FINISHED:
		emit_signal("request_drop")
		_balloon_anim.play(ANIM_NAME_INFLATE)
		
		return
	
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


func _process(_delta):
	var rolling = _is_rolling()
	_exhaust_particles.emitting = rolling
	_bottle_shaker.shaking = rolling
	_straw_shaker.shaking = rolling


func _physics_process(delta):
	super._physics_process(delta)
	if _is_rolling():
		apply_force(-transform.basis.z * 10, _exhaust.position)


func _get_display_name():
	match _get_state():
		STATE_PROGRESS: return "Bottle car (unfinished)"
		STATE_FINISHED: return "Bottle car"
	return "Bottle"


func _get_usable():
	return _get_state() == STATE_FINISHED


func _is_rolling():
	return _balloon_anim.is_playing() && _balloon_anim.current_animation == ANIM_NAME_DEFLATE


func _get_state():
	var pieces_count = 0
	for piece in _pieces:
		if piece.visible:
			pieces_count += 1
	if pieces_count == _pieces.size():
		return STATE_FINISHED
	elif pieces_count > 0:
		return STATE_PROGRESS
	return STATE_NONE


func _on_animation_player_animation_finished(anim_name):
	if anim_name == ANIM_NAME_INFLATE:
		_balloon_anim.play(ANIM_NAME_DEFLATE)
