extends Node2D

@export var selectionArea : SelectionArea
@export var nodeChecker : HoveredNode
@export var inputStuff : Node2D
@export var map : Map

var currentColor : GameColors.colors = GameColors.colors.PURPLE
var selectedNodes : Array[GameNode]
var hoveredNode : GameNode

# Main ticking functioin
func _process(delta):
	inputStuff.tick(delta)
	map.tick(delta)

# Initializes this class when the game starts
func initPlayer(color : GameColors.colors):
	currentColor = color

# For initializing
func updateMap(newMap : Map):
	map = newMap.duplicate()
	map.loadMap(newMap)

# When player wants to send payload, send it
func onInputSendPayload(amount : int):
	# If the node that we try to path to is null, don't path
	if(hoveredNode == null):
		return
	
	# From nodes, to node, unit to send
	map.sendPayload(selectedNodes, hoveredNode, Unit.new(currentColor, amount))

# For when player uses mouse to do area
func updateSelectionArea(pos1, pos2):
	selectedNodes = selectionArea.getNodesInArea(pos1, pos2)

# Check the current hovered node (If there is one)
func checkHoveredNode(pos):
	hoveredNode = nodeChecker.getHoveredNode(pos)
