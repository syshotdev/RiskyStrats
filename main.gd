extends Node2D


@export var selectionArea : SelectionArea

@onready var distributer : PayloadDistributer = PayloadDistributer.new()

var roads
var nodes

var selectedNodes : Array[GameNode] = []

var mouseClicked : bool = false
var mousePositionStart : Vector2 = Vector2.ZERO
var mousePositionEnd : Vector2 = Vector2.ZERO

func _ready():
	roads = find_child("Roads").get_children()
	nodes = find_child("Nodes").get_children()
	
	# Inits the node's neighbors
	for road in roads:
		setRoadNodeNeighbors(road)


func _process(delta):
	var leftClickPressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	# If mouse wasn't already clicked and the left click is currently clicked
	# (if mouse button left click just pressed)
	if(not mouseClicked && leftClickPressed):
		# Say the mouse has been clicked
		mouseClicked = true
		# Get start pos for slection area
		mousePositionStart = get_global_mouse_position()
	elif(leftClickPressed):
		# Get end pos every frame to update selection area
		mousePositionEnd = get_global_mouse_position()
	
	selectedNodes = selectionArea.getNodesInArea(mousePositionStart, mousePositionEnd)
	var randomValueNoUse = 0


func _input(event):
	
	# If the mouse was pressed or released and it wasn't a left click on, say the mouse isn't clicked
	if event is InputEventMouseButton && not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouseClicked = false
	
	if(Input.is_action_just_pressed("Tier1")):
			print(selectedNodes)
			sendSelectedPayloads(selectedNodes, 80)
	#elif event is InputEventAction:


func sendSelectedPayloads(selectedNodes : Array[GameNode], amount : int):
	for node in selectedNodes:
		distributer.sendPayload(node,nodes[2],Unit.new(GameColors.colors.BLUE, amount))


# Gets the road's node1 and node2 and sets themselves as neighbors
func setRoadNodeNeighbors(road : Road):
	var node1 = road.node1
	var node2 = road.node2
	node1.addNeigbor(node2,road)
	node2.addNeigbor(node1,road)
