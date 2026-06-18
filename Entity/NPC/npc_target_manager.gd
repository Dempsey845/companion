class_name NPCTargetManager
extends Node

@export var npc: NPC

var target: Node3D

func _process(_delta: float) -> void:
	if target:
		npc.look_at_point(target.global_position)

func clear_target():
	target = null
	npc.clear_look_target()
