extends Control

class_name BuyMenu

signal buyButtonPressed(type : GameTypes.buildingType)

# Don't make the @export menu bloated :)
@onready var verticalOptions := $VerticalOptions

var buttonTypes : Dictionary = {} # Key: button, Value: buildingType
var currentNode : GameNode # The node that this was spawned on, and will affect


func _ready():
	generateButtons()

# Generates all the buttons and adds them as children and gets signals
func generateButtons():
	for type in GameTypes.buildingCosts.keys():
		var button := generateButton(type, GameTypes.getCostFromType(type))
		
		# Relate the button with the type
		buttonTypes[button] = type
		
		# When button pressed, calls buttonPressed(button) function. .bind adds an argument to the thing.
		button.pressed.connect(buttonPressed.bind(button))
		
		# Add to options object (For display)
		verticalOptions.add_child(button)

# Makes a button with text of "buttonText" and inits some other stuff
func generateButton(type : GameTypes.buildingType, buttonCost : int) -> Button:
	var button : Button = Button.new()
	
	# Horrible one liner, but simple in that turns "type" into string (1 or 4 to FORT), lowercase, then capitalize first letter
	var buttonName = str(GameTypes.buildingType.keys()[type]).to_lower().capitalize()
	button.text = buttonName + " cost: " + str(buttonCost)
	
	return button

# Something
func buttonPressed(button : Button):
	buyButtonPressed.emit(buttonTypes[button])
