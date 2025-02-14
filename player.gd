extends CharacterBody2D


@export var speed: float = 160.0
@export var position_margin: float = 5.0

@onready var target_position: Vector2 = global_position


func _physics_process(_delta: float) -> void:
	if global_position.distance_to(target_position) < position_margin:
		velocity = Vector2.ZERO

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed("ui_accept"):
		target_position = event.position
		var direction: Vector2 = (target_position - global_position).normalized()
		velocity = direction * speed
