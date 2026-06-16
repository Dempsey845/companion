class_name NPCTargetSearchArea
extends Area3D

enum TargetFilter
{
	Player,
	Warrior,
	Both,
	NPC
}

@export var target_filter: TargetFilter

func find_closest_target() -> Node3D:
	var overlapping_bodies := get_overlapping_bodies()
	overlapping_bodies.shuffle()
	
	overlapping_bodies = overlapping_bodies.filter(func(body): return body != get_parent())
	
	match target_filter:
		TargetFilter.Player:
			overlapping_bodies = overlapping_bodies.filter(func(body): return body is Player)
		TargetFilter.Warrior:
			overlapping_bodies = overlapping_bodies.filter(func(body): return body is Warrior)
		TargetFilter.NPC:
			overlapping_bodies = overlapping_bodies.filter(func(body): return body is NPC and body is not Warrior)
	
	var closest_distance_sq := -1.0
	var closest_target: Node3D = null
	
	for body in overlapping_bodies:
		var distance_to_target_sq = global_position.distance_squared_to(body.global_position)
		if distance_to_target_sq > closest_distance_sq:
			closest_target = body
			closest_distance_sq = distance_to_target_sq
	
	return closest_target
