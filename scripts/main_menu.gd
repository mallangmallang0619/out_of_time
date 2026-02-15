extends Control

@onready var _start_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/StartButton
@onready var _quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton

func _ready() -> void:
	_start_button.grab_focus()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tut_game.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
