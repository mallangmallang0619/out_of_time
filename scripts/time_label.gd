extends Label

signal time_expired

@export var start_time: float = 120.0
var time_left: float = start_time
var finished: bool = false

func _ready() -> void:
	time_left = start_time
	finished = false
	update_display()

func _process(delta: float) -> void:
	if finished:
		return

	time_left = max(0.0, time_left - delta)
	update_display()

	if time_left <= 0.0:
		finished = true
		emit_signal("time_expired")

func update_display() -> void:
	var minutes := int(time_left / 60.0)
	var seconds := int(time_left) % 60
	text = "%02d:%02d" % [minutes, seconds]

func reset_timer(new_time: float = -1.0) -> void:
	if new_time >= 0.0:
		start_time = new_time
	time_left = start_time
	finished = false
	update_display()

func get_time_left() -> float:
	return time_left
