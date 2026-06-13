class_name WeaponWorldItem
extends WorldItem

@export_category("Melee")
@export var hitbox: Hitbox
@export var delay_before_can_damage: float = 0.5
@export var hitbox_active_duration: float = 0.2

func init(itm_resource: Item):
	super.init(itm_resource)
	
	assert(
		itm_resource is Weapon,
		"WeaponWorldItem should not be initialised with a Item resource!"
	)
	
	hitbox.damage = itm_resource.damage
	

func use_item():
	if not hitbox:
		push_error("No hitbox assigned. Weapon cannot be correctly used!")
		return
	
	await get_tree().create_timer(delay_before_can_damage).timeout
	hitbox.active = true
	
	await get_tree().create_timer(hitbox_active_duration).timeout
	hitbox.active = false
