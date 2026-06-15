class_name NPCCombatAgent
extends Node

# This node decides which NPC in combat is the attacker/defender
# Who ever the node belongs to is the attacker
# It will manager the states of both NPCs

var attacker_npc: NPC
var defender_npc: NPC
var target_manager: NPCTargetManager

func _ready() -> void:
	assert(get_parent() is not NPC, "NPC CombatAgent has been added to a non-NPC!")
	
	attacker_npc = get_parent()
	defender_npc = target_manager.target
	
	# Prevent multiple combat agents
	var other_combat_agent = defender_npc.get_node_or_null("NPCCombatAgent")
	if other_combat_agent != null and is_instance_valid(other_combat_agent):
		other_combat_agent.queue_free()
