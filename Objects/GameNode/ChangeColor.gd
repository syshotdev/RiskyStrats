@tool
extends Control

@onready var sprite = $Sprite2D
@onready var labelBox = $ColorBox

@export var spriteType : GameTypes.buildingType

func _ready():
	# Sprite loads when game starts
	changeSprite(spriteType)


func updateColorDisplay(colorUnits : Dictionary):
	assert(colorUnits.get_typed_key_builtin() is GameColors.colors)
	assert(colorUnits.get_typed_value_builtin() is int)
	var units := convertColorUnitsToUnits(colorUnits)
	updateLabelDisplay(units)
	if units.size() <= 0:
		return
	
	var biggestUnit : Unit = units.get(0)
	for unit in units:
		if unit.units > biggestUnit.units:
			biggestUnit = unit
	
	sprite.modulate = GameColors.getColorFromEnum(biggestUnit.color)


func convertColorUnitsToUnits(colorUnits : Dictionary) -> Array[Unit]:
	var units : Array[Unit] = []
	for color in colorUnits:
		var unit = Unit.new(color)
		unit.units = colorUnits[color]
		units.append(unit)
	return units

# Changes the sprite based on building type
func updateBuildingDisplay(type : GameTypes.buildingType):
	changeSprite(type)
	spriteType = type

# Change sprite to type
func changeSprite(type : GameTypes.buildingType):
	# VERY INNEFICIENT WAY TO LOAD TEXTURES!!
	# The best way would be to load all of the textures at the start, "load(texture)" and put it into var.
	# Loading it like this makes it load and recompile everything again every time texture changed,
	# meaning massive performance hit. But who cares am I right?
	
	var newTexture := load(str(GameTypes.getSpriteFromEnum(type)))
	
	if(sprite != null):
		sprite.texture = newTexture

func updateLabelDisplay(units : Array[Unit]):
	deleteLabels()
	for unit in units:
		var unitAmountInt : int = floor(unit.units)
		var label = createLabelWithColor(str(unitAmountInt), unit.color)
		labelBox.add_child(label)

func deleteLabels():
	for child in labelBox.get_children():
		labelBox.remove_child(child)

# Returns a label with a color and text
func createLabelWithColor(text : String, color : GameColors.colors):
	# So we can read the label when it's the same color as the node
	var colorOffset : Color = Color(0.2,0.2,0.2,0.0)
	var labelColor : Color = GameColors.getColorFromEnum(color) + colorOffset
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
