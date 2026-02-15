extends Area2D

func _on_body_entered(body):
	print("I still have time...")
	if body is CharacterBody2D and body.name == "Player" and body.has_method("die"):
		body.die()
		
#func _on_timer_timeout():
	#pass
