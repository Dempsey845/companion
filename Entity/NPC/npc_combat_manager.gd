class_name NPCCombatManager
extends Node

@export var npc: NPC

@export var state_machine: StateMachine
@export var chase_state: State
@export var retreat_state: State
@export var wait_to_attack_state: State

@export var skeleton: HumanoidSkeleton 
@export var weapon_manager: NPCWeaponManager
@export var target_manager: NPCTargetManager

var is_weapon_sheathed: bool = true

var combat_target: Node3D
var target_combat_manager: NPCCombatManager

var waiting_for_target: bool

func try_start_combat_with_target():
	if target_manager.target == null:
		return

	var target = target_manager.target

	# already engaged with this target
	if combat_target and target == combat_target:
		return

	if target is NPC:
		var other: NPCCombatManager = target.get_node("NPCCombatManager")

		if other.is_in_combat() and other.combat_target != npc:
			if not waiting_for_target:
				state_machine.change_state(wait_to_attack_state)
				waiting_for_target = true
			return

		target_combat_manager = other

	state_machine.change_state(chase_state)

	combat_target = target

	var target_health: Health = target.get_node("Health")
	target_health.death.connect(_on_target_death)

	print("Combat started")
	withdraw_weapon()


func stop_combat():
	target_combat_manager = null
	combat_target = null

	print("Combat stopped")

	_sheath_weapon()


func can_attack() -> bool:
	return not is_weapon_sheathed


func withdraw_weapon():
	if not is_weapon_sheathed:
		return

	is_weapon_sheathed = false
	skeleton.play_upper_body_animation("Sheath", 1.2)

	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self):
		return

	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.RightHand)


func _sheath_weapon():
	if is_weapon_sheathed:
		return

	is_weapon_sheathed = true
	skeleton.play_upper_body_animation("Sheath", 1.2)

	await get_tree().create_timer(0.5).timeout
	if not is_instance_valid(self):
		return

	weapon_manager.item_manager.requip_current_item(NPCItemManager.ItemSlot.Back)


func is_in_combat() -> bool:
	return combat_target != null

func _on_target_death():
	stop_combat()
