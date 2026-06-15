class_name NPCManager
extends Node

# Experimental (might remove later)

static var instance: NPCManager

var npc_to_combat_state: Dictionary[NPC, bool]

func _ready() -> void:
	instance = self

	var npcs := get_tree().get_nodes_in_group("NPC")
	for npc: NPC in npcs:
		var npc_target_manager: NPCTargetManager = npc.get_node("NPCTargetManager")
		npc_to_combat_state[npc] = false
		npc_target_manager.started_combat.connect(_on_combat_started)
		npc_target_manager.combat_ended.connect(_on_combat_ended)

func _on_combat_started(started_by: NPC, agaisnt: NPC):
	npc_to_combat_state[started_by] = true
	npc_to_combat_state[agaisnt] = true

func _on_combat_ended(ended_by: NPC):
	npc_to_combat_state[ended_by] = false

func is_npc_in_combat(npc: NPC):
	return npc_to_combat_state[npc] 
