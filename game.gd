extends Node2D


@onready var player: CharacterBody2D = $Player
@onready var hiding_spots: Area2D = $World/HidingSpots
@onready var ray: RayCast2D = $RayCast2D
@onready var label: Label = $Label

var hiding_spot: String = ""


func _ready() -> void:
	hiding_spots.input_event.connect(
		func (_viewport: Viewport, event: InputEvent, shape_idx: int):
			if (event is InputEventMouseButton
			and event.pressed):
				_check_hiding_spot(event, shape_idx)
	)
	_set_hiding_spot()


func _check_hiding_spot(_event: InputEventMouseButton, idx: int) -> void:
	var spot: CollisionShape2D = hiding_spots.get_children()[idx]
	var params := PhysicsRayQueryParameters2D.new()
	params.from = player.global_position
	params.to = spot.global_position
	params.collide_with_bodies = false
	params.collide_with_areas = true
	var res := get_world_2d().direct_space_state.intersect_ray(params)
	var dist := player.global_position.distance_to(res.position)
	if dist < 10 and label.global_position == Vector2.ZERO:
		if spot.name == hiding_spot:
			_spawn_label(res.position, "Here!")
			_set_hiding_spot()
		else:
			_spawn_label(res.position, "Not here!")


func _spawn_label(at: Vector2, text: String, distance: float = 36.0, time: float = 2.0) -> void:
	label.text = text
	label.global_position = at
	label.visible = true

	var rand_dir := Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var direction := rand_dir.normalized() * distance
	var tween := create_tween()
	tween.tween_property(label, "global_position", at + direction, time)
	tween.parallel().tween_property(label, "modulate:a", 0.0, time).set_trans(Tween.TRANS_LINEAR)
	tween.finished.connect(func():
		label.visible = false
		label.global_position = Vector2.ZERO
		label.modulate.a = 1.0
		label.text = ""
	)


func _set_hiding_spot() -> void:
	hiding_spot = hiding_spots.get_children().pick_random().name
