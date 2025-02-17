extends CharacterBody2D

@export var speed: int = 1000

var animation_component: AnimatedSprite2D
e
func _ready():
	animation_component = $AnimatedSprite2D

func _process(delta: float):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction.x == 1:
		animation_component.flip_h = false
	elif input_direction.x == -1:
		animation_component.flip_h = true
	
	if input_direction.x == 0 and input_direction.y == 0:
		animation_component.play("idle")
	else:
		animation_component.play("moving")
	
	
	position += input_direction * speed * delta
	move_and_slide()
