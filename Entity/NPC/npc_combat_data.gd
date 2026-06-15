class_name NPCCombatData
extends Node

@export var attack_distance: float = 2.0
@export var min_attack_seperation_distance: float = 1.25

@onready var attack_distance_sq = attack_distance * attack_distance
