extends StaticBody2D

signal sleep

var slept: bool = false

func _ready() -> void:
	$InteractionPoint.set_collision_layer_value(GlobalData.layers["interaction"], true)

func interact() -> void:
	if not slept:
		slept = true
		emit_signal("sleep")
