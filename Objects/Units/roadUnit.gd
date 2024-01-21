extends Unit

class_name RoadUnit

# Remove this road unit (sent to the road housing this road unit)
signal remove()

# Creates a merge area to avoid sooo many problems
@onready var mergeArea : MergeArea

# Visual stuff
var displayColor : Color
var radius : float = calculateCircleSize(units)

# Routing stuff
var route : Array[GameNode] = []
var toSecondNode : bool = true
var progress : float = 0.0


func _init(color : GameColors.colors, initUnits : float):
	super(color, initUnits)
	displayColor = GameColors.getColorFromEnum(currentColor)
	
	initMergeArea()


# all of the merging stuff
func initMergeArea():
	mergeArea = MergeArea.new()
	add_child(mergeArea)
	mergeArea.setRadius(radius)
	mergeArea.roadUnitEntered.connect(merge)


func _draw():
	#Things 
	position = Vector2.ZERO
	radius = calculateCircleSize(units)
	
	# Stuff to keep track of size
	draw_circle(position, radius, displayColor)
	mergeArea.setRadius(radius)


func merge(roadUnit : RoadUnit):
	if(roadUnit.currentColor != currentColor):
		return
	
	# If they have more units than I, return
	if(roadUnit.units > self.units):
		return
	
	# Set my units
	units = roadUnit.units + units
	roadUnit.units = 0
	# Get rid of it!
	roadUnit.remove.emit(roadUnit)
	
	# Update size
	queue_redraw()

# Chatgpt made this basically lol: f(x)=log(100000)49log(b)​⋅log(x)+1,
func calculateCircleSize(number : float):
	var output = 49.0 / 5.0 * log(number) / log(10) + 1  # Using log10(x) formula
	return output


func setColor():
	displayColor = GameColors.getColorFromEnum(currentColor)
