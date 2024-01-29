extends Area2D

signal selected(boolean : bool)

@export var whiteCircle : ShapeVisualizer

# Keeps track of the amount of things that have selected this
var howManySelected : int = 0


func areaEntered(area : Area2D):
	# If not selectable area, stop this code path
	if(!isSelectable(area)):
		return
	
	howManySelected += 1
	selected.emit(true)


func areaExited(area : Area2D):
	# If not selectable area, stop this code path
	if(!isSelectable(area)):
		return
	
	# Amount of selected things, to fix bug where exit of hover thing
	# sends a false thing even if selected by selection area
	howManySelected -= 1
	if(howManySelected > 0):
		return
	
	selected.emit(false)

# Checks if area is selection area or hovered node selection
func isSelectable(area):
	if(area.get_parent() is SelectionArea):
		return true
	elif(area is HoveredNode):
		return true
	return false


func onSelected(boolean):
	whiteCircleToggle(boolean)


func whiteCircleToggle(isVisible : bool):
	# Too lazy to implement other things to automatically check nullness
	if(whiteCircle != null):
		whiteCircle.visible = isVisible
