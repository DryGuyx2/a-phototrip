extends Node2D
class_name Album

@onready var photo_1 = $Photo1
@onready var photo_2 = $Photo2
@onready var photo_3 = $Photo3

@onready var photos = [photo_1, photo_2, photo_3]

func _process(delta: float):
	if Input.is_action_just_pressed("test_1"):
		add_photo(1)
	if Input.is_action_just_pressed("test_2"):
		curse_photo(1)
	if Input.is_action_just_pressed("test_3"):
		add_photo(0)

func add_photo(number) -> void:
	photos[number].find_child("Normal").visible = true

func curse_photo(number: int) -> void:
	photos[number].find_child("Normal").visible = false
	photos[number].find_child("Cursed").visible = true
