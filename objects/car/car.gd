extends Node2D
class_name Car

signal car_started
signal car_exited_parking_spot
signal car_exploded

@export var car_entry: Node2D
@export var explosion_point: Node2D
@export var player: Player
@export var camera: Camera

var interactable = false

@onready var camera_position: Node2D = $CameraPosition


func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	$InteractionPoint.set_collision_layer_value(GlobalData.layers["interaction"], false)


func interact() -> void:
	player.queue_free()
	if not interactable:
		return
	emit_signal("car_started")
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.play("driving")
	
	$Driving.play()
	var drive_tween = create_tween()
	drive_tween.tween_property(self, "global_position:x", 3635, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	drive_tween.tween_callback(exit_parking_spot)


func exit_parking_spot() -> void:
	global_position = car_entry.global_position
	camera.get_parent().remove_child(camera)
	$CameraPosition.add_child(camera)
	camera.global_position = global_position
	camera.global_scale = camera.initial_scale
	emit_signal("car_exited_parking_spot")
	exit_road()


func exit_road() -> void:
	DialogueManager.show_example_dialogue_balloon(load("res://player/dialogue/main.dialogue"), "driving_away")
	$AnimatedSprite2D.play("driving")
	var drive_tween = create_tween()
	drive_tween.tween_property(self, "global_position:x", explosion_point.global_position.x, 3)
	drive_tween.tween_callback(explode)


func explode() -> void:
	$Driving.stop()
	$Explosion.play()
	$AnimatedSprite2D.play("exploding")
	emit_signal("car_exploded")
	await get_tree().create_timer(0.17).timeout
	$Burning.play()


func _on_player_escaping():
	$InteractionPoint.set_collision_layer_value(GlobalData.layers["interaction"], true)
	interactable = true
