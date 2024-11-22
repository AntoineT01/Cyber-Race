extends Control

@onready var label: Label = $CenterContainer/VBoxContainer2/Label
@onready var start_music: AudioStreamPlayer = $"../start_music"

func _ready():
	# Mettre le jeu en pause
	get_tree().paused = true
	# Démarrer le compte à rebours asynchrone
	countdown()

# Fonction asynchrone pour gérer le compte à rebours
func countdown():
	# Attendre 1 seconde avant de commencer le compte à rebours
	await get_tree().create_timer(1.0).timeout
	
	# Démarrer la musique de départ
	start_music.play()
	
	# Définir les étapes du compte à rebours avec leur timing
	var countdown_steps = [
		{"time": 0.0, "text": "3..."},
		{"time": 0.3, "text": "3.."},
		{"time": 0.6, "text": "3."},
		{"time": 1.0, "text": "2..."},
		{"time": 1.3, "text": "2.."},
		{"time": 1.6, "text": "2."},
		{"time": 2.0, "text": "1..."},
		{"time": 2.3, "text": "1.."},
		{"time": 2.6, "text": "1."},
		{"time": 3.0, "text": "GO!"}
	]
	
	# Timer pour suivre le temps écoulé
	var start_time = Time.get_ticks_msec() / 1000.0
	
	# Parcourir chaque étape du compte à rebours
	for step in countdown_steps:
		# Attendre jusqu'au bon moment pour afficher le texte
		var current_time = Time.get_ticks_msec() / 1000.0 - start_time
		var wait_time = step["time"] - current_time
		if wait_time > 0:
			await get_tree().create_timer(wait_time).timeout
		label.text = step["text"]
	
	# Attendre que le son "GO" se termine (environ 1 seconde)
	await get_tree().create_timer(1.0).timeout
	
	# Supprimer la scène du compte à rebours
	queue_free()
	# Désactiver la pause et reprendre le jeu
	get_tree().paused = false
