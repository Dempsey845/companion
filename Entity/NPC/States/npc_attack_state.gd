extends State

signal attack_started

@export var weapon_manager: NPCWeaponManager
@export var target_manager: NPCTargetManager
@export var combat_data: NPCCombatData
@export var chase_state: State

var attack_cooldown_time: float
var change_state_independently: bool = true

var time_away_from_target: float

const DURATION_AWAY_FROM_TARGET_TO_CHASE = 1.0

func enter():
	actor.move = false
	attack_started.emit()
	attack_cooldown_time = randf_range(0.0, 0.7)

	time_away_from_target = 0.0

func exit():
	attack_cooldown_time = randf_range(2.5, 3.5)

func update(delta: float):
	attack_cooldown_time -= delta
	if attack_cooldown_time <= 0:
		if weapon_manager.try_use_current_weapon():
			attack_cooldown_time = randf_range(2.5, 3.5)

	var distance_to_target_sq = actor.global_position.distance_squared_to(target_manager.target.global_position)

	if distance_to_target_sq > combat_data.attack_distance_sq:
		time_away_from_target += delta

		if time_away_from_target > DURATION_AWAY_FROM_TARGET_TO_CHASE:
			state_machine.change_state(chase_state)
	else:
		time_away_from_target = 0.0
