extends Sprite2D

@onready var above_point: Node2D = $AbovePoint
@onready var player = get_parent().get_parent().find_child("Player")
func _process(delta: float) -> void:
	if is_instance_valid(player):
		if player.global_position.y > above_point.global_position.y:
			z_index = 2
		else:
			z_index = 1
