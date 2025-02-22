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

@onready var normal_photos = [$PhotoDisplay/Normal1, $PhotoDisplay/Normal2, $PhotoDisplay/Normal3]
@onready var cursed_photos = [$PhotoDisplay/Cursed1, $PhotoDisplay/Cursed2, $PhotoDisplay/Cursed3]


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

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
	night_sprite.modulate.a += 0.2


func wake() -> void:
	await get_tree().create_timer(sleep_speed / 3).timeout
	var wake_tween = create_tween()
	wake_tween.tween_property(sleep_sprite, "modulate:a", 0, sleep_speed / 3).set_trans(Tween.TRANS_LINEAR)
	wake_tween.play()
	wake_tween.tween_callback(emit_wake)


func emit_wake() -> void:
	emit_signal("awoke")


func remove_photo() -> void:
	var photo_slide_tween = create_tween()
	photo_slide_tween.tween_property(photo, "position:y", 632/6, 1).set_trans(Tween.TRANS_LINEAR)
	photo_slide_tween.play()
	showing_photo = false

var showing_photo: bool = false
var photo: Sprite2D
func _on_player_photographed(number, cursed):
	if cursed:
		photo = cursed_photos[number]
	else:
		photo = normal_photos[number]
	photo.position = Vector2(0, 632/6)
	photo.visible = true
	showing_photo = true
	var photo_slide_tween = create_tween()
	photo_slide_tween.tween_property(photo, "global_position", global_position, 1).set_trans(Tween.TRANS_QUAD)
	photo_slide_tween.play()
	
	var night_tween = create_tween()
	night_tween.tween_property(night_sprite, "modulate:a", night_sprite.modulate.a + 0.2, 10).set_trans(Tween.TRANS_LINEAR)


func _on_intersection_ritual_finished():
	night_sprite.modulate.a = 0
	sleep_sprite.modulate.a = 0


func _on_dialogue_ended(_resource: DialogueResource):
	if showing_photo:
		remove_photo()


func _on_car_car_exploded():
	var end_screen_tween = create_tween()
	end_screen_tween.tween_property($EndScreen, "modulate:a", 1, 3).set_trans(Tween.TRANS_LINEAR)
