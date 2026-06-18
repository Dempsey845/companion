class_name WeaponWorldItem
extends WorldItem

@export_category("Melee")
@export var hitbox: Hitbox

func _ready() -> void:
	var skeleton: NPCSkeleton = get_skeleton()

	skeleton.attack_activate_weapon.connect(func(): hitbox.active = true)
	skeleton.attack_disable_weapon.connect(func(): hitbox.active = false)

func init(itm_resource: Item):
	super.init(itm_resource)
	
	assert(
		itm_resource is Weapon,
		"WeaponWorldItem should not be initialised with a Item resource!"
	)
	
	hitbox.damage = itm_resource.damage

func get_skeleton() -> NPCSkeleton:
	var item_slot = get_parent()
	var item_attachment = item_slot.get_parent()
	var skeleton_3d = item_attachment.get_parent()
	return skeleton_3d.get_parent()

func use_item():
	# if not hitbox:
	# 	push_error("No hitbox assigned. Weapon cannot be correctly used!")
	# 	return
	
	pass
