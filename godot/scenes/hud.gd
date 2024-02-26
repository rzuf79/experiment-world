extends Control


@onready var _focused_object_label : Label = $LabelFocusedObject


func _ready():
	pass


func set_focused_object(object):
	if object == null:
		_focused_object_label.text = ""
	else:
		_focused_object_label.text = object.display_name
