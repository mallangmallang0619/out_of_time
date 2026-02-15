extends Node2D

@export var win_x_position: float = 2200.0

@onready var player_node = $Player
@onready var timer_label = $TestUI/Timer
@onready var end_overlay: Control = $EndGameOverlay
@onready var end_title: Label = $EndGameOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Title
@onready var end_detail: Label = $EndGameOverlay/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Detail

var _spawn_position: Vector2
var _game_finished: bool = false

func _ready() -> void:
	_spawn_position = player_node.global_position
	end_overlay.visible = false
	end_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	player_node.death_finished.connect(_on_player_death_finished)
	timer_label.time_expired.connect(_on_time_expired)

func _process(_delta: float) -> void:
	if _game_finished:
		return
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
	end_title.text = title
	end_detail.text = detail
	end_overlay.visible = true
	get_tree().paused = true

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/tut_game.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
