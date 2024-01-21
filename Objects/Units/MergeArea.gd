extends Area2D

class_name MergeArea

signal roadUnitEntered(roadUnit : RoadUnit)

var collisionShape : CollisionShape2D


func setRadius(radius : float):
	collisionShape.radius = radius


func areaEntered(area):
	var roadUnit = area.get_parent()
	if(roadUnit is RoadUnit):
		roadUnitEntered.emit(roadUnit)
