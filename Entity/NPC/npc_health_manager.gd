extends Node

@export var health: Health

@export var combat_manager: NPCCombatManager
@export var state_machine: StateMachine
@export var retreat_state: State

func _ready() -> void:
	health.death.connect(_on_npc_died)
	health.damage_taken.connect(_on_npc_damage_taken)

func _on_npc_died():
	print("NPC DIED")
	get_parent().queue_free()

func _on_npc_damage_taken(_damage_amount: int):
	if health.current_heatlh < float(health.max_health) / 2 and combat_manager.is_in_combat():
		state_machine.change_state(retreat_state)