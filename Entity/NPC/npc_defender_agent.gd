class_name NPCDefenderAgent
extends Node

var npc: NPC
var state_machine: StateMachine

var retreat_state: State
var attack_state: State

var has_attack_started: bool
var attack_time: float

var retreat_time: float = 3.0

func _ready():
    npc = get_parent()
    state_machine = npc.state_machine

    retreat_state = state_machine.get_node("RetreatState")

    attack_state = state_machine.get_node("AttackState")
    attack_state.change_state_independently = false
    attack_state.attack_started.connect(_on_attack_started)

    state_machine.change_state.call_deferred(retreat_state)

func _process(delta: float):
    if has_attack_started:
        attack_time += delta

        if attack_time > retreat_time:
            attack_time = 0.0
            has_attack_started = false

            state_machine.change_state(retreat_state)

func _on_attack_started():
    has_attack_started = true