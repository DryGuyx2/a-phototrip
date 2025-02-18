extends Area2D
class_name Gate

@export var detection_mask: int
@export var exit_point: Node2D
@export var camera_position: Node2D

@export var camera: Camera2D

# REMEMBER: Connect on exit body entered signal to itself

func _ready() -> void:
	set_collision_mask_value(detection_mask, true)

func _on_body_entered(body) -> void:
	body.global_position = exit_point.position
	camera.global_position = camera_position.position
