extends State

@export var attack_distance: float = 2.0
@export var min_attack_seperation_distance: float = 1.25
@export var weapon_manager: NPCWeaponManager
@export var skeleton: HumanoidSkeleton 
@export var target_search_area: NPCTargetSearchArea

@onready var target_update_timer: Timer = $TargetUpdateTimer
@onready var attack_distance_sq = attack_distance * attack_distance
@onready var distance_check_timer: Timer = $DistanceCheckTimer
@onready var wander_state: Node = $"../WanderState"

var target: Node3D
var minimum_chase_duration: float = 5.0
var chase_time: float = 0.0
var attack_time: float = 0.0
var can_attack: bool

func _ready() -> void:
	target_update_timer.timeout.connect(_on_target_update_timer_timeout)
	distance_check_timer.timeout.connect(_on_distance_check_timer_timeout)

func enter():
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
		
	chase_time = 0.0
	
	if target == null:
		target = target_search_area.find_closest_target()
		if target == null:
			state_machine.change_state(wander_state)
			return
			
	sheath_weapon.call_deferred()
	
func start_timers():
	target_update_timer.start()
	distance_check_timer.start()
	
func sheath_weapon():
	skeleton.play_upper_body_animation("Sheath", 1.2)
	await get_tree().create_timer(0.5).timeout
	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.RightHand)
	can_attack = true
	
	start_timers.call_deferred()
	
func withdraw_weapon():
	skeleton.play_upper_body_animation("Sheath", 1.2)
	await get_tree().create_timer(0.5).timeout
	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.Back)
	can_attack = true
	
func update(delta: float):
	actor.look_at_point(target.global_position)
	
	chase_time += delta
	
func exit():
	target = null
	actor.move = false
	attack_time = 0.0
	target_update_timer.stop()
	distance_check_timer.stop()
	actor.clear_look_target()
	withdraw_weapon()
	
func _on_target_update_timer_timeout():
	var distance_to_target = actor.global_position.distance_to(target.global_position)

	if distance_to_target > attack_distance:
		# Move closer
		actor.set_target_position(target.global_position)
		actor.move = true
	elif distance_to_target < min_attack_seperation_distance:
		# Move backwards
		var retreat_direction = (actor.global_position - target.global_position).normalized()
		actor.set_target_position(
			actor.global_position + retreat_direction * 2.0
		)
		actor.move = true
	else:
		# Ideal range
		actor.move = false


func _on_distance_check_timer_timeout():
	var distance_sq_to_target = actor.global_position.distance_squared_to(target.global_position)

	# Attack when within attack range but not too close
	if (
		distance_sq_to_target < attack_distance_sq
		and distance_sq_to_target > min_attack_seperation_distance * min_attack_seperation_distance
		and can_attack
	):
		weapon_manager.try_use_current_weapon()
		attack_time += distance_check_timer.wait_time
	else:
		attack_time = 0.0

	if distance_sq_to_target > 80.0 and chase_time > minimum_chase_duration:
		state_machine.change_state(wander_state)
