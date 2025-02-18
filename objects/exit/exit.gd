extends Area2D
class_name Exit

@export var detection_mask: int
@export var entrance: Node2D
@export var entrance_camera_position: Node2D

var camera: Camera2D

# REMEMBER: Connect on exit body entered signal to itself

func _ready() -> void:
	set_collision_mask_value(detection_mask, true)

func _on_body_entered(body) -> void:
	body.global_position = entrance.position
	camera.global_position = entrance_camera_position.position
