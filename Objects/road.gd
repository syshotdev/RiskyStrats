extends Node2D

class_name Road

@export var node1 : GameNode
@export var node2 : GameNode
@export var roadUnitScene : PackedScene

@export var color : Color
@export var thickness : int


# For ALL RoadUnits
var nodeSpeed = 100
var roadLength = 100 # Calculated in ready

# For each road unit, to move them all along the road and keep track of them
var currentUnits : Array[RoadUnit]


func _ready():
	roadLength = node1.position.distance_to(node2.position) # Find road length
	position = Vector2.ZERO # This is not needed technically but if not at 0,0 it breaks
	
	var unit : Unit = Unit.new(GameColors.colors.BLUE)
	unit.units = 60
	addUnitToRoad(unit, true)


func _process(delta):
	moveAllRoadUnits(delta)


func _draw():
	drawRoad(node1.global_position,node2.global_position)


func drawRoad(position1 : Vector2, position2 : Vector2):
	draw_line(position1, position2, color, thickness)


# Adds the road to all the nessesary variables to keep track of.
# Also the function that the "node1" or "node2" calls to send a unit payload
func addUnitToRoad(unit : Unit, goingToSecondNode : bool):
	var newRoadUnit := createNewRoadUnit(unit.units, unit.currentColor)
	
	newRoadUnit.toSecondNode = goingToSecondNode
	
	# If going to node 2, start at node 1
	if(goingToSecondNode):
		newRoadUnit.progress = 0
	else:
		newRoadUnit.progress = roadLength
	
	currentUnits.append(newRoadUnit)
	add_child(newRoadUnit)

# Creates a new RoadUnit object from a scene
func createNewRoadUnit(unitAmount : int, color : GameColors.colors) -> RoadUnit:
	var roadUnit = roadUnitScene.instantiate()
	roadUnit.setColor(color)
	roadUnit.units = unitAmount
	return roadUnit


func moveAllRoadUnits(delta):
	for unitIndex in range(currentUnits.size()):
		var unit = currentUnits[unitIndex]
		
		# Percentage goes up speed * delta (Or down if direction is node1)
		var howMuchToMove = calculateRoadUnitMovement(unit, delta)
		unit.progress += howMuchToMove
		
		unit.position = calculateRoadUnitPosition(unit)
		
		# Tries to merge with node1 or node2, and if it does, it gives success = true
		var success = tryMergeWithNearestNode(unit)
		
		# If success, remove it from things
		if(success):
			currentUnits.remove_at(unitIndex)
			unit.queue_free()

# Calculates road unit position based on it's progress on the road
func calculateRoadUnitPosition(roadUnit : RoadUnit):
	var outPosition : Vector2 = Vector2.ZERO
	
	# Lerp from pos1 to pos2 using the percentage of progress / roadlength
	var pos1 = node1.global_position
	var pos2 = node2.global_position
	var progress = roadUnit.progress
	
	outPosition = pos1.lerp(pos2,(progress / roadLength))
	
	return outPosition


# Name is misleading, but checks the node's progress towards a node and gives it if it's close enough
func tryMergeWithNearestNode(roadUnit : RoadUnit):
	if(roadUnit.progress > roadLength):
		node2.addRoadUnit(roadUnit)
		return true
	elif(roadUnit.progress < 0):
		node1.addRoadUnit(roadUnit)
		return true
	
	# Not close enough to nodes
	return false

# Calculates how much it should move per tick
func calculateRoadUnitMovement(unit : RoadUnit, delta : float):
	# If going to the second node, go up in percentage.
	# If going to first node, go down in percentage.
	if (unit.toSecondNode == true):
		return calculateRoadUnitSpeed(unit) * delta
	else:
		return -calculateRoadUnitSpeed(unit) * delta


func calculateRoadUnitSpeed(unit : RoadUnit):
	var speed = 0
	
	# As the units increase, the slower it will go. It will only get about 3x slower at 100 units, 4x slower at 1000, and so on.
	speed = nodeSpeed / (log(unit.units) + 1)
	return speed
