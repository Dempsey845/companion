class_name NPCSkeleton
extends Node3D

signal attack_activate_weapon
signal attack_disable_weapon

enum ItemSlotType
{
	RightHand,
	Back
}

@export var npc: NPC

@export var attachment_root: Node3D

func get_item_slot(type: ItemSlotType):
	return attachment_root.get_node(ItemSlotType.find_key(type) + "ItemAttachment/ItemSlot")

func activate_weapon():
	attack_activate_weapon.emit()

func disable_weapon():
	attack_disable_weapon.emit()