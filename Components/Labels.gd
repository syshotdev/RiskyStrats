extends VBoxContainer

var copyOfTeamsInNode : Dictionary
var teamLabels : Dictionary = {GameNode.Team.GAIA : 0}


func _ready():
	pass


func makeNewLabel(team : GameNode.Team, color : Color):
	var label = Label.new()
	
	label.text = "0"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	label.add_theme_color_override("font_color", color + Color(0.1,0.1,0.1))
	label.add_theme_color_override("font_color", color + Color(0.1,0.1,0.1))
	
	add_child(label)
	teamLabels[team] = label


# Checks each label, and if it doesn't match with the
# dictionary, then remove it. 
func checkLabels(allTeamsInNode : Dictionary):
	updateDictionary(allTeamsInNode)
	
	for team in teamLabels:
		
		# Check if team is in there
		if (!copyOfTeamsInNode.has(team)):
			teamLabels.erase(team)


func updateDictionary(allTeamsInNode : Dictionary):
	copyOfTeamsInNode = allTeamsInNode


# Updates values of all labels
func updateLabels():
	for team in teamLabels:
		var label = teamLabels[team]
		
		label.text = var_to_str(copyOfTeamsInNode[team])
