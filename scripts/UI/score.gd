extends Label

@export var score_offset: int = 257
@export var minimum_score: int = 0
func _process(_delta: float) -> void:
	var raw_score := int(player.x) + score_offset
	var score: int = max(minimum_score, raw_score)
	
	if score >= minimum_score:
		minimum_score = score
	text = "Score: " + str(score)
