@tool
extends Node2D

class_name Road

@export var node1 : GameNode
@export var node2 : GameNode
@export var roadUnitScene : PackedScene = preload("res://Objects/Units/road_unit.tscn")

@export var thickness : int = 10
@export var color : Color


# For ALL RoadUnits
const nodeSpeed = 100
var roadLength # Calculated in ready

# For each road unit, to move them all along the road and keep track of them
var currentUnits : Array[RoadUnit]


func _ready():
	z_index = -1 # Fix road on node problem
	roadLength = node1.position.distance_to(node2.position) # Find road length
	position = Vector2.ZERO # This is not needed technically but if not at 0,0 it breaks


func _draw():
	drawLine(node1.global_position, node2.global_position)


func drawLine(pos1 : Vector2, pos2 : Vector2):
	draw_line(pos1, pos2, color, thickness)

# Adds the road to all the nessesary variables to keep track of.
# Also the function that the "node1" or "node2" calls to send a unit payload
func addUnitToRoad(roadUnit : RoadUnit):
	# So it doesnt jank
	roadUnit.progress = 0
	
	# On top of node and road
	roadUnit.z_index = 1
	
	currentUnits.append(roadUnit)
	# To fix annoying bug where not removed from other parents
	if(roadUnit.get_parent() == null):
		add_child(roadUnit)


func moveAllRoadUnits(delta):
	var copyUnits := currentUnits.duplicate(true)
	for unitIndex in range(currentUnits.size()):
		var roadUnit : RoadUnit = copyUnits[unitIndex]
		
			# Percentage goes up speed * delta (Or down if direction is node1)
		roadUnit.progress += calculateRoadUnitSpeed(roadUnit, delta)
		roadUnit.global_position = calculateRoadUnitPosition(roadUnit)
		
		# Tries to merge with node1 or node2, and if it does, it gives success = true
		var success = tryMergeWithNearestNode(roadUnit)
		
		# If success, remove it from things
		if(success):
			currentUnits.remove_at(unitIndex)

# Calculates road unit position based on it's progress on the road
func calculateRoadUnitPosition(roadUnit : RoadUnit):
	var outPosition : Vector2 = Vector2.ZERO
	
	# Lerp from pos1 to pos2 using the percentage of progress / roadlength
	var pos1 = node1.global_position
	var pos2 = node2.global_position
	var progress = roadUnit.progress
	
	if(roadUnit.toSecondNode == true):
		# Start at first, go to sencond
		outPosition = pos1.lerp(pos2, (progress / roadLength))
	else:
		# Start at second, go to first
		outPosition = pos2.lerp(pos1, (progress/roadLength))
	
	return outPosition

# Name is misleading, but checks the node's progress towards a node and gives it if it's close enough
func tryMergeWithNearestNode(roadUnit : RoadUnit):
	# If the road unit is not at 100% completion, don't try
	if(roadUnit.progress < roadLength):
		return false
	
	# If road unit is 100%, send it to the correct node. If going to second node, node2 gets the thing
	if(roadUnit.toSecondNode == true):
		node2.processRoadUnit(roadUnit)
	else:
		node1.processRoadUnit(roadUnit)
	
	return true

# How much the roadUnit should move per second
func calculateRoadUnitSpeed(roadUnit : RoadUnit, delta : float):
	var speed = 0
	
	# As the units increase, the slower it will go. It will only get about 3x slower at 100 units, 4x slower at 1000, and so on.
	speed = nodeSpeed / (log(roadUnit.units) + 1)
	return speed * delta

func mergeRoadUnit():
	pass
