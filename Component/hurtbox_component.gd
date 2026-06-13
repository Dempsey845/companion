class_name Hurtbox
extends Area3D

@export var health_component: Health

func register_hit(damage: int):
	health_component.take_damage(damage)
