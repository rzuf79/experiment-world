extends Control

@onready var _label_fps : Label = $LabelFPS
@onready var _focused_object_label : Label = $LabelFocusedObject


func _ready():
	pass


func _process(_delta):
	_label_fps.text = "FPS: " + str(Engine.get_frames_per_second())


func set_focused_object(object):
	if object == null:
		_focused_object_label.text = ""
	else:
		_focused_object_label.text = object.display_name
