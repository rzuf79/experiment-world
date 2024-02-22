extends GPUParticles3D


func _ready():
	connect("finished", _on_finished)


func _on_finished():
	queue_free()
