extends CharacterBody2D
class_name Player

signal photographed
signal sleepy

@export var speed: int = 1000
@export var camera: Camera2D
@export var album: Album
@export var intersection: Node2D

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer = $Step
@onready var photo_area: Area2D = $PhotoArea
@onready var interaction_zone = $InteractionZone

var dialoguing = false
var main_dialogue = preload("res://player/dialogue/main.dialogue")
var equipped_camera: bool = false
var photographing: bool = false
var direction: Vector2 = Vector2.ZERO
var immobile: bool = false
var cursed = false
var photos_taken = 0

func _ready() -> void:
	set_collision_layer_value(GlobalData.layers["player_physics"], true)
	set_collision_layer_value(GlobalData.layers["gate"], true)
	set_collision_layer_value(GlobalData.layers["scene_trigger"], true)
	
	set_collision_mask_value(GlobalData.layers["player_physics"], true)
	photo_area.set_collision_mask_value(GlobalData.layers["photo_detection"], true)
	interaction_zone.set_collision_mask_value(GlobalData.layers["interaction"], true)
	
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _process(delta: float) -> void:
	handle_input()
	handle_animations()
	handle_sound()
	
	if not photographing and not immobile:
		position += direction * speed * delta
	move_and_slide()


func handle_sound():
	if animation_component.animation == "moving" or animation_component.animation =="moving_camera":
		if animation_component.frame == 1:
			audio_player.play()


func handle_input():
	if immobile:
		return
	if dialoguing:
		return
	if photographing:
		photograph()
		return
	
	if Input.is_action_pressed("move_up"):
		photo_area.global_rotation_degrees = -90
	elif Input.is_action_pressed("move_down"):
		photo_area.global_rotation_degrees = 90
	elif Input.is_action_pressed("move_left"):
		photo_area.global_rotation_degrees = 180
	elif Input.is_action_pressed("move_right"):
		photo_area.global_rotation_degrees = 0
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("album"):
		album.visible = not album.visible
	
	if Input.is_action_just_pressed("equip"):
		equipped_camera = not equipped_camera

func _unhandled_input(event) -> void:
	if immobile:
		return
	if event.is_action_pressed("interact") and not equipped_camera:
		interact()
		return
	if event.is_action_pressed("interact") and equipped_camera:
		photographing = true
		return


func handle_animations() -> void:
	if immobile:
		return
	if capturing:
		return
	if direction.x > 0:
		animation_component.flip_h = false
	elif direction.x < 0:
		animation_component.flip_h = true
	
	if direction.x == 0 and direction.y == 0:
		play_idle()
	else:
		play_moving()


func play_moving() -> void:
	if equipped_camera:
			animation_component.play("moving_camera")
			return
	else:
		animation_component.play("moving")


func play_idle() -> void:
	if equipped_camera:
			animation_component.play("idle_camera")
			return
	else:
		animation_component.play("idle")


func interact():
	if interaction_zone.get_overlapping_areas().is_empty():
		return
	
	immobilize()
	var interactable = interaction_zone.get_overlapping_areas()[0]
	interactable.get_parent().interact()


var capturing = false
func photograph() -> void:
	if not capturing:
		capturing = true
		animation_component.play("photographing")


func _on_animated_sprite_2d_animation_finished():
	if animation_component.animation == "photographing":
		print("Flashing")
		camera.flash()
	else:
		print("Not flashing")


func _on_camera_finished_flash():
	if photo_area.get_overlapping_areas().is_empty():
		DialogueManager.show_example_dialogue_balloon(main_dialogue, "no_photo")
		photographing = false
		capturing = false
		return
	
	var photo_subject = photo_area.get_overlapping_areas()[0]
	photo_subject.photographed()
	emit_signal("photographed")
	var title = "photo_%s" % photo_subject.number
	if photo_subject.cursed:
		print("Curse")
		title = "%s_cursed" % title
	print(photo_subject.cursed)
	DialogueManager.show_example_dialogue_balloon(main_dialogue, title)
	animation_component.play("idle_camera")
	album.add_photo(photo_subject.number, photo_subject.cursed)
	photos_taken += 1
	if photos_taken == 3:
		DialogueManager.show_example_dialogue_balloon(main_dialogue, "sleepy")
		emit_signal("sleepy")
	
	photographing = false
	capturing = false


func immobilize() -> void:
	play_idle()
	immobile = true
	direction = Vector2.ZERO


func _on_camp_sleep():
	immobilize()


func _on_camera_awoke():
	DialogueManager.show_example_dialogue_balloon(main_dialogue, "sleep_complaint")
	immobile = false


func _on_cult_scene_trigger_triggered_scene():
	immobilize()
	play_idle()
	await get_tree().create_timer(1).timeout
	DialogueManager.show_example_dialogue_balloon(main_dialogue, "spotted_cult")
	await get_tree().create_timer(1).timeout
	play_moving()
	var hide_tween = create_tween()
	hide_tween.tween_property(self, "position", intersection.hiding_spot.global_position, 3)
	hide_tween.tween_callback(finish_walking)


func finish_walking() -> void:
	play_idle()
	intersection.portal.play("active")


func _on_intersection_ritual_finished():
	DialogueManager.show_example_dialogue_balloon(main_dialogue, "awoke_from_ritual")
	await get_tree().create_timer(0.1)
	immobile = false

func _on_dialogue_started(_resource):
	direction = Vector2.ZERO
	dialoguing = true

func _on_dialogue_ended(_resource):
	dialoguing = false
