extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

@export_subgroup("Nodes")
@export var gravity_component: GravityComponent
@export var movement_component: MovementComponent

# --- Ability inventory ---
var has_gun: bool = false		# for double jump
var has_sword: bool = false		# for wall jump
var has_shield: bool = false	# for temporary speed+

# Signals for the UI

signal shield_pickup(value)


# --- Shield speed boost ---
var shield_speed_timer: Timer = Timer.new()
var original_speed: int = 0
var has_original_speed: bool = false  # track original speed storage

func _ready():
	# Add shield speed timer
	add_child(shield_speed_timer)
	shield_speed_timer.one_shot = true
	shield_speed_timer.wait_time = 5.0
	shield_speed_timer.connect("timeout", Callable(self, "_on_shield_speed_timeout"))

func grant_gun():
	has_gun = true
	print("Double jump acquired!")

func grant_sword():
	has_sword = true
	print("Wall jump acquired!")

func grant_shield():
	has_shield = true
	emit_signal("shield_pickup", has_shield)
	print("Speed boost acquired!")
	if movement_component:
		# Store original speed once
		if not has_original_speed:
			original_speed = movement_component.speed
			has_original_speed = true

		# Apply double speed
		movement_component.speed = original_speed * 2
		shield_speed_timer.start()  # 5-second timer

func _on_shield_speed_timeout():
	if movement_component:
		movement_component.speed = original_speed
		print("Speed boost ended")

func _physics_process(delta: float) -> void:
	gravity_component.handle_gravity(self, delta)
	movement_component.get_input(self, delta)
	move_and_slide()
