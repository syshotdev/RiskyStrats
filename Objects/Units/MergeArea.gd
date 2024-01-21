extends Area2D

class_name MergeArea

signal roadUnitEntered(roadUnit : RoadUnit)

var collisionShape : CollisionShape2D
var radius : float = 0


func _init():
	# Fix bug where signal not being connected when this class instanced
	area_entered.connect(areaEntered)


func setRadius(newRadius : float):
	#Too lazy to figure out how to fix _init in this function not working
	if(collisionShape == null):
		initCollisionShape()
	
	# Clamp to positive
	radius = clamp(newRadius, 0, INF)
	
	collisionShape.shape.radius = radius


func initCollisionShape():
	collisionShape = CollisionShape2D.new()
	collisionShape.shape = CircleShape2D.new()
	add_child(collisionShape)


func areaEntered(area):
	var roadUnit = area.get_parent()
	
	var selfPosition = get_parent().global_position
	var otherPosition = roadUnit.global_position
	var distance = selfPosition.distance_to(otherPosition)
	
	if(!roadUnit is RoadUnit):
		return
	
	# If position from this node to that node is more than our detection radius, then don't merge
	if(distance > radius * 2):
		return
	
	# Bug: Roadunit gets initialized at 0,0 , then it merges with other nodes. (Theory at least)
	roadUnitEntered.emit(roadUnit)
