extends Control

@onready var colorRect = $ColorRect
@onready var labelBox = $ColorBox


func updateColorDisplay(units : Array[Unit]):
	updateUnitDisplay(units)


func changeNodeColor(color : GameColors.colors):
	setColorRectColor(color)


func setColorRectColor(color : GameColors.colors):
	colorRect.color = GameColors.getColorFromEnum(color)


func updateUnitDisplay(units : Array[Unit]):
	eraseLabelBoxChildren()
	for unit in units:
		var unitAmountInt : int = unit.units
		var label = createTextWithColor(str(unitAmountInt), unit.currentColor)
		labelBox.add_child(label)


func eraseLabelBoxChildren():
	for child in labelBox.get_children():
		labelBox.remove_child(child)


# Returns a label with a color and text
func createTextWithColor(text : String, color : GameColors.colors):
	# This exists to decipher number amounts when same color as color rect
	var colorOffset : Color = Color(0.1,0.1,0.1,0.0)
	var labelColor : Color = GameColors.getColorFromEnum(color) - colorOffset
	labelColor = clampColor(labelColor)
	
	var label = Label.new()
	
	label.text = text
	label.add_theme_color_override("font_color", labelColor)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	return label


func clampColor(color : Color) -> Color:
	var newColor = color
	newColor.r = clamp(newColor.r, 0, 1)
	newColor.g = clamp(newColor.g, 0, 1)
	newColor.b = clamp(newColor.b, 0, 1)
	newColor.a = clamp(newColor.a, 0, 1)
	return newColor
