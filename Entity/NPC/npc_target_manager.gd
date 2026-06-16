class_name NPCTargetManager
extends Node

@export var npc: NPC

var _target: Node3D
var target: Node3D:
	get():
		return _target
	set(value):
		_target = value

var target_time: float

func _process(delta: float) -> void:
	if target:
		npc.look_at_point(target.global_position)
		target_time += delta
	else:
		target_time = 0.0

func set_target(new_target: Node3D):
	if is_instance_valid(new_target) and new_target != target:
		target = new_target

		if target.has_node("Health"):
			var target_health: Health = target.get_node("Health")
			if not target_health.death.is_connected(_on_target_death):
				target_health.death.connect(_on_target_death)

func clear_target():
	if target.has_node("Health"):
		var target_health: Health = target.get_node("Health")
		if target_health.death.is_connected(_on_target_death):
			target_health.death.disconnect(_on_target_death)

	target = null
	npc.clear_look_target()
	target_time = 0.0

func _on_target_death():
	clear_target()