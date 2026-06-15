class_name Hitbox
extends Area3D

signal hit_hurtbox(hurtbox: Hurtbox)

@export var damage: int

@export var active: bool = true

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D):
	if area is not Hurtbox or not active:
		return
	
	area.register_hit(damage)
	hit_hurtbox.emit(area)
