extends CharacterBody2D


@export var speed: float = 160.0
@export var distance_margin: float = 5.0

@onready var target_position: Vector2 = global_position

var distance_to_target: float = 0.0

func _physics_process(_delta: float) -> void:
	var current_distance: float = global_position.distance_to(target_position)

	if (current_distance < distance_margin
	or current_distance > distance_to_target):
		velocity = Vector2.ZERO
	distance_to_target = current_distance

	move_and_slide()


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton
	and Input.is_action_just_pressed("ui_accept")):
		target_position = event.position
		distance_to_target = global_position.distance_to(target_position)
		velocity = (target_position - global_position).normalized() * speed
