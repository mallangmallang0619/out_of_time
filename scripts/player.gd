extends CharacterBody2D

@export var speed = 100
@export var jump_speed = -200
@export var acceleration = 10
@export var friction = 6
@export var wall_jump_x = 150   # horizontal push away from wall
@export var wall_jump_y = -200  # vertical jump strength
@export var wall_slide_speed = 40  # optional: slow sliding down walls
@onready var _animated_sprite = $AnimatedSprite2D
var jump_counter = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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
func get_input(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if is_on_floor():
		jump_counter = 0
	
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction * delta)

	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		velocity.y = min(velocity.y, wall_slide_speed)

	if Input.is_action_just_pressed("jump"):
		
		if is_on_floor():
			velocity.y = jump_speed
		
		elif is_on_wall():
			var wall_dir = get_wall_normal().x
			velocity.x = wall_dir * wall_jump_x
			velocity.y = wall_jump_y
			jump_counter = 1  # prevents extra jump abuse
		
		# Double jump
		elif jump_counter == 0:
			velocity.y = jump_speed
			jump_counter += 1


func _physics_process(delta):

	velocity.y += gravity*  delta
	get_input(delta)
	move_and_slide()
