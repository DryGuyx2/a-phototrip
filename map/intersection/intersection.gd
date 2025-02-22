extends Node2D

signal ritual_finished

@onready var cultists = [$Cultists/Cultist1, 
$Cultists/Cultist2, 
$Cultists/Cultist3,
$Cultists/Cultist4,
$Cultists/Cultist5,
$Cultists/Cultist6]

@export var portal: Node2D
@onready var hiding_spot = $HidingSpot
@onready var explosion = $Cultists/Explosion

func _ready() -> void:
	print("Portal position: ", portal.global_position)
	print("Intersection posistion: ", self.global_position)
	for cultist in cultists:
		cultist.play("default")

var performing = false

func _process(delta):
	if Input.is_action_just_pressed("test_3"):
		emit_signal("ritual_finished")

func _on_camp_sleep():
	$Cultists.visible = true
	performing = true
	await get_tree().create_timer(1).timeout
	$Cultists/Ritual.play()


func _on_audio_stream_player_finished():
	if performing:
		$Cultists/Ritual.play()


func _on_cult_scene_trigger_triggered_scene() -> void:
	print("Increased volume")
	$Cultists/AudioStreamPlayer.volume_db = 20


func _on_portal_animation_finished() -> void:
	if portal.animation == "active":
		$Portal/Explosion.visible = true
		var explosion_tween = create_tween()
		explosion_tween.tween_property($Portal/Explosion, "scale", Vector2(32, 32), 0.2).set_trans(Tween.TRANS_EXPO)
		explosion_tween.tween_callback(finish_ritual)

func finish_ritual() -> void:
	await get_tree().create_timer(3).timeout
	portal.play("inactive")
	$Cultists.visible = false
	$Cultists/Ritual.stop()
	var explosion_tween = create_tween()
	explosion_tween.tween_property($Portal/Explosion, "modulate:a", 0, 1).set_trans(Tween.TRANS_LINEAR)
	emit_signal("ritual_finished")
