extends Node
class_name Footstep

@export var min_wait: float = 0.20
@export var max_wait: float = 0.15
@export var playing: bool = false

@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	timer.timeout.connect(_on_timeout)


func _on_timeout() -> void:
	if playing:
		audio.play()
		play()


func play() -> void:
	playing = true
	audio.play()
	timer.start(randf_range(min_wait, max_wait))


func stop() -> void:
	playing = false
	timer.stop()
