class_name Item
extends Resource

enum ItemType
{
	Default,
	Weapon
}

@export var item_id: String
@export var item_title: String
@export var item_description: String
@export var world_item_scene: PackedScene
@export var item_type: ItemType
@export var item_use_rate: float = 1.0
@export var remove_item_on_use: bool
@export var use_item_until_stopped: bool
