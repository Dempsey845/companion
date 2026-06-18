extends State

@export var combat_data: NPCCombatData
@export var target_manager: NPCTargetManager
@export var target_search_area: NPCTargetSearchArea

@onready var target_update_timer: Timer = $TargetUpdateTimer
@onready var attack_state: Node = $'../AttackState'

var ideal_time: float

func _ready() -> void:
	target_update_timer.timeout.connect(_on_target_update_timer_timeout)

func enter():
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
	
	start_timers()
	
func start_timers():
	target_update_timer.start()
	
func exit():
	actor.move = false
	target_update_timer.stop()
	
func update(delta: float):
	if !is_instance_valid(target_manager) or target_manager.target == null or not is_instance_valid(target_manager.target):
		return

	var distance_to_target = actor.global_position.distance_to(target_manager.target.global_position)

	if distance_to_target > combat_data.attack_distance:
		# Move closer
		ideal_time = 0.0
		actor.move = true
	elif distance_to_target < combat_data.min_attack_seperation_distance:
		# Move backwards
		ideal_time = 0.0
		var retreat_direction = (actor.global_position - target_manager.target.global_position).normalized()
		actor.set_target_position(
			actor.global_position + retreat_direction * 2.0
		)
		actor.move = true
	else:
		# Ideal range
		actor.move = false
		ideal_time += delta
		if ideal_time > 1.5:
			state_machine.change_state(attack_state)
	
func _on_target_update_timer_timeout():
	if target_manager.target:
		actor.set_target_position(target_manager.target.global_position)
