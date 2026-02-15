extends Area2D

signal goal_reached

var _triggered: bool = false

func _on_body_entered(body: Node) -> void:
	if _triggered:
		_triggered = true
	if not body.is_in_group("Player"):
		return
	print("goal")
	_triggered = true
	emit_signal("goal_reached")
