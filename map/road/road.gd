extends Node2D

@export var car: Car
@onready var tree_fall_trigger_point: Node2D = $AnimatedSprite2D/TreeFallTriggerPoint

func _ready() -> void:
	$AnimatedSprite2D.play("standing")

var tree_fallen: bool = false
func _process(delta: float) -> void:
	if car.global_position.x >= tree_fall_trigger_point.global_position.x and not tree_fallen:
		tree_fallen = true
		$AnimatedSprite2D.play("falling")
