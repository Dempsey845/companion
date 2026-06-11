extends Node3D

@export var npc: NPC
@export var air_tracker: NPCAirState  

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready() -> void:
	animation_tree.active = true

	air_tracker.falling_started.connect(_on_falling_started)
	air_tracker.falling_ended.connect(_on_landed)
	
	npc.jump_started.connect(jump)

func _process(_delta: float) -> void:
	if npc == null:
		return

	var velocity: Vector3 = npc.velocity
	var character_basis: Basis = npc.global_transform.basis

	var local_velocity := character_basis.inverse() * velocity

	var blend_vector := Vector2(
		local_velocity.x,
		-local_velocity.z
	).limit_length(1.0)

	animation_tree.set(
		"parameters/LocomotionStateMachine/Locomotion/blend_position",
		blend_vector
	)

func _on_falling_started() -> void:
	animation_tree.set(
		"parameters/LocomotionStateMachine/conditions/falling",
		true
	)

func _on_landed() -> void:
	animation_tree.set(
		"parameters/LocomotionStateMachine/conditions/falling",
		false
	)

	animation_tree.set(
		"parameters/LocomotionStateMachine/conditions/land",
		true
	)

	await get_tree().process_frame
	animation_tree.set(
		"parameters/LocomotionStateMachine/conditions/land",
		false
	)

func jump() -> void:
	animation_tree.set(
		"parameters/LocomotionStateMachine/conditions/jump",
		true
	)
	
	print("Jump")

	await get_tree().process_frame
	animation_tree.set(
		"parameters/LocomotionStateMachine/conditions/jump",
		false
	)
