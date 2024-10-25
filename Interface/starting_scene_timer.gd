extends Control

# Référence au label UI unique
@onready var label: Label = $CenterContainer/VBoxContainer2/Label

func _ready():
	# Mettre le jeu en pause
	get_tree().paused = true
	# Démarrer le compte à rebours asynchrone
	countdown()

# Fonction asynchrone pour gérer le compte à rebours
func countdown():
	# Attendre 2 secondes avant de commencer le compte à rebours
	await get_tree().create_timer(2.0).timeout

	# Définir les étapes du compte à rebours
	var countdown_steps = [
		"3...",
		"3..",
		"3.",
		"2...",
		"2..",
		"2.",
		"1...",
		"1..",
		"1."
	]

	# Calculer la durée pour chaque étape afin de totaliser 3 secondes
	var step_duration = 3.0 / float(countdown_steps.size())

	# Parcourir chaque étape du compte à rebours
	for step in countdown_steps:
		label.text = step
		await get_tree().create_timer(step_duration).timeout

	# Supprimer la scène du compte à rebours
	queue_free()

	# Désactiver la pause et reprendre le jeu
	get_tree().paused = false
