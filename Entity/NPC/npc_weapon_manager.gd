class_name NPCWeaponManager
extends Node

@export var item_manager: NPCItemManager
@export var humanoid_skeleton: HumanoidSkeleton

var weapon_animations: Dictionary[String, Dictionary] = {
	"Slash": {
		"animation_length": 2.05
	}
}

var weapon_type_animations: Dictionary[Weapon.WeaponType, String] = {
	Weapon.WeaponType.OneHanded: "Slash"
}

var equipped: bool

func _ready() -> void:
	item_manager.item_used.connect(_on_item_used)

func equip():
	if equipped:
		return

	equipped = true
	
func dequip():
	equipped = false

func is_current_item_weapon() -> bool:
	if item_manager.current_world_item == null or not is_instance_valid(item_manager.current_world_item):
		return false
	
	var item_type = item_manager.current_world_item.item_resource.item_type
	return item_type == Item.ItemType.Weapon

func start_using_weapon():
	if not is_current_item_weapon():
		print("Current item is not a weapon")
		return
		
	if item_manager.item_use_timer.is_stopped():
		item_manager.item_use_timer.start()

func stop_using_weapon():
	if not is_current_item_weapon():
		return
		
	item_manager.item_use_timer.stop()

func _on_item_used(_item_type: Item.ItemType):
	if not is_current_item_weapon():
		return
	
	if not equipped:
		equip()
	else:
		_attack()
	
func _attack():
	var weapon_resource = item_manager.current_world_item.item_resource as Weapon
	var weapon_anim_name = weapon_type_animations[weapon_resource.weapon_type]
	var weapon_anim_length: float = weapon_animations[weapon_anim_name]["animation_length"]
	humanoid_skeleton.play_upper_body_animation(weapon_anim_name, weapon_anim_length)
	
