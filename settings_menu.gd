extends Control

@onready var back_button = $BackButton
@onready var volume_slider = $VolumeSlider
@onready var fullscreen_checkbox = $FullscreenCheckbox
@onready var resolution_option_button = $ResolutionOptionButton

# Valeurs par défaut
var settings: Dictionary = {
							   "volume": 50,
							   "fullscreen": false,
							   "resolution": "1920x1080"
						   }

func _ready() -> void:
	# Connecter les boutons et sliders à leurs fonctions avec la syntaxe correcte
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	volume_slider.connect("value_changed", Callable(self, "_on_volume_slider_value_changed"))
	fullscreen_checkbox.connect("toggled", Callable(self, "_on_fullscreen_checkbox_toggled"))
	resolution_option_button.connect("item_selected", Callable(self, "_on_resolution_option_selected"))

	# Initialiser les paramètres dans l'UI
	_load_settings()

# Charger les paramètres sauvegardés
func _load_settings():
	volume_slider.value = settings["volume"]
	fullscreen_checkbox.pressed = settings["fullscreen"]
	# Utilisation de la syntaxe correcte pour l'opérateur ternaire
	resolution_option_button.select(0 if settings["resolution"] == "1920x1080" else 1)

# Sauvegarder les paramètres dans un fichier ou une variable globale
func _save_settings():
	# Ici tu peux sauvegarder dans un fichier ou dans un singleton Autoload
	print("Paramètres sauvegardés : ", settings)

# Lorsque le slider de volume est ajusté
func _on_volume_slider_value_changed(value):
	settings["volume"] = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value / 100 * 24 - 24)  # Modifie le volume global

# Lorsque la case à cocher plein écran est modifiée
func _on_fullscreen_checkbox_toggled(pressed):
	settings["fullscreen"] = pressed
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED)

# Lorsque la résolution est modifiée
func _on_resolution_option_selected(index):
	settings["resolution"] = "1920x1080" if index == 0 else "1280x720"
	var resolution = settings["resolution"].split("x")
	DisplayServer.window_set_size(Vector2(int(resolution[0]), int(resolution[1])))

# Lorsque le bouton retour est pressé
func _on_back_button_pressed():
	_save_settings()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")  # Retour au menu principal
