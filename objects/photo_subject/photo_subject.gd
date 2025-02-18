extends StaticBody2D
class_name PhotoSubject

# IMPORTANT: Set player photo area to be same mask as subject layer

@export var image_path: String
@export var sprite: CanvasItem
@export var detection_point: Area2D

func _ready() -> void:
	if sprite is AnimatedSprite2D:
		sprite.play("default")

func get_image_path() -> String:
	return image_path
