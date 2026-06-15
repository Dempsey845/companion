class_name NPCManager
extends Node

# Experimental (might remove later)

signal combat_ended(npc: NPC)

static var instance: NPCManager

var npc_combat_pairs: Dictionary[NPC, NPC]

func _ready() -> void:
	instance = self

func try_register_npc_combat_pair(attacker_npc: NPC, defender_npc: NPC) -> bool:
	if attacker_npc == defender_npc:
		return false

	if npc_combat_pairs.has(attacker_npc) or npc_combat_pairs.has(defender_npc):
		return false

	npc_combat_pairs[attacker_npc] = defender_npc
	npc_combat_pairs[defender_npc] = attacker_npc

	if not attacker_npc.death.is_connected(_on_npc_death):
		attacker_npc.death.connect(_on_npc_death)

	if not defender_npc.death.is_connected(_on_npc_death):
		defender_npc.death.connect(_on_npc_death)

	return true

func remove_combat_agents_from_npc(npc: NPC):
	if npc.has_node("NPCCombatAgent"):
		npc.get_node("NPCCombatAgent").queue_free()
	if npc.has_node("NPCDefenderAgent"):
		npc.get_node("NPCDefenderAgent").queue_free()

func stop_combat_for_npc(npc: NPC):
	if not npc_combat_pairs.has(npc):
		return

	var opposing_npc:NPC = npc_combat_pairs[npc]

	if is_instance_valid(npc):
		_clean_npc_from_combat(npc)
		combat_ended.emit(npc)
	
	if is_instance_valid(opposing_npc):
		_clean_npc_from_combat(opposing_npc)
		combat_ended.emit(opposing_npc)

	_clear_combat_pair(npc)

func _clear_combat_pair(npc: NPC):
	if !npc_combat_pairs.has(npc):
		return

	var opposing_npc := npc_combat_pairs[npc]

	npc_combat_pairs.erase(npc)

	if npc_combat_pairs.has(opposing_npc):
		npc_combat_pairs.erase(opposing_npc)
	
	_disconnect_death_signal(npc)
	_disconnect_death_signal(opposing_npc)

func _on_npc_death(npc: NPC):
	if not npc_combat_pairs.has(npc):
		return

	var opposing_npc:NPC = npc_combat_pairs[npc]

	_clean_npc_from_combat(opposing_npc)
	_clear_combat_pair(npc)

func _clean_npc_from_combat(npc: NPC):
	if is_instance_valid(npc):
		remove_combat_agents_from_npc(npc)
		if is_instance_valid(npc.state_machine):
			npc.state_machine.change_state(npc.state_machine.get_node("IdleState"))

func _disconnect_death_signal(npc: NPC):
	if is_instance_valid(npc) and npc.death.is_connected(_on_npc_death):
		npc.death.disconnect(_on_npc_death)