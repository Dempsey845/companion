class_name PointsOfInterest
extends Node3D

var points: Array[PointOfInterest]

func _ready() -> void:
	for child: PointOfInterest in get_children():
		points.append(child)

func get_random_point_of_interest() -> PointOfInterest:
	return points.pick_random()
