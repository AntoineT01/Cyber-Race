# SettingsManager.gd
extends Node

var settings: Dictionary = {
	"volume": 50,
	"fullscreen": false,
	"resolution": "1920x1080"
	# Ajoutez d'autres paramètres par défaut si nécessaire
}

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

func _ready():
	load_settings()
	load_key_settings()
	apply_settings()

func load_settings():
	if FileAccess.file_exists("user://settings.json"):
		var file = FileAccess.open("user://settings.json", FileAccess.READ)
		if file:
			var data = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(data)
			if error == OK:
				settings = json.get_data()
				print("Paramètres chargés avec succès.")
			else:
				print("Échec du parsing du fichier de paramètres : ", json.get_error_message())
			file.close()
		else:
			print("Impossible d'ouvrir le fichier de paramètres en lecture.")
	else:
		print("Fichier de paramètres non trouvé. Utilisation des paramètres par défaut.")

func save_settings():
	var json = JSON.new()
	var data = json.stringify(settings)
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	if file:
		file.store_string(data)
		file.close()
		print("Paramètres sauvegardés avec succès.")
	else:
		print("Impossible d'ouvrir le fichier de paramètres en écriture.")
	
	# Sauvegarder les touches
	save_key_settings()

func apply_settings():
	# Appliquer les paramètres chargés au démarrage

	# Appliquer le volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		settings["volume"] / 100 * 24 - 24  # Ajuster le volume global
	)

	# Appliquer le mode plein écran
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED
	)

	# Appliquer la résolution
	var resolution_values = settings["resolution"].split("x")
	DisplayServer.window_set_size(Vector2(int(resolution_values[0]), int(resolution_values[1])))

func save_key_settings():
	var config = ConfigFile.new()
	for i in range(action_mapping.size()):
		var action_name = action_mapping[i]
		var events = InputMap.action_get_events(action_name)
		if events.size() > 0:
			# Vérification que l'événement est bien de type InputEventKey
			for event in events:
				if event is InputEventKey:
					config.set_value("keys", action_name, event.get_keycode())  # Utilisation de get_keycode() au lieu de scancode
					break  # Sauvegarde seulement le premier événement trouvé
	config.save("user://key_settings.cfg")
	print("Configuration des touches sauvegardée avec succès.")


# Charger la configuration des touches depuis le fichier uniquement si elles ont été modifiées
func load_key_settings():
	var config = ConfigFile.new()
	var err = config.load("user://key_settings.cfg")
	if err == OK:
		for i in range(action_mapping.size()):
			var action_name = action_mapping[i]
			var keycode = config.get_value("keys", action_name, null)
			
			# Si une touche a été modifiée (keycode non nul), on la charge
			if keycode != null and keycode != 0:
				var event = InputEventKey.new()
				event.set_keycode(keycode)
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, event)
				print("Touche modifiée chargée", keycode)
		print("Configuration des touches modifiées chargée avec succès.")
	else:
		print("Aucune configuration des touches trouvée. Utilisation des touches par défaut.")