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

var is_weapon_sheathed: bool = true
var target: Node3D

func try_find_closest_target() -> bool:
	target = target_search_area.find_closest_target()
	
	if target != null:
		withdraw_weapon()

		var target_type := get_current_target_type()
		if target_type == TargetType.NPC:
			# Create a npc combat agent
			if not target.has_node("NPCCombatAgent"):
				pass
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
