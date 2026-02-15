extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("grant_shield"):
		body.grant_shield()
		queue_free()
