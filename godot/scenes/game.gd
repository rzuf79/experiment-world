extends Node3D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event : InputEvent):
	var captured =  Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseButton:
		if !captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	
