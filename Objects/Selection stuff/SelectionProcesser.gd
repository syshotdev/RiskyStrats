extends Node2D

signal updateSelectionArea(pos1, pos2) # Updates nodesInArea in player with all nodes in selection area
signal updateHoveredNode(pos) # Updates the hovered node in (player) class
signal buyMenuOn(pos) # Where to put the buy menu
signal buyMenuOff() # Turns of the buy menu
signal sendPayload(amount : int) # Sends the payload with correct amount of units

# Values to send
var tier1 := 5
var tier2 := 80
var tier3 := 400
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
	# If mouse moved, send area 
	if event is InputEventMouseMotion:
		sendCheckHoveredNode()
		sendSelectionArea()
	
	checkPayloadAction()
	
	# Guard clause for mouse inputs
	if not event is InputEventMouseButton:
		return
	
	sendBuyMenuOff()
	
	# If the mouse was pressed or released and it wasn't a left click on, say the mouse isn't clicked
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouseClicked = false
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		sendBuyMenuOn()


func checkPayloadAction():
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

func sendBuyMenuOn():
	buyMenuOn.emit(get_global_mouse_position())

func sendBuyMenuOff():
	buyMenuOff.emit()
