extends Unit

class_name RoadUnit

var route : Array[GameNode] = []

var displayColor : Color
var toSecondNode : bool = true
var progress : float = 0.0


func _init(color : GameColors.colors, initUnits : float):
	super(color, initUnits)
	displayColor = GameColors.getColorFromEnum(currentColor)


func _draw():
	print(position)
	position = Vector2.ZERO
	draw_circle(position,calculateCircleSize(units),displayColor)


func setColor():
	displayColor = GameColors.getColorFromEnum(currentColor)

# Chatgpt made this basically lol: f(x)=log(100000)49log(b)​⋅log(x)+1,
func calculateCircleSize(number : float):
	var output = 49.0 / 5.0 * log(number) / log(10) + 1  # Using log10(x) formula
	return output
