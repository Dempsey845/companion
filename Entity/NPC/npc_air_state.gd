class_name NPCAirState
extends Node

signal falling_started
signal falling_ended
signal landed

@export var character_body: CharacterBody3D

var was_on_floor := true

func _process(_delta: float) -> void:
	if character_body == null:
		return

	var is_on_floor := character_body.is_on_floor()
	var velocity := character_body.velocity
	
	# FALLING START
	if not is_on_floor and velocity.y < 0.0:
		if was_on_floor:
			falling_started.emit()

	# FALLING END
	if is_on_floor and not was_on_floor:
		falling_ended.emit()
		landed.emit()


	was_on_floor = is_on_floor
