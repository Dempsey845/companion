class_name NPCCombatManager
extends Node

signal combat_target_found
signal combat_target_death

@export var target_manager: NPCTargetManager
@export var target_search_area: NPCTargetSearchArea
@export var health_manager: NPCHealthManager

@export var state_machine: StateMachine
@export var chase_state: State
@export var wander_state: State

@onready var target_search_timer: Timer = $TargetSearchTimer

func _ready() -> void:
	target_search_timer.timeout.connect(_on_target_search_timer_timeout)

	start_combat_search()

func start_combat_search():
	_on_target_search_timer_timeout()
	target_search_timer.start()

func stop_combat_search():
	target_search_timer.stop()

func _disconnect_current_target():
	if !is_instance_valid(target_manager) or target_manager.target == null:
		return

	var health: Health = target_manager.target.get_node("Health")
	if health.death.is_connected(_on_target_death):
		health.death.disconnect(_on_target_death)
		health_manager.stop_retreat_on_low_health()

func _set_target(target: Node3D):
	_disconnect_current_target()

	target_manager.target = target
	combat_target_found.emit()
	state_machine.change_state(chase_state)

	var target_health: Health = target.get_node("Health")
	if !target_health.death.is_connected(_on_target_death):
		target_health.death.connect(_on_target_death)
		health_manager.start_retreat_on_low_health()

func _on_target_death():
	target_manager.clear_target()
	state_machine.change_state(wander_state)
	health_manager.stop_retreat_on_low_health()
	combat_target_death.emit()

func _on_target_search_timer_timeout():
	var closest_target = target_search_area.find_closest_target()
	if closest_target and closest_target != target_manager.target:
		_set_target(closest_target)
