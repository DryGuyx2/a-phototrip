extends AnimatedSprite2D

func _process(delta):
	if get_parent().flown_away:
		play("flying")
