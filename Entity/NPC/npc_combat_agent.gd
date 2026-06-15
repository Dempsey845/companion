class_name NPCCombatAgent
extends Node

# This node decides which NPC in combat is the attacker/defender
# Who ever the node belongs to is the attacker
# It will manager the states of both NPCs

var attacker_npc: NPC
var defender_npc: NPC

var attacker_npc_state_machine: StateMachine
var defender_npc_state_machine: StateMachine

var attacker_npc_chase_state: State
var defender_npc_retreat_state: State

var target_manager: NPCTargetManager

var attack_time: float
var has_attack_started: bool

var retreat_rate: float = 3.0

func _ready() -> void:
	assert(get_parent() is NPC, "NPC CombatAgent has been added to a non-NPC!")
	
	attacker_npc = get_parent()
	defender_npc = target_manager.target

	attacker_npc_state_machine = attacker_npc.get_node("StateMachine")
	defender_npc_state_machine = defender_npc.get_node("StateMachine")

	attacker_npc_chase_state = attacker_npc_state_machine.get_node("ChaseState")
	defender_npc_retreat_state = defender_npc_state_machine.get_node("RetreatState")

	var attacker_attack_state = attacker_npc_state_machine.get_node("AttackState")
	var defender_attack_state = defender_npc_state_machine.get_node("AttackState")

	attacker_attack_state.attack_started.connect(_on_attacker_npc_attack_started)
	defender_attack_state.attack_started.connect(_on_defender_npc_attack_started)

	attacker_attack_state.change_state_independently = false
	defender_attack_state.change_state_independently = false

	# For testing only
	attacker_npc.get_node("CombatStatusLabel").text = "Attacker"
	defender_npc.get_node("CombatStatusLabel").text = "Defender"

	target_manager.target_died.connect(_on_target_died)

func _process(delta: float) -> void:
	if has_attack_started:
		attack_time += delta

		if attack_time > retreat_rate:
			attack_time = 0.0
			has_attack_started = false

			defender_npc_state_machine.change_state(defender_npc_retreat_state)
			
			await get_tree().create_timer(1.0).timeout

			attacker_npc_state_machine.change_state(attacker_npc_chase_state)

func _on_attacker_npc_attack_started():
	pass

func _on_defender_npc_attack_started():
	has_attack_started = true

func _on_target_died():
	queue_free()
