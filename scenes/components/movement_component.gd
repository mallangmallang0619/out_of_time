class_name MovementComponent
extends Node

@export_subgroup("Settings")
@export var speed = 100
@export var jump_speed = -200
@export var acceleration = 10
@export var friction = 6
@export var wall_jump_x = 150   # horizontal push away from wall
@export var wall_jump_y = -200  # vertical jump strength
@export var wall_slide_speed = 40  
var jump_counter = 0

var controls = {"move_right": [KEY_RIGHT, KEY_D],
"move_left": [KEY_LEFT, KEY_A],
"jump": [KEY_UP, KEY_W, KEY_SPACE]}

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

#delta is per frame
#basic input handler
func get_input(body: CharacterBody2D, delta:float) -> void:
	var direction = Input.get_axis("move_left", "move_right")
	
	if body.is_on_floor():
		jump_counter = 0
	
	if direction:
		body.velocity.x = lerp(body.velocity.x, direction * speed, acceleration * delta)
	else:
		body.velocity.x = lerp(body.velocity.x, 0.0, friction * delta)

	if body.is_on_wall() and not body.is_on_floor() and body.velocity.y > 0:
		body.velocity.y = min(body.velocity.y, wall_slide_speed)

	if Input.is_action_just_pressed("jump"):
		
		if body.is_on_floor():
			body.velocity.y = jump_speed
		
		elif body.is_on_wall():
			var wall_dir = body.get_wall_normal().x
			body.velocity.x = wall_dir * wall_jump_x
			body.velocity.y = wall_jump_y
			jump_counter = 1  # prevents extra jump abuse
		
		# Double jump
		elif jump_counter == 0:
			body.velocity.y = jump_speed
			jump_counter += 1
