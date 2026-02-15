extends TextureRect

func _ready() -> void:
	visible = bool(player.has_shield)

func _process(_delta: float) -> void:
	visible = bool(player.has_shield)

func _on_score_ready() -> void:
	pass
