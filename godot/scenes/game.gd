extends Node3D


@onready var _player = $Player
@onready var _hud = $CanvasLayer/HUD

func _ready():
	_player.connect("focused_object_changed", _hud.set_focused_object)
	_player.connect("grabbed_object_changed", _hud.set_grabbed_object)


func _input(event : InputEvent):
	var captured =  Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseButton:
		if !captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	
