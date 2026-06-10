extends State

func enter():
	print("Entered Chase")
	
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")
	
	actor.chase_target = true

func update(_delta: float):
	pass
