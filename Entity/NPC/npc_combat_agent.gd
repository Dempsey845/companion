class_name NPCCombatAgent
extends Node

var npc: NPC
var defender_npc: NPC

var state_machine: StateMachine
var chase_state: State

var target_manager: NPCTargetManager

func _ready() -> void:
	assert(get_parent() is NPC, "NPC CombatAgent has been added to a non-NPC!")

	npc = get_parent()

	assert(!npc.has_node("NPCDefenderAgent"), "NPC can not be an attacker and defender!")

	defender_npc = target_manager.target

	state_machine = npc.state_machine

	chase_state = state_machine.get_node("ChaseState")

	var attack_state = state_machine.get_node("AttackState")
	attack_state.change_state_independently = false

	# For testing only
	npc.get_node("CombatStatusLabel").text = "Attacker"
	defender_npc.get_node("CombatStatusLabel").text = "Defender"

	state_machine.change_state.call_deferred(chase_state)

func _on_defender_retreat():
	state_machine.change_state(chase_state)
