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
	if previous != player.has_shield:
		toggle()
	previous = player.has_shield
