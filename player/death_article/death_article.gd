extends Node2D

func play() -> void:
	visible = true
	var show_tween = create_tween().set_parallel()
	show_tween.tween_property(self, "rotation", 12.56, 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	show_tween.tween_property(self, "scale", Vector2(6, 6), 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	show_tween.play()
