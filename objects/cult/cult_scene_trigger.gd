extends Area2D

signal triggered_scene

var player_slept = false

func _ready() -> void:
	set_collision_mask_value(GlobalData.layers["scene_trigger"], true)

func _on_body_entered(body):
	if player_slept:
		emit_signal("triggered_scene")

func _on_camp_sleep():
	player_slept = true
