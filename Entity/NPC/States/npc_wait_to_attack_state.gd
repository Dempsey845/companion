extends State

@export var npc: NPC
@export var target_manager: NPCTargetManager
@export var combat_manager: NPCCombatManager

@export var idle_state: State

var min_distance_from_target: float = 6.0
var min_distance_from_target_sq: float = min_distance_from_target * min_distance_from_target

var targets_combat_target: Node3D

func enter():
	npc.get_node("CombatStatusLabel").text = "Waiting"

	target_manager.target_changed.connect(_on_target_changed)

func update(_delta: float):
	combat_manager.try_start_combat_with_target()

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

func exit():
	combat_manager.waiting_for_target = false

func _on_target_changed():
	state_machine.change_state(idle_state)
