extends Area2D

var triggered: bool = false

func _ready() -> void:
	set_collision_mask_value(GlobalData.layers["scene_trigger"], true)

func _on_body_entered(_body):
	if not triggered:
		set_collision_layer_value(GlobalData.layers["scene_trigger"], false)
		triggered = true
		DialogueManager.show_example_dialogue_balloon(load("res://player/dialogue/main.dialogue"), "portal")
