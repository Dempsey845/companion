class_name NPCTargetManager
extends Node

enum TargetType
{
	NPC,
	Player,
	Other
}

@export var npc: NPC
@export var target_search_area: NPCTargetSearchArea
@export var skeleton: HumanoidSkeleton 
@export var weapon_manager: NPCWeaponManager

@export var npc_state_machine: StateMachine
@export var npc_idle_state: State 
@export var npc_wait_to_attack_state: State

var combat_agent_scene: PackedScene = preload("uid://t6l7i71p7q7v")
var defender_agent_scene: PackedScene = preload("uid://doly0bktw68sy")

var is_weapon_sheathed: bool = true

var _target: Node3D
var target: Node3D:
	get():
		return _target
	set(value):
		var last_target = _target
		_target = value
		if value and value.has_node("Health"):
			if is_instance_valid(last_target) and last_target.has_node("Health"):
				last_target.get_node("Health").death.disconnect(_on_target_death)

			var health = value.get_node("Health")

			if not health.death.is_connected(_on_target_death):
				health.death.connect(_on_target_death)

var in_combat : bool = false

func _ready() -> void:
	NPCManager.instance.combat_ended.connect(_on_combat_ended)

func try_find_closest_target() -> bool:
	var closest_target = target_search_area.find_closest_target()

	# Only targetting NPCs for now
	if closest_target == null or \
		closest_target == target or \
		get_target_type(closest_target) != TargetType.NPC:
		return false

	if target == null:
		return try_start_combat_with_target(closest_target)

	return false

func try_start_combat_with_target(npc_target: NPC) -> bool:
	target = npc_target

	if NPCManager.instance.try_register_npc_combat_pair(npc, npc_target):
		npc_target.target_manager.start_combat()
		npc_target.target_manager.target = npc

		var combat_agent := combat_agent_scene.instantiate() as NPCCombatAgent
		combat_agent.target_manager = self

		npc.add_child(combat_agent, true)
		npc_target.add_child(defender_agent_scene.instantiate(), true)

		start_combat()

		return true

	npc.state_machine.change_state(npc_wait_to_attack_state)

	return false


func start_combat():
	print("Combat started")
	in_combat = true
	_withdraw_weapon()


func get_current_target_type() -> TargetType:
	return get_target_type(target)

func get_target_type(target_node: Node3D) -> TargetType:
	if target_node is NPC:
		return TargetType.NPC
	elif target_node is Player:
		return TargetType.Player
		
	return TargetType.Other

func can_attack() -> bool:
	return not is_weapon_sheathed

func _clear_target():
	_sheath_weapon()
	target = null
	npc.clear_look_target()
	in_combat = false

func _on_combat_ended(combat_npc: NPC):
	if combat_npc == npc or \
	(get_current_target_type() == TargetType.NPC and combat_npc == target):
		_clear_target()

func _process(_delta: float) -> void:
	if target:
		npc.look_at_point(target.global_position)

func _withdraw_weapon():
	if not is_weapon_sheathed:
		return

	skeleton.play_upper_body_animation("Sheath", 1.2)
	await get_tree().create_timer(0.5).timeout
	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.RightHand)
	is_weapon_sheathed = false
	
func _sheath_weapon():
	if is_weapon_sheathed:
		return

	skeleton.play_upper_body_animation("Sheath", 1.2)
	await get_tree().create_timer(0.5).timeout
	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.Back)
	is_weapon_sheathed = true

func _on_target_death():
	_clear_target()
