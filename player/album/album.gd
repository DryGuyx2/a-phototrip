extends Node2D
class_name Album

@onready var photo_1_normal = $Normal1
@onready var photo_2_normal = $Normal2
@onready var photo_3_normal = $Normal3
@onready var photo_1_cursed = $Cursed1
@onready var photo_2_cursed = $Cursed2
@onready var photo_3_cursed = $Cursed3

@onready var normal_photos = [photo_1_normal, photo_2_normal, photo_3_normal]
@onready var cursed_photos = [photo_1_cursed, photo_2_cursed, photo_3_cursed]

@onready var positions = {
	$Position1: "empty",
	$Position2: "empty",
	$Position3: "empty",
	$Position4: "empty",
	$Position5: "empty",
	$Position6: "empty",
}

#func _ready() -> void:
#	normal_photos[0].position = positions.keys()[0].position


func add_photo(number, cursed) -> void:
	print("Adding photo: ", number)
	var photo_position
	for position in positions.keys():
		if positions[position] == "empty":
			photo_position = position
			positions[position] = "used"
			break
	if cursed:
		cursed_photos[number].global_position = photo_position.global_position
	else:
		normal_photos[number].global_position = photo_position.global_position
