class_name NPCSkeleton
extends Node3D

enum ItemSlotType
{
	RightHand,
	Back
}

@export var npc: NPC

@export var attachment_root: Node3D

func get_item_slot(type: ItemSlotType):
    return attachment_root.get_node(ItemSlotType.find_key(type) + "ItemAttachment/ItemSlot")