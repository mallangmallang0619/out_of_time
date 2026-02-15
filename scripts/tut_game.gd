extends Node2D

@export var win_x_position: float = 2200.0
@export var score_offset: int = 257
@export var win_score_multiplier: float = 1.5
@export var time_score_per_second: float = 2.0

@onready var player_node = $Player
@onready var timer_label = $TestUI/Timer
@onready var spawn_area = $"Spawn Area"
@onready var goal_node = $Goal

var _spawn_position: Vector2
var _game_finished: bool = false

func _ready() -> void:
	_spawn_position = player_node.global_position
	_game_finished = false

	# Reset run-level stats each new run.
	player.x = 0
	player.best_x = -1000000
	player.end_title = "Game Over"
	player.end_detail = ""
	player.end_final_score = 0
	player.end_is_win = false
	player.end_multiplier = 1.0
	player.end_score_saved = false

	player_node.death_finished.connect(_on_player_death_finished)
	timer_label.time_expired.connect(_on_time_expired)
	if goal_node and goal_node.has_signal("goal_reached"):
		goal_node.goal_reached.connect(_on_goal_reached)

func _process(_delta: float) -> void:
	if _game_finished:
		return

	# Keep global score tracking in sync from live player position.
	var current_distance = int(player_node.global_position.x - 137)
	player.x = current_distance
	if current_distance > player.best_x:
		player.best_x = current_distance

func _on_player_death_finished() -> void:
	if _game_finished:
		return
	player_node.respawn(_spawn_position)
	if spawn_area and spawn_area.has_method("regenerate_items"):
		spawn_area.call_deferred("regenerate_items", _spawn_position)

func _on_goal_reached() -> void:
	if _game_finished:
		return
	_show_end_screen("You Win!", "You captured the flag.", true)

func _on_time_expired() -> void:
	if _game_finished:
		return
	_show_end_screen("Time Up", "The clock hit zero. Game over.", false)

func _show_end_screen(title: String, detail: String, won: bool) -> void:
	_game_finished = true
	player.end_title = title
	player.end_detail = detail
	player.end_is_win = won
	player.end_multiplier = win_score_multiplier if won else 1.0
	player.end_score_saved = false

	var live_distance = int(player_node.global_position.x - 137)
	var best_distance = max(player.best_x, player.x, live_distance)
	var time_left = 0.0
	if timer_label and timer_label.has_method("get_time_left"):
		time_left = max(0.0, float(timer_label.get_time_left()))
	var time_bonus = int(round(time_left * time_score_per_second))
	var base_score = max(0, best_distance + score_offset + time_bonus)
	player.end_final_score = int(round(base_score * player.end_multiplier))
	player.x = 0
	player.best_x = -1000000
	get_tree().change_scene_to_file("res://scenes/end_game_overlay.tscn")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
