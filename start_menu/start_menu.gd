extends Node2D

signal game_started

@onready var start_button = $StartButton
var hovered = false

func _ready() -> void:
	start_button.play("default")

func _on_area_2d_mouse_entered():
	start_button.play("hovered")
	hovered = true


func _on_area_2d_mouse_exited():
	start_button.play("default")
	hovered = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		var menu_fade_tween = create_tween()
		menu_fade_tween.tween_property(self, "modulate:a", 0, 1).set_trans(Tween.TRANS_LINEAR)
		menu_fade_tween.play()
		menu_fade_tween.tween_callback(start_game)

func start_game() -> void:
	emit_signal("game_started")
