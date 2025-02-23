extends Sprite2D

@onready var above_point: Node2D = $AbovePoint

func _process(delta: float) -> void:
	if get_parent().get_parent().find_child("Player").global_position.y > above_point.global_position.y:
		z_index = 2
	else:
		z_index = 1
