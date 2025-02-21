extends Node2D

@export var intersection: Node2D

func _ready():
	if get_name() == "NestArea":
		intersection.ritual_finished.connect($Node2D/YellowBird._on_ritual_finished)
	elif get_name() == "Coast":
		intersection.ritual_finished.connect($Path2D/PathFollow2D/RedBird._on_ritual_finished)
	elif get_name() == "Cliff":
		intersection.ritual_finished.connect($Path2D/PathFollow2D/BlueBird._on_ritual_finished)
