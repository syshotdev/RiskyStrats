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

@export var inputHandler : Node2D
@onready var camera := $Camera2D
@onready var buyMenu := $BuyMenu
@onready var selectionTool := $SelectionTool

@onready var color : GameColors.colors = GameColors.colors.PURPLE
var selectedNodes : Array[GameNode]
var currentNode : GameNode

func _ready() -> void:
	selectionTool.enabled = true

func _process(delta: float) -> void:
	inputHandler.tick(delta)

func _input(event: InputEvent) -> void:
	if event.is_action("right_click"):
		selectionTool.deselect_all_nodes()
	
	if !get_tree().root.get_viewport().is_input_handled():
		camera.tool_event(event)
	if !get_tree().root.get_viewport().is_input_handled():
		selectionTool.tool_event(event)

# When player wants to send payload, send it
func onInputSendPayload(amount : int):
	# If the node that we try to path to is null, don't path
	if(currentNode == null):
		return
	
	orderSendPayload.emit(self, selectedNodes, currentNode, amount)

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
