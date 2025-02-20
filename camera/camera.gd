extends Camera2D
class_name Camera

signal finished_flash
signal awoke

@export var flash_speed: float
@export var sleep_speed: float

@onready var flash_sprite = $Flash
@onready var sleep_sprite = $Sleep
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
	var flash_tween = create_tween()
	flash_tween.tween_property(sleep_sprite, "modulate:a", 1, sleep_speed / 2).set_trans(Tween.TRANS_LINEAR)
	flash_tween.play()
	flash_tween.tween_callback(wake)

func wake() -> void:
	var flash_tween = create_tween()
	flash_tween.tween_property(sleep_sprite, "modulate:a", 0, sleep_speed / 2).set_trans(Tween.TRANS_LINEAR)
	flash_tween.play()
	flash_tween.tween_callback(emit_wake)

func emit_wake() -> void:
	emit_signal("awoke")
