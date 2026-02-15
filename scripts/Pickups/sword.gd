extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("I am the bone of my Sword...")
	queue_free()
