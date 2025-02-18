extends PhotoSubject
class_name Bird

var idle_time_left: float = randf_range(3.0, 6.0)

func _process(delta: float):
	if idle_time_left > 0:
		idle_time_left -= delta
		return
	
	$AnimatedSprite2D.play("eating")
	await $AnimatedSprite2D.animation_finished
	
	$AnimatedSprite2D.play("default")
	idle_time_left = randf_range(3.0, 6.0)
