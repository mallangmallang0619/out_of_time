extends Area2D

@export var point1: Vector2 = Vector2(0,0)
@export var point2: Vector2 = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
