extends State

@export var combat_data: NPCCombatData
@export var weapon_manager: NPCWeaponManager
@export var target_manager: NPCTargetManager

@onready var chase_state: State = $'../ChaseState'

var control_state_independently: bool = true # Determines whether an agent should control the exiting of this state

func enter():
	actor.move = false
	print("Attack state entered")

func exit():
	print("Attack state exited")

func update(_delta: float):
	weapon_manager.try_use_current_weapon()


# if control_state_independently:
# 	var distance_sq_to_target = actor.global_position.distance_squared_to(target_manager.target.global_position)
# 	if distance_sq_to_target > combat_data.attack_distance_sq \
# 	or distance_sq_to_target < combat_data.min_attack_seperation_distance:
# 		state_machine.change_state(chase_state)
