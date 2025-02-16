extends Area2D


signal win()
signal reset()

@onready var animation: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	input_event.connect(func(_viewport: Viewport, event: InputEvent, _shape_idx: int):
		if event is InputEventMouseButton and event.pressed:
			_on_click()
	)


func _on_click() -> void:
	if animation.current_animation == "hug" and animation.is_playing():
		reset.emit()
		queue_free()
	else:
		win.emit()
		animation.play("hug")
