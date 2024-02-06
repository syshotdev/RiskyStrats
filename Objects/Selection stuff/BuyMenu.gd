extends Control

class_name BuyMenu

# Don't make the @export menu bloated :)
@onready var verticalOptions := $VerticalOptions

# All of the building costs (for purposes)
var buildingCosts : Dictionary = {
	GameTypes.buildingType.FACTORY : 500,
	GameTypes.buildingType.REACTOR : 2500,
	GameTypes.buildingType.FORT : 500,
	GameTypes.buildingType.ARTILLERY : 5000,
}

var buttonTypes : Dictionary = {} # Key: button, Value: buildingType

var currentNode : GameNode # The node that this was spawned on, and will affect


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
func generateButton(type : GameTypes.buildingType, buttonCost : int) -> Button:
	var button : Button = Button.new()
	
	# Horrible one liner, but simple in that turns "type" into string (1 or 4 to FORT), lowercase, then capitalize first letter
	var buttonName = str(GameTypes.buildingType.keys()[type]).to_lower().capitalize()
	button.text = buttonName + " cost: " + str(buttonCost)
	
	return button

# Something
func buttonPressed(button : Button):
	tryToBuyType(buttonTypes[button])

# Try to buy the type
func tryToBuyType(type : GameTypes.buildingType):
	var cost : int = buildingCosts[type]
	
	if(currentNode == null):
		return
	
	var success : bool = currentNode.buyBuildingType(type, cost)
	
	# If the current node is not null, then close this tab when purchase successful
	if(success):
		turnOff()

# Basically gets rid of the window
func turnOff():
	self.visible = false
