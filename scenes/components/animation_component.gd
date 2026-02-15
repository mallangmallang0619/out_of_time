class_name AnimationComponent
extends Node

@export_subgroup("Nodes")
@export var animated_sprite: AnimatedSprite2D

@export_subgroup("Settings")
@export var x_deadzone: float = 5.0
@export var y_deadzone: float = 5.0
@export var idle_animation: StringName = &"idle"
@export var run_animation: StringName = &"run"
@export var jump_animation: StringName = &"jump"
@export var fall_animation: StringName = &"jump"
@export var death_animation: StringName = &"death"
@export var shield_animation: StringName = &"shield"
@export var gun_animation: StringName = &"gun"
@export var sword_animation: StringName = &"sword"

var _facing_sign: int = 1

func update_animation(body: CharacterBody2D) -> void:
	if animated_sprite == null:
		return

	_update_facing(body.velocity.x)
	animated_sprite.flip_h = _facing_sign < 0

	var next_animation := _select_animation(body)
	if next_animation != &"" and (animated_sprite.animation != next_animation or not animated_sprite.is_playing()):
		animated_sprite.play(next_animation)

# Select animation based on movement and player state.
func _select_animation(body: CharacterBody2D) -> StringName:
	if body.has_method("die") and bool(body.get("is_dead")):
		return _valid_animation(death_animation, idle_animation)

	if not body.is_on_floor():
		if body.velocity.y < -y_deadzone:
			#checks if player has gun is true 
			if _has_flag(body, "has_gun", "grant_gun"):
				return _valid_animation(gun_animation, jump_animation)
			if _has_flag(body, "has_sword", "grant_sword"):
				return _valid_animation(sword_animation, jump_animation)
			return _valid_animation(jump_animation, idle_animation)
		return _valid_animation(fall_animation, jump_animation)

	if abs(body.velocity.x) > x_deadzone:
		if _has_flag(body, "has_shield", "grant_shield"):
			return _valid_animation(shield_animation, run_animation)
		return _valid_animation(run_animation, idle_animation)
	return _valid_animation(idle_animation, run_animation)

#change direction of sprite depending on velocity
func _update_facing(x_velocity: float) -> void:
	if x_velocity > x_deadzone:
		_facing_sign = 1
	elif x_velocity < -x_deadzone:
		_facing_sign = -1

func _valid_animation(primary: StringName, fallback: StringName) -> StringName:
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(primary):
		return primary
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(fallback):
		return fallback
	return &""

func _has_flag(body: CharacterBody2D, flag_name: String, grant_method: String) -> bool:
	return body.has_method(grant_method) and bool(body.get(flag_name))
