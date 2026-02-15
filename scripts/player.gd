extends CharacterBody2D


@onready var _animated_sprite = $AnimatedSprite2D
@export_subgroup("Nodes")

@export var gravity_component: GravityComponent
@export var movement_component: MovementComponent


func _physics_process(delta:float) -> void:
	
	gravity_component.handle_gravity(self,delta)
	movement_component.get_input(self,delta)
	move_and_slide()
