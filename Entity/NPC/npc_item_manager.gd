class_name NPCItemManager
extends Node

signal item_used(item_type: Item.ItemType)

@export var skeleton: Node3D
@export var start_item: Item

var item_slot: Node3D

var current_world_item: WorldItem

@onready var item_use_timer: Timer = $ItemUseTimer

func _ready() -> void:
	item_slot = skeleton.get_node("Skeleton3D/ItemAttachment/ItemSlot")
	
	item_use_timer.timeout.connect(_item_use_timer_timeout)
	
	equip_new_item(start_item)

func remove_current_item():
	if current_world_item and is_instance_valid(current_world_item):
		current_world_item.queue_free()
	item_use_timer.stop()

func equip_new_item(item_resource: Item):
	remove_current_item()
		
	current_world_item = item_resource.world_item_scene.instantiate() as WorldItem
	current_world_item.init(item_resource)
	
	item_slot.add_child(current_world_item)
	
	item_use_timer.wait_time = item_resource.item_use_rate

func _item_use_timer_timeout():
	current_world_item.use_item()
	item_used.emit(current_world_item.item_resource.item_type)
	if current_world_item.item_resource.use_item_until_stopped:
		item_use_timer.start()
