extends Node2D

signal ritual_finished

@onready var cultists = [$Cultists/Cultist1, 
$Cultists/Cultist2, 
$Cultists/Cultist3,
$Cultists/Cultist4,
$Cultists/Cultist5,
$Cultists/Cultist6]

@export var portal: Node2D
@export var hiding_spot: Node2D
@onready var explosion = $Cultists/Explosion

func _ready() -> void:
	print("Portal position: ", portal.global_position)
	print("Intersection posistion: ", self.global_position)
	for cultist in cultists:
		cultist.play("default")

var performing = false

func _on_camp_sleep():
	$Cultists.visible = true
	performing = true
	await get_tree().create_timer(1).timeout
	$Cultists/Ritual.play()


func _on_audio_stream_player_finished():
	if performing:
		$Cultists/Ritual.play()


func _on_cult_scene_trigger_triggered_scene() -> void:
	$Cultists/AudioStreamPlayer.volume_db = 20
	portal.play("active")


func _on_portal_animation_finished() -> void:
	if portal.animation == "active":
		portal.find_child("Explosion").visible = true
		var explosion_tween = create_tween()
		explosion_tween.tween_property(portal.find_child("Explosion"), "scale", Vector2(32, 32), 0.2).set_trans(Tween.TRANS_EXPO)
		explosion_tween.tween_callback(finish_ritual)

func finish_ritual() -> void:
	await get_tree().create_timer(3).timeout
	portal.play("inactive")
	$Cultists.visible = false
	$Cultists/Ritual.stop()
	var explosion_tween = create_tween()
	explosion_tween.tween_property(portal.find_child("Explosion"), "modulate:a", 0, 1).set_trans(Tween.TRANS_LINEAR)
	emit_signal("ritual_finished")
