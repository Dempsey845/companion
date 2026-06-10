extends State

@export var target: Node3D

@onready var target_update_timer: Timer = $TargetUpdateTimer

func _ready() -> void:
	target_update_timer.timeout.connect(_on_target_update_timer_timeout)

func enter():
	print("Entered Chase")
	
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
		
	actor.move = true
	target_update_timer.start()
	
func exit():
	target_update_timer.stop()
	
func _on_target_update_timer_timeout():
	actor.set_target_position(target.global_position)
