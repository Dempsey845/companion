extends State

@onready var chase_state: Node = $"../ChaseState"

func enter():
	print("Entered Idle")
	
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")

func physics_update(_delta: float):
	if actor.is_target_in_range():
		state_machine.change_state(chase_state)
