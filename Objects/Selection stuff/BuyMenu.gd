extends Control

# Don't make the @export menu bloated :)
@onready var verticalOptions := $VerticalOptions

# All of the building costs (for purposes)
var buildingCosts : Dictionary = {
	UnitGenerator.buildingType.FACTORY : 500,
	UnitGenerator.buildingType.REACTOR : 2500,
	UnitGenerator.buildingType.FORT : 500,
	UnitGenerator.buildingType.ARTILLERY : 5000,
}

var buttonTypes : Dictionary = {} # Key: button, Value: buildingType


func _ready():
	generateButtons()


# Generates all the buttons and adds them as children and gets signals
func generateButtons():
	for type in buildingCosts.keys():
		var button := generateButton(type, buildingCosts[type])
		
		# Relate the button with the type
		buttonTypes[button] = type
		
		# When button pressed, calls buttonPressed(button) function. .bind adds an argument to the thing.
		button.pressed.connect(buttonPressed.bind(button))
		
		# Add to options object (For display)
		verticalOptions.add_child(button)

# Makes a button with text of "buttonText" and inits some other stuff
func generateButton(type : UnitGenerator.buildingType, buttonCost : int) -> Button:
	var button : Button = Button.new()
	
	# Horrible one liner, but simple in that turns "type" into string (not 1 or 4), lowercase, then capitalize first letter
	var buttonName = str(UnitGenerator.buildingType.keys()[type]).to_lower().capitalize()
	button.text = buttonName + " cost: " + str(buttonCost)
	
	return button

# Something
func buttonPressed(button : Button):
	# Get the cost of the button being pressed
	print(buttonTypes[button])
