extends Node2D

@onready var camera := $Camera2D
@export var buyMenu : BuyMenu
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

func _input(event: InputEvent) -> void:
	if !get_tree().root.get_viewport().is_input_handled():
		camera.tool_event(event)

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

# Checks the current hovered node, and turns buy menu visibility on if circumstances right.
# THIS WILL CHANGE LATER: I don't know how to turn buy menu off
func buyMenuOn(pos : Vector2):
	# Guard clauses
	if(hoveredNode == null):
		return
	if(hoveredNode.currentColor != currentColor):
		return
	
	buyMenu.position = pos
	buyMenu.visible = true
	buyMenu.currentNode = hoveredNode

# Turns of buy menu
func buyMenuOff():
	buyMenu.hide()
