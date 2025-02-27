extends Area2D
class_name Bird

@export var type: String
@export var exit_position: Node2D
@export var exit_time: float
@export var number: int
@export var flying: bool

@export_category("Path following")
@export var path_follow: PathFollow2D 
@export var flight_speed: float = 100
@export var flight_turnpoint: Node2D

@onready var animation_component: AnimatedSprite2D = $AnimatedSprite2D
@onready var initial_position: Vector2 = get_parent().global_position
@onready var chirp_player: AudioStreamPlayer = $Chirp

var intersection: Node2D
var idle_time_left: float = randf_range(3.0, 6.0)
var cursed = false
var flown_away: bool = false

func _ready() -> void:
	set_collision_layer_value(GlobalData.layers["photo_detection"], true)
	
	if path_follow:
		animation_component.play("flight_%s" % type)
	else:
		animation_component.play("default_%s" % type)


func _process(delta: float) -> void:
	if flying and not flown_away:
		animation_component.flip_h = global_position.x > flight_turnpoint.global_position.x
		path_follow.progress += flight_speed * delta
		return
	if idle_time_left > 0:
		idle_time_left -= delta
		return
	animation_component.play("acting_%s" % type)
	idle_time_left = 10


func _on_animated_sprite_2d_animation_finished() -> void:
	if animation_component.animation == "acting_%s" % type:
		animation_component.play("default_%s" % type)
		idle_time_left = randf_range(3.0, 10.0)


func photographed() -> void:
	chirp_player.play()
	flown_away = true
	animation_component.play("flight_%s" % type)
	var flight_tween = create_tween()
	flight_tween.tween_property(get_parent(), "global_position", exit_position.global_position, exit_time)
	flight_tween.tween_callback(disable_photography)
	flight_tween.play()


func disable_photography() -> void:
	set_collision_layer_value(GlobalData.layers["photo_detection"], false)

func reset() -> void:
	set_collision_layer_value(GlobalData.layers["photo_detection"], true)
	get_parent().global_position = initial_position
	flown_away = false

func _on_ritual_finished():
	reset()
	cursed = true
