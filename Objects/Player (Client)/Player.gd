extends Node2D

@export var selectionArea : SelectionArea
@export var inputStuff : Node2D
@export var map : Map

var currentColor : GameColors.colors
var selectedNodes : Array[GameNode]

# Main ticking functioin
func _process(delta):
	inputStuff.tick+(delta)
	map.tick(delta)

# Initializes this class when the game starts
func initPlayer(color : GameColors.colors):
	currentColor = color

# For initializing
func updateMap(map : Map):
	map = map.duplicate()

# When player wants to send payload, send it
func onInputSendPayload(amount : int):
	map.sendPayload(selectedNodes, map.nodes[0], Unit.new(currentColor, amount))

# For when player uses mouse to do area
func updateSelectionArea(pos1, pos2):
	selectedNodes = selectionArea.getNodesInArea(pos1, pos2)
