extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print("*Bang, Bang* - you got gun")
	queue_free()
