extends Control

const MODE_MAIN := 0
const MODE_SAVE := 1
const MODE_SCORES := 2
const DEFAULT_NAME := "Player"
const SCORES_PER_PAGE := 6

@onready var _title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Title
@onready var _detail_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Detail
@onready var _score_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/FinalScore

@onready var _main_actions: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/MainActions
@onready var _open_save_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/MainActions/OpenSaveButton
@onready var _show_scores_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/MainActions/ShowScoresButton
@onready var _restart_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/MainActions/RestartButton
@onready var _end_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/MainActions/EndGameButton

@onready var _save_section: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/SaveSection
@onready var _name_input: LineEdit = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/SaveSection/NameInput
@onready var _confirm_save_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/SaveSection/ConfirmSaveButton
@onready var _save_status_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/SaveSection/SaveStatus

@onready var _scores_section: VBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/ScoresSection
@onready var _scores_text: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/ScoresSection/HighScoresText
@onready var _scores_prev_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/ScoresSection/ScoresPager/PrevScoresButton
@onready var _scores_page_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/ScoresSection/ScoresPager/ScoresPageLabel
@onready var _scores_next_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/ScoresSection/ScoresPager/NextScoresButton
@onready var _scores_back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/ScoresSection/BackFromScoresButton

var _mode: int = MODE_MAIN
var _scores_page: int = 0
var _scores_cache: Array = []

func _ready() -> void:
	_title_label.text = player.end_title
	_detail_label.text = player.end_detail
	_score_label.text = "Final Score: %d" % int(player.end_final_score)

	_name_input.text = ""
	_save_status_label.text = ""
	_apply_save_state()
	_set_mode(MODE_SAVE) # Prompt for name first on both win/loss.

func _set_mode(next_mode: int) -> void:
	_mode = next_mode
	_main_actions.visible = _mode == MODE_MAIN
	_save_section.visible = _mode == MODE_SAVE
	_scores_section.visible = _mode == MODE_SCORES

	match _mode:
		MODE_MAIN:
			_restart_button.grab_focus()
		MODE_SAVE:
			if not bool(player.end_score_saved):
				_name_input.grab_focus()
			else:
				_confirm_save_button.grab_focus()
		MODE_SCORES:
			_update_high_scores_text()
			_scores_back_button.grab_focus()

func _on_open_save_pressed() -> void:
	_set_mode(MODE_SAVE)

func _on_show_scores_pressed() -> void:
	_scores_page = 0
	_set_mode(MODE_SCORES)

func _on_back_from_save_pressed() -> void:
	_set_mode(MODE_MAIN)

func _on_back_from_scores_pressed() -> void:
	_set_mode(MODE_MAIN)

func _on_confirm_save_pressed() -> void:
	_save_score_if_needed()

func _on_name_input_text_submitted(_new_text: String) -> void:
	_save_score_if_needed()

func _save_score_if_needed() -> void:
	if bool(player.end_score_saved):
		_save_status_label.text = "Score already saved."
		return

	var saved_scores = player.add_high_score(_effective_name(), int(player.end_final_score), bool(player.end_is_win))
	player.end_score_saved = true
	_apply_save_state()
	_save_status_label.text = "Score saved."
	_scores_page = 0
	_update_high_scores_text(saved_scores)

func _effective_name() -> String:
	var entered = _name_input.text.strip_edges()
	if entered.is_empty():
		return DEFAULT_NAME
	return entered

func _apply_save_state() -> void:
	var already_saved = bool(player.end_score_saved)
	_confirm_save_button.disabled = already_saved
	_name_input.editable = not already_saved
	_open_save_button.text = "Score Saved" if already_saved else "Enter Name"

func _update_high_scores_text(scores: Array = []) -> void:
	_scores_cache = scores if not scores.is_empty() else player.load_high_scores()
	var page_count = _get_scores_page_count()
	_scores_page = clampi(_scores_page, 0, max(0, page_count - 1))

	if _scores_cache.is_empty():
		_scores_text.text = "No scores yet."
		_scores_page_label.text = "Page 1/1"
		_scores_prev_button.disabled = true
		_scores_next_button.disabled = true
		return

	var start_index = _scores_page * SCORES_PER_PAGE
	var end_index = min(start_index + SCORES_PER_PAGE, _scores_cache.size())
	var lines: Array[String] = []
	for i in range(start_index, end_index):
		var entry = _scores_cache[i]
		var name = String(entry.get("name", DEFAULT_NAME))
		if name.length() > 10:
			name = name.substr(0, 10)
		var score = int(entry.get("score", 0))
		lines.append("%d. %s %d" % [i + 1, name, score])

	_scores_text.text = "\n".join(lines)
	_scores_page_label.text = "Page %d/%d" % [_scores_page + 1, page_count]
	_scores_prev_button.disabled = _scores_page <= 0
	_scores_next_button.disabled = _scores_page >= page_count - 1

func _get_scores_page_count() -> int:
	if _scores_cache.is_empty():
		return 1
	return int(ceil(float(_scores_cache.size()) / float(SCORES_PER_PAGE)))

func _on_prev_scores_pressed() -> void:
	if _scores_page <= 0:
		return
	_scores_page -= 1
	_update_high_scores_text(_scores_cache)

func _on_next_scores_pressed() -> void:
	var page_count = _get_scores_page_count()
	if _scores_page >= page_count - 1:
		return
	_scores_page += 1
	_update_high_scores_text(_scores_cache)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	player.x = 0
	player.best_x = -1000000
	get_tree().change_scene_to_file("res://scenes/tut_game.tscn")

func _on_end_game_pressed() -> void:
	get_tree().quit()
