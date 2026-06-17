extends State

signal attack_started

@export_category("Combat")
@export var attack_cooldown_duration_min: float = 2.5
@export var attack_cooldown_duration_max: float = 3.0

@export_category("Dependencies")
@export var weapon_manager: NPCWeaponManager
@export var target_manager: NPCTargetManager
@export var combat_data: NPCCombatData
@export var chase_state: State

var attack_cooldown_time: float
var change_state_independently: bool = true

var time_away_from_target: float

const DURATION_AWAY_FROM_TARGET_TO_CHASE: float = 1.0
const MAX_START_ATTACK_DELAY: float = 0.5

func enter():
	actor.move = false
	attack_started.emit()
	attack_cooldown_time = randf_range(0.0, MAX_START_ATTACK_DELAY)

	time_away_from_target = 0.0

func exit():
	attack_cooldown_time = randf_range(attack_cooldown_duration_min, attack_cooldown_duration_max)

func update(delta: float):
	if target_manager.target == null or not is_instance_valid(target_manager.target):
		return

	handle_attack(delta)
	handle_target_distance(delta)
	
func handle_attack(delta: float):
	attack_cooldown_time -= delta
	if attack_cooldown_time <= 0:
		if weapon_manager.try_use_current_weapon():
			attack_cooldown_time = randf_range(attack_cooldown_duration_min, attack_cooldown_duration_max)

func handle_target_distance(delta: float):
	var distance_to_target_sq = actor.global_position.distance_squared_to(target_manager.target.global_position)

	if distance_to_target_sq > combat_data.attack_distance_sq:
		time_away_from_target += delta

		if time_away_from_target > DURATION_AWAY_FROM_TARGET_TO_CHASE:
			state_machine.change_state(chase_state)
	else:
		time_away_from_target = 0.0