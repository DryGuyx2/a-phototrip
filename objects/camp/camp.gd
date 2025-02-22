extends StaticBody2D

signal sleep

var slept: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$InteractionPoint.set_collision_layer_value(GlobalData.layers["interaction"], false)

func interact() -> void:
	if not slept:
		slept = true
		$InteractionPoint.set_collision_layer_value(GlobalData.layers["interaction"], false)
		emit_signal("sleep")


func _on_player_sleepy():
	$InteractionPoint.set_collision_layer_value(GlobalData.layers["interaction"], true)
