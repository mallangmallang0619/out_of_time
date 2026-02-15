extends Node2D

@export var point1: Vector2 = Vector2(0, 0)
@export var point2: Vector2 = Vector2(400, 300)
@export var max_spawn_attempts: int = 10
@export var item_radius: float = 32.0
@export var wall_collision_mask: int = 1
@export var player_path: NodePath
@export var min_distance_from_player: float = 100.0

# Store pickups in an array (cleaner than if/else)
@onready var pickups: Array[PackedScene] = [
	preload("res://scenes/Pickups/gun.tscn"),
	preload("res://scenes/Pickups/sword.tscn"),
	preload("res://scenes/Pickups/shield.tscn")
]
@onready var player: Node2D = get_node(player_path)

# Generate random point inside rectangle
func get_random_point() -> Vector2:
	return Vector2(
		randf_range(point1.x, point2.x),
		randf_range(point1.y, point2.y)
	)

# Pick random scene
func pick_random_item() -> PackedScene:
	return pickups[randi_range(0, pickups.size() - 1)]

# Check if spawn position is free
func is_position_free(position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var shape := CircleShape2D.new()
	shape.radius = item_radius
	
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collision_mask = wall_collision_mask
	
	var result = space_state.intersect_shape(query)
	
	# If hitting a wall → invalid
	if not result.is_empty():
		return false
	
	# Check distance from player
	if player and position.distance_to(player.global_position) < min_distance_from_player:
		return false
	
	return true

# Spawn item safely
func spawn_item():
	var attempts := 0
	var spawn_position: Vector2
	
	while attempts < max_spawn_attempts:
		spawn_position = get_random_point()
		
		if is_position_free(spawn_position):
			var item_instance = pick_random_item().instantiate()
			item_instance.global_position = spawn_position
			add_child(item_instance)
			return
		
		attempts += 1
	
	print("Failed to find valid spawn location after ", max_spawn_attempts, " attempts.")

func _ready() -> void:
	randomize()
	spawn_item()
