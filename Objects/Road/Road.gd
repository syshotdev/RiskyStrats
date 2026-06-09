@tool
extends Node2D

class_name Road

@export var node1 : GameNode
@export var node2 : GameNode
@export var roadUnitScene : PackedScene = preload("res://Objects/Units/road_unit.tscn")

@export var thickness : int = 10
const color : Color = Color("2b2b2b")
const shadowColor : Color = Color("1a1a1a")
const selectionColor : Color = Color("fa9c1cff")


# For ALL RoadUnits
const nodeSpeed := 250.0
@onready var roadLength = node1.position.distance_to(node2.position)
var isSelected := false

# For each road unit, to move them all along the road and keep track of them
# (Key roadunit : Value 0)
var currentUnits : Dictionary

var editor_selection: EditorSelection
var highlight_material: StandardMaterial3D

func _ready() -> void:
	z_index = -1 # Fix road on node problem
	
	# Only execute this detection logic inside the Godot editor
	if Engine.is_editor_hint():
		editor_selection = EditorInterface.get_selection()
		editor_selection.selection_changed.connect(_on_editor_selection_changed)

func _on_editor_selection_changed() -> void:
	var selected_nodes = editor_selection.get_selected_nodes()
	
	if self in selected_nodes:
		isSelected = true
	else:
		isSelected = false
	
	queue_redraw()


func _exit_tree() -> void:
	# Safe disconnect when node is removed
	if editor_selection and editor_selection.selection_changed.is_connected(_on_editor_selection_changed):
		editor_selection.selection_changed.disconnect(_on_editor_selection_changed)


func _draw():
	if(node1 != null && node2 != null):
		var shadowOffset : Vector2 = Vector2(0, -5)
		draw_line(
			node1.global_position - shadowOffset - position, 
			node2.global_position - shadowOffset - position, 
			shadowColor,
			thickness)
		draw_line(
			node1.global_position - position, 
			node2.global_position - position, 
			color,
			thickness)
		
		if !isSelected:
			return
		draw_line(
			node1.global_position - position, 
			node2.global_position - position, 
			selectionColor,
			thickness + 3)

# Adds the road to all the nessesary variables to keep track of.
# Also the function that the "node1" or "node2" calls to send a unit payload
func addUnitToRoad(roadUnit : RoadUnit):
	# So it doesnt jank
	roadUnit.progress = 0
	
	# On top of node and road
	roadUnit.z_index = 1
	roadUnit.remove.connect(removeRoadUnit)
	
	currentUnits[roadUnit] = 0
	
	if(roadUnit.get_parent() != null):
		roadUnit.get_parent().remove_child(roadUnit)
	
	self.add_child(roadUnit)


func moveAllRoadUnits(delta):
	for roadUnit in currentUnits.keys():
		# Percentage goes up speed * delta (Or down if direction is node1)
		roadUnit.progress += calculateRoadUnitSpeed(roadUnit, delta)
		roadUnit.global_position = calculateRoadUnitPosition(roadUnit)
		
		# Tries to merge with node1 or node2, and if it does, it gives success = true
		var success = tryMergeWithNearestNode(roadUnit)
		
		# If success, remove it from things
		if(success):
			currentUnits.erase(roadUnit)

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

# General function for removing road units from existence
func removeRoadUnit(roadUnit : RoadUnit):
	currentUnits.erase(roadUnit)
	roadUnit.queue_free()

# How much the roadUnit should move per second
func calculateRoadUnitSpeed(roadUnit : RoadUnit, delta : float):
	var speed = 0
	
	# As the units increase, the slower it will go. It will only get about 3x slower at 100 units, 4x slower at 1000, and so on.
	speed = nodeSpeed / (log(roadUnit.units) + 1)
	return speed * delta
