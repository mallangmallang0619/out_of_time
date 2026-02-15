extends TextureRect

func _ready() -> void:
	visible = bool(player.has_sword)

func _process(_delta: float) -> void:
	visible = bool(player.has_sword)
