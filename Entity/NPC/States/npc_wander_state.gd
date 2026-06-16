extends State

enum WanderType
{
	Random,
	PointsOfInterest
}

@export var wander_type: WanderType
@export var wander_radius: float = 10.0
@export var wander_wait_time: float = 2.0
@export var points_of_interest: PointsOfInterest

@export var target_search_area: NPCTargetSearchArea
@export var target_manager: NPCTargetManager

@onready var wait_timer: Timer = $WaitTimer
@onready var chase_state: Node = $"../ChaseState"

var destination: Vector3
var current_poi: PointOfInterest

func _ready() -> void:
	wait_timer.timeout.connect(_on_wait_timer_timeout)
	
	
	if points_of_interest == null:
		points_of_interest = get_tree().get_nodes_in_group("points_of_interest").pick_random()

	connect_navigation_finished.call_deferred()

func connect_navigation_finished():
	actor.navigation_finished.connect(_on_navigation_finished)

func enter():
	if actor is not NPC:
		push_error("This State is only compatible with NPC's!")

	wait_timer.start()

func exit():
	wait_timer.stop()

func pick_new_destination() -> void:
	match wander_type:
		WanderType.Random:
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
		WanderType.PointsOfInterest:
			current_poi = points_of_interest.get_random_point_of_interest()
			wait_timer.wait_time = current_poi.observation_duration
			actor.set_target_position(current_poi.global_position)
			actor.move = true

func _on_wait_timer_timeout():
	pick_new_destination()

func _on_navigation_finished():
	if current_poi:
		actor.look_at_point(current_poi.global_position)
		current_poi = null
		
	wait_timer.start()