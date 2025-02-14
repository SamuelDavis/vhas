extends CharacterBody2D


@export var speed := 160.0

@onready var target := position
var moving := false

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
