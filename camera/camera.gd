extends Camera2D
class_name Camera

signal finished_flash

@export var flash_speed: float
@onready var flash_sprite = $Flash
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _process(delta):
	if Input.is_action_just_pressed("test_1"):
		flash()

func flash() -> void:
	audio_player.play()
	var flash_tween = create_tween()
	flash_tween.tween_property(flash_sprite, "modulate:a", 1, flash_speed / 2).set_trans(Tween.TRANS_EXPO)
	flash_tween.play()
	flash_tween.tween_callback(deflash)

func deflash():
	var flash_tween = create_tween()
	flash_tween.tween_property(flash_sprite, "modulate:a", 0, flash_speed / 2).set_trans(Tween.TRANS_EXPO)
	flash_tween.play()
	flash_tween.tween_callback(finish)

func finish():
	emit_signal("finished_flash")
