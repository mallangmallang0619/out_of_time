extends Node2D

@export var player_path: NodePath

@export var floor_collision_mask: int = 1
@export var blocking_collision_mask: int = 1
@export var player_collision_mask: int = 2
@export var item_radius: float = 14.0
@export var spawn_clearance_padding: float = 2.0

@export var max_spawn_attempts: int = 24
@export var spawn_number_of_items: int = 4
@export var spawn_interval: float = 2.0
@export var spawn_per_cycle: int = 1
@export var max_active_items: int = 7

@export var min_distance_from_player: float = 64.0
@export var min_item_spacing: float = 40.0
@export var floor_clearance: float = 10.0
@export var min_floor_normal_dot: float = 0.75

@export var spawn_behind_distance: float = 80.0
@export var spawn_ahead_min: float = 90.0
@export var spawn_ahead_max: float = 240.0
@export_range(0.0, 1.0, 0.01) var right_spawn_bias: float = 0.9
@export var despawn_behind_distance: float = 340.0
@export var despawn_ahead_distance: float = 540.0
@export var despawn_vertical_distance: float = 220.0
@export var level_left_x: float = 0.0
@export var level_right_x: float = 1844.0
@export var level_top_y: float = -84.0
@export var level_bottom_y: float = 96.0
@export var floor_surface_buffer: float = 16.0
@export var overlap_resolve_step: float = 4.0
@export var overlap_resolve_steps: int = 16
@export var refill_per_frame: int = 2

@onready var pickups: Array[PackedScene] = [
	preload("res://scenes/Pickups/gun.tscn"),
	preload("res://scenes/Pickups/sword.tscn"),
	preload("res://scenes/Pickups/shield.tscn")
]
@onready var player: Node2D = get_node_or_null(player_path)

var _spawn_accumulator: float = 0.0
var _spawn_focus_override: Vector2 = Vector2.ZERO
var _has_spawn_focus_override: bool = false
var _is_regenerating: bool = false

func _ready() -> void:
	randomize()
	await get_tree().process_frame
	regenerate_items()

func _process(delta: float) -> void:
	if _is_regenerating:
		return

	_prune_distant_items()
	_refill_items_immediately()

	_spawn_accumulator += delta
	if _spawn_accumulator < spawn_interval:
		return

	_spawn_accumulator = 0.0
	_spawn_cycle()

func regenerate_items(focus_position: Vector2 = Vector2.INF) -> void:
	_is_regenerating = true

	if focus_position != Vector2.INF:
		_spawn_focus_override = focus_position
		_has_spawn_focus_override = true

	_spawn_accumulator = 0.0
	_clear_spawned_items()
	await get_tree().process_frame
	_spawn_accumulator = 0.0

	var initial_to_spawn = min(spawn_number_of_items, max_active_items)
	for _i in range(initial_to_spawn):
		spawn_item()

	_has_spawn_focus_override = false
	_is_regenerating = false

func _spawn_cycle() -> void:
	var active = _active_item_count()
	if active >= max_active_items:
		return

	var slots = max_active_items - active
	var to_spawn = min(spawn_per_cycle, slots)
	for _i in range(to_spawn):
		spawn_item()

func spawn_item() -> bool:
	var attempts = 0
	while attempts < max_spawn_attempts:
		var candidate = _find_spawn_candidate()
		if candidate != null:
			var item_instance = _pick_random_item().instantiate()
			item_instance.global_position = candidate
			add_child(item_instance)
			return true
		attempts += 1
	return false

func _find_spawn_candidate() -> Variant:
	var focus_pos = _get_spawn_focus_position()
	var sample_x = _sample_spawn_x(focus_pos.x)

	# Very wide vertical probe so it still finds floors on different elevations.
	var ray_from = Vector2(sample_x, -10000.0)
	var ray_to = Vector2(sample_x, 10000.0)

	var space_state = get_world_2d().direct_space_state
	var ray_query = PhysicsRayQueryParameters2D.create(ray_from, ray_to, floor_collision_mask)
	ray_query.collide_with_areas = false
	ray_query.collide_with_bodies = true

	var hit = space_state.intersect_ray(ray_query)
	if hit.is_empty():
		return null

	var normal: Vector2 = hit.normal
	if normal.dot(Vector2.UP) < min_floor_normal_dot:
		return null

	var candidate = hit.position + Vector2(0, -(item_radius + floor_clearance + floor_surface_buffer))
	var resolved_candidate = _resolve_candidate_above_ground(candidate)
	if resolved_candidate == null:
		return null
	candidate = resolved_candidate

	if not _has_floor_support(candidate):
		return null
	if not _is_position_valid(candidate):
		return null

	return candidate

func _resolve_candidate_above_ground(start_position: Vector2) -> Variant:
	var candidate = start_position
	for _i in range(overlap_resolve_steps + 1):
		if not _is_blocked_by_level(candidate) and not _is_blocked_by_level(candidate + Vector2(0, -2.0)):
			return candidate
		candidate.y -= overlap_resolve_step
	return null

func _has_floor_support(position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var support_from = position + Vector2(0, -2.0)
	var support_depth = _get_support_cast_depth()
	var support_to = position + Vector2(0, support_depth)
	var support_query = PhysicsRayQueryParameters2D.create(support_from, support_to, floor_collision_mask)
	support_query.collide_with_areas = false
	support_query.collide_with_bodies = true

	var support_hit = space_state.intersect_ray(support_query)
	if support_hit.is_empty():
		return false

	var support_normal: Vector2 = support_hit.normal
	return support_normal.dot(Vector2.UP) >= min_floor_normal_dot

func _get_support_cast_depth() -> float:
	# Must reach from the candidate center down to floor even after upward overlap resolution.
	var resolve_lift = overlap_resolve_step * float(overlap_resolve_steps)
	return item_radius + floor_clearance + floor_surface_buffer + resolve_lift + 24.0

func _is_position_valid(position: Vector2) -> bool:
	if not _is_within_spawn_bounds(position.x):
		return false
	if not _is_within_spawn_height(position.y):
		return false

	var player_pos = _get_player_position()
	if position.distance_to(player_pos) < min_distance_from_player:
		return false

	if _has_item_near(position):
		return false

	if _is_blocked_by_level(position):
		return false

	var space_state = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = item_radius + spawn_clearance_padding

	var player_query = PhysicsShapeQueryParameters2D.new()
	player_query.shape = shape
	player_query.transform = Transform2D(0, position)
	player_query.collision_mask = player_collision_mask
	player_query.collide_with_areas = false
	player_query.collide_with_bodies = true

	var player_result = space_state.intersect_shape(player_query)
	if not player_result.is_empty():
		return false

	return true

func _is_blocked_by_level(position: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = item_radius + spawn_clearance_padding

	var block_query = PhysicsShapeQueryParameters2D.new()
	block_query.shape = shape
	block_query.transform = Transform2D(0, position)
	block_query.collision_mask = blocking_collision_mask
	block_query.collide_with_areas = false
	block_query.collide_with_bodies = true

	var block_result = space_state.intersect_shape(block_query)
	return not block_result.is_empty()

func _sample_spawn_x(player_x: float) -> float:
	var min_x = min(level_left_x + item_radius, level_right_x - item_radius)
	var max_x = max(level_left_x + item_radius, level_right_x - item_radius)
	var ahead_min_offset = max(spawn_ahead_min, min_distance_from_player + item_radius + 8.0)
	var ahead_max_offset = max(spawn_ahead_max, ahead_min_offset + 20.0)

	# Most spawns are ahead, but kept in a near-player window.
	if randf() < right_spawn_bias:
		var ahead_x = player_x + randf_range(ahead_min_offset, ahead_max_offset)
		return clampf(ahead_x, min_x, max_x)

	# Some spawns are slightly behind or near the player to keep local density up.
	var behind_max = max(16.0, ahead_min_offset * 0.5)
	var behind_x = player_x + randf_range(-spawn_behind_distance, behind_max)
	return clampf(behind_x, min_x, max_x)

func _is_within_spawn_bounds(x_value: float) -> bool:
	var min_x = min(level_left_x + item_radius, level_right_x - item_radius)
	var max_x = max(level_left_x + item_radius, level_right_x - item_radius)
	return x_value >= min_x and x_value <= max_x

func _is_within_spawn_height(y_value: float) -> bool:
	var min_y = min(level_top_y + item_radius, level_bottom_y - item_radius)
	var max_y = max(level_top_y + item_radius, level_bottom_y - item_radius)
	return y_value >= min_y and y_value <= max_y

func _get_spawn_focus_position() -> Vector2:
	if _has_spawn_focus_override:
		return _spawn_focus_override
	return _get_player_position()

func _has_item_near(position: Vector2) -> bool:
	for child in get_children():
		if child is Area2D and not child.is_queued_for_deletion() and child.global_position.distance_to(position) < min_item_spacing:
			return true
	return false

func _active_item_count() -> int:
	var count = 0
	for child in get_children():
		if child is Area2D and not child.is_queued_for_deletion():
			count += 1
	return count

func _prune_distant_items() -> void:
	var player_pos = _get_player_position()
	for child in get_children():
		if child is Area2D and not child.is_queued_for_deletion():
			var dx = child.global_position.x - player_pos.x
			var dy = absf(child.global_position.y - player_pos.y)
			if dx < -despawn_behind_distance or dx > despawn_ahead_distance or dy > despawn_vertical_distance:
				child.queue_free()

func _refill_items_immediately() -> void:
	var target_active = max_active_items
	var missing = max(0, target_active - _active_item_count())
	var to_spawn = min(refill_per_frame, missing)
	for _i in range(to_spawn):
		spawn_item()

func _clear_spawned_items() -> void:
	for child in get_children():
		if child is Area2D:
			child.queue_free()

func _get_player_position() -> Vector2:
	if player != null:
		return player.global_position
	return global_position

func _pick_random_item() -> PackedScene:
	return pickups[randi_range(0, pickups.size() - 1)]
