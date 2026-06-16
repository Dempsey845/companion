extends State

@export var npc: NPC

@onready var wander_state: Node = $'../WanderState'

func enter():
	print("Entered Idle")

	npc.get_node("CombatStatusLabel").text = "Calm"
	
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
	
	state_machine.change_state(wander_state)
		
