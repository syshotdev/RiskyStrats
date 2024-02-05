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


func _ready():
	generateButtons()


# Generates all the buttons and adds them as children and gets signals
func generateButtons():
	for type in buildingCosts.keys():
		# Horrible one liner, but simple in that turns "type" into string (not 1 or 4), lowercase, then capitalize first letter
		var button := generateButton(str(UnitGenerator.buildingType.keys()[type]).to_lower().capitalize(), buildingCosts[type])
		verticalOptions.add_child(button)

# Makes a button with text of "buttonText" and inits some other stuff
func generateButton(buttonText : String, buttonCost : int) -> Button:
	var button : Button = Button.new()
	button.text = buttonText + " cost: " + str(buttonCost)
	return button
