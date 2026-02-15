extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("grant_gun"):
		body.grant_gun()
		queue_free()
