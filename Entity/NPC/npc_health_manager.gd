extends Node

@export var health: Health

func _ready() -> void:
	health.death.connect(_on_npc_died)

func _on_npc_died():
	print("NPC DIED")
	get_parent().queue_free()

