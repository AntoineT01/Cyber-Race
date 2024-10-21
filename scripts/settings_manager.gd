# SettingsManager.gd
extends Node

var settings: Dictionary = {
	"volume": 50,
	"fullscreen": false,
	"resolution": "1920x1080"
	# Ajoutez d'autres paramètres par défaut si nécessaire
}

func _ready():
	load_settings()
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
