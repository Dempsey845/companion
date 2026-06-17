class_name NPCCombatManager
extends Node

signal combat_target_found
signal combat_target_death

@export var target_manager: NPCTargetManager
@export var target_search_area: NPCTargetSearchArea

@export var state_machine: StateMachine
@export var chase_state: State
@export var wander_state: State

func _process(_delta: float) -> void:
	if target_manager.target == null:
		var closest_target = target_search_area.find_closest_target()
		if closest_target:
			_set_target(closest_target)
			
func _set_target(target: Node3D):
	target_manager.set_target(target)
	combat_target_found.emit()
	state_machine.change_state(chase_state)

	var target_health: Health = target.get_node("Health")
	target_health.death.connect(_on_target_death)

func change_combat_target(target: Node3D):
	if is_instance_valid(target_manager.target):
		var target_health: Health = target_manager.target.get_node("Health")
		target_health.death.disconnect(_on_target_death)

	_set_target(target)

func _on_target_death():
	combat_target_death.emit()
	state_machine.change_state(wander_state)
