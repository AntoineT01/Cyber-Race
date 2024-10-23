extends Control

@onready var back_button = $CenterContainer/VBoxContainer/BackButton
@onready var volume_slider = $CenterContainer/VBoxContainer/VolumeSlider
@onready var fullscreen_checkbox = $CenterContainer/VBoxContainer/CenterContainer2/FullscreenCheckbox

@onready var key_buttons: Array[Variant] = [
										   $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/Throttle1,
										   $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/Brake1,
										   $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/LeftSteering1,
										   $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/RightSteering1,
										   $CenterContainer/VBoxContainer/CenterContainer/HBoxContainer_Player1/Reverse1,
										   $CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/Throttle2,
										   $CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/Brake2,
										   $CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/LeftSteering2,
										   $CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/RightSteering2,
										   $CenterContainer/VBoxContainer/CenterContainer3/HBoxContainer_Player2/Reverse2
										   ]

@onready var key_config_dialog = $KeyConfigDialog  # Référence à la fenêtre popup pour la configuration des touches
@onready var dialog_label = $KeyConfigDialog/Label  # Référence au label à l'intérieur de la popup

var action_mapping: Array[Variant] = [
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

var current_key_configuring: int = -1  # Pour savoir quel bouton de touche est configuré

func _ready() -> void:
	print("Ready function called")
	# Connecter les boutons et sliders à leurs fonctions
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	volume_slider.connect("value_changed", Callable(self, "_on_volume_slider_value_changed"))
	fullscreen_checkbox.connect("toggled", Callable(self, "_on_fullscreen_checkbox_toggled"))

	# Connecter les boutons de touches à leurs fonctions pour ouvrir la fenêtre de configuration
	for i in range(key_buttons.size()):
		key_buttons[i].connect("pressed", Callable(self, "_on_key_button_pressed").bind(i))

	# Initialiser les éléments de l'UI avec les paramètres chargés
	_initialize_ui()

	# Initialiser les boutons de configuration de touches avec les actions correspondantes
	_initialize_key_buttons()

	key_config_dialog.hide()

func _initialize_ui():
	print("UI initialized")
	volume_slider.value = SettingsManager.settings["volume"]
	fullscreen_checkbox.set_pressed(SettingsManager.settings["fullscreen"])

# Initialiser les boutons de touches avec les touches actuelles de l'Input Map
func _initialize_key_buttons():
	print("Key buttons initialized")
	for i in range(key_buttons.size()):
		var action_name               = action_mapping[i]
		var events: Array[InputEvent] = InputMap.action_get_events(action_name)

		if events.size() > 0:
			var event: InputEventKey = events[0] as InputEventKey
			if event:
				key_buttons[i].text = event.as_text().replace("(Physical)", "").replace(" ", "")

# Lorsque le slider de volume est ajusté
func _on_volume_slider_value_changed(value):
	print("Volume slider value changed: ", value)
	SettingsManager.settings["volume"] = value
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		value / 100 * 24 - 24  # Ajuster le volume global
	)

# Lorsque la case à cocher plein écran est modifiée
func _on_fullscreen_checkbox_toggled(button_pressed):
	print("Fullscreen toggled: ", button_pressed)
	SettingsManager.settings["fullscreen"] = button_pressed
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if button_pressed else DisplayServer.WINDOW_MODE_WINDOWED
	)

# Lorsque le bouton retour est pressé
func _on_back_button_pressed():
	print("Back button pressed")
	SettingsManager.save_settings()
	get_tree().change_scene_to_file("res://main_menu.tscn")  # Retour au menu principal

# Quand un bouton pour configurer une touche est pressé
func _on_key_button_pressed(button_index):
	var button_text = key_buttons[button_index].text
	key_config_dialog.start_key_config(button_index, button_text)  # Lancer la configuration de la touche
