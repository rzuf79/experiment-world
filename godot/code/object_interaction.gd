class_name ObjectInteraction
extends Resource

enum InteractionType { ONE_WAY, BOTH_WAYS, BACKWARDS }

@export var disabled : bool = false
@export var other_object : PackedScene
@export var resulting_object : PackedScene
@export var direction : InteractionType = InteractionType.BOTH_WAYS
@export var remove_self : bool = true
@export var remove_other : bool = true
@export var disable_interaction_after_use : bool = true
@export var callable : String = ""
