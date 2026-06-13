extends State

@export var target: Node3D
@export var attack_distance: float = 2.0
@export var weapon_manager: NPCWeaponManager

@onready var target_update_timer: Timer = $TargetUpdateTimer
@onready var attack_distance_sq = attack_distance * attack_distance
@onready var distance_check_timer: Timer = $DistanceCheckTimer

func _ready() -> void:
	target_update_timer.timeout.connect(_on_target_update_timer_timeout)
	distance_check_timer.timeout.connect(_on_distance_check_timer_timeout)

func enter():
	print("Entered Chase")
	
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
		
	target_update_timer.start()
	distance_check_timer.start()
	
func update(_delta: float):
	actor.look_at_point(target.global_position)
	
func exit():
	actor.move = false
	target_update_timer.stop()
	distance_check_timer.stop()
	weapon_manager.stop_using_weapon()
	actor.clear_look_target()
	
func _on_target_update_timer_timeout():
	actor.set_target_position(target.global_position)
	actor.move = true

func _on_distance_check_timer_timeout():
	var distance_sq_to_target = actor.global_position.distance_squared_to(target.global_position)
	print(distance_sq_to_target)
	
	if distance_sq_to_target < attack_distance_sq:
		weapon_manager.try_use_current_weapon()
		
