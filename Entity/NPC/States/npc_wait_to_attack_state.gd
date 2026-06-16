extends State

@export var npc: NPC
@export var target_manager: NPCTargetManager
@export var target_search_area: NPCTargetSearchArea

@export var idle_state: State

var min_distance_from_target: float = 6.0
var min_distance_from_target_sq: float = min_distance_from_target * min_distance_from_target

var combat_update_timer: float

var targets_combat_target: Node3D

func enter():
	npc.get_node("CombatStatusLabel").text = "Waiting"

func update(_delta: float):
	var distance_to_target_sq = actor.global_position.distance_squared_to(target_manager.target.global_position)
	
	if distance_to_target_sq > min_distance_from_target_sq:
		actor.set_target_position(target_manager.target.global_position)
		actor.move = true
	elif distance_to_target_sq < min_distance_from_target_sq / 2.0:
		var retreat_direction = (actor.global_position - target_manager.target.global_position).normalized()
		actor.set_target_position(
		actor.global_position + retreat_direction * 2.0
		)
		actor.move = true
	else:
		actor.move = false
