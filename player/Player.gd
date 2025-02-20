extends CharacterBody2D
class_name Player

@export var speed: int = 1000
@export var camera: Camera2D
@export var album: Album

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D
@onready var  audio_player: AudioStreamPlayer = $Step
@onready var photo_area: Area2D = $Pivot/PhotoArea
@onready var pivot: Node2D = $Pivot
@onready var interaction_zone = $InteractionZone

var equipped_camera: bool = false
var photographing: bool = false
var direction: Vector2 = Vector2.ZERO
var immobile: bool = false

func _ready() -> void:
	set_collision_layer_value(GlobalData.layers["player_physics"], true)
	set_collision_layer_value(GlobalData.layers["gate"], true)
	
	set_collision_mask_value(GlobalData.layers["player_physics"], true)
	photo_area.set_collision_mask_value(GlobalData.layers["photo_detection"], true)
	interaction_zone.set_collision_mask_value(GlobalData.layers["interaction"], true)

func _process(delta: float) -> void:
	handle_input()
	handle_animations()
	handle_sound()
	
	if not photographing:
		position += direction * speed * delta
	move_and_slide()

func handle_sound():
	if animation_component.animation == "moving" or animation_component.animation =="moving_camera":
		if animation_component.frame == 1:
			audio_player.play()

func handle_input():
	if immobile:
		return
	if photographing:
		photograph()
		return
	
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
	if direction.x > 0:
		animation_component.flip_h = false
		pivot.scale.x = 1
	elif direction.x < 0:
		animation_component.flip_h = true
		pivot.scale.x = -1
	
	if direction.x == 0 and direction.y == 0:
		if equipped_camera:
			animation_component.play("idle_camera")
			return
		animation_component.play("idle")
	else:
		if equipped_camera:
			animation_component.play("moving_camera")
			return
		animation_component.play("moving")

func interact():
	if interaction_zone.get_overlapping_areas().is_empty():
		return
	
	var interactable = interaction_zone.get_overlapping_areas()[0]
	interactable.get_parent().interact()


var capturing = false
func photograph() -> void:
	if not capturing:
		capturing = true
		camera.flash()

func _on_camera_finished_flash():
	if photo_area.get_overlapping_areas().is_empty():
		DialogueManager.show_example_dialogue_balloon(load("res://player/dialogue/photo.dialogue"), "no_photo")
		photographing = false
		capturing = false
		return
	
	var photo_subject = photo_area.get_overlapping_areas()[0]
	photo_subject.photographed()
	DialogueManager.show_example_dialogue_balloon(load("res://player/dialogue/main.dialogue"), "photo_%s" % photo_subject.number)
	animation_component.play("idle_camera")
	album.add_photo(photo_subject.number)
	photographing = false
	capturing = false


func _on_camp_sleep():
	immobile = true


func _on_camera_awoke():
	DialogueManager.show_example_dialogue_balloon(load("res://player/dialogue/main.dialogue"), "sleep_complaint")
	immobile = false
