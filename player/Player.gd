extends CharacterBody2D

@export var speed: int = 1000

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D

var equipped_camera: bool = false
var photographing: bool = false
var direction: Vector2 = Vector2.ZERO

func _process(delta: float):
	handle_input()
	handle_animations()
	
	if not photographing:
		position += direction * speed * delta
	move_and_slide()

func handle_input():
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("equip"):
		equipped_camera = not equipped_camera
	
	if Input.is_action_just_pressed("interact"):
		photograph()

func handle_animations():
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

func photograph():
	if equipped_camera:
		photographing = true
		print("Photographing...")
		photographing = false
