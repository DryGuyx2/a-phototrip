extends Camera2D
class_name Camera

signal finished_flash
signal awoke

@export var flash_speed: float
@export var sleep_speed: float

@onready var flash_sprite = $Flash
@onready var sleep_sprite = $Sleep
@onready var night_sprite = $Night
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func flash() -> void:
	audio_player.play()
	var flash_tween = create_tween()
	flash_tween.tween_property(flash_sprite, "modulate:a", 1, flash_speed / 2).set_trans(Tween.TRANS_EXPO)
	flash_tween.play()
	flash_tween.tween_callback(deflash)


func deflash() -> void:
	var flash_tween = create_tween()
	flash_tween.tween_property(flash_sprite, "modulate:a", 0, flash_speed / 2).set_trans(Tween.TRANS_EXPO)
	flash_tween.play()
	flash_tween.tween_callback(finish)


func finish() -> void:
	emit_signal("finished_flash")


func _on_camp_sleep() -> void:
	var sleep_tween = create_tween()
	sleep_tween.tween_property(sleep_sprite, "modulate:a", 1, sleep_speed / 3).set_trans(Tween.TRANS_LINEAR)
	sleep_tween.play()
	sleep_tween.tween_callback(wake)
	night_sprite.modulate += 0.2


func wake() -> void:
	await get_tree().create_timer(sleep_speed / 3).timeout
	var wake_tween = create_tween()
	wake_tween.tween_property(sleep_sprite, "modulate:a", 0, sleep_speed / 3).set_trans(Tween.TRANS_LINEAR)
	wake_tween.play()
	wake_tween.tween_callback(emit_wake)


func emit_wake() -> void:
	emit_signal("awoke")


func _on_player_photographed():
	var night_tween = create_tween()
	night_tween.tween_property(sleep_sprite, "modulate:a", sleep_sprite.modulate.a + 0.2, 10).set_trans(Tween.TRANS_LINEAR)
