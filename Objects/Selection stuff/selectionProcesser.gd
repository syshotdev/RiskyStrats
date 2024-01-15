extends Node2D

signal updateSelectionArea(pos1, pos2)
signal updateHoveredNode(pos)
signal sendPayload(amount : int)

# Values to send
var tier1 := 80
var tier2 := 160
var tier3 := 1024
var tier4 := 4096

# Selection area stuff
var mouseClicked : bool = false
var mousePositionStart : Vector2 = Vector2.ZERO
var mousePositionEnd : Vector2 = Vector2.ZERO


func tick(_delta):
	var leftClickPressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	# (if mouse button left click just pressed)
	if(not mouseClicked && leftClickPressed):
		# Say the mouse has been clicked
		mouseClicked = true
		# Get start pos for slection area
		mousePositionStart = get_global_mouse_position()
	elif(leftClickPressed):
		# Get end pos every frame to update selection area
		mousePositionEnd = get_global_mouse_position()


func _input(event):
	# If the mouse was pressed or released and it wasn't a left click on, say the mouse isn't clicked
	if event is InputEventMouseButton && not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouseClicked = false
	
	# If mouse moved, send area 
	if event is InputEventMouseMotion:
		sendCheckHoveredNode()
		sendSelectionArea()
	
	
	if(Input.is_action_just_pressed("Tier1")):
		sendPayload.emit(tier1)
	elif(Input.is_action_just_pressed("Tier2")):
		sendPayload.emit(tier2)
	elif(Input.is_action_just_pressed("Tier3")):
		sendPayload.emit(tier3)
	elif(Input.is_action_just_pressed("Tier4")):
		sendPayload.emit(tier4)


func sendSelectionArea():
	updateSelectionArea.emit(mousePositionStart, mousePositionEnd)

func sendCheckHoveredNode():
	updateHoveredNode.emit(get_global_mouse_position())
