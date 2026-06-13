class_name Weapon
extends Item

enum WeaponType
{
	OneHanded,
	TwoHanded
}

@export var weapon_type: WeaponType
@export var damage: int
