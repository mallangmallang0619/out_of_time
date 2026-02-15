extends Label

var start_time := 60.0
var time_left := start_time
var finished := false

func _ready():
	update_display()

func _process(delta):
	if finished:
		return
		
	if time_left > 0:
		time_left -= delta
		update_display()
	else:
		time_left = 0
		update_display()
		trigger_death()

func update_display():
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	text = "%02d:%02d" % [minutes, seconds]

func trigger_death():
	finished = true
	print("Time ran out!")
	get_tree().reload_current_scene()
