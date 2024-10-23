extends PopupPanel

var action_mapping = [
	"throttle_1",
	"brake_1",
	"left_steering_1",
	"right_steering_1",
	"reverse_1",
	"throttle_2",
	"brake_2",
	"left_steering_2",
	"right_steering_2",
	"reverse_2"
]

@onready var key_buttons: Array[Variant] = [
										   $"../CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/Throttle1",
										   $"../CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/Brake1",
										   $"../CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/LeftSteering1",
										   $"../CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/RightSteering1",
										   $"../CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/Reverse1",
										   $"../CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/Throttle2",
										   $"../CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/Brake2",
										   $"../CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/LeftSteering2",
										   $"../CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/RightSteering2",
										   $"../CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/Reverse2"
										   ]
@onready var dialog_label = $Label  # Référence au label à l'intérieur du popup

var current_key_configuring = -1  # Pour savoir quel bouton de touche est configuré

# Appelée lorsque la PopupPanel est prête
func _ready():
	print("PopupPanel ready")
	hide()  # Assurez-vous que le popup est caché au départ

# Définir l'action actuelle à configurer et afficher le popup
func start_key_config(button_index: int, button_text: String):
	current_key_configuring = button_index
	dialog_label.text = "Appuyez sur une touche pour configurer " + button_text
	popup_centered()  # Afficher le popup au centre de l'écran

# Capturer les touches dans la PopupPanel via _input
func _input(event):
	if current_key_configuring != -1 and event is InputEventKey and event.pressed:
		print("Key captured: ", event.as_text())

		# Mettre à jour la configuration de la touche
		var action_name = action_mapping[current_key_configuring]
		InputMap.action_erase_events(action_name)  # Effacer les anciennes touches
		InputMap.action_add_event(action_name, event)  # Ajouter la nouvelle touche

		# Mettre à jour l'UI avec la nouvelle touche
		update_ui_for_key(current_key_configuring, event)

		# Fermer le popup une fois la touche configurée
		current_key_configuring = -1
		hide()
		
		# Sauvegarder la nouvelle configuration
		SettingsManager.save_settings()

# Mettre à jour l'UI pour refléter la nouvelle touche
func update_ui_for_key(button_index: int, event: InputEventKey):
	if button_index >= 0 and button_index < key_buttons.size():
		key_buttons[button_index].text = event.as_text().replace("(Physical)", "").replace(" ", "")  # Mettre à jour le texte du bouton
