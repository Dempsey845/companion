extends State

@export var target_manager: NPCTargetManager
@onready var idle_state: Node = $'../IdleState'

var min_distance_from_target: float = 6.0
var min_distance_from_target_sq: float = min_distance_from_target * min_distance_from_target

var targets_combat_target: NPC

func _ready() -> void:
    NPCManager.instance.combat_ended.connect(_on_combat_ended)

func enter():
    targets_combat_target = NPCManager.instance.get_npcs_combat_pair(target_manager.target)

    if target_manager.target == null or target_manager.get_current_target_type() != target_manager.TargetType.NPC:
        state_machine.change_state(idle_state)
    else:
        target_manager.target.death.connect(_on_target_death)

func update(_delta: float):
    var distance_to_target_sq = actor.global_position.distance_squared_to(target_manager.target.global_position)
    
    if distance_to_target_sq > min_distance_from_target_sq:
        actor.set_target_position(target_manager.target.global_position)
        actor.move = true
    elif distance_to_target_sq < min_distance_from_target_sq / 2.0:
        var retreat_direction = (actor.global_position - target_manager.target.global_position).normalized()
        actor.set_target_position(
        actor.global_position + retreat_direction * 2.0
        )
        actor.move = true
    else:
        actor.move = false

func exit():
    if is_instance_valid(target_manager.target):
        if target_manager.target.death.is_connected(_on_target_death):
            target_manager.target.death.disconnect(_on_target_death)

    targets_combat_target = null

func _on_combat_ended(npc: NPC):
    if target_manager.target == null:
        return

    print("Combat!")
    if npc == target_manager.target:
        print("Combat ended!")
        target_manager.try_start_combat_with_target(npc)

func _on_target_death(_npc: NPC):
    if targets_combat_target and is_instance_valid(targets_combat_target):
        target_manager.try_start_combat_with_target(targets_combat_target)
    else:
        state_machine.change_state(idle_state)

