class_name NPCTargetManager
extends Node

signal target_died
signal started_combat(started_by: NPC, agaisnt: NPC)
signal combat_ended(ended_by: NPC)

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

var combat_agent_scene: PackedScene = preload("uid://t6l7i71p7q7v")
var defender_agent_scene: PackedScene = preload("uid://doly0bktw68sy")

var is_weapon_sheathed: bool = true
var target: Node3D

# TODO: Optimize this function
func is_npc_in_combat(target_npc: NPC):
	return target_npc.has_node("NPCCombatAgent") or target_npc.has_node("NPCDefenderAgent")

func try_find_closest_target() -> bool:
	if target:
		return true

	target = target_search_area.find_closest_target()
	
	if target != null:
		withdraw_weapon()

		if target.has_node("Health"):
			var target_health: Health = target.get_node("Health")
			target_health.death.connect(_on_target_died)

		var target_type := get_current_target_type()
		if target_type == TargetType.NPC:
			# Check to see if the target or this npc is already in combat
			if is_npc_in_combat(target) or is_npc_in_combat(get_parent()):
				return false

			var combat_agent := combat_agent_scene.instantiate() as NPCCombatAgent
			combat_agent.target_manager = self

			get_parent().add_child(combat_agent, true)
			target.add_child(defender_agent_scene.instantiate(), true)

			started_combat.emit(get_parent(), target)
	else:
		sheath_weapon()
	
	return target != null

func clear_target():
	target = null
	npc.clear_look_target()

func get_current_target_type() -> TargetType:
	if target is NPC:
		return TargetType.NPC
	elif target is Player:
		return TargetType.Player
		
	return TargetType.Other

func withdraw_weapon():
	if not is_weapon_sheathed:
		return

	skeleton.play_upper_body_animation("Sheath", 1.2)
	await get_tree().create_timer(0.5).timeout
	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.RightHand)
	is_weapon_sheathed = false
	

func _process(_delta: float) -> void:
	if target:
		npc.look_at_point(target.global_position)
	
func sheath_weapon():
	if is_weapon_sheathed:
		return

	skeleton.play_upper_body_animation("Sheath", 1.2)
	await get_tree().create_timer(0.5).timeout
	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.Back)
	is_weapon_sheathed = true

func can_attack() -> bool:
	return not is_weapon_sheathed

func _on_target_died():
	npc_state_machine.change_state(npc_idle_state)
	combat_ended.emit(get_parent())
	target_died.emit()
