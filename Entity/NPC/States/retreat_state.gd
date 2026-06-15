extends State

@export var target_manager: NPCTargetManager
@export var chase_state: State

var retreat_time: float
var retreat_duration: float = 2.0

func enter():
    actor.move = true

func update(delta: float):
    var retreat_direction = (actor.global_position - target_manager.target.global_position).normalized()
    actor.set_target_position(
        actor.global_position + retreat_direction * 2.0
    )

    retreat_time += delta

    if retreat_time > retreat_duration:
        state_machine.change_state(chase_state)
        retreat_time = 0.0

func exit():
    retreat_time = 0.0