extends State

@onready var wander_state: Node = $'../WanderState'

func enter():
	print("Entered Idle")
	
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
	
	state_machine.change_state(wander_state)
		
