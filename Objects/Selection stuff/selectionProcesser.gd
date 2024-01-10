extends Node2D

var selectedNodes : Array[GameNode] = []

var mouseClicked : bool = false
var mousePositionStart : Vector2 = Vector2.ZERO
var mousePositionEnd : Vector2 = Vector2.ZERO

func tick():
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
	
	var randomValueNoUse = 0


func _input(event):
	
	# If the mouse was pressed or released and it wasn't a left click on, say the mouse isn't clicked
	if event is InputEventMouseButton && not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouseClicked = false
	
	# Future nick, I'm sorry. I tried putting all the detection code somewhere else that's not main.
	# Problem: Most of the things relied on it being main
	if(Input.is_action_just_pressed("Tier1")):
		print(selectedNodes)
		sendSelectedPayloads(selectedNodes, 80)
	#elif event is InputEventAction:
