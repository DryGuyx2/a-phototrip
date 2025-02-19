extends Area2D
class_name Bird

@export var type: String

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D

var idle_time_left: float = randf_range(3.0, 6.0)

func _ready():
	set_collision_layer_value(GlobalData.layers["photo_detection"], true)


func _process(delta: float):
	if idle_time_left > 0:
		idle_time_left -= delta
		return
	
	animation_component.play("acting_%s" % type)
	idle_time_left = 10


func _on_animated_sprite_2d_animation_finished():
	if animation_component.animation == "acting_%s" % type:
		animation_component.play("default_%s" % type)
		idle_time_left = randf_range(3.0, 10.0)
