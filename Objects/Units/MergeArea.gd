extends Area2D

class_name MergeArea

signal roadUnitEntered(roadUnit : RoadUnit)

var collisionShape : CollisionShape2D


func _init():
	# Fix bug where signal not being connected when this class instanced
	area_entered.connect(areaEntered)


func setRadius(radius : float):
	#Too lazy to figure out how to fix _init in this function not working
	if(collisionShape == null):
		initCollisionShape()
	
	# Clamp to positive
	radius = clamp(radius, 0, INF)
	
	collisionShape.shape.radius = radius


func initCollisionShape():
	collisionShape = CollisionShape2D.new()
	collisionShape.shape = CircleShape2D.new()
	add_child(collisionShape)


func areaEntered(area):
	var roadUnit = area.get_parent()
	if(roadUnit is RoadUnit):
		roadUnitEntered.emit(roadUnit)
