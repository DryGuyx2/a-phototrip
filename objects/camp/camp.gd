extends StaticBody2D

signal sleep

func _ready() -> void:
	$InteractionPoint.set_collision_layer_value(GlobalData.layers["interaction"], true)

func interact() -> void:
	emit_signal("sleep")
