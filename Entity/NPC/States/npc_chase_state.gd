extends State

@export var target: Node3D
@onready var target_update_timer: Timer = $TargetUpdateTimer

@export var weapon_manager: NPCWeaponManager

func _ready() -> void:
	target_update_timer.timeout.connect(_on_target_update_timer_timeout)

func enter():
	print("Entered Chase")
	
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
		
	target_update_timer.start()
	
	weapon_manager.start_using_weapon.call_deferred()
	
func exit():
	actor.move = false
	target_update_timer.stop()
	weapon_manager.stop_using_weapon()
	
func _on_target_update_timer_timeout():
	actor.set_target_position(target.global_position)
	actor.move = true
