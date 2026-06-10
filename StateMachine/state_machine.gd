class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var actor

func _ready():
	actor = get_parent()

	for child in get_children():
		if child is State:
			child.actor = actor
			child.state_machine = self

	if initial_state:
		change_state(initial_state)

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func change_state(new_state: State):
	if current_state:
		current_state.exit()

	current_state = new_state

	if current_state:
		current_state.enter()
