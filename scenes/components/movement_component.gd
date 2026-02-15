class_name MovementComponent
extends Node

@export_subgroup("Nodes")
@export var jump_buffer_timer: Timer
@export var coyote_timer: Timer
@export var double_grace_timer: Timer

@export_subgroup("Settings")
@export var speed: int = 100
@export var jump_speed: int = -200
@export var acceleration: int = 10
@export var friction: int = 6
@export var wall_jump_x: int = 150
@export var wall_jump_y: int = -250
@export var wall_slide_speed: int = 40
@export var queued_double_jump: bool = false

var jump_counter: int = 0
var is_jumping: bool = false
var last_frame_on_floor: bool = false

var controls = {
	"move_right": [KEY_RIGHT, KEY_D],
	"move_left": [KEY_LEFT, KEY_A],
	"jump": [KEY_UP, KEY_W, KEY_SPACE]
}

func can_double_jump(body: CharacterBody2D) -> bool:
	return body.has_method("grant_gun") and body.has_gun


func can_wall_jump(body: CharacterBody2D) -> bool:
	return body.has_method("grant_sword") and body.has_sword


func consume_double_jump(body):
	body.has_gun = false   # one-time consumable


func consume_wall_jump(body):
	body.has_sword = false # one-time consumable


# ==========================================================

func _ready():
	add_inputs()


func add_inputs():
	var ev
	for action in controls:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in controls[action]:
			ev = InputEventKey.new()
			ev.keycode = key
			InputMap.action_add_event(action, ev)


# ==========================================================
# Core movement helpers
# ==========================================================

func jump(body: CharacterBody2D) -> void:
	body.velocity.y = jump_speed
	jump_buffer_timer.stop()
	is_jumping = true
	coyote_timer.stop()


func has_landed(body: CharacterBody2D) -> bool:
	return body.is_on_floor() and not last_frame_on_floor and is_jumping


func has_just_left_ledge(body: CharacterBody2D) -> bool:
	return not body.is_on_floor() and last_frame_on_floor and not is_jumping


func handle_coyote_time(body: CharacterBody2D) -> void:
	if has_just_left_ledge(body):
		coyote_timer.start()


func _on_double_grace_timer_timeout() -> void:
	queued_double_jump = false


# ==========================================================
# Input / movement
# ==========================================================

func get_input(body: CharacterBody2D, delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	if body.is_on_floor():
		jump_counter = 0
		is_jumping = false
		queued_double_jump = false
		double_grace_timer.stop()

		if not jump_buffer_timer.is_stopped():
			jump(body)

	elif body.is_on_wall() and body.velocity.y >= 0:
		# Preserve air jump after touching wall
		jump_counter = 0


	# Consume queued double jump if it becomes valid
	if queued_double_jump and jump_counter == 0 and not body.is_on_floor() and can_double_jump(body):
		jump(body)
		jump_counter = 1
		queued_double_jump = false
		double_grace_timer.stop()
		consume_double_jump(body)



	# Horizontal movement
	if direction:
		body.velocity.x = lerp(body.velocity.x, direction * speed, acceleration * delta)
	else:
		body.velocity.x = lerp(body.velocity.x, 0.0, friction * delta)


	# Wall slide
	if body.is_on_wall() and not body.is_on_floor() and body.velocity.y > 0:
		body.velocity.y = min(body.velocity.y, wall_slide_speed)


	# Jump input
	if Input.is_action_just_pressed("jump"):

		# Normal jump
		if body.is_on_floor():
			jump(body)

		# Wall jump (Sword ability)
		elif body.is_on_wall() and can_wall_jump(body):
			var wall_dir = body.get_wall_normal().x

			body.velocity.x = wall_dir * wall_jump_x
			body.velocity.y = wall_jump_y

			jump_counter = 0
			queued_double_jump = false
			double_grace_timer.stop()
			jump_buffer_timer.stop()
			consume_wall_jump(body)


		# Double jump (Gun ability)
		elif jump_counter == 0 and can_double_jump(body):
			jump(body)
			jump_counter = 1

			queued_double_jump = false
			double_grace_timer.stop()
			consume_double_jump(body)


		# Grace queue if too early
		else:
			queued_double_jump = true
			double_grace_timer.start()

			if not body.is_on_floor():
				jump_buffer_timer.start()


	handle_coyote_time(body)
	last_frame_on_floor = body.is_on_floor()
