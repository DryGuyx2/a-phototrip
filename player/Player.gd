extends CharacterBody2D
class_name Player

@export var speed: int = 1000
@export var camera: Camera2D 

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D
@onready var  audio_player: AudioStreamPlayer = $Step
@onready var photo_area: Area2D = $Pivot/PhotoArea
@onready var pivot: Node2D = $Pivot

var equipped_camera: bool = false
var photographing: bool = false
var direction: Vector2 = Vector2.ZERO
var immobile: bool = false

func _ready() -> void:
	set_collision_layer_value(GlobalData.layers["player_physics"], true)
	set_collision_layer_value(GlobalData.layers["gate"], true)
	
	set_collision_mask_value(GlobalData.layers["player_physics"], true)
	photo_area.set_collision_mask_value(GlobalData.layers["photo_detection"], true)

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
	
	if Input.is_action_just_pressed("equip"):
		equipped_camera = not equipped_camera

func _unhandled_input(event) -> void:
	if immobile:
		return
	if event.is_action_pressed("interact") and equipped_camera:
		photographing = true

func handle_animations() -> void:
	if direction.x == 1:
		animation_component.flip_h = false
		pivot.scale.x = 1
	elif direction.x == -1:
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
	DialogueManager.show_example_dialogue_balloon(load("res://player/dialogue/photo.dialogue"), "photo")
	animation_component.play("idle_camera")
	photographing = false
	capturing = false
