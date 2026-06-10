extends State

@export var wander_radius: float = 10.0
@export var wander_wait_time: float = 2.0

@onready var wait_timer: Timer = $WaitTimer

var destination: Vector3

func _ready() -> void:
	wait_timer.timeout.connect(_on_wait_timer_timeout)

func enter():
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")

	wait_timer.start()
	actor.navigation_finished.connect(_on_navigation_finished)

func exit():
	wait_timer.stop()

func pick_new_destination() -> void:
	var random_offset = Vector3(
		randf_range(-wander_radius, wander_radius),
		0,
		randf_range(-wander_radius, wander_radius)
	)

	var target = actor.global_position + random_offset
	destination = NavigationServer3D.map_get_closest_point(
		actor.get_world_3d().navigation_map,
		target
	)

	actor.set_target_position(destination)
	actor.move = true

func _on_wait_timer_timeout():
	pick_new_destination()

func _on_navigation_finished():
	wait_timer.start()
