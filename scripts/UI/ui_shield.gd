extends TextureRect


var has_shield: bool = false


func _on_action_triggered():
	print("Shield UI updated")
	visible = !visible
	
