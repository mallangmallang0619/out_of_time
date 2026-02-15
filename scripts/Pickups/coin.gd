extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("oh boy, coin")
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
