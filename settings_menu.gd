extends Control

@onready var back_button = $BackButton
@onready var volume_slider = $VolumeSlider
@onready var fullscreen_checkbox = $FullscreenCheckbox

func _ready() -> void:
	# Connecter les boutons et sliders à leurs fonctions
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	volume_slider.connect("value_changed", Callable(self, "_on_volume_slider_value_changed"))
	fullscreen_checkbox.connect("toggled", Callable(self, "_on_fullscreen_checkbox_toggled"))
	
	# Initialiser les éléments de l'UI avec les paramètres chargés
	_initialize_ui()

func _initialize_ui():
	volume_slider.value = SettingsManager.settings["volume"]
	fullscreen_checkbox.set_pressed(SettingsManager.settings["fullscreen"])
	# Initialiser d'autres éléments de l'UI si nécessaire

# Lorsque le slider de volume est ajusté
func _on_volume_slider_value_changed(value):
	SettingsManager.settings["volume"] = value
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		value / 100 * 24 - 24  # Ajuster le volume global
	)

# Lorsque la case à cocher plein écran est modifiée
func _on_fullscreen_checkbox_toggled(button_pressed):
	SettingsManager.settings["fullscreen"] = button_pressed
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if button_pressed else DisplayServer.WINDOW_MODE_WINDOWED
	)

# Lorsque la résolution est modifiée
func _on_resolution_option_selected(index):
	var resolution = "1920x1080" if index == 0 else "1280x720"
	SettingsManager.settings["resolution"] = resolution
	var resolution_values = resolution.split("x")
	DisplayServer.window_set_size(Vector2(int(resolution_values[0]), int(resolution_values[1])))

# Lorsque le bouton retour est pressé
func _on_back_button_pressed():
	SettingsManager.save_settings()
	get_tree().change_scene_to_file("res://main_menu.tscn")  # Retour au menu principal

@onready var key_buttons: Array[Variant] = [
	$Throttle1, $Brake1, $LeftSteering1, $RightSteering1,
	$Throttle2, $Brake2, $LeftSteering2, $RightSteering2
]

var current_key_configuring = -1  # Pour savoir quel bouton de touche est configuré

# Quand un bouton pour configurer une touche est pressé
func _on_key_button_pressed(button_index):
	current_key_configuring = button_index
	key_buttons[button_index].text = "Appuyez sur une touche..."

# Capture l'entrée utilisateur pour la nouvelle touche
func _input(event):
	if current_key_configuring != -1 and event is InputEventKey:
		var action_name = "action_" + str(current_key_configuring + 1)  # Nom de l'action dans Input Map
		InputMap.action_erase_events(action_name)  # Effacer les anciennes touches
		InputMap.action_add_event(action_name, event)  # Ajouter la nouvelle touche
		key_buttons[current_key_configuring].text = "Configurer Touche " + str(current_key_configuring + 1)
		current_key_configuring = -1  # Réinitialiser
