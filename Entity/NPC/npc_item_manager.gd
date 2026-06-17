class_name NPCItemManager
extends Node

signal item_used(item_type: Item.ItemType)

@export var skeleton: NPCSkeleton
@export var start_item: Item
@export var start_item_slot_type: NPCSkeleton.ItemSlotType

var current_world_item: WorldItem

@onready var item_use_cooldown_timer: Timer = $ItemUseCooldownTimer

func _ready() -> void:
	if skeleton == null:
		push_warning("NPC exists without an assigned skeleton for ItemManager. This means items cannot be equipped.")

	equip_new_item(start_item, start_item_slot_type)

func remove_current_item():
	if current_world_item and is_instance_valid(current_world_item):
		current_world_item.queue_free()

func requip_current_item(item_slot_type: NPCSkeleton.ItemSlotType):
	if skeleton == null:
		return

	var item_slot = skeleton.get_item_slot(item_slot_type)
	current_world_item.reparent(item_slot)
	current_world_item.position = Vector3.ZERO
	current_world_item.rotation = Vector3.ZERO

func equip_new_item(item_resource: Item, item_slot_type: NPCSkeleton.ItemSlotType):
	if skeleton == null:
		return

	remove_current_item()
		
	var item_slot = skeleton.get_item_slot(item_slot_type)
		
	current_world_item = item_resource.world_item_scene.instantiate() as WorldItem
	current_world_item.init(item_resource)
	
	item_slot.add_child(current_world_item)
	
	item_use_cooldown_timer.wait_time = item_resource.item_use_cooldown_duration

func try_use_current_item() -> bool:
	if skeleton == null:
		return false

	if item_use_cooldown_timer.is_stopped():
		current_world_item.use_item()
		item_used.emit(current_world_item.item_resource.item_type)
		item_use_cooldown_timer.start()
		return true

	return false
