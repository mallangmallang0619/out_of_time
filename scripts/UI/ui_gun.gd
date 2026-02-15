extends TextureRect

var previous: bool = false

func toggle():
	print("Shield UI updated")
	visible = !visible

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	toggle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("Has gun ", player.has_gun)
	if previous != player.has_gun:
		toggle()
	previous = player.has_gun
