class_name NPC
extends CharacterBody3D

signal navigation_finished
signal jump_started

@export var speed: float = 4.0
@export var acceleration: float = 10.0
@export var jump_velocity: float = 6.0

var _move: bool
var move: bool:
	get:
		return _move
	set(value):
		_move = value
		
		if value:
			clear_look_target()

var gravity: float = 9.8
var next_position: Vector3

var look_target_position: Vector3
var has_look_target := false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var forward_ray: RayCast3D = $ForwardRay

func _physics_process(delta: float):
	_try_apply_gravity(delta)
	
	if move:
		_move_towards_target_position(delta)
	else:
		_stop_moving(delta)
	
	if has_look_target:
		face_target_position(delta)
	else:
		face_movement_direction(delta)
	
	move_and_slide()

func _move_towards_target_position(delta: float):
	next_position = nav_agent.get_next_path_position()
	
	if nav_agent.is_navigation_finished():
		navigation_finished.emit()
		move = false
		return
	
	_handle_obstacles()

	_move_to_next_position(delta)

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

func look_at_point(point: Vector3):
	look_target_position = point
	has_look_target = true

func clear_look_target():
	has_look_target = false

func face_target_position(delta: float):
	var direction = look_target_position - global_position
	direction.y = 0

	if direction.length_squared() < 0.01:
		return

	var target_rotation = atan2(
		-direction.x,
		-direction.z
	)

	rotation.y = lerp_angle(
		rotation.y,
		target_rotation,
		8.0 * delta
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

func set_target_position(new_target_position: Vector3):
	nav_agent.target_position = new_target_position

func jump():
	if is_on_floor():
		velocity.y = jump_velocity
		jump_started.emit()

func is_target_in_range() -> bool:
	return true
