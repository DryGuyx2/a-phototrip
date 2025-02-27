extends CharacterBody2D
class_name Player

signal photographed(number, cursed)
signal sleepy
signal escaping

@export var speed: int = 1000
@export var camera: Camera2D
@export var album: Album
@export var intersection: Node2D

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D
@onready var step: AudioStreamPlayer = $Step
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
	immobile = true
	set_collision_layer_value(GlobalData.layers["player_physics"], true)
	set_collision_layer_value(GlobalData.layers["gate"], true)
	set_collision_layer_value(GlobalData.layers["scene_trigger"], true)
	
	set_collision_mask_value(GlobalData.layers["player_physics"], true)
	photo_area.set_collision_mask_value(GlobalData.layers["photo_detection"], true)
	$PhotoArea/MissArea.set_collision_mask_value(GlobalData.layers["photo_detection"], true)
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
			step.play()


func handle_input():
	if immobile:
		return
	if dialoguing:
		return
	if photographing:
		photograph()
		return
	
	if Input.is_action_pressed("move_left"):
		photo_area.global_rotation_degrees = 180
	elif Input.is_action_pressed("move_right"):
		photo_area.global_rotation_degrees = 0
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("album"):
		album.visible = not album.visible
	
	if Input.is_action_just_pressed("equip"):
		$EquipCamera.play()
		equipped_camera = not equipped_camera
		$PhotoArea/Outline.visible = not $PhotoArea/Outline.visible

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
		camera.flash()



func _on_camera_finished_flash():
	if photo_area.get_overlapping_areas().is_empty():
		if not $PhotoArea/MissArea.get_overlapping_areas().is_empty():
			DialogueManager.show_example_dialogue_balloon(main_dialogue, "missed_photo")
			photographing = false
			capturing = false
			return
		DialogueManager.show_example_dialogue_balloon(main_dialogue, "no_photo")
		photographing = false
		capturing = false
		return
	
	var photo_subject = photo_area.get_overlapping_areas()[0]
	photo_subject.photographed()
	emit_signal("photographed", photo_subject.number, photo_subject.cursed)
	var title = "photo_%s" % photo_subject.number
	if photo_subject.cursed:
		print("Curse")
		title = "%s_cursed" % title
	print(photo_subject.cursed)
	await get_tree().create_timer(1).timeout
	DialogueManager.show_example_dialogue_balloon(main_dialogue, title)
	animation_component.play("idle_camera")
	album.add_photo(photo_subject.number, photo_subject.cursed)
	photos_taken += 1
	
	photographing = false
	capturing = false


func immobilize() -> void:
	play_idle()
	immobile = true
	direction = Vector2.ZERO


func _on_camp_sleep():
	slept = true
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
	intersection.explosion.play()


func _on_intersection_ritual_finished():
	triggered_cult = true
	DialogueManager.show_example_dialogue_balloon(main_dialogue, "awoke_from_ritual")
	immobile = false

func _on_dialogue_started(_resource):
	direction = Vector2.ZERO
	dialoguing = true

var slept: bool = false
var triggered_escape: bool = false
var triggered_sleepy: bool = false
var triggered_cult: bool = false
func _on_dialogue_ended(_resource):
	dialoguing = false
	
	if photos_taken == 3 and not triggered_sleepy:
		triggered_sleepy = true
		DialogueManager.show_example_dialogue_balloon(main_dialogue, "sleepy")
		emit_signal("sleepy")
	
	if photos_taken == 6 and not triggered_escape:
		DialogueManager.show_dialogue_balloon(main_dialogue, "escape")
		triggered_escape = true
		emit_signal("escaping")
	
	if triggered_escape:
		camera.change_task("Get to the car and get away")
		return
	
	if triggered_cult:
		camera.change_task("Explore the area and photograph birds: %s/3" % (photos_taken - 3))
		return
	
	if not triggered_cult and slept:
		camera.change_task("Investigate the weird noise")
		return
	
	if triggered_sleepy and photos_taken == 3:
		camera.change_task("Get back to camp and go to sleep")
	
	if not triggered_sleepy:
		camera.change_task("Explore the area and photograph birds: %s/3" % photos_taken)
		return


func _on_start_menu_game_started():
	immobile = false
	DialogueManager.show_example_dialogue_balloon(main_dialogue, "start_0")


func _on_interaction_zone_area_entered(_area):
	camera.toggle_interaction(true)


func _on_interaction_zone_area_exited(_area):
	camera.toggle_interaction(false)
