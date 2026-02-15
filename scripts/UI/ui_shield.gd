extends TextureRect


func _on_action_triggered():
	print("Shield UI updated")
	visible = !visible
	get_node("shield_icon").hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("have Shield?: ", player.has_shield)
	pass
