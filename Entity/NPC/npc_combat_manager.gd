extends Node

@export var skeleton: HumanoidSkeleton 
@export var weapon_manager: NPCWeaponManager
@export var target_manager: NPCTargetManager
@export var target_search_area: NPCTargetSearchArea

@export var state_machine: StateMachine
@export var chase_state: State
@export var wander_state: State


var is_weapon_sheathed: bool = true

func _process(_delta: float) -> void:
	if target_manager.target == null:
		var closest_target = target_search_area.find_closest_target()
		if closest_target:
			_set_target(closest_target)
			
func _set_target(target: Node3D):
	target_manager.set_target(target)
	_withdraw_weapon()
	state_machine.change_state(chase_state)

	var target_health: Health = target.get_node("Health")
	target_health.death.connect(_on_target_death)

func _withdraw_weapon():
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

func change_combat_target(target: Node3D):
	if is_instance_valid(target_manager.target):
		var target_health: Health = target_manager.target.get_node("Health")
		target_health.death.disconnect(_on_target_death)

	_set_target(target)

func _on_target_death():
	_sheath_weapon()
	state_machine.change_state(wander_state)
