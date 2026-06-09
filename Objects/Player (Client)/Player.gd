extends Node2D

class_name Player

signal orderSendPayload(
	color : GameColors.colors, 
	nodes : Array[GameNode], 
	target : GameNode, 
	amount : int
)
signal orderBuyBuilding(
	color : GameColors.colors, 
	target : GameNode, 
	type : GameTypes.buildingType
)

@onready var camera := $Camera2D
@onready var buyMenu := $BuyMenu
@onready var selectionTool : SelectionTool = $SelectionTool

@export var color : GameColors.colors = GameColors.colors.GAIA

var tier1 := 5
var tier2 := 80
var tier3 := 400
var tier4 := 4096

func _ready() -> void:
	selectionTool.enabled = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		buyMenuOff()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if selectionTool.hovered_node_exists(): 
				buyMenuOn()
	
	if(Input.is_action_just_pressed("Tier1")):
		sendPayload(tier1)
	elif(Input.is_action_just_pressed("Tier2")):
		sendPayload(tier2)
	elif(Input.is_action_just_pressed("Tier3")):
		sendPayload(tier3)
	elif(Input.is_action_just_pressed("Tier4")):
		sendPayload(tier4)
	
	if !get_tree().root.get_viewport().is_input_handled():
		camera.tool_event(event)
	if !get_tree().root.get_viewport().is_input_handled():
		selectionTool.tool_event(event)



# When player wants to send payload, send it
func sendPayload(amount : int):
	var hoveredNode := selectionTool.get_hovered_node()
	var selectedNodes := selectionTool.get_selected_nodes()
	if !hoveredNode or selectedNodes.size() == 0:
		return
	
	orderSendPayload.emit(self.color, selectedNodes, hoveredNode, amount)

# Checks the current hovered node, and turns buy menu visibility on if circumstances right.
func buyMenuOn():
	var hoveredNode := selectionTool.get_hovered_node()
	if !hoveredNode or hoveredNode.color != self.color:
		return
	
	buyMenu.on(hoveredNode)


func buyMenuOff():
	buyMenu.off()


func buyButtonPressed(type : GameTypes.buildingType) -> void:
	orderBuyBuilding.emit(self.color, buyMenu.target, type)
