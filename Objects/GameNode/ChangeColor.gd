extends Control

@onready var sprite = $Sprite2D
@onready var labelBox = $ColorBox


func updateColorDisplay(units : Array[Unit]):
	updateUnitDisplay(units)

# Change color of sprite
func changeColor(color : GameColors.colors):
	sprite.modulate = GameColors.getColorFromEnum(color)


func buildingTypeChanged(type : GameTypes.buildingType):
	changeSprite(type)


# Change sprite to type
func changeSprite(type : GameTypes.buildingType):
	# VERY INNEFICIENT WAY TO LOAD TEXTURES!!
	# The best way would be to load all of the textures at the start, "load(texture)" and put it into var.
	# Loading it like this makes it load and recompile everything again every time texture changed,
	# meaning massive performance hit. But who cares am I right?
	var newTexture := load(str(GameTypes.getSpriteFromEnum(type)))
	
	if(sprite != null):
		sprite.texture = newTexture


func updateUnitDisplay(units : Array[Unit]):
	eraseLabelBoxChildren()
	for unit in units:
		var unitAmountInt : int = floor(unit.units)
		var label = createTextWithColor(str(unitAmountInt), unit.currentColor)
		labelBox.add_child(label)


func eraseLabelBoxChildren():
	for child in labelBox.get_children():
		labelBox.remove_child(child)


# Returns a label with a color and text
func createTextWithColor(text : String, color : GameColors.colors):
	# This exists to decipher number amounts when same color as color rect
	var colorOffset : Color = Color(0.2,0.2,0.2,0.0)
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
