extends Node2D

@export var win_x_position: float = 2200.0
@export var score_offset: int = 257

@onready var player_node = $Player
@onready var timer_label = $TestUI/Timer

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

	player_node.death_finished.connect(_on_player_death_finished)
	timer_label.time_expired.connect(_on_time_expired)

func _process(_delta: float) -> void:
	if _game_finished:
		return

	# Keep global score tracking in sync from live player position.
	var current_distance = int(player_node.global_position.x - 137)
	player.x = current_distance
	if current_distance > player.best_x:
		player.best_x = current_distance

	if player_node.global_position.x >= win_x_position:
		_show_end_screen("You Escaped!", "You reached the end of the level.")

func _on_player_death_finished() -> void:
	if _game_finished:
		return
	player_node.respawn(_spawn_position)

func _on_time_expired() -> void:
	if _game_finished:
		return
	_show_end_screen("Time Up", "The clock hit zero. Game over.")

func _show_end_screen(title: String, detail: String) -> void:
	_game_finished = true
	player.end_title = title
	player.end_detail = detail

	var live_distance = int(player_node.global_position.x - 137)
	var best_distance = max(player.best_x, player.x, live_distance)
	player.end_final_score = max(0, best_distance + score_offset)
	player.x = 0
	player.best_x = -1000000
	get_tree().change_scene_to_file("res://scenes/end_game_overlay.tscn")

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
