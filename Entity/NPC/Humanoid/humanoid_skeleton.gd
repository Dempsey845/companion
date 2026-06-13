class_name HumanoidSkeleton
extends Node3D

@export var npc: NPC
@export var air_tracker: NPCAirState  

@onready var animation_tree: AnimationTree = $AnimationTree

var upper_body_state_machine: AnimationNodeStateMachinePlayback

var playing_upper_body_animation: bool

func _ready() -> void:
	animation_tree.active = true

	air_tracker.falling_started.connect(_on_falling_started)
	air_tracker.falling_ended.connect(_on_landed)
	
	npc.jump_started.connect(jump)
	
	upper_body_state_machine = animation_tree.get(
		"parameters/UpperBodyStateMachine/playback"
	)

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
	
	await get_tree().process_frame
	animation_tree.set(
		"parameters/LocomotionStateMachine/conditions/jump",
		false
	)

func play_upper_body_animation(state_name: String, animation_length: float, blend_time: float = 0.1):
	if playing_upper_body_animation:
		push_warning("Already playing an upper body animation!")
		return
	
	start_upper_body_blend(_play_upper_body_animation.bind(state_name, animation_length), blend_time)

func _play_upper_body_animation(state_name: String, animation_length: float):
	upper_body_state_machine.travel(state_name)
	playing_upper_body_animation = true
	
	await get_tree().create_timer(animation_length).timeout
	stop_upper_body_blend(func(): playing_upper_body_animation = false)

func start_upper_body_blend(on_complete: Callable = Callable(), blend_time: float = 0.1) -> void:
	var tween := create_tween()

	tween.tween_property(
		animation_tree,
		"parameters/UpperBodyBlend/blend_amount",
		1.0,
		blend_time
	)

	tween.finished.connect(func():
		if on_complete.is_valid():
			on_complete.call()
	)

func stop_upper_body_blend(on_complete: Callable = Callable(), blend_time: float = 0.1) -> void:
	var tween := create_tween()

	tween.tween_property(
		animation_tree,
		"parameters/UpperBodyBlend/blend_amount",
		0.0,
		blend_time
	)

	tween.finished.connect(func():
		if on_complete.is_valid():
			on_complete.call()
	)
	
