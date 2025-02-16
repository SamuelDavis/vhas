extends Node2D


@onready var jessica: CharacterBody2D = $World/Jessica
@onready var samuel: Sprite2D = $World/Samuel
@onready var first_hiding_spots: Area2D = $World/FirstFloor/HidingSpots
@onready var second_hiding_spots: Area2D = $World/SecondFloor/HidingSpots
@onready var ray: RayCast2D = $RayCast2D
@onready var label: Label = $Label
@onready var stairs: Area2D = $World/Stairs
@onready var first_floor: Node2D = $World/FirstFloor
@onready var second_floor: Node2D = $World/SecondFloor
@onready var active_floor: Node2D = $World/FirstFloor

var hiding_spot: String = ""


func _ready() -> void:
	for spots: Area2D in [first_hiding_spots, second_hiding_spots]:
		spots.input_event.connect(
			func (_viewport: Viewport, event: InputEvent, shape_idx: int):
				if (event is InputEventMouseButton
				and event.pressed):
					_check_hiding_spot(event, shape_idx, spots)
		)
	_set_hiding_spot()
	stairs.body_entered.connect(_toggle_level)
	_toggle_level(jessica)
	_toggle_level(jessica)

func _toggle_level(body) -> void:
	if body != jessica: return

	for child in active_floor.get_children():
		if child is TileMapLayer:
			child.collision_enabled = false
		if child is Area2D:
			child.input_pickable = false

	if second_floor.visible:
		second_floor.visible = false
		active_floor = first_floor
		first_floor.modulate = Color(1.0, 1.0, 1.0, 1)
	else:
		second_floor.visible = true
		active_floor = second_floor
		first_floor.modulate = Color(0.5, 0.5, 0.5, 1)

	for child in active_floor.get_children():
		if child is TileMapLayer:
			child.collision_enabled = true
		if child is Area2D:
			child.input_pickable = true



func _check_hiding_spot(_event: InputEventMouseButton, idx: int, spots: Area2D) -> void:
	var spot: CollisionShape2D = spots.get_children()[idx]
	var params := PhysicsRayQueryParameters2D.new()
	params.from = jessica.global_position
	params.to = spot.global_position
	params.collide_with_bodies = false
	params.collide_with_areas = true
	var res: Dictionary = get_world_2d().direct_space_state.intersect_ray(params)

	if not res.has("position"): return

	var dist := jessica.global_position.distance_to(res.position)
	if dist < 10 and label.global_position == Vector2.ZERO:
		if spot.name == hiding_spot:
			_spawn_label(res.position, "Here!")
			_spawn_samuel(res.position)
		else:
			_spawn_label(res.position, _get_not_found_text(spot))


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


func _spawn_samuel(at: Vector2) -> void:
	samuel.scale = Vector2.ZERO
	samuel.global_position = at

	var tween := create_tween()
	tween.tween_property(samuel, "scale", Vector2.ONE, 1.0)
	tween.finished.connect(func():
		_set_hiding_spot()
		samuel.scale = Vector2.ZERO
		samuel.global_position = Vector2.ZERO
	)


func _set_hiding_spot() -> void:
	var first_floor_spot = first_hiding_spots.get_children().pick_random().name
	var second_floor_spot = second_hiding_spots.get_children().pick_random().name
	hiding_spot = first_floor_spot if randi() % 2 == 0 else second_floor_spot


func _get_not_found_text(spot: CollisionShape2D) -> String:
	var options: Array[String] = ["Not here!", "Somewhere else!"]

	match spot.name:
		"Bath":
			options.push_back("Not bathing.")
			options.push_back("Not showering.")
		"Shower":
			options.push_back("Not showering.")
		"Closet":
			options.push_back("Just mess.")
			options.push_back("No room!")
		"Bed", "Guest", "Couch":
			options.push_back("No naps!")
			options.push_back("No napping.")
		"Desk":
			options.push_back("Your desk!")
			options.push_back("Not under here!")
		"Table":
			options.push_back("Not under here!")
			options.push_back("Not snacking.")


	return options.pick_random()
