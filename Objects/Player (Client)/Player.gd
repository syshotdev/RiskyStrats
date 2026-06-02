extends Node2D

class_name Player

signal orderSendPayload(
	player : Player, 
	nodes : Array[GameNode], 
	target : GameNode, 
	amount : int
)
signal orderBuyBuilding(
	player : Player, 
	target : GameNode, 
	type : GameTypes.buildingType
)

@onready var camera := $Camera2D
@export var buyMenu : BuyMenu
@export var selectionArea : SelectionArea
@export var nodeChecker : HoveredNode
@export var inputHandler : Node2D

@onready var color : GameColors.colors = GameColors.colors.PURPLE
var selectedNodes : Array[GameNode]
var currentNode : GameNode

func _process(delta: float) -> void:
	inputHandler.tick(delta)

func _input(event: InputEvent) -> void:
	if !get_tree().root.get_viewport().is_input_handled():
		camera.tool_event(event)

# When player wants to send payload, send it
func onInputSendPayload(amount : int):
	# If the node that we try to path to is null, don't path
	if(currentNode == null):
		return
	
	orderSendPayload.emit(self, selectedNodes, currentNode, amount)

# For when player uses mouse to do area
func updateSelectionArea(pos1, pos2):
	selectedNodes = selectionArea.getNodesInArea(pos1, pos2)

# Check the current hovered node (If there is one)
func checkHoveredNode(pos):
	currentNode = nodeChecker.getHoveredNode(pos)

# Checks the current hovered node, and turns buy menu visibility on if circumstances right.
# THIS WILL CHANGE LATER: I don't know how to turn buy menu off
func buyMenuOn(pos : Vector2):
	# Guard clauses
	if(currentNode == null):
		return
	if(currentNode.color != self.color):
		return
	
	buyMenu.position = pos
	buyMenu.visible = true
	buyMenu.currentNode = currentNode

# Turns of buy menu
func buyMenuOff():
	buyMenu.visible = false


func buyButtonPressed(type : GameTypes.buildingType) -> void:
	orderBuyBuilding.emit(self, buyMenu.currentNode, type)
