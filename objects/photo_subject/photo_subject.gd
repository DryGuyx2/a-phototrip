extends Area2D
class_name PhotoSubject

@export var sprite: CanvasItem
@export var image_path: String
@export var detection_layer: int

func _ready() -> void:
	set_collision_layer_value(detection_layer, true)
	if sprite is AnimatedSprite2D:
		sprite.play("default")

func get_image_path() -> String:
	return image_path
