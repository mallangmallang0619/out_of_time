extends Control

@onready var _title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Title
@onready var _detail_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Detail
@onready var _score_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FinalScore
@onready var _retry_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/RetryButton
@onready var _menu_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MainMenuButton

func _ready() -> void:
	_title_label.text = player.end_title
	_detail_label.text = player.end_detail
	_score_label.text = "Final Score: %d" % player.end_final_score

	_retry_button.grab_focus()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	player.x = 0
	player.best_x = -1000000
	get_tree().change_scene_to_file("res://scenes/tut_game.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	player.x = 0
	player.best_x = -1000000
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
