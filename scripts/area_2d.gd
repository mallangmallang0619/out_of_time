extends Node2D

@export var point1: Vector2 = Vector2(0, 0)
@export var point2: Vector2 = Vector2(400, 300)
@export var max_spawn_attempts: int = 35
@export var item_radius: float = 14.0
@export var wall_collision_mask: int = 1
@export var player_collision_mask: int = 2
@export var floor_collision_mask: int = 1
@export var player_path: NodePath
@export var min_distance_from_player: float = 100.0

@export var spawn_number_of_items: int = 12
@export var spawn_interval: float = 1.5
@export var spawn_per_cycle: int = 2
@export var max_active_items: int = 20
@export var raycast_height: float = 220.0
@export var floor_clearance: float = 2.0
@export var min_floor_normal_dot: float = 0.7

@onready var pickups: Array[PackedScene] = [
	preload("res://scenes/Pickups/gun.tscn"),
	preload("res://scenes/Pickups/sword.tscn"),
	preload("res://scenes/Pickups/shield.tscn")
]
@onready var player: Node2D = get_node(player_path)

var _spawn_accumulator: float = 0.0

func pick_random_item() -> PackedScene:
	return pickups[randi_range(0, pickups.size() - 1)]

func _random_x() -> float:
	return randf_range(point1.x, point2.x)

func _active_item_count() -> int:
	var count = 0
	for child in get_children():
		if child is Area2D:
			count += 1
	return count

func _find_spawn_on_floor() -> Variant:
	var space_state = get_world_2d().direct_space_state
	var sample_x = _random_x()

	var ray_from = Vector2(sample_x, point1.y)
	var ray_to = Vector2(sample_x, point2.y + raycast_height)

	var ray_query = PhysicsRayQueryParameters2D.create(ray_from, ray_to, floor_collision_mask)
	ray_query.collide_with_areas = false
	ray_query.collide_with_bodies = true

	var hit = space_state.intersect_ray(ray_query)
	if hit.is_empty():
		return null

	var normal: Vector2 = hit.normal
	if normal.dot(Vector2.UP) < min_floor_normal_dot:
		return null

	var candidate = hit.position + Vector2(0, -item_radius - floor_clearance)
	if candidate.y < point1.y or candidate.y > point2.y + raycast_height:
		return null

	if not is_position_free(candidate):
		return null

	return candidate

func is_position_free(position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = item_radius

	var wall_query = PhysicsShapeQueryParameters2D.new()
	wall_query.shape = shape
	wall_query.transform = Transform2D(0, position)
	wall_query.collision_mask = wall_collision_mask
	wall_query.collide_with_areas = false
	wall_query.collide_with_bodies = true

	var wall_result = space_state.intersect_shape(wall_query)
	if not wall_result.is_empty():
		return false

	var player_query = PhysicsShapeQueryParameters2D.new()
	player_query.shape = shape
	player_query.transform = Transform2D(0, position)
	player_query.collision_mask = player_collision_mask
	player_query.collide_with_areas = false
	player_query.collide_with_bodies = true

	var player_result = space_state.intersect_shape(player_query)
	if not player_result.is_empty():
		return false

	if player and position.distance_to(player.global_position) < min_distance_from_player:
		return false

	return true

func spawn_item() -> bool:
	var attempts = 0
	while attempts < max_spawn_attempts:
		var spawn_position_variant = _find_spawn_on_floor()
		if spawn_position_variant != null:
			var item_instance = pick_random_item().instantiate()
			item_instance.global_position = spawn_position_variant
			add_child(item_instance)
			return true
		attempts += 1
	return false

func _spawn_cycle() -> void:
	var active = _active_item_count()
	if active >= max_active_items:
		return

	var slots = max_active_items - active
	var to_spawn = min(spawn_per_cycle, slots)
	for _i in range(to_spawn):
		spawn_item()

func _ready() -> void:
	randomize()
	await get_tree().process_frame

	var initial_to_spawn = min(spawn_number_of_items, max_active_items)
	for _i in range(initial_to_spawn):
		spawn_item()

func _process(delta: float) -> void:
	_spawn_accumulator += delta
	if _spawn_accumulator < spawn_interval:
		return
	_spawn_accumulator = 0.0
	_spawn_cycle()
