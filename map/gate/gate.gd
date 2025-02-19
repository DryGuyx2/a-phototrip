extends Area2D
class_name Gate

@export var exit_point: Node2D
@export var camera_position: Node2D

@onready var camera: Camera2D = get_parent().get_parent().find_child("Camera")

# REMEMBER: Connect on exit body entered signal to itself

func _ready() -> void:
	set_collision_mask_value(GlobalData.layers["gate"], true)

func _on_body_entered(body) -> void:
	body.global_position = exit_point.global_position
	camera.global_position = camera_position.global_position
