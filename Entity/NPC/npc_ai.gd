class_name NPC
extends CharacterBody3D

@export var speed: float = 4.0
@export var acceleration: float = 10.0
@export var jump_velocity: float = 6.0
@export var target: Node3D

var gravity: float = 9.8
var next_position: Vector3

var _chase_target: bool
var chase_target: bool:
	get:
		return _chase_target
	set(value):
		_chase_target = value
		_on_chase_target()

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var forward_ray: RayCast3D = $ForwardRay
@onready var target_update_timer: Timer = $TargetUpdateTimer

func _ready() -> void:
	target_update_timer.timeout.connect(_on_target_update_timer_timeout)

func _physics_process(delta: float):
	_try_apply_gravity(delta)
	
	if chase_target:
		_handle_chase_target(delta)
	
	move_and_slide()

func _handle_chase_target(delta: float):
	if target == null:
		move_and_slide()
		return

	# Stop when destination reached
	if nav_agent.is_navigation_finished():
		_stop_moving(delta)
		return

	_handle_obstacles()

	_move_to_next_position(delta)

	face_movement_direction(delta)

	move_and_slide()

func _try_apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

func _stop_moving(delta: float):
	velocity.x = move_toward(
		velocity.x,
		0.0,
		acceleration * delta
	)

	velocity.z = move_toward(
		velocity.z,
		0.0,
		acceleration * delta
	)

	move_and_slide()

func _handle_obstacles():
	# Auto jump if obstacle detected
	if is_on_floor() and forward_ray.is_colliding():
		jump()

	# Jump if next nav point is significantly higher
	if is_on_floor():
		var height_difference = next_position.y - global_position.y

		if height_difference > 0.75:
			jump()

func _move_to_next_position(delta: float):
	var direction = next_position - global_position
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = move_toward(
		velocity.x,
		direction.x * speed,
		acceleration * delta
	)

	velocity.z = move_toward(
		velocity.z,
		direction.z * speed,
		acceleration * delta
	)

func face_movement_direction(delta: float):
	var horizontal_velocity = Vector3(
		velocity.x,
		0,
		velocity.z
	)

	if horizontal_velocity.length() > 0.1:
		var target_rotation = atan2(
			-horizontal_velocity.x,
			-horizontal_velocity.z
		)

		rotation.y = lerp_angle(
			rotation.y,
			target_rotation,
			8.0 * delta
		)

func jump():
	if is_on_floor():
		velocity.y = jump_velocity

func is_target_in_range() -> bool:
	return true

func _on_chase_target():
	if target == null:
		push_warning("NPC: No target to chase!")
		chase_target = false

func _on_target_update_timer_timeout() -> void:
	nav_agent.target_position = target.global_position
	next_position = nav_agent.get_next_path_position()
