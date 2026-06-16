class_name NPCHealthManager
extends Node

@export var health: Health

@export var state_machine: StateMachine
@export var retreat_state: State

func _ready() -> void:
	health.death.connect(_on_npc_died)

func _on_npc_died():
	print("NPC DIED")
	get_parent().queue_free()

func start_retreat_on_low_health():
	health.damage_taken.connect(_on_npc_damage_taken)

func stop_retreat_on_low_health():
	health.damage_taken.disconnect(_on_npc_damage_taken)

func _on_npc_damage_taken(_damage_amount: int):
	if health.current_heatlh < float(health.max_health) / 2:
		state_machine.change_state(retreat_state)