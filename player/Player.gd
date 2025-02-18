extends CharacterBody2D
class_name Player

@export var speed: int = 1000

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D
@onready var photo_area: Area2D = $PhotoArea

var equipped_camera: bool = false
var photographing: bool = false
var viewing: bool = false
var direction: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	handle_input()
	handle_animations()
	
	if not photographing and not viewing:
		position += direction * speed * delta
	move_and_slide()

func handle_input() -> void:
	if viewing:
		return
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("equip"):
		equipped_camera = not equipped_camera
	
	if Input.is_action_just_pressed("interact"):
		photograph()

func handle_animations() -> void:
	if direction.x == 1:
		animation_component.flip_h = false
	elif direction.x == -1:
		animation_component.flip_h = true
	
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

func photograph() -> void:
	if equipped_camera and not viewing:
		if photo_area.get_overlapping_areas().is_empty():
			return
		var photo_subject = photo_area.get_overlapping_areas()[0]
		viewing = true
		animation_component.play("idle_camera")
