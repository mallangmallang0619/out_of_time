extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

@export_subgroup("Nodes")
@export var gravity_component: GravityComponent
@export var movement_component: MovementComponent
@export var animation_component: AnimationComponent

var is_dead: bool = false
var final_pos: int = 0

# --- Ability inventory ---
var has_gun: bool = false		# for double jump
var has_sword: bool = false		# for wall jump
var has_shield: bool = false	# for temporary speed+

# Signals for the UI

signal shield_pickup(value)
signal death_finished


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
	_animated_sprite.animation_finished.connect(_on_animation_finished)
	if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.has_animation("death"):
		_animated_sprite.sprite_frames.set_animation_loop("death", false)

func grant_gun():
	has_gun = true
	player.has_gun = true
	print("Double jump acquired!")

func grant_sword():
	has_sword = true
	player.has_sword = true
	print("Wall jump acquired!")

func grant_shield():
	has_shield = true
	player.has_shield = true
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
		has_shield = false
		player.has_shield = false
		print("Speed boost ended")

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	
	# Play death animation first, then notify game controller.
	if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.has_animation("death"):
		_animated_sprite.play("death")
	else:
		emit_signal("death_finished")

func _on_animation_finished() -> void:
	if is_dead and _animated_sprite.animation == &"death":
		emit_signal("death_finished")

func respawn(spawn_point: Vector2) -> void:
	global_position = spawn_point
	velocity = Vector2.ZERO
	is_dead = false
	if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.has_animation("idle"):
		_animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	if is_dead:
		move_and_slide()
		return

	gravity_component.handle_gravity(self, delta)
	movement_component.get_input(self, delta)
	move_and_slide()
	animation_component.update_animation(self)

	# --- Update score based on x-distance ---
	player.x = int(global_position.x-137)  

	
