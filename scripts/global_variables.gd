extends Node

# --- Ability inventory ---
var has_gun: bool = false
var has_sword: bool = false
var has_shield: bool = false

# --- Run stats ---
var x: int = 0
var y: int = 0
var best_x: int = -1000000

# --- End game payload ---
var end_title: String = "Game Over"
var end_detail: String = ""
var end_final_score: int = 0
var end_is_win: bool = false
var end_multiplier: float = 1.0
var end_score_saved: bool = false

const REPO_HIGH_SCORE_FILE_PATH: String = "res://data/high_scores.json"
const USER_HIGH_SCORE_FILE_PATH: String = "user://high_scores.json"
const MAX_HIGH_SCORES: int = 30

func load_high_scores() -> Array:
	var repo_scores = _read_scores_from_path(REPO_HIGH_SCORE_FILE_PATH)
	if not repo_scores.is_empty():
		return _normalize_and_trim_scores(repo_scores)

	var user_scores = _read_scores_from_path(USER_HIGH_SCORE_FILE_PATH)
	return _normalize_and_trim_scores(user_scores)

func save_high_scores(scores: Array) -> void:
	var normalized_scores = _normalize_and_trim_scores(scores)
	var payload = JSON.stringify(normalized_scores)

	var repo_file = FileAccess.open(REPO_HIGH_SCORE_FILE_PATH, FileAccess.WRITE)
	if repo_file != null:
		repo_file.store_string(payload)
		return

	var user_file = FileAccess.open(USER_HIGH_SCORE_FILE_PATH, FileAccess.WRITE)
	if user_file != null:
		user_file.store_string(payload)

func add_high_score(player_name: String, score: int, won: bool) -> Array:
	var name = player_name.strip_edges()
	if name.is_empty():
		name = "Player"

	var scores = load_high_scores()
	scores.append({
		"name": name,
		"score": max(0, score),
		"won": won,
		"date": Time.get_datetime_string_from_system()
	})

	scores.sort_custom(func(a, b):
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	if scores.size() > MAX_HIGH_SCORES:
		scores.resize(MAX_HIGH_SCORES)

	save_high_scores(scores)
	return scores

func _read_scores_from_path(path: String) -> Array:
	if not FileAccess.file_exists(path):
		return []

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []

	var raw = file.get_as_text()
	if raw.strip_edges().is_empty():
		return []

	var parsed = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_ARRAY:
		return []
	return parsed

func _normalize_and_trim_scores(scores: Array) -> Array:
	var cleaned: Array = []
	for entry in scores:
		if typeof(entry) != TYPE_DICTIONARY:
			continue

		var name = String(entry.get("name", "Player")).strip_edges()
		if name.is_empty():
			name = "Player"

		cleaned.append({
			"name": name,
			"score": int(entry.get("score", 0)),
			"won": bool(entry.get("won", false)),
			"date": String(entry.get("date", ""))
		})

	cleaned.sort_custom(func(a, b):
		return int(a.get("score", 0)) > int(b.get("score", 0))
	)
	if cleaned.size() > MAX_HIGH_SCORES:
		cleaned.resize(MAX_HIGH_SCORES)
	return cleaned
