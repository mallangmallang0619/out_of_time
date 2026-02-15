extends Area2D

@onready var timer = $Timer

func _on_body_entered(body):
	print("I still have time...")
	if body is CharacterBody2D and body.name == "Player":
		timer.start()
	
func _on_timer_timeout():
	get_tree().reload_current_scene()
