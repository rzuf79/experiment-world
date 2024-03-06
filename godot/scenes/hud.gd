extends Control

@onready var _label_fps : Label = $LabelFPS
@onready var _focused_object_label : Label = $LabelFocusedObject
@onready var _label_use : Label = $LabelUse

var _focused_object = null
var _grabbed_object = null


func _process(_delta):
	if _label_fps.visible:
		_label_fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
	if _focused_object:
		_focused_object_label.text = _focused_object.display_name
	if _grabbed_object:
		_label_use.visible = _grabbed_object.usable


func set_focused_object(object):
	if object == null:
		if _focused_object:
			_focused_object.disconnect("removed", _on_focused_object_removed)
		_focused_object_label.text = ""
	else:
		object.connect("removed", _on_focused_object_removed)
	
	_focused_object = object


func set_grabbed_object(object):
	if object == null:
		if _grabbed_object:
			_grabbed_object.disconnect("removed", _on_grabbed_object_removed)
		_label_use.visible = false
	else:
		object.connect("removed", _on_grabbed_object_removed)
	
	_grabbed_object = object


func _on_focused_object_removed():
	set_focused_object(null)


func _on_grabbed_object_removed():
	set_grabbed_object(null)
