extends State

@export var target_manager: NPCTargetManager
@export var chase_state: State
@export var idle_state: State

@onready var update_timer: Timer = $UpdateTimer

var retreat_time: float
var retreat_duration: float = 2.0

func _ready() -> void:
	update_timer.timeout.connect(_on_update_timer_timeout)

func enter():
	actor.move = true
	update_timer.start()

func update(delta: float):
	retreat_time += delta

	if retreat_time > retreat_duration:
		state_machine.change_state(chase_state)
		retreat_time = 0.0

func exit():
	retreat_time = 0.0
	update_timer.stop()

func _on_update_timer_timeout():
	if target_manager.target == null:
		state_machine.change_state(idle_state)
		return

	var retreat_direction = (actor.global_position - target_manager.target.global_position).normalized()
	actor.set_target_position(
		actor.global_position + retreat_direction * 2.0
	)
